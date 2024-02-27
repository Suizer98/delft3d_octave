function varargout = read_KMLtransects(Transectname,varargin)
%READ_KMLTRANSECTS desription
%
%   readGE_transects(Transectname,<keyword,value>)
%
% This function read the transects for the vaklodingen, 
% defined manually on GoogleEarth, lauched by
% GE_transects_multitile_years.m
% 
% This function calls "myplaces.kml" to find the transects of interest.
%
%See also: snctools
 
%%

% read myplaces.kml from the C:\ drive

userid = getenv('USERID');
url_GE = ['C:\Documents and Settings\', userid, '\Application Data\Google\GoogleEarth\myplaces.kml'];

fid_GE = fopen(url_GE,'rt');
frewind(fid_GE);

% single transect, chosen by the user
ntrans = 1;

% cycle to read the coordinates
for i = 1:ntrans
frewind(fid_GE);
fprintf('reading coordinates: % d / %d \n', i, ntrans);

while ~feof(fid_GE)
    dum=fgetl(fid_GE);
    
    if strfind(dum, ['<name>',Transectname,'</name>'])
        while isempty(strfind(dum, '<coordinates>'))
            dum = fgetl(fid_GE);
        end
        strGE_coord = fgetl(fid_GE);
        output(:,i) = sscanf(strGE_coord,'%f, %f, %f');
    end
end
end

fclose(fid_GE);
varargout = {output};

end
%% EOF