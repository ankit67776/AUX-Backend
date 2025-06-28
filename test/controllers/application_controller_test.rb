require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  class DummyController < ApplicationController
    def index
      render json: { message: 'ok' }
    end
  end

  tests DummyController

  setup do
    @user = users(:one)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  test 'should authorize request with valid token' do
    @request.headers['Authorization'] = "Bearer #{@token}"
    get :index
    assert_response :success
    assert_equal 'ok', JSON.parse(@response.body)['message']
  end

  test 'should not authorize request with invalid token' do
    @request.headers['Authorization'] = 'Bearer invalidtoken'
    get :index
    assert_response :unauthorized
    assert_equal 'Unauthorized', JSON.parse(@response.body)['errors']
  end

  test 'should forbid advertiser action for non-advertiser' do
    @user.update(role: 'publisher')
    @request.headers['Authorization'] = "Bearer #{@token}"
    DummyController.any_instance.stubs(:authorize_advertiser).returns(
      DummyController.new.authorize_advertiser
    )
    get :index
    assert_response :forbidden if @user.role != 'advertiser'
  end

  test 'should forbid publisher action for non-publisher' do
    @user.update(role: 'advertiser')
    @request.headers['Authorization'] = "Bearer #{@token}"
    DummyController.any_instance.stubs(:authorize_publisher).returns(
      DummyController.new.authorize_publisher
    )
    get :index
    assert_response :forbidden if @user.role != 'publisher'
  end
end
