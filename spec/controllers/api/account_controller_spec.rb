require 'spec_helper'

describe Api::AccountController do

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'collection'" do
    it "returns http success" do
      get 'collection'
      response.should be_success
    end
  end

  describe "GET 'get'" do
    it "returns http success" do
      get 'get'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end

  describe "GET 'delete'" do
    it "returns http success" do
      get 'delete'
      response.should be_success
    end
  end

end
