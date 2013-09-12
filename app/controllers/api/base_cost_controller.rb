class Api::BaseCostController < ApplicationController
  def create
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.basecosts.find(params[:deal_id])
      if deal 
        params[:basecost][:cost] = (params[:basecost][:cost].to_f * 100).to_i
        basecost = deal.basecosts.build(params[:basecost)
        basecost.total = basecost.cost * basecost.quantity
        deal.units << basecost
        render json: basecost 
      end
    else
      render nothing: true, status: 404
    end

    @deal = Deal.find(params[:deal_id])
    params[:basecost][:cost] = (params[:basecost][:cost].to_f * 100).to_i

    @basecost = Basecost.create(params[:basecost])
    @invoice = @deal.invoices.where(status: "Active").first
    @basecost.deal = @deal

    @deal.basecosts << @basecost
    @deal.save

    @basecost.total = @basecost.cost * @basecost.quantity
    @basecost.save
  end

  def collection
    render json: current_user.accounts.find(params[:account_id]).basecosts
  end

  def get
    basecosts = current_user.accounts.find(params[:account_id]).basecosts
    basecost = basecosts.find(params[:id])
    if basecost
      render json: basecost
    else 
      render nothing: true, status: 404
    end
  end

  def update
  end

  def delete
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        basecost = deal.basecosts.find(params[:metered_id])
        if basecost
          render json: basecost.destroy
        end
      end
    end

    render nothing: true, status: 404
  end
end
