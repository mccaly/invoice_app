class AccountsController < ApplicationController

	def home
		@account = current_user.accounts.build
	end

	def show
		@account = Account.find(params[:id])
		@invoices = @account.invoices
	end

	def index

	end


	def create
		@account = current_user.accounts.build(params[:account])
		if @account.save
			flash[:success] = "New account saved"
			redirect_to :controller => :users, :action => :show, :id => current_user.id 
		else
			render 'users/show'
		end
	end

	def destroy
	end

	def new
		@account = Account.new
	end

	def account
		@account = Account.new
	end



end