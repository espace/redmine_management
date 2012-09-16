class ManagementController < ApplicationController
  
  before_filter :find_project, :authorize, :only => :index
  
  def index
    chart = ChartCalculations.new(@project);
    @x_axis=chart.x_axis
    @iteration_velocity = chart.iteration_velocity
    @iteration_urls = chart.iteration_urls
    @iteration_names = chart.iteration_names
    
    #--------------Scope--------------------------
    @all_points,@all_points_dbd = chart.all_story_points
    @dev_points,@dev_points_dbd = chart.dev_complete_points
    @qc_points,@qc_points_dbd = chart.qc_complete_points
    @closed_points,@closed_points_dbd = chart.closed_points 
    
    #--------------Effort-------------------------
    @work_done,@work_done_dbd = chart.points_for_work_done
    @estimates,@estimates_dbd = chart.points_for_estimate_change
    @initial_estimate = chart.initial_estimate
    @average_velocity = chart.average_velocity
  end
  
  private
  
  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
  
end
