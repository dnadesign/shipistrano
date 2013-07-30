require "test/unit"
require_relative "../lib/shipistrano/helpers/helpers"

class HelperTests < Test::Unit::TestCase

  def test_local_file_exists
  	assert_equal true, local_file_exists?(File.expand_path(__FILE__))
  	assert_equal false, local_file_exists?(File.expand_path(File.dirname(__FILE__)) + "/fake.rb")
  end

  def test_local_command_exists
  	assert_equal true, local_command_exists?('gem')
  	assert_equal false, local_command_exists?('gemishcommand')
  end
end