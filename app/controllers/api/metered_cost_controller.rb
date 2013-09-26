class Api::MeteredCostController < Api::ApiController

  def tally
    unit = Unit.find_by(access_token: params[:access_token])
    unit_tally = unit.unit_tallys.where(status: 'Active').first
    invoice = unit_tally.invoice
    tally = Tally.where(:access_token => unit.access_token).and(:date => Date.today).first
    if tally
      tally.inc(:quantity, 1)
      tally_running_total = (tally.amount_unit).to_i
      tally.inc(:amount_total, tally_running_total) 
      unit_tally.inc(:total, tally.amount_unit)
      invoice.set(:metered_total, invoice.unit_tallys.sum(:total).to_i)
      if invoice.adjust_total != "true"
        invoice.set(:amount, invoice.metered_total + invoice.basecost_total)
      end

      return render json: tally
    else
      tally_new = Tally.create(params[:tally])
      tally_new.unit_tally = unit_tally
      tally_new.quantity = 1
      tally_new.date = Date.today
      tally_new.amount_unit = unit.amount
      tally_new.amount_total = (@tally_new.amount_unit * @tally_new.quantity)
      tally_new.access_token = unit.access_token
      tally_new.deal = unit.deal
      unit_tally.tallys << tally_new
      unit_tally.inc(:total, tally_new.amount_unit)
      unit_tally.save
      invoice.set(:metered_total, invoice.unit_tallys.sum(:total).to_i)
      if invoice.adjust_total != "true"
        invoice.set(:amount, invoice.metered_total + invoice.basecost_total)
      end
      tally_new.save

      return render json: tally_new
    end 
  end

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
