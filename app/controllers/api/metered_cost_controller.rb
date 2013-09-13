class Api::MeteredCostController < Api::ApiController
  def create
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        params[:metered][:amount] = (params[:metered][:amount].to_f * 100).to_i
        metered = deal.units.build(params[:metered])
        deal.units << metered
        self.create_invoice_metered_cost_tally(deal,metered)
        return render json: metered 
      end
    else
      render nothing: true, status: 404
    end
  end

  def collection
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        return render json: deal.units
      end
    end
    
    render nothing: true, status: 404
  end

  def get
    ccount = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        metered = deal.units.find(params[:id])
        if metered
          return render json: metered
        end
      end
    end

    render nothing: true, status: 404
  end

  def update
    ccount = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        metered = deal.units.find(params[:id])
        if metered
          metered.update_attributes(params[:metered])
          return render json: metered
        end
      end
    end

    render nothing: true, status: 404
  end

  def delete
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        metered = deal.units.find(params[:id])
        if metered
          return render json: metered.destroy
        end
      end
    end

    render nothing: true, status: 404
  end

  protected
  def create_invoice_metered_cost_tally(deal, metered)
    invoice = deal.invoices.where(status: "Active").first
    if invoice
      metered_tally              = UnitTally.create
      metered_tally.name         = metered.name
      metered_tally.access_token = metered.access_token
      metered_tally.status       = 'Active'
      metered_tally.end_date     = invoice.end_date
      metered_tally.set(:total, metered_tally.tallys.sum(:amount_total).to_i)
      metered_tally.invoice      = invoice
      metered_tally.unit         = metered
      metered_tally.save
      invoice.unit_tallys << metered_tally
      invoice.save
    end
  end
end
