#
#
# User class object for Cas pedagogue
class User < ApplicationRecord
	has_many :authorizations
	validates :login_id, presence: true

	def self.from_omniauth(auth)
		Rails.logger.info ("DEBUG: User.from_omni_auth() auth: #{auth.inspect}")
		login_id = auth.uid
		user = User.find auth.user.id
		user ||= User.create do |user|
			user.provider = auth.provider
			user.uid = auth.uid
			user.email = auth.email if auth.email
			user.name = auth.user.name
		end
		logger.info "DEBUG: User.from_omni_auth() returning user: #{user.inspect}"
		user
	end

	def add_provider(auth_hash)
		unless authorizations.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
			Authorization.create user: self, provider: auth_hash['provider'], uid: auth_hash['uid']
		end
	end
end
