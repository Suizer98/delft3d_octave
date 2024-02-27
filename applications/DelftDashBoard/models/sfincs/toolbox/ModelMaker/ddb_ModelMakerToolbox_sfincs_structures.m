function ddb_ModelMakerToolbox_sfincs_structures(varargin)
%ddb_ModelMakerToolbox_sfincs_structures  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_DrawingToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_DrawingToolbox
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_drawingToolbox_export.m 12926 2016-10-15 07:47:58Z ormondt $
% $Date: 2016-10-15 09:47:58 +0200 (Sat, 15 Oct 2016) $
% $Author: ormondt $
% $Revision: 12926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/drawing/ddb_drawingToolbox_export.m $
% $Keywords: $

%%

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    ddb_plotsfincs('update','active',1,'visible',1);
    handles=getHandles;
    h=handles.model.sfincs.structurespline.handle;
    if ~isempty(h)
        set(h,'visible','on');
    end
%    ddb_sfincs_plot_structure_points(handles, 'update', 'vis',1);    
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'drawstructurespline'}
            draw_structure_spline;
        case{'deletestructurespline'}
            delete_structure_spline;
        case{'loadstructurespline'}
            load_structure_spline;
        case{'savestructurespline'}
            save_structure_spline;
        case{'createstructurepoints'}
            create_structure_points;
        case{'removestructurepoints'}
            remove_structure_points;
        case{'loadstructurepoints'}
            load_structure_points;
        case{'savestructurepoints'}
            save_structure_points;
            
    end
    
end

%%
function draw_structure_spline

setInstructions({'','Click on map to draw structure spline','Use right-click to end structure'});

ddb_zoomOff;

gui_polyline('draw','Tag','sfincsstructurespline','Marker','o','createcallback',@create_structure_spline,'changecallback',@change_structure_spline, ...
    'type','polyline','closed',0);

%%
function delete_structure_spline

handles=getHandles;

h=handles.model.sfincs.structurespline.handle;
if ~isempty(h)
    try
        delete(h);
    end
end
h=findobj(gcf,'Tag','sfincsstructurespline');
if ~isempty(h)
    delete(h);
end

handles.model.sfincs.structurespline.handle=[];
handles.model.sfincs.structurespline.x=[];
handles.model.sfincs.structurespline.y=[];
handles.model.sfincs.structurespline.changed=0;
handles.model.sfincs.structurespline.length=0;

setHandles(handles);

%%
function create_structure_spline(h,x,y,nr)

delete_structure_spline;

h=gui_polyline('plot','x',x,'y',y,'Tag','sfincsstructurespline','Marker','o','changecallback',@change_structure_spline, ...
    'type','polyline','closed',0);


handles=getHandles;
handles.model.sfincs.structurespline.handle=h;
handles.model.sfincs.structurespline.x=x;
handles.model.sfincs.structurespline.y=y;
handles.model.sfincs.structurespline.length=length(x);
handles.model.sfincs.structurespline.changed=1;
setHandles(handles);

[xsnap,ysnap]=gridsnapper(handles.model.sfincs.domain.xg,handles.model.sfincs.domain.yg,x,y,handles.model.sfincs.domain(ad).input.dx/10);

psnap=plot(xsnap,ysnap);
set(psnap,'Color',[0 0 0],'LineWidth',1.5);
set(psnap,'tag','sfincsstructuresnap');
set(psnap,'HitTest','off');

uistack(h,'top');

gui_updateActiveTab;


%%
function change_structure_spline(h,x,y,nr)

handles=getHandles;

handles.model.sfincs.structurespline.handle=h;
handles.model.sfincs.structurespline.x=x;
handles.model.sfincs.structurespline.y=y;
handles.model.sfincs.structurespline.length=length(x);
handles.model.sfincs.structurespline.changed=1;

hsnap=findobj(gcf,'tag','sfincsstructuresnap');
if ~isempty(hsnap)
    delete(hsnap);
end

[xsnap,ysnap]=gridsnapper(handles.model.sfincs.domain.xg,handles.model.sfincs.domain.yg,x,y,handles.model.sfincs.domain(ad).input.dx/10);

psnap=plot(xsnap,ysnap);
set(psnap,'Color',[0 0 0],'LineWidth',1.5);
set(psnap,'tag','sfincsstructuresnap');
set(psnap,'HitTest','off');

uistack(h,'top');

setHandles(handles);


%%
function create_structure_points

handles=getHandles;

xs=handles.model.sfincs.structurespline.x;
ys=handles.model.sfincs.structurespline.y;

[xp,yp]=spline2d(xs,ys,handles.model.sfincs.structurespline.flowdx);

merge=0;
if handles.model.sfincs.domain(ad).structure.length>0
    % Boundary points already exist
    ButtonName = questdlg('Merge with existing boundary points ?', ...
        'Merge Points', ...
        'Cancel', 'No', 'Yes', 'Yes');
    switch ButtonName,
        case 'Cancel',
            return;
        case 'No',
            merge=0;
        case 'Yes',
            merge=1;
    end
end

% Now get the bathy and orientation data
cs=handles.screenParameters.coordinateSystem;
datasets(1).name=handles.screenParameters.backgroundBathymetry;
s=sfincs_get_structure_data(xp,yp,xs,ys,cs,datasets,1);



% for ip=1:length(xp)
% xx=[xp(ip)+200*cos(s.orientation(ip)) xp(ip)-200*cos(s.orientation(ip))];
% yy=[yp(ip)+200*sin(s.orientation(ip)) yp(ip)-200*sin(s.orientation(ip))];
% hh(ip)=plot(xx,yy,'k:');
% end
% 
% shite=1
% delete(hh);

if merge
    handles.model.sfincs.domain(ad).structure.x=[handles.model.sfincs.domain(ad).structure.x xp];
    handles.model.sfincs.domain(ad).structure.y=[handles.model.sfincs.domain(ad).structure.y yp];
    for ip=1:length(xp)
        handles.model.sfincs.domain(ad).structure.orientation=[handles.model.sfincs.domain(ad).structure.orientation s.orientation(ip)];
        handles.model.sfincs.domain(ad).structure.dean=[handles.model.sfincs.domain(ad).structure.dean s.dean(ip)];
        handles.model.sfincs.domain(ad).structure.slope=[handles.model.sfincs.domain(ad).structure.slope s.slope(ip)];
        handles.model.sfincs.domain(ad).structure.reef_width=[handles.model.sfincs.domain(ad).structure.reef_width s.reef_width(ip)];
        handles.model.sfincs.domain(ad).structure.reef_height=[handles.model.sfincs.domain(ad).structure.reef_height s.reef_height(ip)];
        handles.model.sfincs.domain(ad).structure.type=[handles.model.sfincs.domain(ad).structure.type s.type(ip)];
    end
else
    handles.model.sfincs.domain(ad).structure.orientation=[];
    handles.model.sfincs.domain(ad).structure.dean=[];
    handles.model.sfincs.domain(ad).structure.slope=[];
    handles.model.sfincs.domain(ad).structure.type=[];
        handles.model.sfincs.domain(ad).structure.reef_width=[];
        handles.model.sfincs.domain(ad).structure.reef_height=[];
    handles.model.sfincs.domain(ad).structure.x=xp;
    handles.model.sfincs.domain(ad).structure.y=yp;
    for ip=1:length(xp)
        handles.model.sfincs.domain(ad).structure.orientation(ip)=s.orientation(ip);
        handles.model.sfincs.domain(ad).structure.dean(ip)=s.dean(ip);
        handles.model.sfincs.domain(ad).structure.slope(ip)=s.slope(ip);
        handles.model.sfincs.domain(ad).structure.type(ip)=s.type(ip);
        handles.model.sfincs.domain(ad).structure.reef_width(ip)=s.reef_width(ip);
        handles.model.sfincs.domain(ad).structure.reef_height(ip)=s.reef_height(ip);
    end
end

handles.model.sfincs.domain(ad).structure.length=length(handles.model.sfincs.domain(ad).structure.x);

handles.model.sfincs.domain(ad).input.cstfile='sfincs.cst';

% fname=handles.model.sfincs.domain(ad).input.cstfile;

sfincs_write_structure(handles.model.sfincs.domain(ad).input.cstfile,handles.model.sfincs.domain(ad).structure);

% fid=fopen(fname,'wt');
% for ip=1:handles.model.sfincs.domain(ad).structure.length
%     x=handles.model.sfincs.domain(ad).structure.x(ip);
%     y=handles.model.sfincs.domain(ad).structure.y(ip);
%     itype=handles.model.sfincs.domain(ad).structure.type(ip);
% %     phi=mod(90-handles.model.sfincs.domain(ad).structure.orientation(ip)*180/pi,360);
%     phi=handles.model.sfincs.domain(ad).structure.orientation(ip);
%     slope=handles.model.sfincs.domain(ad).structure.slope(ip);
%     dean=handles.model.sfincs.domain(ad).structure.dean(ip);
%     fprintf(fid,'%11.1f %11.1f %2i %6.1f %10.7f %10.7f\n',x,y,itype,phi,slope,dean);
% end
% fclose(fid);

handles.model.sfincs.domain(ad).structure.active_point=1;

setHandles(handles);

delete_structure_points;

plot_structure_points;

%%
function remove_structure_points

handles=getHandles;

handles.model.sfincs.domain(ad).input.cstfile='';

handles.model.sfincs.domain(ad).structure.x=[];
handles.model.sfincs.domain(ad).structure.y=[];
handles.model.sfincs.domain(ad).structure.length=0;

setHandles(handles);

delete_structure_points;

% %%
% function load_structure_points
% 
% remove_structure_points;
% 
% handles=getHandles;
% 
% filename=handles.model.sfincs.domain(ad).input.cstfile;
% xy=load(filename);
% xy=xy';
% xp=xy(1,:);
% yp=xy(2,:);
% 
% handles.model.sfincs.domain(ad).flowboundarypoints.x=xp;
% handles.model.sfincs.domain(ad).flowboundarypoints.y=yp;
% handles.model.sfincs.domain(ad).flowboundarypoints.length=length(xp);
% 
% handles.model.sfincs.domain(ad).flowboundarypoints.time=[handles.model.sfincs.domain(ad).input.tref;handles.model.sfincs.domain(ad).input.tstop];
% handles.model.sfincs.domain(ad).flowboundarypoints.zs=zeros(2,length(xp));
% 
% setHandles(handles);
% 
% plot_flow_boundary_points;

%%
function save_structure_points

handles=getHandles;

filename=handles.model.sfincs.domain(ad).input.cstfile;

fid=fopen(filename,'wt');
for ip=1:handles.model.sfincs.domain(ad).structure.length
    fprintf(fid,'%10.1f %10.1f\n',handles.model.sfincs.domain(ad).structure.x(ip),handles.model.sfincs.domain(ad).structure.y(ip));
end
fclose(fid);

setHandles(handles);


%%
function delete_structure_points

handles=getHandles;

handles=ddb_sfincs_plot_structure_points(handles,'delete','domain',ad);

setHandles(handles);

%%
function plot_structure_points

handles=getHandles;

handles=ddb_sfincs_plot_structure_points(handles,'plot','domain',ad);

setHandles(handles);
