function draw_scope_burnup_chart(all_points, all_points_dbd, dev_points, dev_points_dbd, qc_points, qc_points_dbd, closed_points, closed_points_dbd, x_axis, iteration_urls, iteration_names, register, minx, miny, maxx, maxy){
    var limit = x_axis[x_axis.length - 1][0]
    var ymax = 0
    
    var effective_xaxis = x_axis
    
    var all_points_color = "red"
    var dev_color = "magenta"
    var qc_color = "green"
    var closed_color = "blue"
    var closedw = 1
    var qcw = 2
    var devw = 3
    var allw = 1
    
    for (i = 0; i < all_points_dbd.length; i++) {
        if (all_points_dbd[i][1] > ymax) {
            ymax = all_points_dbd[i][1]
        }
    }
    
    
    for (i = 0; i < x_axis.length; i++) {
        if (i < all_points.length && all_points[i][1] > ymax) {
            ymax = all_points[i][1]
        }
        if (i < qc_points.length && qc_points[i][1] > ymax) {
            ymax = qc_points[i][1]
        }
        if (i < dev_points.length && dev_points[i][1] > ymax) {
            ymax = dev_points[i][1]
        }
    }
    
    if (ymax == 0) {
        ymax = 5;
    }
    
    //ymax is now determined
    
    if (minx == -1 && miny == -1 && maxy == -1 && maxx == -1) {
        minx = (-0.02 * limit + 1);
        miny = -0.04 * ymax;
        maxx = 1.02 * limit;
        maxy = 1.04 * ymax;
        $('scope_reset_view').hide();
    }
    else {
        k = 0;
        minimum_index = 0
        found = false;
        for (k = 0; k < x_axis.length; k++) {
            if (!found && x_axis[k][0] > minx) {
                minimum_index = Math.max(k - 1, 0);
                found = true;
            }
            if (x_axis[k][0] > maxx) {
                break;
            }
        }
        effective_xaxis = x_axis.slice(minimum_index, k);
        
        $('scope_reset_view').show();
        
    }
    
    var devformatter = function(obj){
        j = 0
        for (j = 0; j < dev_points.length; j++) {
            ele = dev_points[j];
            if (ele[0] == obj.x && ele[1] == obj.y) {
                if (!j == 0) {
                    return iteration_names[j - 1] + ": " + obj.y + " dev-complete stories";
                }
                else {
                    return "Start of project";
                }
            }
        }
    }
    
    var testformatter = function(obj){
        j = 0
        for (j = 0; j < qc_points.length; j++) {
            ele = qc_points[j];
            if (ele[0] == obj.x && ele[1] == obj.y) {
                if (!j == 0) {
                    return iteration_names[j - 1] + ": " + obj.y + " QC-complete stories";
                }
                else {
                    return "Start of project";
                }
            }
        }
    }
    
    var closedformatter = function(obj){
        j = 0
        for (j = 0; j < closed_points.length; j++) {
            ele = closed_points[j];
            if (ele[0] == obj.x && ele[1] == obj.y) {
                if (!j == 0) {
                    return iteration_names[j - 1] + ": " + obj.y + " closed stories";
                }
                else {
                    return "Start of project";
                }
            }
        }
    }
    
    var allformatter = function(obj){
        j = 0
        for (j = 0; j < all_points.length; j++) {
            ele = all_points[j];
            if (ele[0] == obj.x && ele[1] == obj.y) {
                if (!j == 0) {
                    return iteration_names[j - 1] + ": " + obj.y + " total stories";
                }
                else {
                    return "Start of project";
                }
            }
        }
    }
	
    var f = Flotr.draw($('burnup_chart'), [{ // => All issues
        data: all_points_dbd,
        color: all_points_color,
        lines: {
            show: true,
            lineWidth: allw
        },
        points: {
            show: false
        }
    }, { // => All issues
        data: all_points,
        color: all_points_color,
        label: "Total Stories",
        lines: {
            show: false
        },
        points: {
            show: true
        },
        mouse: {
            track: true, // => true to track mouse
            trackFormatter: allformatter
        }
    }, { // => Dev complete dbd
        data: dev_points_dbd,
        color: dev_color,
        lines: {
            show: true,
            lineWidth: devw
        },
        points: {
            show: false
        }
    }, { // => development closed
        data: dev_points,
        color: dev_color,
        label: "Dev-Completed",
        lines: {
            show: false
        },
        points: {
            show: true
        },
        mouse: {
            track: true, // => true to track mouse
            trackFormatter: devformatter
        }
    }, { // => qc complete dbd
        data: qc_points_dbd,
        color: qc_color,
        lines: {
            show: true,
            lineWidth: qcw
        },
        points: {
            show: false
        }
    }, { // => QC closed
        data: qc_points,
        color: qc_color,
        label: "QC Completed",
        lines: {
            show: false
        },
        points: {
            show: true
        },
        mouse: {
            track: true,
            trackFormatter: testformatter
        }
    }, { // => closed dbd
        data: closed_points_dbd,
        color: closed_color,
        lines: {
            show: true,
            lineWidth: closedw
        },
        points: {
            show: false
        }
    }, { // => closed
        data: closed_points,
        color: closed_color,
        label: "Closed",
        lines: {
            show: false
        },
        points: {
            show: true
        },
        mouse: {
            track: true,
            trackFormatter: closedformatter
        }
    }], {
        title: "<div class='chart_title'>Stories scope burn-up chart</div>",
        xaxis: {
            title: 'Iterations (Date)',
            ticks: effective_xaxis,
            min: minx,
            max: maxx
        },
        yaxis: {
            title: '<div class=\'vertical_text\'>Stories</div>',
            //tickFormatter: yformatter,
            min: miny,
            max: maxy,
			tickDecimals:0
            //max: 1.04 * initial_estimate
        },
        mouse: {
            position: 'se', // => position to show the track value box
            relative: true,
            color: '#ff3f19', // => color for the tracking points, null to hide points
            trackDecimals: 0, // => number of decimals for track values
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
        $('burnup_chart').observe('flotr:click', function(event){
            // Retrieve where the user clicked.
            var position = event.memo[0];
            
            for (i = 1; i < x_axis.length; i++) {
                if (i < all_points.length && within(all_points[i][0], all_points[i][1], position.x, position.y)) {
                    window.location = iteration_urls[i - 1];
                    return;
                }
                if (i < qc_points.length && within(qc_points[i][0], qc_points[i][1], position.x, position.y)) {
                    window.location = iteration_urls[i - 1];
                    return;
                }
                if (i < dev_points.length && within(dev_points[i][0], dev_points[i][1], position.x, position.y)) {
                    window.location = iteration_urls[i - 1];
                    return;
                }
                if (i < closed_points.length && within(closed_points[i][0], closed_points[i][1], position.x, position.y)) {
                    window.location = iteration_urls[i - 1];
                    return;
                }
            }
            
        });
        
        function within(x, y, x1, y1){
            if (Math.abs(x - x1) < (limit / 50) && Math.abs(y - y1) < (ymax / 50)) {
                return true;
            }
            else {
                return false;
            }
        }
    }
    
}
