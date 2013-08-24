class Api::ApiController < ApplicationController
	before_filter :restrict_access

	private
	def restrict_access
		head :unauthorized unless user_signed_in?
	end
end