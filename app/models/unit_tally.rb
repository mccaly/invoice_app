class UnitTally
  include Mongoid::Document
  include Mongoid::Timestamps

  field :access_token, :type => String
  field :name, :type => String
  field :total, :type => Integer
  field :status, :type => String
  field :end_date, :type => Date

  belongs_to :invoice
  has_many :tallys
  belongs_to :unit


end
