require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "test@example.com", password: "password", role: "publisher")
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    @user.save!
    user2 = User.new(email: "test@example.com", password: "password", role: "advertiser")
    assert_not user2.valid?
    assert_includes user2.errors[:email], "has already been taken"
  end

  test "should only allow valid roles" do
    @user.role = "invalid"
    assert_not @user.valid?
    assert_includes @user.errors[:role], "is not included in the list"
  end
end
