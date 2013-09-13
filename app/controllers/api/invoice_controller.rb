class Api::InvoiceController < Api::ApiController

  	def get
		account = current_user.accounts.find(params[:account_id])
	  	if account
			invoice = account.invoices.find(params[:id])
			if invoice
				return render json: invoice
			end
	    end

	    render nothing: true, status: 404
  	end

  	def collection 
  		account = current_user.accounts.find(params[:account_id])
	  	if account
			return render json: account.invoices
	    end

	    render nothing: true, status: 404
  	end
end
