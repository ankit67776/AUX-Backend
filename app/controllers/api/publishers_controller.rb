require "net/http"
require "uri"
require "openssl"
require "json"

class Api::PublishersController < ApplicationController
  before_action :authorize_request

  def complete_registration
    data = params.permit(:companyName, :contactName, :contactTitle, :website, :address, :ga_property_id)

    if data[:ga_property_id].blank?
      return render json: { message: "Google Analytics property is required." }, status: :bad_request
    end

    access_token = fetch_access_token_from_refresh_token

    # Call metadata endpoint using Net::HTTP
    uri = URI("https://analyticsdata.googleapis.com/v1beta/properties/#{data[:ga_property_id]}/metadata")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :TLSv1_2
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # http.enable_ssl_session_reuse = false

    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{access_token}"

    response = http.request(req)

    unless response.code.to_i == 200
      Rails.logger.warn("GA access denied or invalid property: #{response.body}")
      return render json: {
        message: "Could not verify GA access. Please ensure you've shared viewer access with ga4abakwa@gmail.com"
      }, status: :unauthorized
    end

    @current_user.update!(
      company_name: data[:companyName],
      contact_name: data[:contactName],
      contact_title: data[:contactTitle],
      website: data[:website],
      address: data[:address],
      ga_property_id: data[:ga_property_id]
    )

    render json: { message: "Registration completed successfully." }, status: :ok
  rescue => e
    Rails.logger.error("Registration error: #{e.message}")
    render json: { message: "Registration failed." }, status: :unprocessable_entity
  end

  def analytics_snapshot
    unless @current_user.ga_property_id.present?
      return render json: { error: "No GA Property ID associated with user." }, status: :bad_request
    end

    access_token = fetch_access_token_from_refresh_token
    property_id = @current_user.ga_property_id

    stats_response = run_report(access_token, property_id, metrics: %w[activeUsers newUsers averageSessionDuration])

    users_over_time_response = run_report(
      access_token,
      property_id,
      dimensions: [ { name: "date" } ],
      metrics: [ { name: "activeUsers" } ],
      date_range: { start_date: "28daysAgo", end_date: "today" }
    )
    active_users_last_30min_response = run_report(
      access_token,
      property_id,
      metrics: [ { name: "activeUsers" } ],
      date_range: { start_date: "today", end_date: "today" }
    )

    users_by_channel_response = run_report(
      access_token,
      property_id,
      dimensions: [ { name: "sessionDefaultChannelGroup" } ],
      metrics: [ { name: "activeUsers" } ]
    )

    sessions_by_channel_response = run_report(
      access_token,
      property_id,
      dimensions: [ { name: "sessionDefaultChannelGroup" } ],
      metrics: [ { name: "sessions" } ]
    )

    users_by_country_response = run_report(
      access_token,
      property_id,
      dimensions: [ { name: "countryId" }, { name: "country" } ],
      metrics: [ { name: "activeUsers" } ]
    )

    user_activity_1d = run_report(
      access_token,
      property_id,
      metrics: [ { name: "activeUsers" } ],
      date_range: { start_date: "1daysAgo", end_date: "today" }
    )

    user_activity_7d = run_report(
      access_token,
      property_id,
      metrics: [ { name: "activeUsers" } ],
      date_range: { start_date: "7daysAgo", end_date: "today" }
    )

    user_activity_30d = run_report(
      access_token,
      property_id,
      metrics: [ { name: "activeUsers" } ],
      date_range: { start_date: "30daysAgo", end_date: "today" }
    )

    views_by_page_response = run_report(
      access_token,
      property_id,
      dimensions: [ { name: "pageTitle" } ],
      metrics: [ { name: "screenPageViews" }, { name: "activeUsers" } ]
    )

    event_count_response = run_report(
      access_token,
      property_id,
      dimensions: [ { name: "eventName" } ],
      metrics: [ { name: "eventCount" }, { name: "totalUsers" } ]
    )

# ltv_by_channel_response = run_report(
#   access_token,
#   property_id,
#   dimensions: [ { name: "sessionDefaultChannelGroup" } ],
#   metrics: [ { name: "lifetimeValue" } ]
# )

formatted_data = {
      stats: {
        activeUsers: stats_response.dig("rows", 0, "metricValues", 0, "value"),
        newUsers: stats_response.dig("rows", 0, "metricValues", 1, "value"),
        averageEngagementTime: format_seconds(stats_response.dig("rows", 0, "metricValues", 2, "value")),
        activeUsersLast30Mins: active_users_last_30min_response.dig("rows", 0, "metricValues", 0, "value")
      },
      usersOverTime: users_over_time_response["rows"]&.map do |row|
        {
          date: row["dimensionValues"][0]["value"],
          users: row["metricValues"][0]["value"].to_i
        }
      end || [],
      usersByChannel: users_by_channel_response["rows"]&.each_with_index.map do |row, i|
        {
          channel: row["dimensionValues"][0]["value"],
          users: row["metricValues"][0]["value"].to_i,
          fill: "hsl(var(--chart-#{i+1}))"
        }
      end || [],
      sessionsByChannel: {
        headers: [ "SESSION PRIMARY CHANNEL GROUP", "SESSIONS" ],
        rows: sessions_by_channel_response["rows"]&.map do |row|
          [
            row["dimensionValues"][0]["value"],
            row["metricValues"][0]["value"].to_i
          ]
        end || []
      },
      usersByCountry: users_by_country_response["rows"]&.map do |row|
        {
          code: row["dimensionValues"][0]["value"],
          name: row["dimensionValues"][1]["value"],
          users: row["metricValues"][0]["value"].to_i
        }
      end || [],
      userActivity: [
        { period: "1 Day", users: user_activity_1d.dig("rows", 0, "metricValues", 0, "value").to_i, fill: "hsl(var(--chart-1))" },
        { period: "7 Day", users: user_activity_7d.dig("rows", 0, "metricValues", 0, "value").to_i, fill: "hsl(var(--chart-2))" },
        { period: "30 Day", users: user_activity_30d.dig("rows", 0, "metricValues", 0, "value").to_i, fill: "hsl(var(--chart-3))" }
      ],
      userActivityByCohort: {
        cohortData: [
          { week: "May 12 - May 18", values: [ 100.0, 1.2, 0.8, nil, 0.2, 0.1 ] },
          { week: "May 19 - May 25", values: [ 100.0, 1.0, nil, 0.5, 0.1, nil ] }
        ]
      },
      viewsByPage: {
        headers: [ "PAGE TITLE AND SCREEN CLASS", "VIEWS", "USERS" ],
        rows: views_by_page_response["rows"]&.map do |row|
          [
            row["dimensionValues"][0]["value"],
            row["metricValues"][0]["value"].to_i,
            row["metricValues"][1]["value"].to_i
          ]
        end || []
      },
      eventCountByName: {
        headers: [ "EVENT NAME", "EVENT COUNT", "TOTAL USERS" ],
        rows: event_count_response["rows"]&.map do |row|
          [
            row["dimensionValues"][0]["value"],
            row["metricValues"][0]["value"].to_i,
            row["metricValues"][1]["value"].to_i
          ]
        end || []
      }
    }

    render json: formatted_data, status: :ok
  rescue => e
    Rails.logger.error("Analytics snapshot error: #{e.message}")
    render json: { error: "Failed to fetch analytics snapshot." }, status: :internal_server_error
  end

  private

  def run_report(access_token, property_id, dimensions: [], metrics:, date_range: { start_date: "7daysAgo", end_date: "today" })
    uri = URI("https://analyticsdata.googleapis.com/v1beta/properties/#{property_id}:runReport")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :TLSv1_2
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # http.enable_ssl_session_reuse = false

    req = Net::HTTP::Post.new(uri.path, {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    })

    body = {
      property: "properties/#{property_id}",
      dateRanges: [ date_range ],
      metrics: metrics.map { |m| m.is_a?(Hash) ? m : { name: m } },
      dimensions: dimensions
    }

    req.body = body.to_json
    response = http.request(req)

    raise "Google Analytics API error: #{response.body}" unless response.code.to_i == 200

    JSON.parse(response.body)
  end

  def fetch_access_token_from_refresh_token
    uri = URI("https://oauth2.googleapis.com/token")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :TLSv1_2
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # http.enable_ssl_session_reuse = false

    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data({
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      refresh_token: ENV["GA_REFRESH_TOKEN"],
      grant_type: "refresh_token"
    })

    response = http.request(req)
    data = JSON.parse(response.body)

    if data["access_token"]
      data["access_token"]
    else
      raise "Failed to refresh GA access token #{data}"
    end
  end

  def format_seconds(seconds)
    return "0s" if seconds.nil? || seconds.to_f.zero?
    minutes = (seconds.to_f / 60).floor
    remaining_seconds = (seconds.to_f % 60).round
    "#{minutes}m #{remaining_seconds}s"
  end

  def ensure_publisher!
    unless @current_user.role == "publisher"
      render json: { error: "Only publishers can perform this action." }, status: :forbidden
    end
  end
end
