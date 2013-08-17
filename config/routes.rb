InvoiceApp::Application.routes.draw do
  devise_for :users

  root to: 'static_pages#home'

  resources :tallys
  resources :unit_tallys
  resources :accounts, only: [:create, :new, :show, :edit, :update]

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
  match '/:controller/:action/:id'
  match '/deals/:deal_id/invoices', to: 'invoices#create', via: :post
  match '/help',                    to: 'static_pages#help'
  match '/about',                   to: 'static_pages#about'
  match '/docs',                    to: 'static_pages#docs'
  match '/dashboard' => 'users#dashboard', :as => 'user_root'
end
