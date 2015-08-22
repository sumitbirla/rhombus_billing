Rails.application.routes.draw do

  namespace :admin do
  namespace :billing do
    get 'cc_transactions/index'
    end
  end

  namespace :admin do
    
    namespace :billing do
      resources :cc_transactions
      resources :service_types
      resources :packages do
        member do
          get 'details' => 'packages#details'
          post 'details' => 'packages#update_details'
        end
      end
      resources :package_details
      resources :user_packages do
        member do
          get 'services'
        end
      end
      resources :user_services
      resources :payment_methods
      resources :payments
    end
    
  end
  
  namespace :account do
    resources :payments
    resources :payment_methods do
      member do 
        get 'primary'
      end
    end
  end
  
end
