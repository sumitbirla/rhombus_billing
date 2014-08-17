Rails.application.routes.draw do
  
  namespace :admin do
    
    namespace :billing do
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
          get 'services' => 'user_packages#services'
        end
      end
      resources :user_services
      resources :payment_methods
      resources :payments
    end
    
  end
  
end
