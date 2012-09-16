require_dependency 'issue'
module IssuePatch
  def self.included(base)
    base.send(:extend,ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      has_many :status_updates
      after_save :create_status_update
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    
    OPEN_STATUSES = ['New','Assigned','Feedback','Reopened','Postponed']
    DEV_COMPLETE_STATUSES=['Resolved','Closed','Ready for testing','Verified',
      'Delivered','Closed and Accepted','Under testing']
    TESTING_COMPLETE_STATUSES=['Closed','Verified','Delivered','Closed and Accepted']
    CLOSED_STATUSES=['Closed','Closed and Accepted']
    
    def open?
      Issue::OPEN_STATUSES.include? status.name
    end
    
    def dev_complete?
      Issue::DEV_COMPLETE_STATUSES.
      include? status.name
    end
    
    def testing_complete?
      Issue::TESTING_COMPLETE_STATUSES.
      include? status.name
    end
    
    def create_status_update
      if self.changed? && self.changes['status_id'] && !@duplicate2
        StatusUpdate.create(:issue_id=>self.id, 
                            :old_status_id =>self.changes['status_id'][0], 
                            :new_status_id =>self.changes['status_id'][1])
        @duplicate2 = true
      end
    end
    
  end
end