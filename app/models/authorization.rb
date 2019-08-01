class Authorization < ApplicationRecord
		belongs_to :user
		validates :provider, :uid, presence: true

	def self.find_or_create(auth_hash)
		unless auth = find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
			Authorization.create user: self, provider: auth_hash['provider'], uid: auth_hash['uid']
		end
	end
end
