function output=getINIValue(filename,keyword);
%GETINIVALUE   Gets a value from a specified INI-file
%
% INI-File looks like:
%  DataPath=p:\planstudies\etc\data 
%  BackgroundColor=1 0 1
%  etc., so KEYWORD=VALUE
%
% NB1: Keyword is case-INsensitive
% NB2: everything on the same line behind the '=' is the OUTPUT
% NB3: OUTPUT is always a string
% 
% syntax:
%   output=getINIValue('myProgram.ini','KEYWORD');
%
%   See also setinivalue

% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.0, February 2004 (Version 1.0, February 2004)
% By:           <R. Morelissen (email: robin.morelissen@wldelft.nl>
% --------------------------------------------------------------------------

if ~exist(filename,'file')
    errordlg('INI-file not found','INI-file not found');
    return
end

fid=fopen(filename);
output=[];

while ~feof(fid)
    line=fgetl(fid);
    if strncmp(lower(keyword),lower(line),length(keyword))
        [dum,output]=strtok(line,'=');
        output=output(2:end);
        fclose(fid);
        return
    end
end

fclose(fid);

%If it hasn't been found, check the common inifile (UCIT-specific)
%It is called McToolbox_common.ini
if isempty(output)
    fid=fopen('McToolbox_common.ini');
    output=[];
    
    while ~feof(fid)
        line=fgetl(fid);
        if strncmp(lower(keyword),lower(line),length(keyword))
            [dum,output]=strtok(line,'=');
            output=output(2:end);
            fclose(fid);
            return
        end
    end
    
    fclose(fid);
end
