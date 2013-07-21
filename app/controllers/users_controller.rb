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

  def export
    @user = User.find(params[:id])

  end

  def export_csv
    @user = User.find(params[:id])
    @start_date = Date.civil(params[:users]["start_date(1i)"].to_i,
                         params[:users]["start_date(2i)"].to_i,
                         params[:users]["start_date(3i)"].to_i)
    @end_date = Date.civil(params[:users]["end_date(1i)"].to_i,
                         params[:users]["end_date(2i)"].to_i,
                         params[:users]["end_date(3i)"].to_i)
    user_invoices = @user.invoices
    @basecosts = []
    @units = []
    user_invoices.each do |invoice|
      basecosts = invoice.basecost_tallys.where(:created_at.gte => @start_date).and(:created_at.lte => @end_date)
      basecosts.each do |basecost|
        @basecosts << basecost
       
      end
    end
    user_invoices.each do |invoice|
      costs = invoice.unit_tallys.where(:created_at.gte => @start_date).and(:created_at.lte => @end_date)
      costs.each do |cost|
        @units << costs
       
      end
    end
    

    export = CSV.generate do |csv|
      csv << ["date", "invoice name", "basecost", "metered cost", "$"]
        @basecosts.each do |basecost|
          invoice = basecost.invoice
          invoice_name = invoice.name 
          csv << [basecost.created_at, invoice_name, basecost.name, "nil", basecost.amount]
        end

        @units.each do |unit|
          unit.each do |unit_i|
            invoice = unit_i.invoice
            invoice_name = invoice.name 
            csv << [unit_i.created_at, invoice_name, "nil", unit_i.name, unit_i.total]
         end
        end
    end    
    
    send_data export, :type => "text/plain", :filename => "export.csv"



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
