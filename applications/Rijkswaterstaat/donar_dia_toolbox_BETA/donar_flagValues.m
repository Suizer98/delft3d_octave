function  data = donar_flagValues(thefield,data)
%donar_flagValues  flag donar values for unrealistic values
%
%  data = donar_flagValues(thefield,data)
%
%See also: 

%% Flag strange values. 
% Code 1: Not in mask
% Code 2: Unfeasible value
% Code 3: Negative depth
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Flag values out of the model domain: Code 1 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    theindices = inmask(data(:,1),data(:,2),'lonlat');
    numcol = size(data,2) + 1;
    data(~theindices,numcol) = 1; 
    clear theindices

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Flag "unfeasible" variable values: Code 2 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch lower(thefield)
        case{'zuurstof'}
            % 0 < zuurstof
            theindices = data(:,6) < 0;
            data(theindices,numcol) = data(theindices,numcol)*10+2;
        case{'fluorescentie'}
            % 0 < fluorescentie < 100
            theindices = (data(:,6) > 100 | data(:,6) < 0);
            data(theindices,numcol) = data(theindices,numcol)*10+2;
        case{'zuurgraad'}
            % 7 < pH < 9 
            theindices = (data(:,6) > 14 | data(:,6) < 0);
            data(theindices,numcol) = data(theindices,numcol)*10+2;
        case{'saliniteit'}
            % 0 < saliniteit < 36
            theindices = (data(:,6) > 36 | data(:,6) < 0);
            data(theindices,numcol) = data(theindices,numcol)*10+2;
        case{'temperatuur'}
            % -40 < temperatuur < 40
            theindices = (data(:,6) > 40 | data(:,6) < -40);
            data(theindices,numcol) = data(theindices,numcol)*10+2;
        case{'troebelheid'}
            % 0 < troebelheid < 500
            theindices = (data(:,6) > 500 | data(:,6) < 0);
            data(theindices,numcol) = data(theindices,numcol)*10+2;
        case{'geleidendheid'}

    end
    clear theindices
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Flag values with negative depths: Code 3 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    theindices = data(:,3) < 0;
    data(theindices,numcol) = data(theindices,numcol)*10 + 3; % 
    clear theindices
    

end