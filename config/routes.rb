Rails.application.routes.draw do

  namespace :admin do
    namespace :billing do
      get 'billing_arrangements/index'
      get 'billing_arrangements/edit'
    end
  end
  namespace :admin do
  namespace :billing do
    get 'credit_memos/index'
    end
  end

  namespace :admin do
  namespace :billing do
    get 'credit_memos/edit'
    end
  end

  namespace :admin do
  namespace :billing do
    get 'cc_transactions/index'
    end
  end

  namespace :admin do
    
    namespace :billing do
      post 'email_invoice' => 'invoices#email'
      post 'invoices_print_batch' => 'invoices#print_batch'
      post 'invoices_email_batch' => 'invoices#email_batch'
      post 'invoices_update_status_batch' => 'invoices#update_status_batch'
      
			resources :billing_arrangements
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
          get 'add_service'
        end
      end
      resources :user_services
      resources :payment_methods
      resources :invoices do 
        member do 
          get 'print'
          post 'email'
        end
      end
      resources :credit_memos do 
        member do 
          get 'print'
        end
      end
      resources :payments do 
        member do
          get 'refund'
        end
      end
    end
    
  end
  
  namespace :account do
    resources :user_packages
    resources :payments
    resources :payment_methods do
      member do 
        get 'primary'
      end
    end
  end
  
end
