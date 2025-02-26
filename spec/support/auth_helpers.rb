# frozen_string_literal: true

module AuthHelpers
  def auth_headers(user)
    post "/auth/sign_in", params: { email: user.email, password: user.password }
    response.headers.slice("access-token", "client", "uid")
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
