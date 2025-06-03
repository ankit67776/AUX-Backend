class Api::AllAdsController < ApplicationController
  before_action :authorize_request
  before_action :ensure_publisher!

  def index
    ads = Ad.includes(:user, media_attachment: :blob).all

    render json: ads.map { |ad|
      ad.as_json(
        methods: [ :media_url ],
        include: {
          user: { only: [ :id, :name, :email ] }
        }
      )
  }
  end

  private

  def ensure_publisher!
    unless @current_user.role == "publisher"
      render json: { error: "Only publishers can access all ads" }, status: :forbidden
    end
  end
end
