function selection=UCIT_selectGridPoly(command,polygon)
%UCIT_SELECTGRIDPOLY  Selects rays using a polygon, makes them yellow and
%returns their handles
%
%
%   See also getDataInPolygon 

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
%   --------------------------------------------------------------------% ------------------------------------------------------------------------------------

dataRoot = [fileparts(which('ucit')) filesep 'UCIT_Actions\DataGrids\'];

mapW=findobj('tag','gridOverview');

if isempty(mapW)
    errordlg(['Display grid outlines first!',' No map found']);
    return
end

figure(mapW);
% Reset current object (set the current object to be the figure itself)
set(mapW,'CurrentObject',mapW);

%Find all rays
rayH=findobj(gca,'type','patch','LineStyle','-');
if isempty(rayH)
    errordlg('No rays found!','');
    return
else
    dpTs=strvcat(get(rayH,'tag'));
    for ii=1:size(dpTs,1);
        if strfind(dpTs(ii,:),'KB')
            res(ii)=1;
        end
    end
    rayH=rayH(find(res==1));
end

if nargin~=2
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

elseif (polygon ~= ' ')
    uo=polygon(:,1);
    vo=polygon(:,2);
end
% connect
if(exist('hp'))
    uo = [uo(:);uo(1)];
    vo = [vo(:);vo(1)];
    %    set(hp,'tag',guiGetROI);
end

hold off

% STEP 1: FIND ALL Kaartbladen INPOLYGON
%Find all rays with at least one point in the polygon
tx=get(rayH,'xdata');
ty=get(rayH,'ydata');
x=[];
y=[];
for i=1:size(tx,1)
    a=cat(1,tx{i}');
    b=cat(1,ty{i}');
    x=[x;a];
    y=[y;b];
end
polyKBx=x;
polyKBy=y;

refinement=10;
x3=[];y3=[];
for row = 1:size(x,1)
    x2=[];y2=[];
    for col = 1:size(x,2)-1
        x2=[x2 linspace(x(row,col),x(row,col+1),refinement)];
        y2=[y2 linspace(y(row,col),y(row,col+1),refinement)];
    end
    x3=[x3;x2];
    y3=[y3;y2];
end
x=x3;
y=y3;
% hier met linspace het aantal punten waaruit een kaartblad bestaat
% vergroten: nieuwe x en y

% selection=rayH(inpolygon(x(:,1),y(:,1),uo,vo));
selection=[];
% STEP 1: FIND ALL Kaartbladen INPOLYGON
for i=1:size(x,2)
    try
        selection=[selection ;rayH(inpolygon(x(:,i),y(:,i),uo,vo))];
    end
end
for i = 1:size(polyKBx,1)
    try
        if ~isempty(rayH(inpolygon(uo,vo,polyKBx(i,:)',polyKBy(i,:)')))
            selection=[selection ;rayH(i)];
%             disp('check')
        end
        %         selection=[selection ;rayH(inpolygon(uo,vo,polyKBx(i,:)',polyKBy(i,:)'))];
    end
end
selection = unique(selection);
switch command
    case 'new'
        %First make all rayH's red
        set(rayH,'edgecolor',[1 0 0],'linewidth',1);
        %Then yellow up the selection
        set(selection,'edgecolor',[1 1 0]);

    case 'extend'
        %Just yellow up the selection
        set(selection,'edgecolor',[1 1 0]);

    case 'unselect'
        %Just make selection red
        set(selection,'edgecolor',[1 0 0]);
end

%Check whether additionally New (Delft3D) template grid is to be built
try
    [popupValue4,info5]=UCIT_DC_getInfoFromPopup('GrActions');
    if strcmp(info5.focus,'BuildDelft3dModel')
%        filnam = [dataRoot 'commonactions' filesep 'showTemplateGrids' filesep 'u0v0.mat'];
        filnam = [getenv('temp') filesep 'u0v0.mat'];
        polygon=[uo vo];
        save(filnam,'polygon');
    end
end
try
    delete(hp); %Delete polygon
end
try
    selection=unique(selection);
end



