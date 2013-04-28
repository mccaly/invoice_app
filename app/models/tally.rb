class Account 
	include Mongoid::Document
	include Mongoid::Timestamps

	field :access_token, :type => String

	belongs_to :deal

	has_many :units

end