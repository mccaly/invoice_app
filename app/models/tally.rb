class Tally
	include Mongoid::Document
	include Mongoid::Timestamps

	field :access_token, :type => String

	belongs_to :deal

	belongs_to :unit

	has_many :units

end