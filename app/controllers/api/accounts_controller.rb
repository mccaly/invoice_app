class Api::AccountsController < ApplicationController

  def create

  end

  def collection
    render json: Account.all
  end

  def get
    render json: Account.find(params[:id])
  end

  def update
  end

  def delete
  end
end
