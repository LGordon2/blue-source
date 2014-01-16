ManagerPortal::Application.routes.draw do
  
  get "directory/index"
  #Vacation
  delete "/vacation/:id", to: "vacation#destroy", as: :vacation
  post "/vacation/new", to: "vacation#new"
  patch "/vacation/:id", to: "vacation#update"
 
  #Employees stuff
  get "employees/vacation/:id", to: "employees#vacation", as: :employee_vacation
  get "employees/vacation/:id/view", to: "employees#view_vacation", as: :view_vacation
  resources :employees, only: [:index,:show,:create,:update,:edit]
  
  #Projects
  get "projects/:id/leads", to: "projects#all_leads", as: :leads
  resources :projects, only: [:index,:show,:create,:update,:edit]
  
  
  #Welcome (login)
  get "sorry", to: 'welcome#sorry', as: :sorry
  get "login", to: 'welcome#login', as: :login
  get "logout", to: "welcome#logout", as: :logout
  post "login", to: "welcome#validate", as: :check_login
  post "issue", to: "welcome#issue", as: :issue
  
  #Directory
  get 'directory', to: 'directory#index', as: :directory
  get "directory/employees", to: "directory#employees"
  
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
