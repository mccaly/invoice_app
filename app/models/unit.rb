class Unit 
	include Mongoid::Document
  include Mongoid::Timestamps

  field :api_key, :type => String
  field :name, :type => String
  field :amount, :type => Integer


  belongs_to :deal

  
end
