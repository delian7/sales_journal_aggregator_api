# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :password, presence: true, length: { minimum: 6 }
  validates :first_name, presence: true
  validates :last_name, presence: true

  def generate_authentication_tokens
    token = SecureRandom.urlsafe_base64(nil, false)
    client_id = SecureRandom.urlsafe_base64(nil, false)
    token_hash = BCrypt::Password.create(token)
    expiry = (Time.now + DeviseTokenAuth.token_lifespan).to_i

    tokens[client_id] = {
      token: token_hash,
      expiry: expiry
    }
    save!

    { "access-token" => token, "client" => client_id, "uid" => email }
  end
end
