#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  #http://redmine.espace.com.eg/projects/red-track/issues
  map.management 'projects/:project_id/management', :controller => "management", :action => 'index', :method => :get
end