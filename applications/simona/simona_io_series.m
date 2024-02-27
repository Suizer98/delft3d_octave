function [varargout] = simona_io_series(cmd,varargin)
% Function: Reads or writes SIMONA Series
%           Reading has to be implemented yet
%           Argument 1: cmd = 'read' or 'write'
%           for writing
%           Argument 2: filename of the resulting series file
%           Argument 3: structure with the fields Time  (in minutes), and,
%                                                 Value
%
%           Optional <keyword,value> pairs
%           Series_type, 'regular' or 'irregular', if not specified the function tries 
%                                                  to figure out what type of series this is
%           Comments   , cell array written as written as header lines, 
%                        you can specify here what is, for instance, the reference date of the series 

eps      = 1e-6;
filename = varargin{1};

switch cmd

    %% Read the series
    case('read')

        % To implement yet

    %% Write the series
    case('write')

        %% Open file (Appand so the header must be written by the calling function
        fid    = fopen(filename,'w+');

        %% Remainder of the argument
        SERIES          = varargin{2};
        OPT.Series_type = '';
        OPT.Comments    = [];
        OPT             = setproperty(OPT,varargin{3:end});
        
        %% Write Comments to the output file (for instance refrence date of the SERIES)
        for i_com = 1: length(OPT.Comments)
            fprintf(fid,'%s \n',OPT.Comments{i_com});
        end
        
        %% No type specified, try to figure out whether it is a regular of irregular series
        if isempty(OPT.Series_type)
            intval = SERIES.Times(2:end) - SERIES.Times(1:end-1);
            irregular = find (abs(intval(2:end) - intval(1:end-1)) > eps);
            if ~isempty(irregular)
                OPT.Series_type = 'irregular';
            else
                OPT.Series_type = 'regular';
            end
        end

        %% Regular or irregular series
        string = ['SERIES = ''' OPT.Series_type ''''];
        fprintf(fid,'%s \n',string);
        switch (OPT.Series_type)
            
            %% Regular Series
            case ('regular')
                fprintf(fid,'FRAME = %12.3f %12.3f %12.3f \n',SERIES.Times(1),SERIES.Times(2) - SERIES.Times(1),SERIES.Times(end));
                fprintf(fid,[repmat('%12.6f ',1,8) '\n'],SERIES.Values(:));
                
            %% Irregular series
            case ('irregular')
                for i_time = 1: length(SERIES.Times);
                    i_day  = floor((SERIES.Times(i_time) + eps)/1440.);
                    i_hour = floor((SERIES.Times(i_time) - i_day*1440. + eps)/60.);
                    i_min  = floor(SERIES.Times(i_time) - i_day*1440. - i_hour*60. + eps);
                    if (size(SERIES.Values,2) ==2)
                        fprintf(fid,'TIME_AND_VALUE %3.3i  %2.2i:%2.2i  %12.6f %12.6f \n',i_day,i_hour,i_min,SERIES.Values(i_time,:));
                    else
                        fprintf(fid,'TIME_AND_VALUE %3.3i  %2.2i:%2.2i  %12.6f \n',i_day,i_hour,i_min,SERIES.Values(i_time));
                    end
                end
        end
        fclose (fid);
end

