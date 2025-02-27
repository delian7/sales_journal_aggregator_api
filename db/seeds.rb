# frozen_string_literal: true

# Import orders and payments from CSV
ENV["FILE_PATH"] = "data.csv"
Rake::Task["import:orders_and_payments"].invoke

# Create a default user if it doesn't exist
# This is useful for testing purposes
# Display the access token, client, and uid
# for the default user
user = User.find_or_create_by(
  email: "test@example.com",
  first_name: "Test",
  last_name: "User"
)

user.password = "password"
user.password_confirmation = "password"
user.save! if user.changed?

tokens = user.generate_authentication_tokens

puts "User created with the following authentication tokens:"
puts "access-token: #{tokens['access-token']}"
puts "client: #{tokens['client']}"
puts "uid: #{tokens['uid']}"
