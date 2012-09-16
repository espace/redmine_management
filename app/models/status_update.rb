class StatusUpdate < ActiveRecord::Base
  
  belongs_to :old_status, :class_name=>'IssueStatus'
  belongs_to :new_status, :class_name=>'IssueStatus'
  
  belongs_to :issue
  validates_presence_of :issue_id
  
  
  def became_dev_complete?
    Issue::DEV_COMPLETE_STATUSES.include?(new_status_name) &&
     (!old_status || !Issue::DEV_COMPLETE_STATUSES.include?(old_status_name))
  end
  
  def became_qc_complete?
    Issue::TESTING_COMPLETE_STATUSES.include?(new_status_name) &&
     (!old_status || !Issue::TESTING_COMPLETE_STATUSES.include?(old_status_name))
  end
  
  def became_closed?
    Issue::CLOSED_STATUSES.include?(new_status_name) &&
     (!old_status || !Issue::CLOSED_STATUSES.include?(old_status_name))
  end
  
  def became_open?
    Issue::OPEN_STATUSES.include?(new_status_name) &&
     (!old_status || !Issue::OPEN_STATUSES.include?(old_status_name))
  end
  
  def was_dev_complete?
    old_status && Issue::DEV_COMPLETE_STATUSES.include?(old_status_name)
  end
  
  def was_qc_complete?
    old_status && Issue::TESTING_COMPLETE_STATUSES.include?(old_status_name)
  end
  
  def was_closed?
    old_status && Issue::CLOSED_STATUSES.include?(old_status_name)
  end
  
  def old_status_name
    old_status.name
  end
  
  def new_status_name
    new_status.name
  end
  
end
