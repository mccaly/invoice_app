class Unit 
	include Mongoid::Document
  include Mongoid::Timestamps


before_create :generate_access_token

  field :access_token, :type => String
  field :name, :type => String
  field :amount, :type => Integer


  belongs_to :deal

  has_many :unit_tallys

 private

	def generate_access_token
		begin
			self.access_token = SecureRandom.hex
		end while self.class.where(access_token: access_token).exists?
	end
end
