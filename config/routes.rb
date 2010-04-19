ActionController::Routing::Routes.draw do |map|
  map.resources :sensors


  map.experiment1 'experiment1', :controller=>"experiments", :action=>"temp1"
  map.experiment2 'experiment2', :controller=>"experiments", :action=>"temp2"
  map.experiment3 'experiment3', :controller=>"experiments", :action=>"temp3"
  map.experiment4 'experiment4', :controller=>"experiments", :action=>"temp4"
  map.experiment5 'experiment5', :controller=>"experiments", :action=>"temp5"
  map.experiment6 'experiment6', :controller=>"experiments", :action=>"temp6"
  
  
  map.about "about", :controller=>"home", :action=>"about"
  
  map.official "official", :controller=>"observations", :action=>"official"
  map.local "local", :controller=>"observations", :action=>"local"
  

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
