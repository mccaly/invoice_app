namespace :users do 
	desc "Check to see if user is about to exit trial period"
	task :send_reminder_that_trial_period_will_expire => :environment do
		User.send_reminder_that_trial_period_will_expire
	end	

# 	desc "Change user status if past free trial"
# 	task :change_user_status_if_past_free_trial => :environment do
# 		User.change_user_status_if_past_free_trial
# 	end

 end