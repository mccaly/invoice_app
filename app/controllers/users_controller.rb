class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update]
  before_filter :correct_user, only: [:edit, :update]


	def show
		@user = User.find(params[:id])
    @account = @user.accounts
    @invoice_email = @user.invoices.where(status: 'waiting_on_payment').and(:email_invoice_approved => false)
    @reminder_invoice = @user.invoices.where(status: 'Overdue').and(:email_reminder_approved => false)
	end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(params[:user])
  	if @user.save
      UserMailer.welcome_email(@user).deliver!
      UserMailer.new_user(@user).deliver!
			flash[:success] = "Welcome to Invoice App"
 			redirect_to @user
 		else
			redirect_to new_user_path(@user)
  	end
	end

  def edit
    #@user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:success] = "profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def approve
    @user = User.find(params[:id])
    accounts = @user.accounts
    @invoice = @user.invoices.where(status: 'waiting_on_payment').and(:email_invoice_approved => false)
    @reminder_invoice = @user.invoices.where(status: 'Overdue').and(:email_reminder_approved => false)
  end



  private

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "please sign in"
      end
    end

    def correct_user
       @user= User.find(params[:id])
       redirect_to(root_path) unless current_user == @user 
    end
end
