require 'redmine'
#require 'dispatcher'

Rails.configuration.to_prepare do
  require_dependency 'project'
  require 'project_patch2'
  Project.send( :include, ProjectPatch)

  require_dependency 'issue'
  require 'issue_patch2'
  Project.send( :include, IssuePatch)
end


Redmine::Plugin.register :redmine_management do
  name 'Redmine Management plugin'
  author 'Yaser'
  description 'This is a management tab with some charts and information'
  version '0.0.1'
  permission :view_management_tab, :management => :index
  menu :project_menu, :management, { :controller => 'management', :action => 'index' }, 
  :caption => 'Management',  :param => :project_id, :last=>true
end

