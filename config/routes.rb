BlueSource::Application.routes.draw do
  #BlueSource API
  get 'api/subordinates'
  get 'api/manager'

  resources :titles

  #Admin
  get 'admin/index'
  namespace :admin do
    resources :departments, only: :index
    resources :titles
  end
 
  #Employees stuff
  resources :employees do
    resources :vacations, only: [:index,:create,:update,:destroy] do
      collection do
        get 'view'
        post 'requests'
      end
      member do
        delete 'cancel'
      end
    end
    resources :project_histories, path: 'projects'
    patch 'preferences'
  end

  resources :departments, only: [:destroy, :new, :create, :update, :edit] do
    get 'sub_departments'
    get 'employees'
  end
  
  #Projects

  resources :projects, only: [:index,:show,:create,:update,:edit] do
    get 'leads'
  end
  
  #Welcome (login)
  get "login", to: 'welcome#login', as: :login
  get "logout", to: "welcome#logout", as: :logout
  post "login", to: "welcome#validate", as: :check_login
  post "issue", to: "welcome#issue", as: :issue
  post "search", to: "welcome#search_employee", as: :search
  post "login_issue", to: "welcome#login_issue", as: :login_issue
  
  #Directory
  resource :directory, only: [:show], controller: "directory" do
    resources :employees, only: [:index], action: "directory"
  end
  
  resource :calendar, only: [:index] do 
     get '/', to: 'calendar#index'
     get '/report', to: 'calendar#report'
  end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'employees#index'

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
