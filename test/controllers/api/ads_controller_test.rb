require "test_helper"

class Api::AdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @advertiser = users(:two) || User.create!(email: 'adv2@example.com', password: 'password', role: 'advertiser')
    @token = JsonWebToken.encode(user_id: @advertiser.id)
  end

  test 'should create ad' do
    post api_ads_url, params: { ad: { title: 'Ad Title', description: 'Ad Desc' } }, headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :created
    assert_equal 'Ad uploaded successfully', JSON.parse(@response.body)['message']
  end

  test 'should not create ad with invalid params' do
    post api_ads_url, params: { ad: { title: '', description: '' } }, headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :unprocessable_entity
    assert JSON.parse(@response.body)['errors'].any?
  end

  test 'should get ads for advertiser' do
    Ad.create!(title: 'Ad1', description: 'Desc1', user: @advertiser)
    get api_ads_url, params: { advertiserId: @advertiser.id }, headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :success
    assert JSON.parse(@response.body).is_a?(Array)
  end

  test 'should not get ads for another advertiser' do
    other = User.create!(email: 'other@example.com', password: 'password', role: 'advertiser')
    get api_ads_url, params: { advertiserId: other.id }, headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :unauthorized
    assert_equal 'Unauthorized access', JSON.parse(@response.body)['error']
  end
end
