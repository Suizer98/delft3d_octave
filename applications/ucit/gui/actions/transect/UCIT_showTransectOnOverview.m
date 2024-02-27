function UCIT_showTransectOnOverview()
%UCIT_SHOWTRANSECTSONOVERVIEW shows transect of listbox in user window on overview figure
%
%   
%
%   Syntax:
%   
%
%   Input: get from GUI
%   
%
%   Output: none
%   
%
%   Example
%  
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
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

[d] = UCIT_getMetaData(1);

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make an overview plot (plotTransectOverview)','No map found');
    return
end

figure(mapW);
% Reset current object (set the current object to be the figure itself)
set(mapW,'CurrentObject',mapW);

%Find all rays
rayH = findobj(gca,'type','line','LineStyle','-');
arrowindicator = findobj('tag','arrowindicator');
delete(arrowindicator);

if isempty(rayH)
    errordlg('No rays found!','');
    return
end

[DataType,info1]=UCIT_getInfoFromPopup('TransectsDatatype');
[Area,info2]=UCIT_getInfoFromPopup('TransectsArea');
[TransectID,info3]=UCIT_getInfoFromPopup('TransectsTransectID');
[SoundingID,info4]=UCIT_getInfoFromPopup('TransectsSoundingID');


if strcmp(DataType,'Jarkus Data')
    id_match = cellfun(@(x) (strcmp(x, UCIT_getInfoFromPopup('TransectsArea'))==1), {cellstr(d.area)}, 'UniformOutput',false);
    transectIDs = str2double(d.transectID)- unique(round(str2double(d.transectID(id_match{1}))/1000000))*1000000; % convert back from uniqu id
    id = find (transectIDs  == str2num(TransectID) & strcmp(Area,d.area));
    TransectID = char(d.transectID(id));
    id = find (str2double(d.transectID)  == str2num(TransectID) & strcmp(Area,d.area));
else
    id = find (str2double(d.transectID)  == str2num(TransectID));
end
curRay = findobj(rayH,'tag',[DataType '_' Area '_' TransectID '_' datestr(d.year(1) + datenum(1970,1,1))]);

if isempty(curRay)
    fh = findobj('tag','mapWindow');figure(fh);
    curRay = line([d.contour((id),1) d.contour(id,2)],[d.contour(id,3) d.contour(id,4)],'color','g','tag',[DataType '_' Area '_' TransectID '_' datestr(d.year(1) + datenum(1970,1,1))],'linewidth',2);
end
set(rayH,'color',[1 0 0],'linewidth',1.0);
set(curRay,'color',[0 1 0],'linewidth',3);
refresh;

th2 = text(d.contour(id,1),d.contour(id,3),100,['\leftarrow'], 'horizontalalignment','left','fontsize',20,'fontweight','bold','color','b','tag','arrowindicator');
