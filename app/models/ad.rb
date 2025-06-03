class Ad < ApplicationRecord
  belongs_to :user
  has_one_attached :media
  belongs_to :advertiser, class_name: "User"
  has_many :ad_requests, dependent: :destroy

  validates :title, :description, presence: true
  # validates :media, attached: true, content_type: [ "image/png", "image/jpg", "image/jpeg", "video/mp4" ]

  def media_url
    Rails.application.routes.url_helpers.url_for(media) if media.attached?
  end
end
