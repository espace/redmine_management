function draw_effort_burnup_chart(work_done, work_done_dbd, estimate_points, estimates_dbd, initial_estimate, method, velocity, x_axis, register, iteration_urls, iteration_names, minx, miny, maxx, maxy){
	
    var iestimate = []
    var limit = x_axis[x_axis.length - 1][0]
    var baseline_data = []
    
    effective_xaxis = x_axis
    
    
    var ymax = 0
    for (i = 0; i < work_done_dbd.length; i++) {
        if (work_done_dbd[i][1] > ymax) {
            ymax = work_done_dbd[i][1]
        }
    }
    for (i = 0; i < estimates_dbd.length; i++) {
        if (estimates_dbd[i][1] > ymax) {
            ymax = estimates_dbd[i][1]
        }
    }
    
    ymax = Math.max(ymax, initial_estimate)
    
    if (ymax < 5) {
        ymax = 5;
    }
    
    
    //ymax is known
    
    if (minx == -1 && miny == -1 && maxy == -1 && maxx == -1) {
        minx = (-0.02 * limit + 1);
        miny = -0.04 * ymax;
        maxx = 1.02 * limit;
        maxy = 1.04 * ymax;
		$('reset_view').hide();
    }else {
        k = 0;
        minimum_index = 0
        found = false;
        for (k = 0; k < x_axis.length; k++) {
            if (!found && x_axis[k][0] > minx) {
                minimum_index = Math.max(k-1,0);
				found=true;
            }
            if (x_axis[k][0] > maxx) {
                break;
            }
        }
		effective_xaxis = x_axis.slice(minimum_index, k);
		$('reset_view').show();
    }
    
    if (method == 'velocity') {
        if (velocity == 0) {
            baseline_data = [[1, 0]];
        }
        else {
            baseline_data = [[1, 0], [limit, (x_axis.length * velocity)]];
        }
    }
    else {
        baseline_data = [[1, 0], [limit, initial_estimate]];
    }
    
    for (var i = 1; i < limit; i += (limit / 150)) 
        iestimate.push([i, initial_estimate]);
    
    var estformatter = function(obj){
        j = 0
        for (j = 0; j < estimate_points.length; j++) {
            ele = estimate_points[j];
            if (ele[0] == obj.x && ele[1] == obj.y) {
                if (!j == 0) {
                    return iteration_names[j - 1] + " :" + obj.y + " hours total estimation";
                }
                else {
                    return "Start of project";
                }
            }
        }
    }
    
    var wdformatter = function(obj){
        j = 0
        for (j = 0; j < work_done.length; j++) {
            ele = work_done[j];
            if (ele[0] == obj.x && ele[1] == obj.y) {
                if (!j == 0) {
                    return iteration_names[j - 1] + " :" + obj.y + " hours spent";
                }
                else {
                    return "Start of project";
                }
            }
        }
    }
    
    var f = Flotr.draw($('effort_burnup_chart'), [{
        data: work_done_dbd,
        color: "blue",
        lines: {
            show: true,
            lineWidth: 1
        },
        points: {
            show: false
        }
    }, {
        data: work_done,
        color: "blue",
        label: "Work done",
        lines: {
            show: false
        },
        points: {
            show: true
        },
        mouse: {
            track: true,
            trackFormatter: wdformatter
        }
    }, {// estimated work done
        data: baseline_data,
        label: "Baseline",
        color: "darkviolet",
        lines: {
            show: true,
            lineWidth: 1
        }
    }, {// Initial estimate line 
        data: iestimate,
        color: "red",
        label: "Original Est.",
        lines: {
            show: false
        },
        points: {
            show: true,
            radius: 0.25, // => point radius (pixels)
            lineWidth: 1, // => line width in pixels
            fill: true, // => true to fill the points with a color, false for (transparent) no fill
            fillColor: '#ffffff',
            fillOpacity: 1
        }
    }, {
        data: estimates_dbd,
        color: "orange",
        lines: {
            show: true,
            lineWidth: 1
        },
        points: {
            show: false
        }
    }, {
        data: estimate_points,
        label: "Current Est.",
        color: "orange",
        lines: {
            show: false
        },
        mouse: {
            track: true,
            trackFormatter: estformatter
        },
        points: {
            show: true
        }
    }], {
        title: "<div class='chart_title'>Effort burn-up chart</div>",
        xaxis: {
            title: 'Iterations (Date)',
            ticks: effective_xaxis,
            //autoscaleMargin: 0.005,
            min: minx, // => part of the series is not displayed.
            max: maxx // => part of the series is not displayed.
        },
        yaxis: {
            title: '<div class=\'vertical_text\'>Effort (hours)</div>',
            min: miny,
            max: maxy
        },
        mouse: {
            position: 'se', // => position to show the track value box
            relative: true,
            color: '#ff3f19', // => color for the tracking points, null to hide points
            trackDecimals: 1, // => number of decimals for track values
            radius: 3, // => radius of the tracking points
            sensibility: 50 // => the smaller this value, the more precise you've to point with the mouse
        },
        legend: {
            position: 'se',
            backgroundColor: "#333399",
            backgroundOpacity: 0.15,
            margin: 15
        },
        grid: {
            backgroundColor: "#FFFFFF",
            labelMargin: 5,
            verticalLines: false,
            horizontalLines: true,
            outlineWidth: 1
        },
        shadowSize: 0,
        selection: {
            mode: 'xy',
            fps: 30
        }
    });
    
    
    
    if (register) {
        var call_back = function change_estimation_method(element){
            if (element.getValue() === 'velocity') {
                baseline = 'velocity'
            }
            else {
                baseline = 'deadline'
            }
            draw_effort_burnup_chart(work_done, work_done_dbd, estimate_points, estimates_dbd, initial_estimate, baseline, velocity, x_axis, false, iteration_urls, iteration_names, -1, -1, -1, -1);
        }
        var observer = new Form.Element.Observer('baseline_method1', 0.5, call_back);
        var observer = new Form.Element.Observer('baseline_method2', 0.5, call_back);
        
        $('effort_burnup_chart').observe('flotr:click', function(event){
            // Retrieve where the user clicked.
            var position = event.memo[0];
            
            for (i = 1; i < x_axis.length; i++) {
                if (i < work_done.length && within(work_done[i][0], work_done[i][1], position.x, position.y)) {
                    window.location = iteration_urls[i - 1];
                    return;
                }
                if (i < estimate_points.length && within(estimate_points[i][0], estimate_points[i][1], position.x, position.y)) {
                    window.location = iteration_urls[i - 1];
                    return;
                }
            }
        });
        
    }
    
    function within(x, y, x1, y1){
        if (Math.abs(x - x1) < (limit / 50) && Math.abs(y - y1) < (ymax / 50)) {
            return true;
        }
        else {
            return false;
        }
    }
    
}
