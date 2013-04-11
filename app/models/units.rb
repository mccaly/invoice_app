class Units < ActiveRecord::Base
  attr_accessible :api_key, :name

  belongs_to :invoice

  belongs_to :account

  belongs_to :user
  
end
