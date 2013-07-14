#namespace :invoices do 
	desc "change status of invoice that is ending (either because invoice end date is today or deal is ending today) & creatign new invoice if deal still has more time"
	task :create_next_invoice => :environment do
		Invoice.create_next_invoice
	end	

	desc "create new invoice if deal starts today & invoice doesnt already exist"
	task :create_new_invoice_on_deal_start => :environment do
		Invoice.create_new_invoice_on_deal_start
	end

	desc "change status to 'overdue'"
	task :change_invoice_status_to_overdue => :environment do
		Invoice.change_invoice_status_to_overdue
	end	
#end