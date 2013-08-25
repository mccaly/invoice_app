class Api::DealsController < Api::ApiController
  def create
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.build(params[:account])
      account.deals << deal
      if account.save
        render json: deal
      else 
        render nothing: true, status: 418
      end
    else
      render nothing: true, status: 404
    end
  end

  def collection
    render json: current_user.accounts.find(params[:account_id]).deals
  end

  def get
    deals = current_user.accounts.find(params[:account_id]).deals
    if account
      render json: deals.find(params[:id])
    else 
      render nothing: true, status: 404
    end
  end

  def update
    
  end

  def delete
  end
end
