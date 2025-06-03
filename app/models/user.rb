class User < ApplicationRecord
  has_secure_password

  has_many :ads, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[publisher advertiser] }

  has_many :ad_requests, foreign_key: :publisher_id, dependent: :destroy
  has_many :requested_ads, through: :ad_requests, source: :ad
  has_many :ads_as_advertiser, foreign_key: :advertiser_id, class_name: "Ad"
end
