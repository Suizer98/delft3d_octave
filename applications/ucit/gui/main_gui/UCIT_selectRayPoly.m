function selection = UCIT_selectRayPoly(command)
%UCIT_SELECTRAYPOLY   this routine selects transects using a polygon, makes them yellow and returns their handles
%
% Selects transects using a polygon, makes them yellow and returns their handles
%              
% input:       
%    command =  
%     'new' : select new transects
%     'extend' : sdd transects to the selection
%     'unselect' : remove transects from the selection
%
% output:       
%    selection = variable containing info about the selected transects 
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, January 2006)
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id: UCIT_selectRayPoly.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make a JARKUS Overview!','No map found');
    return
end

figure(mapW);
% Reset current object (set the current object to be the figure itself)
set(mapW,'CurrentObject',mapW);

%Find all rays
rayH=findobj(gca,'type','line','LineStyle','-');
dpTs=strvcat(get(rayH,'tag'));
for ii=1:size(dpTs,1);
    if strfind(dpTs(ii,:),'_')
        res(ii)=1;
    end
end
rayH=rayH(find(res==1));

if isempty(rayH)
    errordlg('No rays found!','');
    return
end

%Draw polygon (from Argus IBM)
% pick some boundaries
uo = []; vo = []; button = [];

[uo,vo,lfrt] = ginput(1);
button = lfrt;
hold on; hp = plot(uo,vo,'+m');

while lfrt == 1
    [u,v,lfrt] = ginput(1);
    uo=[uo;u]; vo=[vo;v]; button=[button;lfrt];      
    delete(hp);
    hp = plot(uo,vo,'m');
end

% Bail out at ESCAPE = ascii character 27
if lfrt == 27
    delete(hp)
    if exist('bp')
        set(bp,'linestyle','-')
    end   
    return
end

% connect
if(exist('hp'))
    uo = [uo(:);uo(1)];
    vo = [vo(:);vo(1)];
    %    set(hp,'tag',guiGetROI);   
end
hold off

%Find all rays with at least one point in the polygon
tx=get(rayH,'xdata');
ty=get(rayH,'ydata');
x=cat(1,tx{:});
y=cat(1,ty{:});
selection=rayH(inpolygon(x(:,1),y(:,1),uo,vo));
try
    selection=[selection ;rayH(inpolygon(x(:,2),y(:,2),uo,vo))];
end
selection=unique(selection);
delete(hp); %Delete poly

switch command
    
    case 'new'
        %First make all rayH's red
        set(rayH,'color',[1 0 0]);
        
        %Then yellow up the selection
        set(selection,'color',[1 1 0]);
        
    case 'extend'
        
        %Just yellow up the selection
        set(selection,'color',[1 1 0]);
        
    case 'unselect'
        
        %Just make selection red
        set(selection,'color',[1 0 0]);
        
end







