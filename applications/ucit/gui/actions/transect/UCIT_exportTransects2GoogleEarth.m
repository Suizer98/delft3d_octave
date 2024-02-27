function UCIT_exportTransects2GoogleEarth
%UCIT_EXPORTTRANSECTS2GOOGLEEARTH   export a transect to Google Earth
%
% input: select transects in UCIT GUI
%   
% output: temporary kml file
%   
%   See also KMLline, KMLtext

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   -------------------------------------------------------------------- 

[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make an overview plot (plotTransectOverview)','No map found');
    return
end
%% select transects to plot
fh = figure(findobj('tag','mapWindow'));set(fh,'visible','off');
[xv,yv] = polydraw;polygon=[xv' yv'];

%% get metadata (either from the console or the database)
d = UCIT_getMetaData(1);

%% filter transects using inpolygon
test = d.contour;
id1  = inpolygon(test(:,1),test(:,3),polygon(:,1),polygon(:,2));
id2  = inpolygon(test(:,2),test(:,4),polygon(:,1),polygon(:,2));
id   = (id1|id2);

%% Find all transects and colour them blue
figure(fh);
rayH=findobj(gca,'type','line','LineStyle','-');
set(rayH,'color','r');
dpTs=get(rayH,'tag');

for i = 1:length(dpTs)
    if ~strcmp(dpTs{i},'')
        tagtext     = dpTs{i};
        underscores = strfind(tagtext,'_');
        id_text(i)  = str2double(tagtext([underscores(2)+1:underscores(3)-1]));
    end
end

[C,IA,IB] = intersect(str2double(d.transectID(id)),id_text');
try
set(rayH(IB),'color','b');
end

%% Extract xy coordinates from contour lines
contours = d.contour(id,:);
transectids = d.transectID(id,:);
transectcontours = repmat(nan,3*length(contours),2);
transectcontours(1:3:3*length(contours),1) = contours(1:length(contours),1);
transectcontours(2:3:3*length(contours),1) = contours(1:length(contours),2);
transectcontours(1:3:3*length(contours),2) = contours(1:length(contours),3);
transectcontours(2:3:3*length(contours),2) = contours(1:length(contours),4);

%% Convert UTM to World Coordinates

if strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),'Jarkus Data')
    [lon,lat] = convertCoordinates(transectcontours(:,1),transectcontours(:,2),'CS1.name','Amersfoort / RD New','CS2.code',4326);
else
    [lon,lat] = convertCoordinates(transectcontours(:,1),transectcontours(:,2),'CS1.code',32610,'CS2.code',4326);
end

%% Make kml file
filename = [getenv('TEMP'),'transects'];
counter = 1;
for j = 1 : 3: length(transectcontours)-1
    KMLline([lat(j) lat(j+1)], [lon(j) lon(j+1)],'fileName',[filename '_' num2str(j) '_1.kml'],'fillColor',jet(5),'fillAlpha',[1 0 1 0 1],'lineColor',[1 1 1],'lineWidth',[1],'lineAlpha',[0.5]);
    KMLline([lat(j) lat(j  )]',[lon(j) lon(j)]',[0 35]','fileName',[filename '_' num2str(j) '_2.kml'],'lineColor',[1 1 1]) ;
    KMLtext( lat(j),lon(j  ),[num2str(str2double(transectids{counter}))],40,'fileName',[filename '_' num2str(j)  '_3.kml']);
    KMLmerge_files('fileName',[transectids{counter} '.kml'],'sourceFiles',{[filename '_' num2str(j) '_1.kml'] [filename '_' num2str(j) '_2.kml'] [filename '_' num2str(j) '_3.kml']});
    delete([filename '_*.kml']);
    sourceFiles{counter}=[transectids{counter} '.kml'];
    counter = counter + 1;
end
KMLmerge_files('fileName',[filename '.kml'],'sourceFiles',sourceFiles);
delete(['*.kml']);

%% Run kml file in Google Earth
eval(['!', filename '.kml']);

