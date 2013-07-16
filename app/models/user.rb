# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User 
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :name, :type => String
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  ##Payment info
  field :paypal_url, :type => String
  field :bank_wire_details, :type => String
  field :company, :type => String

  ##account info
  field :admin, :type => Boolean, :default => false 
  #field :passed_free_trial, :type => Boolean, :defaut =>false
  field :plan_type, :type => String

  has_many :accounts
  has_many :invoices

  after_create :send_welcome_email
  after_create :send_new_user_email



  #send reminder that free trail is about to expire
  def self.send_reminder_that_trial_period_will_expire  
      User.each do |user|
          if (user.admin == false) && user.created_at < (Date.today - 25.days)
            ApprovalMailer.trial_period_reminder_5days(user).deliver
          end  
      end
  end

  # #take user out of free trial
  # def self.change_user_status_if_past_free_trial
  #   User.each do |user|
  #     # if (user.admin == false) && user.created_at < (Date.today - 30.days)
  #      # user.toggle!(:passed_free_trial)
  #     # end
  # end


private
    def send_welcome_email
      UserMailer.welcome_email(self).deliver
    end

    def send_new_user_email
      UserMailer.new_user(self).deliver!
    end

  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end
end
