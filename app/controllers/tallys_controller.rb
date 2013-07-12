class TallysController < ApplicationController


	def show
		@tally = Tally
	end

	def index
		@tally = Tally.all
	end

	def create
		unit = Unit.find_by(access_token: params[:access_token])
		unit_tally = unit.unit_tallys.where(status: 'Active').first
		invoice = unit_tally.invoice
		tally = Tally.where(:access_token => unit.access_token).and(:date => Date.today).first
		if tally
			tally.inc(:quantity, 1)
			@tally_running_total = (tally.amount_unit).to_i
			tally.inc(:amount_total, @tally_running_total) 
			unit_tally.inc(:total, tally.amount_unit)
			invoice.set(:metered_total, invoice.unit_tallys.sum(:total).to_i)
			if invoice.adjust_total != "true"
				invoice.set(:amount, invoice.metered_total + invoice.basecost_total)
			end
		else
		 	@tally_new = Tally.create(params[:tally])
		 	@tally_new.unit_tally = unit_tally
		 	@tally_new.quantity = 1
		 	@tally_new.date = Date.today
		 	@tally_new.amount_unit = unit.amount
		 	@tally_new.amount_total = (@tally_new.amount_unit * @tally_new.quantity)
		 	@tally_new.access_token = unit.access_token
		 	@tally_new.deal = unit.deal
		 	unit_tally.tallys << @tally_new
		 	unit_tally.inc(:total, @tally_new.amount_unit)
		 	unit_tally.save
		 	invoice.set(:metered_total, invoice.unit_tallys.sum(:total).to_i)
		 	if invoice.adjust_total != "true"
		 		invoice.set(:amount, invoice.metered_total + invoice.basecost_total)
		 	end
		 	@tally_new.save

		end

		respond_to do |format|
			format.json { render json: @tally_new}
		end
	end

	def new
		@tally = Tally.new
	end

end
