class TallysController < ApplicationController


	def show
		@tally = Tally
	end

	def index
		@tally = Tally.all
	end

	def create
		unit = Unit.find_by(access_token: params[:access_token])
		invoice = unit.invoices.where(status: 'Active').first
		tally = Tally.where(:access_token => unit.access_token).and(:date => Date.today).first
		if tally
			tally.inc(:quantity, 1)
			@tally_running_total = (tally.amount_unit).to_i
			tally.inc(:amount_total, @tally_running_total) 
			invoice.inc(:metered_total, tally.amount_unit)
			if invoice.adjust_total != "true"
				invoice.set(:amount, invoice.metered_total + invoice.basecost_total)
			end
		else
		 	@tally_new = Tally.create(params[:tally])
		 	@tally_new.unit = unit
		 	@tally_new.unit_id = unit.id
		 	@tally_new.quantity = 1
		 	@tally_new.date = Date.today
		 	@tally_new.amount_unit = unit.amount
		 	@tally_new.amount_total = (@tally_new.amount_unit * @tally_new.quantity)
		 	@tally_new.access_token = unit.access_token
		 	@tally_new.deal = unit.deal
		 	unit.tallys << @tally_new
		 	unit.save
		 	invoice.inc(:metered_total, @tally_new.amount_total)
		 	if invoice.adjust_total != "true"
		 		invoice.set(:amount, invoice.metered_total + invoice.basecost_total)
		 	end
		 	@tally_new.save

		end

		respond_to do |format|
			format.json { render json: @tally}
		end
	end

	def new
		@tally = Tally.new
	end

end
