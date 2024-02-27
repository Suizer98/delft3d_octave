function d = UCIT_SelectTransectsUS(datatype,transectsSoundingID,begintransect,endtransect)
%UCIT_SELECTTRANSECTSUS  select a number of alongshore US Lidar transects to plot
%
%   d = UCIT_SelectTransectsUS(datatype,transectsSoundingID,begintransect,endtransect)
%
% Example:
%
% D = UCIT_SelectTransectsUS('Lidar Data US','2002',9,1200)
%
% See also: plotAlongshore

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

[check]=UCIT_checkPopups(1, 1);
if check == 0
    return
end

mapWhandle = findobj('tag','mapWindow');

if ~isempty(mapWhandle) & strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),'Lidar Data US')
    [d] = UCIT_getMetaData(1);
elseif isempty(mapWhandle)
    disp('Make overview figure first')
    return
end

if nargin==0
    figure(mapWhandle)
   [xv,yv] = polydraw;polygon=[xv' yv'];
    test = d.contour;
    id1  = inpolygon(test(:,1),test(:,3),polygon(:,1),polygon(:,2));
    id2  = inpolygon(test(:,2),test(:,4),polygon(:,1),polygon(:,2));
    id  =  (id1|id2);
    
    e=find(id>0);NHandle.beginTransect=findobj('tag','beginTransect');NHandle.endTransect=findobj('tag','endTransect');
    
    set(NHandle.beginTransect,'value',e(1));set(NHandle.endTransect,'value',e(end));
else
    a=find(str2double(vertcat(d.transectID))==str2double(begintransect));
    b=find(str2double(vertcat(d.transectID))==str2double(endtransect));
    id=[a:b];
end

fh=findobj('tag','mapWindow');


% Find all transects and colour them blue
figure(fh);
rayH=findobj(gca,'type','line','LineStyle','-');
set(rayH, 'color','r');
dpTs=get(rayH,'tag');

for i = 1:length(dpTs)-1
    if ~strcmp(dpTs{i},'')
    tagtext = dpTs{i};
    underscores = strfind(tagtext,'_');
    id_text(i) = str2double(tagtext([underscores(2)+1:underscores(3)-1]));
    end
end

[C,IA,IB] = intersect(str2double(d.transectID(id)),id_text');

try
        set(rayH(IB),'color','b');
end
