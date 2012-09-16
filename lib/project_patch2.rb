require_dependency 'project'
module ProjectPatch
  def self.included(base)
    base.send(:extend,ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    
    def stories
      Issue.find(:all,:conditions=>{:project_id => id, 
                 :tracker_id=>[Tracker.find_by_name("story").id,Tracker.find_by_name("feature").id]},
                 :order=>"created_on")
    end
    
  end
end