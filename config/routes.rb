#custom routes for this plugin
if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
   match 'projects/:project_id/management' , :controller => "management", :action => 'index', :method => :get , :as => :management
  end
else
 ActionController::Routing::Routes.draw do |map|
  #http://redmine.espace.com.eg/projects/red-track/issues
  map.management 'projects/:project_id/management', :controller => "management", :action => 'index', :method => :get
 end
end
