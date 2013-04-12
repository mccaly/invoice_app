class Unit 
	include Mongoid::Document
  include Mongoid::Timestamps

  field :api_key, :type => String
  field :name, :type => String


  belongs_to :invoice

  
end
