require "test_helper"

class AdRequestTest < ActiveSupport::TestCase
  def setup
    @publisher = User.create!(email: "pub@example.com", password: "password", role: "publisher")
    @advertiser = User.create!(email: "adv@example.com", password: "password", role: "advertiser")
    @ad = Ad.create!(title: "Ad Title", description: "Ad Description", user: @advertiser)
    @ad_request = AdRequest.new(ad: @ad, publisher: @publisher, status: "pending")
  end

  test "should be valid with valid attributes" do
    assert @ad_request.valid?
  end

  test "should require unique ad per publisher" do
    @ad_request.save!
    duplicate = AdRequest.new(ad: @ad, publisher: @publisher, status: "pending")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:ad_id], "already requested by this publisher"
  end

  test "should only allow valid statuses" do
    @ad_request.status = "invalid"
    assert_not @ad_request.valid?
    assert_includes @ad_request.errors[:status], "is not included in the list"
  end
end
