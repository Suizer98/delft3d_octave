function [output] = KML_track(lat,lon,z,time,data,heading,varargin)
% KML_TRACK subsidiary of KMLtrack
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: KML_track.m 10842 2014-06-12 12:50:54Z scheel $
% $Date: 2014-06-12 20:50:54 +0800 (Thu, 12 Jun 2014) $
% $Author: scheel $
% $Revision: 10842 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_track.m $
% $Keywords: $

% if  ( odd(nargin) & ~isstruct(varargin{2})) | ...
%     (~odd(nargin) &  isstruct(varargin{2}));
%    z       = varargin{1};
%    nextarg = 2;
% else
%    z       = 'clampToGround';
%    nextarg = 1;
% end
%
%% keyword,value

OPT.styleName    = [];
OPT.visibility   = 1;
OPT.extrude      = [];
OPT.name         = 'track';
OPT.extendedData = '';
OPT.tessellate   = [];
OPT.schemaName   = [];
OPT.model        = '';
OPT.dateStrStyle = 'yyyy-mm-ddTHH:MM:SS';

OPT = setproperty(OPT,varargin{:});

if nargin==0
    output = OPT;
    return
end

if nargin==0
    output = OPT;
    return
end

if isempty(OPT.styleName)
    warning('property ''stylename'' required');
end

%%

if all(isnan(z(:)))
    output = '';
    return
end

%% preprocess visibility
if  ~OPT.visibility
    visibility = '<visibility>0</visibility>\n';
else
    visibility = '';
end
%% preprocess extrude
if  OPT.extrude
    extrude = '<extrude>1</extrude>\n';
else
    extrude = '<extrude>0</extrude>\n';
end
%% preprocess tessellate
if  OPT.tessellate
    tessellate = '<tessellate>1</tessellate>\n';
else
    tessellate = '';
end
%% preprocess model
if  ~isempty(OPT.model)
    model = sprintf([...
        '<Model>\n'...
        '  <altitudeMode>clampToGround</altitudeMode>\n'...
        '  <Link>\n'...
        '    <href>%s</href>\n'...
        '  </Link>\n'...
        '</Model>\n'],...
        OPT.model);
else
    model = '';
end


%% preprocess extendedData
if  isempty(OPT.extendedData)
    extendedData = '';
else
    extendedData = ['<ExtendedData>' OPT.extendedData '</ExtendedData>'];
end

%% preproces altitude mode
if strcmpi(z,'clampToGround')
    altitudeMode = sprintf('<altitudeMode>clampToGround</altitudeMode>\n');
    z = zeros(size(lon));
else
    altitudeMode =  '<altitudeMode>absolute</altitudeMode>\n';
end

%% put all coordinates in one vector
coordinates  = [lon(:)'; lat(:)'; z(:)'];

%% split vector at nan's
notnanindex  = find(~any(isnan(coordinates),1));
if isempty(notnanindex)
    pieces = [1 size(coordinates,2)];
else
    pieces = [notnanindex([true ~(notnanindex(2:end)-notnanindex(1:end-1)==1)])'...
        notnanindex([~(notnanindex(2:end)-notnanindex(1:end-1)==1) true])'];
end

track = '';
for ii = 1:size(pieces,1)
    nn = pieces(ii,1) :   pieces(ii,2);
    %% timeString
    timeString = [repmat('<when>',size(time(nn))),datestr(time(nn),OPT.dateStrStyle),repmat(['</when>' char(10)],size(time(nn)))]';
    
    %% coordinateString
    coordinateString  = sprintf('<gx:coord>%3.8f %3.8f %3.3f </gx:coord>\n',coordinates(:,(nn)));
    
    % heading
    %heading, tilt, and roll
    if ~isempty(heading)
        %     angles = [heading zeros(length(heading),2)]';
        angles = [heading(nn) zeros(length(heading(nn)),2)]';
        angleString  = sprintf('<gx:angles>%0.1f %0.1f %0.1f </gx:angles>\n',angles);
    else
        angleString = '';
    end
    
    %% dataString
    if ~isempty(data)
        dataString = sprintf([...
            '   <ExtendedData>\n'...
            '     <SchemaData schemaUrl="#%s">\n'],...
            OPT.schemaName);
        
        for jj=1:length(data)
            % determine data type:
            
            nEl = numel(nn);
            if iscell(data(jj).value)
                values = [repmat('         <gx:value>',nEl,1)    char(reshape(data(jj).value(nn),nEl,1)) repmat(['</gx:value>' char(10)],nEl,1)];
            else
                values = [repmat('         <gx:value>',nEl,1) num2str(reshape(data(jj).value(nn),nEl,1)) repmat(['</gx:value>' char(10)],nEl,1)];
            end
            
            dataString = [dataString sprintf([...
                '       <gx:SimpleArrayData name="%s">\n'... data(ii).id
                '%s'...                                    values
                '       </gx:SimpleArrayData>\n'],...
                data(jj).id,values')];
        end
        dataString = [dataString sprintf([...
            '     </SchemaData>\n'...
            '   </ExtendedData>\n'])];
    else
        dataString = '';
    end
    %% generate output
    track = [track sprintf([...
        '<gx:Track>\n'...
        '%s'...                         % extrude
        '%s'...                         % altitudeMode
        '%s'...                         % model
        '%s\n'...                       % timeString
        '%s\n'...                       % coordinateString
        '%s\n'...                       % angleString
        '%s\n'...                       % dataString
        '</gx:Track>\n'],...
        extrude,altitudeMode,model,timeString,coordinateString,angleString,dataString)];
end

%% generate output
output = sprintf([...
    '<Placemark>\n'...
    '<name>%s</name>\n'...,         % OPT.name
    '<styleUrl>#%s</styleUrl>\n'...,% OPT.styleName
    '%s\n'...                       % extendedData
    '<gx:MultiTrack>\n'...
    '%s\n'...                       % dataString
    '</gx:MultiTrack>\n'...
    '</Placemark>\n'],...
    OPT.name,OPT.styleName,extendedData,track);

%% EOF
