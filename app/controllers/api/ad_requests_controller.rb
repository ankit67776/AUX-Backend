class Api::AdRequestsController < ApplicationController
  before_action :authorize_request
  # before_action :ensure_publisher!

  def create
    ad = Ad.find(params[:ad_id])

    return render json: { error: "Ad not found" }, status: :not_found unless ad

    existing_request = AdRequest.find_by(ad_id: ad.id, publisher_id: @current_user.id)

    if existing_request
      return render json: { message: "You've already requested this ad.", status: existing_request.status }, status: :ok
    end

    ad_request = AdRequest.new(
      ad: ad,
      publisher: @current_user,
      requested_at: Time.current
    )

    if ad_request.save
      # TODO: Notify the ad owner about the new request
      render json: { success: true, message: "Ad request submitted successfully." }, status: :created
    else
      render json: { errors: ad_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

def index
  if params[:publisher_id].present?
    #  logic — publisher side
    ad_requests = AdRequest.includes(ad: :user).where(publisher_id: params[:publisher_id])

    result = ad_requests.map do |request|
      ad = request.ad
      ad.attributes.merge(
        advertiser: {
          id: ad.user.id,
          name: ad.user.name
        },
        media_url: ad.media.attached? ? url_for(ad.media) : nil,
        request_status: request.status,
        request_id: request.id,
        publisher_id: request.publisher_id
      )
    end

    render json: result, status: :ok

  elsif params[:advertiser_id].present?
    #  logic — advertiser side
    ad_requests = AdRequest.joins(:ad)
                           .includes(:publisher, ad: :media_attachment)
                           .where(ads: { user_id: params[:advertiser_id] })

    result = ad_requests.map do |request|
      {
        id: request.id,
        status: request.status,
        requested_at: request.requested_at,
        ad: request.ad.attributes.merge(
          media_url: request.ad.media.attached? ? url_for(request.ad.media) : nil
        ),
        publisher: {
          id: request.publisher.id,
          name: request.publisher.name,
          email: request.publisher.email

        }
      }
    end

    render json: result, status: :ok

  else
    render json: { error: "publisher_id or advertiser_id is required" }, status: :bad_request
  end
end


# PATCH /api/ad_requests/:id/approve
def approve
  ad_request = AdRequest.find_by(id: params[:id])

  return render json: { error: "Ad request not found" }, status: :not_found unless ad_request

  # Only advertiser who owns the ad can approve
  if ad_request.ad.user_id != @current_user.id
    return render json: { error: "Unauthorized" }, status: :unauthorized
  end

  ad_request.update(status: "approved")
  render json: { message: "Request approved", status: ad_request.status }, status: :ok
end

# PATCH /api/ad_requests/:id/reject
def reject
  ad_request = AdRequest.find_by(id: params[:id])

  return render json: { error: "Ad request not found" }, status: :not_found unless ad_request

  if ad_request.ad.user_id != @current_user.id
    return render json: { error: "Unauthorized" }, status: :unauthorized
  end

  ad_request.update(status: "rejected")
  render json: { message: "Request rejected", status: ad_request.status }, status: :ok
end


  private

  def ensure_publisher!
    unless @current_user.role == "publisher"
      render json: { error: "Only publishers can request ads." }, status: :forbidden
    end
  end
end
