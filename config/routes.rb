Tdn::Application.routes.draw do
  resources :notifications

  resources :notification_templates

  resources :job_applicants

  #starting brochure page
  root :to => 'welcome#index'
  
  match '/about/' => 'welcome#about'
  match '/privacy/' => 'welcome#privacy'
  
  match '/test/' => 'welcome#test'

  match '/messages/sent' => 'messages#sent'
  match '/messages/sent/:id' => 'messages#show_sent'
  match '/messages/reply/:id' => 'messages#reply'
  resources :messages
  
  match 'transactions/admin/' => 'transactions#admin'
  match 'transactions/admin/:page' => 'transactions#admin'
  resources :transactions
  
  match '/roles/set' => 'roles#set'
  match '/roles/set/:id' => 'roles#set_user_role'
  match 'roles/choose_user_and_set' => 'roles#choose_user_and_set_role'
  resources :roles
  
  match '/search/' => 'search#index'
  

  resources :profiles do # should make this shallow
	resources :answers
  	resources :images
  	resources :resumes # NOTE: resumes can also be associated with a service (instead of a user choosing one of their general resumes, they can just submit a new one)
  end
  
  resources :notification_templates

  resources :job_applicants
  
  resources :confirmations
  # so I guess I can't limit nested resources...
  #resources :questions - this should not be by itself  
  
  #resources :questions, :path => '/admin/questions' # only an admin should be able to interact with the questions controller (removes need for Admin:: prefix)
  
  scope "/admin" do #-- only take this out for now
    resources :questions
    resources :feedback_forms # this part may be moved eventually if anyone can create a feedback form
  end
  
  get 'questions/autocomplete_choice_value' # used?  
  
devise_scope :user do
 match "user/allusers" => "users#allusers"
 match "user/allusers_advanced" => "users#allusers_advanced"
end

devise_scope :user do
 match "disputes/admin_list" => "disputes#admin_list"
 match "disputes/dispute_list" => "disputes#dispute_list"
end
  
  devise_scope :user do
  	get "user", :to => "users#index"
	get "search", :to => "users#search"
	get "search/:search", :to => "users#search"
  end
  devise_for :users, :controllers => { :registrations => :users }
  resources :users do
	resources :disputes
  member do
    get 'search'
	get :following, :followers
  end
end
  resources :users, :only => [:index, :show]
  
 
  resources :relationships, :only => [:create, :destroy]
  match '/profiles/:id/following' => 'profiles#following'
  
  match '/jobs/posted' => 'jobs#posted'
  match '/jobs/applied' => 'jobs#applied'
  match 'jobs/accept/:id'=> 'jobs#accept'
  match 'jobs/search/area' => 'jobs#area'
  match 'transactions/reward/:id' => 'transactions#reward'
  match 'jobs/alljobs' => 'jobs#alljobs'
  
  resources :jobs
  
  resources :disputes
  
  
  resources :categories
  

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
  

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
