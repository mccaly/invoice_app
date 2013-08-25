class Api::AccountsController < Api::ApiController

  def create
    account = current_user.accounts.build(params[:account])
    account.user = current_user
    current_user.accounts << account
    current_user.save

    if account.save
      render json: account
    else
      render json: false
    end
  end

  def collection
    render json: current_user.accounts
  end

  def get
    render json: current_user.accounts.find(params[:id])
  end

  def update
    account = current_user.accounts.find(params[:id])
    if account.update_attributes(params[:account])
      invoices = @account.invoices.where(email_reminder_approved: false)
      if invoices
        invoices.each do |invoice|
          invoice.update_attributes(
            account_name:          account.name,
            account_contact_email: account.contact_email,
            account_contact_name:  account.contact_name
          )
          invoice.save
        end
      end
      render json: account
    else
      render json: false, status: 400
    end
  end

  def delete
    account = current_user.accounts.find(params[:id])
    render json: account.destroy
  end
end
