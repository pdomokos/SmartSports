Rails.application.routes.draw do

  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  resources :notifications

  # get 'user_sessions/create'
  # get 'user_sessions/destroy'

  resources :user_sessions

  resources :users do
    resources :activities
    resources :measurements
    resources :notifications
    resources :friendships
    resources :summary
  end

  resources :password_resets

  get 'pages/login'
  get 'pages/signup'
  get 'pages/dashboard'
  get 'pages/health'
  get 'pages/training'
  get 'pages/lifestyle'
  get 'pages/genetics'
  get 'pages/settings'

  resources :activities
  resources :notifications
  resources :measurements
  resources :friendships

  get 'sync/sync_moves'
  get 'sync/sync_withings'
  get 'sync/sync_fitbit'

  get 'pages/pwreset'
  get 'pages/mdestroy'
  get 'pages/wdestroy'
  get 'pages/fdestroy'
  get '/auth/moves/callback' => 'pages#movescb'
  get '/auth/withings/callback' => 'pages#withingscb'
  get '/auth/fitbit/callback' => 'pages#fitbitcb'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#dashboard'

  get 'login' => 'pages#login', :as => :login
  get 'signup' => 'pages#signup', :as => :signup
  post 'logout' => 'user_sessions#destroy', :as => :logout

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
