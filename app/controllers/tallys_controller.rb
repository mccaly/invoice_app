class TallysController < ApplicationController


	def show
		@tally = Tally
	end

	def index
		@tally = Tally.all
	end

	def create
		unit = Unit.find_by(access_token: params[:access_token])
		@tally = Tally.create(params[:tally])
		@tally.unit_id = unit.id
		@tally.amount = unit.amount
		@tally.save
		respond_to do |format|
			format.json { render json: @tally}
		end
	end

	def new
		@tally = Tally.new
	end

end
