ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
require "rails/test_help"

# Clean up data before each test to avoid conflicts in production environment
module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # Disable parallelization to avoid conflicts in production environment
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    setup do
      # Clean up test data to avoid uniqueness conflicts
      # Delete in correct order due to foreign key constraints
      Reaction.where("user_name LIKE ?", "Test%").destroy_all
      Reaction.where("user_name LIKE ?", "Unique-%").destroy_all
      Message.where("user_name LIKE ?", "Test%").destroy_all
      Message.where("user_name LIKE ?", "Unique-%").destroy_all
      Room.where("name LIKE ?", "Test%").destroy_all
      Room.where("name LIKE ?", "Unique-%").destroy_all
    end
  end
end
