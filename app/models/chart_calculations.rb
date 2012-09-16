class ChartCalculations
  
  def initialize project
    @project = project
    @stories = project.stories
    first_issue = Issue.find(:first,:conditions=>{:project_id=>@project.id},:order=>"created_on")
    if first_iteration= Version.find(:first,:conditions=>{:project_id=>@project.id},:order=>"created_on")
      @start_date = first_iteration.created_on.to_date
      if first_issue && first_issue.created_on.to_date < @start_date
        @start_date = first_issue.created_on.to_date
      end
    else
      @start_date = first_issue ? first_issue.created_on.to_date : Time.now.to_date
    end
    get_x_axis_points
    @end_date = @days && @days[-1] ? @start_date +(@days[-1] - 1):Time.now.to_date
    stories_scope_burnup_chart
    @estimate_updates = EstimateUpdate.find(:all,:conditions=>{:issue_id=> @project.issues.collect{|s|s.id}},:order=>"created_at")
    @time_entries = TimeEntry.find(:all,:conditions=>{:project_id=> @project.id},:order=>"spent_on")
    effort_burnup_chart
  end
  
  attr_reader :project
  attr_reader :stories
  
  #--------------Effort chart specific----------------------------------------
  def points_for_work_done
    js_points @wd_arr
  end
  
  def points_for_estimate_change
    js_points @estimates_arr
  end
  
  def initial_estimate
    
    return @estimates_arr[0][1] if @estimates_arr && @estimates_arr[0]
    return 0
    
  end
  
  #--------------Scope burn-up chart----------------------------------------------
  
  def dev_complete_points
    js_points @dev_complete_arr
  end
  
  def qc_complete_points
    js_points @qc_complete_arr
  end
  
  def all_story_points
    js_points @all_story_arr
  end
  
  def closed_points
    js_points @closed_arr
  end
  
  def js_points array
    js_points_dbd="["
    previous_entry = array[0]
    array.each_with_index do |entry,index|
      if entry[0] > Time.now.to_date
        i = (Time.now.to_date-@start_date).to_i + 1
        js_points_dbd << (index==0 ?  "[#{i},#{previous_entry[1]}]":",[#{i},#{previous_entry[1]}]")
        break;
      elsif entry[0] == Time.now.to_date
        i = (Time.now.to_date-@start_date).to_i + 1
        js_points_dbd << (index==0 ?  "[#{i},#{previous_entry[1]}]":",[#{i},#{previous_entry[1]}]")
        i = (entry[0]-@start_date).to_i + 1
        js_points_dbd << (index==0 ?  "[#{i},#{entry[1]}]":",[#{i},#{entry[1]}]")
        break;
      end
      i = (entry[0]-@start_date).to_i + 1
      js_points_dbd << (index==0 ?  "[#{i},#{entry[1]}]":",[#{i},#{entry[1]}]")
      previous_entry = entry
    end
    js_points_dbd << "]"
    
    js_points_it = "["
    @dates.each_with_index do |date,index|
      if date > Time.now.to_date
        break;
      end
      array.each do |entry|
        if date <= entry[0]
          js_points_it << (index==0 ?  "[#{@days[index]},#{entry[1]}]":",[#{@days[index]},#{entry[1]}]")
          break;
        end          
      end
    end
    js_points_it << "]"
    return js_points_it,js_points_dbd
  end
  
  # ---------------General-----------------------------------
  #TODO convert to join query
  def iteration_velocity
    today = Time.now.to_date
    due_date = nil
    @dates.each do |d| 
      if today >= d
        due_date = d
      else
        break;
      end
    end
    return 0 if !due_date
    latest_iteration = Version.find(:first,
                        :conditions=> ["project_id = ? AND effective_date = ?",@project.id, due_date])
    return 0 if !latest_iteration
    issues = latest_iteration.fixed_issues
    memo=0;
    issues.inject(0) do |memo,issue|
      if issue && memo && issue.estimated_hours
        memo+= issue.estimated_hours 
      end
    end
    return memo
  end
  
  def average_velocity
    sum= Issue.sum('estimated_hours', :conditions=>{:project_id=>"#{@project.id}"});
    result = @project.versions.length>0 ? (((sum/(@project.versions.length)) * 10**3).round.to_f / 10**3):0 
    return result
  end
  
  def x_axis
    i=-1;
    strings=@dates.collect do |d|
      i+=1;"[#{@days[i]},'#{d.strftime('%d/%m')}']" #'
    end
    return "[#{strings.join(',')}]"; 
  end
  
  def iteration_names
    result ="[\""; 
    result << @iteration_names.join("\",\"") 
    result << "\"]" 
  end
  
  
  def iteration_urls
    result ="["
    @ids.each_with_index {|id,index| result << (index==0 ?  "'/versions/show/#{id}'":",'/versions/show/#{id}'") }
    result << "]"
  end
  
  #---------Effort burn-up chart----------------------------'
  
  def effort_burnup_chart
    
    total = 0
    iss_id = []
    index = 0
    temp_arr=[]
    @estimates_arr = []
    
    
    @estimate_updates.each_with_index do |update,ind|
      change = update.new_estimated_hours
      change -= update.old_estimated_hours if update.old_estimated_hours 
      temp_arr << [update.created_at.to_date,change]
      first=true;
      
      if update.old_estimated_hours && !(iss_id.include? update.issue_id)
       (0...ind).each do |num|
          if @estimate_updates[num].issue_id == update.issue_id
            first=false;
          end
        end
        if first
          temp_arr << [update.issue_created_on,update.old_estimated_hours]
        end
      end
      
      iss_id << update.issue_id
      
    end
    
    @project.issues.each do |iss|
      if (!(iss_id.include? iss.id)) && iss.estimated_hours
        temp_arr << [iss.created_on.to_date,iss.estimated_hours]
      end
    end
    
    temp_arr.sort!(){|a,b| a[0]<=>b[0]}
    
    total =0;
    index =0;
    temp_arr.each do |entry|
      break if entry[0]> @end_date
      if(@estimates_arr[index])
        if(@estimates_arr[index][0]==entry[0])
          @estimates_arr[index][1]+=entry[1]
          total+=entry[1]
        else
          if (entry[0]-@estimates_arr[index][0])>1
            index+=1
            @estimates_arr[index] = [entry[0]-1,@estimates_arr[index-1][1]]
          end
          index+=1;total+=entry[1]
          @estimates_arr[index] = [entry[0],total]
        end
      else
        @estimates_arr[index]=[entry[0],entry[1]]
        total+=entry[1]
      end
    end
    
    @estimates_arr = pad_array(@estimates_arr , total)
    #-----------------------------------Estimates array done
    
    total = 0
    index = 0
    @wd_arr = []
    
    @time_entries.each do |te|
      if(@wd_arr[index])
        if(@wd_arr[index][0]==te.spent_on && te.spent_on <= @end_date)
          total += te.hours if te.hours
          @wd_arr[index][1]=total;
          
        elsif (@wd_arr[index][0] < te.spent_on && te.spent_on <= @end_date)
          if((te.spent_on - @wd_arr[index][0]).to_i) > 1
            index+=1;@wd_arr[index]=[te.spent_on - 1,total]
          end
          total += te.hours if te.hours
          index+=1;
          @wd_arr[index]=[te.spent_on,total]
        end
        
      else
        total += te.hours
        @wd_arr[index]=[te.spent_on,total]
      end
    end
    
    @wd_arr = pad_array(@wd_arr, total)
  end
  
  #-----------General--------------------------------------
  def get_x_axis_points
    ids = []
    @iteration_names = []
    dates = project.versions.collect do |v|
      if v.effective_date
        ids << v.id
        @iteration_names << v.name
        @start_date = v.effective_date if v.effective_date < @start_date
        v.effective_date
      end
    end
    dates.each_with_index { |date, idx|
      if !date
        ids.delete_at(idx)
        @iteration_names.delete_at(idx)
      end
    }
    dates.delete(nil)
    dates =  dates + [@start_date]
    dates.reverse!;ids.reverse!;@iteration_names.reverse!
    days = dates.collect do |element|
     (element - @start_date).to_i + 1
    end
    @dates=dates;@days=days;@ids=ids
  end
  
  #story scope chart------------------------------------------
  
  def stories_scope_burnup_chart
    dev_complete = 0; qc_complete=0; closed = 0;
    dev_index = 0; qc_index = 0;closed_index=0;
    @all_story_arr = [];
    @dev_complete_arr = [];
    @qc_complete_arr = [];
    @closed_arr = [];
    
    acc = 0
    index = 0;
    
    #-------------------All stories-------------------------------------
    stories.each do |story|
      if(@all_story_arr[index] )
        if(@all_story_arr[index][0]==story.created_on.to_date && story.created_on.to_date <= @end_date)
          @all_story_arr[index][1]+=1;
          acc+=1;
        elsif (@all_story_arr[index][0] < story.created_on.to_date && story.created_on.to_date <= @end_date)
          if((story.created_on.to_date - @all_story_arr[index][0]).to_i) > 1
            index+=1;@all_story_arr[index]=[story.created_on.to_date - 1,acc]
          end
          index+=1;acc+=1;
          @all_story_arr[index]=[story.created_on.to_date,acc]
        end
      else
        acc+=1;
        @all_story_arr[index]=[story.created_on.to_date,acc]
      end
    end
    
    @all_story_arr = pad_array(@all_story_arr, acc)
    #-------------------All stories done-------------------------------------
    
    #-------------------dev and QC-------------------------------------
    StatusUpdate.find(:all,:conditions=>{:issue_id=> stories.collect{|s|s.id}},:order=>"created_at").each do |update|
      if update.became_open?
        if update.was_dev_complete?
          @dev_complete_arr,dev_complete,dev_index = add_entry(update,@dev_complete_arr,dev_complete,dev_index,-1,false)
        end  
        if update.was_qc_complete?
          @qc_complete_arr,qc_complete,qc_index = add_entry(update,@qc_complete_arr,qc_complete,qc_index,-1,false)
        end
        if update.was_closed?
          @closed_arr,closed,closed_index = add_entry(update,@closed_arr,closed,closed_index,-1,false)
        end
      else
        if update.became_dev_complete?
          @dev_complete_arr,dev_complete,dev_index = add_entry(update,@dev_complete_arr,dev_complete,dev_index)
        end
        if update.became_qc_complete?
          @qc_complete_arr,qc_complete,qc_index = add_entry(update,@qc_complete_arr,qc_complete,qc_index)
        end
        if update.became_closed?
          @closed_arr,closed,closed_index = add_entry(update,@closed_arr,closed,closed_index)
        end
      end
      
    end
    
    @closed_arr = pad_array(@closed_arr, closed)
    @qc_complete_arr = pad_array(@qc_complete_arr, qc_complete)
    @dev_complete_arr = pad_array(@dev_complete_arr, dev_complete)
    #-------------------dev and QC done-------------------------------------
  end
  
  def add_entry(update,array,counter,index,add=1,other = true)
    if array[index]
      if array[index][0] == update.created_at.to_date && update.created_at.to_date <= @end_date
        array[index][1]+=add
        counter+=add;
      elsif array[index][0] < update.created_at.to_date && update.created_at.to_date <= @end_date
        if((update.created_at.to_date - array[index][0]).to_i) > 1
          index+=1;array[index]=[update.created_at.to_date - 1,counter]
        end
        counter+=1;index+=1;
        array[index] = [update.created_at.to_date,counter]
      end
    elsif other
      counter+=1
      array[index] = [update.created_at.to_date,counter]
    end
    return array,counter,index
  end
  
  def pad_array (array,final_value)
    if array.empty? || (array[0][0] > @start_date)
      if array[0] && (array[0][0] - @start_date).to_i > 1
        array = [[array[0][0] - 1,0]] + array
      end
      array = [[@start_date,0]] + array
    end
    
    if (array[-1][0] < @end_date)
      array << [@end_date,final_value]
    end
    
    return array
  end
  
end
