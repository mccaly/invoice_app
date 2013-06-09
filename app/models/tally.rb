class Tally
	include Mongoid::Document
	include Mongoid::Timestamps

	field :access_token, :type => String
	field :unit_id, :type => String
	field :quantity, :type => Integer
	field :amount_unit, :type => Integer
  	field :amount_total, :type => Integer
  	field :date, :type => Date

	belongs_to :deal	

	belongs_to :unit

end