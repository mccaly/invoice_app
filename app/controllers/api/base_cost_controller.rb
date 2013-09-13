class Api::BaseCostController < Api::ApiController
  def create
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        params[:basecost][:cost] = (params[:basecost][:cost].to_f * 100).to_i
        basecost = deal.basecosts.build(params[:basecost])
        basecost.total = basecost.cost * basecost.quantity
        deal.units << basecost
        self.create_invoice_base_cost_tally(deal,basecost)
        render json: basecost 
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
        return render json: deal.basecosts
      end
    end
    
    render nothing: true, status: 404
  end

  def get
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        basecost = deal.basecosts.find(params[:id])
        if basecost
          return render json: basecost
        end
      end
    end
    
    render nothing: true, status: 404
  end

  def update
    account = current_user.accounts.find(params[:account_id])
    if account
      deal = account.deals.find(params[:deal_id])
      if deal 
        basecost = deal.basecosts.find(params[:id])
        if basecost
          params[:basecost][:cost] = (params[:basecost][:cost].to_f * 100).to_i
          basecost.update_attributes(params[:basecost])
          basecost.total = basecost.cost * basecost.quantity
          basecost.save

          basecost_tally = basecost.basecost_tallys.where(status: "Active").first
          self.update_invoice_base_cost_tally(deal, basecost)

          return render json: basecost
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
        basecost = deal.basecosts.find(params[:id])
        if basecost
          self.delete_invoice_base_cost_tally(deal,basecost)
          return render json: basecost.destroy
        end
      end
    end

    render nothing: true, status: 404
  end

  protected
  def create_invoice_base_cost_tally(deal, basecost)
    invoice = deal.invoices.where(status: "Active").first
    if invoice
      basecost_tally           = BasecostTally.create
      basecost_tally.basecost  = basecost
      basecost_tally.name      = basecost.name
      basecost_tally.amount    = basecost.cost
      basecost_tally.quantity  = basecost.quantity
      basecost_tally.set(:total, basecost_tally.amount * basecost_tally.quantity)
      basecost_tally.invoice   = invoice
      #basecost_tally.end_date = invoice.end_date
      basecost_tally.status    = 'Active'
      basecost_tally.deal      = deal
      basecost_tally.save

      basecost.basecost_tallys    << basecost_tally

      invoice.basecost_tallys << basecost_tally
      invoice_basecosts        = invoice.basecost_tallys
      invoice.basecost_total   = invoice_basecosts.sum(:total).to_i
      
      invoice.set(:amount, invoice.basecost_total + invoice.metered_total)
      invoice.save
    end
  end

  def update_invoice_base_cost_tally(deal, basecost)
    basecost_tally = basecost.basecost_tallys.where(status: "Active").first
    if basecost_tally
      basecost_tally.update_attribute(name: basecost.name, amount: basecost.cost, quantity: basecost.quantity)
      basecost_tally.set(:total, basecost_tally.amount * basecost_tally.quantity)
      basecost_tally.save
      invoice = deal.invoices.where(status: "Active").first
      if invoice
        invoice_basecosts = invoice.basecost_tallys
        invoice.basecost_total = invoice_basecosts.sum(:total).to_i
        invoice.set(:amount, invoice.basecost_total + invoice.metered_total)
        invoice.save
      end
    end
  end

  def delete_invoice_base_cost_tally(deal, basecost)
    basecost_tally = basecost.basecost_tallys.where(status: "Active").first
    basecost_tally.destroy
    invoice = deal.invoices.where(status: "Active").first
    invoice_basecosts = invoice.basecost_tallys
    invoice.basecost_total = invoice_basecosts.sum(:total).to_i
    invoice.set(:amount, invoice.basecost_total + invoice.metered_total)
    invoice.save
  end

end
