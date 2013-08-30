class Api::ApiController < ApplicationController
	skip_before_filter  :verify_authenticity_token
	before_filter :restrict_access

	private
	def restrict_access
		head :unauthorized unless user_signed_in?
	end
end