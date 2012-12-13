require 'test_helper'

class TrainingDealsControllerTest < ActionController::TestCase
  setup do
    @training_deal = training_deals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:training_deals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create training_deal" do
    assert_difference('TrainingDeal.count') do
      post :create, training_deal: {  }
    end

    assert_redirected_to training_deal_path(assigns(:training_deal))
  end

  test "should show training_deal" do
    get :show, id: @training_deal
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @training_deal
    assert_response :success
  end

  test "should update training_deal" do
    put :update, id: @training_deal, training_deal: {  }
    assert_redirected_to training_deal_path(assigns(:training_deal))
  end

  test "should destroy training_deal" do
    assert_difference('TrainingDeal.count', -1) do
      delete :destroy, id: @training_deal
    end

    assert_redirected_to training_deals_path
  end
end
