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
			tally.set(:amount_total, tally.quantity * tally.amount_unit)
			invoice.inc(:amount, tally.amount_unit)
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
		 	invoice.inc(:amount, @tally_new.amount_total)
		 	@tally_new.save

		end

		#@tally = Tally.create(params[:tally])
		#@tally.unit_id = unit.id
		#@tally.amount_unit = unit.amount
		#@unit_tally = UnitTally.where(unit.id == :unit_id)
		#@tally.save
		# if @tally.save && @unit_tally.where(:created_at == Date.today) == nil
		# 	@unittally = UnitTally.create(params[:unit_tally])
		# 	@unittally.unit = unit
		# 	@unittally.access_token = @tally.access_token
		# 	@unittally.amount_unit = @tally.amount
		# 	@unittally.quantity = 1
		# 	@unittally.amount_total = (@unittally.quantity * @unittally.amount_unit)
		# 	@unittally.date = @unittally.created_at
		# 	@unittally.save
		# elsif @tally.save && @unit_tally.where(:created_at == Date.today) != nil
		# 	#update quantity of unity_tally (where created_at == Date.today) by +1
		# else @tall.save && @unit_tally == nil
		# 	#create new unit tally	
		#end

		respond_to do |format|
			format.json { render json: @tally}
		end
	end

	def new
		@tally = Tally.new
	end

end
