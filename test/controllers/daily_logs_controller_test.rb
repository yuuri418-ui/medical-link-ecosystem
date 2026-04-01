require "test_helper"

class DailyLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get daily_logs_new_url
    assert_response :success
  end

  test "should get index" do
    get daily_logs_index_url
    assert_response :success
  end

  test "should get show" do
    get daily_logs_show_url
    assert_response :success
  end

  test "should get edit" do
    get daily_logs_edit_url
    assert_response :success
  end
end
