require "test_helper"

class AdTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "aduser@example.com", password: "password", role: "advertiser")
    @ad = Ad.new(title: "Ad Title", description: "Ad Description", user: @user)
  end

  test "should be valid with valid attributes" do
    assert @ad.valid?
  end

  test "should require title" do
    @ad.title = nil
    assert_not @ad.valid?
    assert_includes @ad.errors[:title], "can't be blank"
  end

  test "should require description" do
    @ad.description = nil
    assert_not @ad.valid?
    assert_includes @ad.errors[:description], "can't be blank"
  end

  test "should belong to user" do
    assert_equal @user, @ad.user
  end
end
