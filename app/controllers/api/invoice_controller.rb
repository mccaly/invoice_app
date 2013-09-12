class Api::DealsController < Api::ApiController

  def get
    invoice = Invoice.find(params[:id])
    if invoice && invoice.user = current_user
      render json: invoice
    else 
      render nothing: true, status: 404
    end
  end

end
