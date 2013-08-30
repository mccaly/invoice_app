class Api::DealsController < Api::ApiController

  def create
    account = current_user.accounts.find(params[:account_id])
    if account
      self.process_date(params[:deal], "start_date")
      self.process_date(params[:deal], "end_date")
      deal = account.deals.build(params[:deal])
      account.deals << deal
      deal.process_deal(params, current_user)
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
    deal = deals.find(params[:id])
    if deal
      render json: deal
    else 
      render nothing: true, status: 404
    end
  end

  def update
    deals = current_user.accounts.find(params[:account_id]).deals
    deal = deals.find(params[:id])
    if deal
      if deal.update_attributes(params[:deal])
        render json: deal
      else
        render json: false, status: 400
      end
    else
      render nothing: true, status: 404
    end
  end

  def delete
    account = current_user.accounts.find(params[:id])
    render json: account.destroy
  end

  protected
  def process_date(obj, field_name)
    dateval = obj["#{field_name}"];
    date = Date.parse(dateval)
    obj[field_name] = date
  end
end
