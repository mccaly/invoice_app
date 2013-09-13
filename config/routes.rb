InvoiceApp::Application.routes.draw do
  get "metered_cost/create"

  get "metered_cost/collection"

  get "metered_cost/get"

  get "metered_cost/update"

  get "metered_cost/delete"

  get "base_cost/create"

  get "base_cost/collection"

  get "base_cost/get"

  get "base_cost/update"

  get "base_cost/delete"

  get "deals_controller/create"

  get "deals_controller/collection"

  get "deals_controller/get"

  get "deals_controller/update"

  get "deals_controller/delete"

  get "account/create"

  get "account/collection"

  get "account/get"

  get "account/update"

  get "account/delete"

  devise_for :users

  root to: 'static_pages#home'

  resources :tallys
  resources :unit_tallys
  resources :accounts, only: [:create, :new, :show, :edit, :update]
  resources :pdf

  resources :users do
    member do
      get 'approve'
      get 'export'
    end
  end

  resources :deals do
    resources :basecost
    resources :units
    resources :invoices do
      member do
        put 'email_invoice'
        put 'email_reminder'
      end
    end
  end

  match '/invoices/:id',            to: 'invoices#show'
  # this route needs to be rethought to add in support for non-logged in users looking at a prepared invoice
  #match ':controller/:action/:id'
  match '/deals/:deal_id/invoices', to: 'invoices#create', via: :post
  match '/help',                    to: 'static_pages#help'
  match '/about',                   to: 'static_pages#about'
  match '/docs',                    to: 'static_pages#docs'
  match '/dashboard' => 'users#dashboard', :as => 'user_root'

  namespace :api do 
    get "/accounts/:account_id/invoices(.:format)" => "invoice#collection"
    get "/accounts/:account_id/invoices/:id(.:format)" => "invoice#get"

    post "/accounts/:account_id/deals/:deal_id/metereds(.:format)" => 'metered_cost#create'
    get "/accounts/:account_id/deals/:deal_id/metereds(.:format)" => "metered_cost#collection"
    get "/accounts/:account_id/deals/:deal_id/metereds/:id(.:format)" => "metered_cost#get"
    delete "/accounts/:account_id/deals/:deal_id/metereds/:id(.:format)" => "metered_cost#delete"

    post "/accounts/:account_id/deals/:deal_id/basecosts(.:format)" => 'base_cost#create'
    get "/accounts/:account_id/deals/:deal_id/basecosts(.:format)" => "base_cost#collection"
    get "/accounts/:account_id/deals/:deal_id/basecosts/:id(.:format)" => "base_cost#get"
    delete "/accounts/:account_id/deals/:deal_id/basecosts/:id(.:format)" => "base_cost#delete"

    post "/accounts/:account_id/deals(.:format)" => 'deals#create'
    get "/accounts/:account_id/deals(.:format)" => "deals#collection"
    get "/accounts/:account_id/deals/:id(.:format)" => "deals#get"
    delete "/accounts/:account_id/deals/:id(.:format)" => "deals#delete"

    post "/accounts(.:format)" => "accounts#create"
    get "/accounts(.:format)" => "accounts#collection"
    get "/accounts/:id(.:format)" => "accounts#get"
    delete "/accounts/:id(.:format)" => "accounts#delete"
    
  end
end
