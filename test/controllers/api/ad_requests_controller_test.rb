require "test_helper"

class Api::AdRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @publisher = users(:one) || User.create!(email: "pub1@example.com", password: "password", role: "publisher")
    @advertiser = users(:two) || User.create!(email: "adv1@example.com", password: "password", role: "advertiser")
    @ad = Ad.create!(title: "Test Ad", description: "Test Description", user: @advertiser)
    @token = JsonWebToken.encode(user_id: @publisher.id)
  end

  test "should create ad request" do
    post api_ad_requests_url, params: { ad_id: @ad.id }, headers: { "Authorization" => "Bearer #{@token}" }
    assert_response :created
    assert_equal "Ad request submitted successfully.", JSON.parse(@response.body)["message"]
  end

  test "should not create duplicate ad request" do
    AdRequest.create!(ad: @ad, publisher: @publisher, status: "pending")
    post api_ad_requests_url, params: { ad_id: @ad.id }, headers: { "Authorization" => "Bearer #{@token}" }
    assert_response :ok
    assert_match /already requested/, JSON.parse(@response.body)["message"]
  end

  test "should return not found for invalid ad" do
    post api_ad_requests_url, params: { ad_id: 0 }, headers: { "Authorization" => "Bearer #{@token}" }
    assert_response :not_found
    assert_equal "Ad not found", JSON.parse(@response.body)["error"]
  end
end
