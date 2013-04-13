AvMobile::Application.routes.draw do
  root :to => 'welcome#shutdown_notice'
  match '*path' => redirect('/', status: 302)
  match 'login' => 'user_sessions#new', via: :get, as: :login
  match 'login' => 'user_sessions#verify_code', via: :put
  match 'login' => 'user_sessions#create', via: :post
  match 'logout' => 'user_sessions#destroy'
  resources :blurbs, only: [:index, :show]
  match 'blurbs-with-phone-:phone' => 'blurbs#index', via: :get, as: :blurbs_with_phone
  match 'phone-search' => 'phone_searches#new', via: :get, as: :new_phone_search
  match 'phone-search' => 'phone_searches#create', via: :post
  resources :sms_notifications, only: [:index], path: 'sms-notifications'
  match 'search' => 'search#edit', :via => :get, :as => :edit_search
  match 'search' => 'search#update', :via => :put
  match 'sms-notifications/step-1' => 'sms_notifications#step1', as: :sms_notification_step1
  match 'sms-notifications/step-2' => 'sms_notifications#step2', as: :sms_notification_step2
  match 'sms-notifications/step-3' => 'sms_notifications#step3', as: :sms_notification_step3
  match 'send-verification-code' => 'phones#send_verification_code', as: :send_verification_code, via: :post
  match 'verify-code-and-subscribe' => 'phones#verify_and_subscribe', as: :subscribe_to_sms_notification, via: :post
  match 'b/:short_id' => 'blurbs#show', as: :short_blurb, via: :get
  match 'sms-billing' => 'phones#payment'
  match 'wiki/free-version' => 'wiki#free-version', as: :free_wiki
  match 'hide-ads' => 'welcome#hide_ads', via: :post, as: :hide_ads
  match 'stats' => 'stats#index', as: :stats
  resources :my_search_queries, path: 'my-search-queries', only: [:index, :show, :destroy]
  resources :articles, only: [:show]
  namespace :admin do
    resources :articles
  end
  namespace :my do
    resources :blurbs, only: [:index, :new, :create, :destroy]
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
