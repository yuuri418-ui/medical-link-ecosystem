require "test_helper"

class VisitLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get visit_logs_index_url
    assert_response :success
  end

  test "should get new" do
    get visit_logs_new_url
    assert_response :success
  end

  test "should get show" do
    get visit_logs_show_url
    assert_response :success
  end

  test "should get edit" do
    get visit_logs_edit_url
    assert_response :success
  end
end
