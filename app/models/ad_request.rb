class AdRequest < ApplicationRecord
  belongs_to :ad
  belongs_to :publisher, class_name: "User"

  STATUSES = %w[pending approved rejected active_on_site]

  validates :ad_id, uniqueness: { scope: :publisher_id, message: "already requested by this publisher" }
  validates :status, inclusion: { in: STATUSES }
end
