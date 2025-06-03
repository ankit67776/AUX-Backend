class Api::AdsController < ApplicationController
  before_action :authorize_request
  before_action :check_advertiser_role

  def create
    ad = @current_user.ads.build(ad_params)

    if ad.save
      render json: {
        message: "Ad uploaded successfully",
        ad: {
          id: ad.id,
          title: ad.title,
          description: ad.description,
          media_url: ad.media.attached? ? url_for(ad.media) : nil,
          created_at: ad.created_at
        }
      }, status: :created
    else
        render json: { errors: ad.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    # get advertiserId from params or fallback to current_user.id
    advertiser_id = params[:advertiserId] || @current_user.id

    # ensure only current user can access their ads
    if advertiser_id.to_i != @current_user.id
      render json: { error: "Unauthorized access" }, status: :unauthorized and  return
    end

    # fetch ads belonging to the advertiser
    ads = Ad.where(user_id: advertiser_id).includes(:media_attachment, :media_blob)

    # return ads with media URL
    render json: ads.map { |ad| ad.as_json(methods: [ :media_url ]) }
  end

  private

  def ad_params
    params.require(:ad).permit(
      :title,
      :description,
      :ad_format,
      :ad_size,
      :custom_width,
      :custom_height,
      :ad_txt_content,
      :header_code,
      :header_bidding,
      :header_bidding_partners,
      :fallback_image,
      :start_date,
      :end_date,
      :budget,
      :bid_strategy,
      :target_audience,
      :target_locations,
      :target_devices,
      :media # for multiple file attachments

    )
  end

  private

  def check_advertiser_role
    puts "User: #{@current_user.id}, Role: #{@current_user.role}, name: #{@current_user.name}"
    unless @current_user.role == "advertiser"
      render json: { error: "Only advertisers can create ads" }, status: :forbidden
    end
  end
end
