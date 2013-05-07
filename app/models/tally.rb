class Tally
	include Mongoid::Document
	include Mongoid::Timestamps

	field :access_token, :type => String
	field :unit_id, :type => String
	field :amount, :type => Integer

	belongs_to :deal

	belongs_to :unit

	has_many :units

end