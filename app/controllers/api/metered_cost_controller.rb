class Api::MeteredCostController < ApplicationController
  def create
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        
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
    deal = deals.find(params[:id])
    if deal
      render json: deal
    else 
      render nothing: true, status: 404
    end
  end

  def update
  end

  def delete
  end
end
