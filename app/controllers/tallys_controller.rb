class TallysController < ApplicationController


	def show
		@tally = Tally.all
	end

	def index
		@tally = Tally.all
	end

	def create
		@tally = Tally.create(params[:tally])
		unit = Unit.find_by(access_token: params[:access_token])
		@tally.unit_id = unit.id
		respond_to do |format|
			format.json { render json: @tally}
		end
	end

	def new
		@tally = Tally.new
	end

end
