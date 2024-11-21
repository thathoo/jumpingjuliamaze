require "test_helper"

class MazeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get maze_index_url
    assert_response :success
  end
end
