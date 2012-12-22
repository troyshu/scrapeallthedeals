require 'test_helper'

class LocationUrlMapsControllerTest < ActionController::TestCase
  setup do
    @location_url_map = location_url_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:location_url_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location_url_map" do
    assert_difference('LocationUrlMap.count') do
      post :create, location_url_map: { site: @location_url_map.site, static_location: @location_url_map.static_location, suffix: @location_url_map.suffix }
    end

    assert_redirected_to location_url_map_path(assigns(:location_url_map))
  end

  test "should show location_url_map" do
    get :show, id: @location_url_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @location_url_map
    assert_response :success
  end

  test "should update location_url_map" do
    put :update, id: @location_url_map, location_url_map: { site: @location_url_map.site, static_location: @location_url_map.static_location, suffix: @location_url_map.suffix }
    assert_redirected_to location_url_map_path(assigns(:location_url_map))
  end

  test "should destroy location_url_map" do
    assert_difference('LocationUrlMap.count', -1) do
      delete :destroy, id: @location_url_map
    end

    assert_redirected_to location_url_maps_path
  end
end
