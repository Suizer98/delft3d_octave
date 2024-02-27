function [varargout] = sobekre_io_series(cmd,varargin)

% Function: reads or writes a SOBEK Time series file
% Arguments in   cmd      : 'read' for reading 'write' for writing
%                filename : name of the file to read from, or write to
%                struct   : for writing only, containg fields Times and
%                           Values
%           out  struct   : for reading only, containg fields Times and
%                           Values
filename  = varargin{1};
switch cmd

    %% Read the file
    case ('read')
        
        SERIES.Times  = [];
        SERIES.Values = [];

        %% Specify format for datenum
        format = 'yyyymmdd  HHMMSS';

        %% open file
        fid = fopen(filename);

        %% read the series
        i_time = 0;
        line   = fgetl(fid);
        while ischar(line)
            i_time               = i_time + 1;
            result               = sscanf(line,'"%d/%d/%d;%d:%d:%d"%f');
            SERIES.Times (i_time) = datenum ([num2str(result(1),'%4.4i') num2str(result(2),'%2.2i') num2str(result(3),'%2.2i') '  ' ...
                                             num2str(result(4),'%2.2i') num2str(result(5),'%2.2i') num2str(result(6),'%2.2i') ], format);
            SERIES.Values(i_time) = result(7);
            line           = fgetl(fid);
        end

        %% Close the file
        fclose(fid);

        varargout = {SERIES};
    %% Write the file
    case ('write')
        SERIES   = varargin{2};
        fid      = fopen(filename,'w+');
        for i_time = 1: length(SERIES.Times)
            fprintf(fid,'%s %12.6f \n',datestr(SERIES.Times(i_time),'"yyyy/mm/dd;HH:MM:SS"'),SERIES.Values(i_time));
        end
        fclose(fid);
end
        

        