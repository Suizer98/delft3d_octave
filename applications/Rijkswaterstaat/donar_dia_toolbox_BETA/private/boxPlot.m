function draw_data = boxPlot(theXvalue, data0,thefigure,lineWidth, width)
% boxPlot(data0) - plot box-whiskers diagram, accept multiple columns
% Arguments: data0     -  unsorted data, mxn, m samples, n columns
%            lineWidth -  line thickness in the plot default = 1;
%            width     -  the width of the box, default = 1;
% Returns:	 
% Notes: each column is considered as a single set	
    
%    subplot(thefigure)
        
    if nargin<4,
        lineWidth = 1;
        width = 1;
    elseif nargin<5, 
        width = 1;
    end


    [m n] = size(data0);
    data = sort(data0,1); % ascend
    
    
    q2 = median(data, 1);
    
    if(rem(m,2) == 0)
        upperA = data(    1:m/2,:);
        lowA   = data(m/2+1:end,:);
    else
        upperA = data(1:round(m/2),:);
        lowA   = data(round(m/2):end,:);  
    end;
    
    q1 = median(upperA, 1);
    q3 = median(lowA, 1);

    min_v = data(1,:);
    max_v = data(end,:);
    
    draw_data = [max_v; q3; q2; q1; min_v; m;];
    
    % adjust the width
    drawBox(draw_data, lineWidth, width, thefigure, theXvalue);
return;


function drawBox(draw_data, lineWidth, width, fig_handle, i)

    n = size(draw_data, 2);

    unit = (1-1/(1+n))/(1+9/(width+3));
    
    %figure;    
    %hold on;
        
    v = draw_data;
        
    % draw the min line
    plot([i-unit, i+unit],[v(5), v(5)], 'LineWidth', lineWidth);
    % draw the max line
    plot([i-unit, i+unit],[v(1), v(1)], 'LineWidth', lineWidth);
    % draw middle line
    plot([i-unit, i+unit], [v(3), v(3)], 'LineWidth', lineWidth);
    % draw vertical line
    plot([i, i], [v(5), v(4)], 'LineWidth', lineWidth);
    plot([i, i], [v(2), v(1)], 'LineWidth', lineWidth);
    % draw box
    plot([i-unit, i+unit, i+unit, i-unit, i-unit], [v(2), v(2), v(4), v(4), v(2)], 'LineWidth', lineWidth);
    
return;