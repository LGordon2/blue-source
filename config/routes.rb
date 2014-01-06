ManagerPortal::Application.routes.draw do
 
  #Vacation
  delete "/vacation/:id", to: "vacation#destroy", as: :vacation
  post "/vacation/new", to: "vacation#new"
  patch "/vacation/:id", to: "vacation#update"
 
  #Employees stuff
  get "employee/vacation/:id", to: "employee#vacation", as: :employee_vacation
  get "employees", to: "employee#all"
  get "employee/edit/:id", to: "employee#edit"
  get "employee/:id", to: "employee#index", as: :employee
  patch "employee/:id", to: "employee#update"
  post "employee/new", to: "employee#new"
  
  #Projects
  get "projects", to: "project#all"
  post "projects", to: "project#new"
  get "project/add"
  get "project/:id", to: "project#index", as: :project
  patch "project/:id", to: "project#update"
  
  #Welcome (login)
  get "sorry", to: 'welcome#sorry', as: :sorry
  get "login", to: 'welcome#login', as: :login
  get "logout", to: "welcome#logout", as: :logout
  get "consultant/vacation/:id", to: "welcome#consultant_vacation", as: :consultant_vacation
  post "login", to: "welcome#validate", as: :check_login
  post "issue", to: "welcome#issue", as: :issue
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
