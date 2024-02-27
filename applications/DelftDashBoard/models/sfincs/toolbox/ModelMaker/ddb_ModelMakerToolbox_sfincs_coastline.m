function ddb_ModelMakerToolbox_sfincs_coastline(varargin)
%ddb_DrawingToolbox  One line description goes here.
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
    h=handles.model.sfincs.coastspline.handle;
    if ~isempty(h)
        set(h,'visible','on');
    end
    ddb_sfincs_plot_coastline_points(handles, 'update', 'vis',1);    
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'drawcoastspline'}
            draw_coastline_spline;
        case{'deletecoastspline'}
            delete_coastline_spline;
        case{'loadcoastspline'}
            load_coastline_spline;
        case{'savecoastspline'}
            save_coastline_spline;
        case{'createcoastlinepoints'}
            create_coastline_points;
        case{'removecoastlinepoints'}
            remove_coastline_points;
        case{'loadcoastlinepoints'}
            load_coastline_points;
        case{'savecoastlinepoints'}
            save_coastline_points;
            
    end
    
end

%%
function draw_coastline_spline

setInstructions({'','Click on map to draw boundary spline','Use right-click to end coast line'});

ddb_zoomOff;

gui_polyline('draw','Tag','sfincscoastspline','Marker','o','createcallback',@create_coastline_spline,'changecallback',@change_coastline_spline, ...
    'type','spline','closed',0);

%%
function delete_coastline_spline

handles=getHandles;

h=handles.model.sfincs.coastspline.handle;
if ~isempty(h)
    try
        delete(h);
    end
end
h=findobj(gcf,'Tag','sfincscoastspline');
if ~isempty(h)
    delete(h);
end

handles.model.sfincs.coastspline.handle=[];
handles.model.sfincs.coastspline.x=[];
handles.model.sfincs.coastspline.y=[];
handles.model.sfincs.coastspline.changed=0;
handles.model.sfincs.coastspline.length=0;

setHandles(handles);

%%
function create_coastline_spline(h,x,y,nr)

delete_coastline_spline;

h=gui_polyline('plot','x',x,'y',y,'Tag','sfincscoastspline','Marker','o','changecallback',@change_coastline_spline, ...
    'type','spline','closed',0);

handles=getHandles;
handles.model.sfincs.coastspline.handle=h;
handles.model.sfincs.coastspline.x=x;
handles.model.sfincs.coastspline.y=y;
handles.model.sfincs.coastspline.length=length(x);
handles.model.sfincs.coastspline.changed=1;
setHandles(handles);

gui_updateActiveTab;


%%
function change_coastline_spline(h,x,y,nr)

handles=getHandles;

handles.model.sfincs.coastspline.handle=h;
handles.model.sfincs.coastspline.x=x;
handles.model.sfincs.coastspline.y=y;
handles.model.sfincs.coastspline.length=length(x);
handles.model.sfincs.coastspline.changed=1;

setHandles(handles);


%%
function create_coastline_points

handles=getHandles;

xs=handles.model.sfincs.coastspline.x;
ys=handles.model.sfincs.coastspline.y;

[xp,yp]=spline2d(xs,ys,handles.model.sfincs.coastspline.flowdx);

merge=0;
if handles.model.sfincs.domain(ad).coastline.length>0
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
s=sfincs_get_coastline_data(xp,yp,xs,ys,cs,datasets,1);



% for ip=1:length(xp)
% xx=[xp(ip)+200*cos(s.orientation(ip)) xp(ip)-200*cos(s.orientation(ip))];
% yy=[yp(ip)+200*sin(s.orientation(ip)) yp(ip)-200*sin(s.orientation(ip))];
% hh(ip)=plot(xx,yy,'k:');
% end
% 
% shite=1
% delete(hh);

if merge
    handles.model.sfincs.domain(ad).coastline.x=[handles.model.sfincs.domain(ad).coastline.x xp];
    handles.model.sfincs.domain(ad).coastline.y=[handles.model.sfincs.domain(ad).coastline.y yp];
    for ip=1:length(xp)
        handles.model.sfincs.domain(ad).coastline.orientation=[handles.model.sfincs.domain(ad).coastline.orientation s.orientation(ip)];
        handles.model.sfincs.domain(ad).coastline.dean=[handles.model.sfincs.domain(ad).coastline.dean s.dean(ip)];
        handles.model.sfincs.domain(ad).coastline.slope=[handles.model.sfincs.domain(ad).coastline.slope s.slope(ip)];
        handles.model.sfincs.domain(ad).coastline.reef_width=[handles.model.sfincs.domain(ad).coastline.reef_width s.reef_width(ip)];
        handles.model.sfincs.domain(ad).coastline.reef_height=[handles.model.sfincs.domain(ad).coastline.reef_height s.reef_height(ip)];
        handles.model.sfincs.domain(ad).coastline.type=[handles.model.sfincs.domain(ad).coastline.type s.type(ip)];
    end
else
    handles.model.sfincs.domain(ad).coastline.orientation=[];
    handles.model.sfincs.domain(ad).coastline.dean=[];
    handles.model.sfincs.domain(ad).coastline.slope=[];
    handles.model.sfincs.domain(ad).coastline.type=[];
        handles.model.sfincs.domain(ad).coastline.reef_width=[];
        handles.model.sfincs.domain(ad).coastline.reef_height=[];
    handles.model.sfincs.domain(ad).coastline.x=xp;
    handles.model.sfincs.domain(ad).coastline.y=yp;
    for ip=1:length(xp)
        handles.model.sfincs.domain(ad).coastline.orientation(ip)=s.orientation(ip);
        handles.model.sfincs.domain(ad).coastline.dean(ip)=s.dean(ip);
        handles.model.sfincs.domain(ad).coastline.slope(ip)=s.slope(ip);
        handles.model.sfincs.domain(ad).coastline.type(ip)=s.type(ip);
        handles.model.sfincs.domain(ad).coastline.reef_width(ip)=s.reef_width(ip);
        handles.model.sfincs.domain(ad).coastline.reef_height(ip)=s.reef_height(ip);
    end
end

handles.model.sfincs.domain(ad).coastline.length=length(handles.model.sfincs.domain(ad).coastline.x);

handles.model.sfincs.domain(ad).input.cstfile='sfincs.cst';

% fname=handles.model.sfincs.domain(ad).input.cstfile;

sfincs_write_coastline(handles.model.sfincs.domain(ad).input.cstfile,handles.model.sfincs.domain(ad).coastline);

% fid=fopen(fname,'wt');
% for ip=1:handles.model.sfincs.domain(ad).coastline.length
%     x=handles.model.sfincs.domain(ad).coastline.x(ip);
%     y=handles.model.sfincs.domain(ad).coastline.y(ip);
%     itype=handles.model.sfincs.domain(ad).coastline.type(ip);
% %     phi=mod(90-handles.model.sfincs.domain(ad).coastline.orientation(ip)*180/pi,360);
%     phi=handles.model.sfincs.domain(ad).coastline.orientation(ip);
%     slope=handles.model.sfincs.domain(ad).coastline.slope(ip);
%     dean=handles.model.sfincs.domain(ad).coastline.dean(ip);
%     fprintf(fid,'%11.1f %11.1f %2i %6.1f %10.7f %10.7f\n',x,y,itype,phi,slope,dean);
% end
% fclose(fid);

handles.model.sfincs.domain(ad).coastline.active_point=1;

setHandles(handles);

delete_coastline_points;

plot_coastline_points;

%%
function remove_coastline_points

handles=getHandles;

handles.model.sfincs.domain(ad).input.cstfile='';

handles.model.sfincs.domain(ad).coastline.x=[];
handles.model.sfincs.domain(ad).coastline.y=[];
handles.model.sfincs.domain(ad).coastline.length=0;

setHandles(handles);

delete_coastline_points;

% %%
% function load_coastline_points
% 
% remove_coastline_points;
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
function save_coastline_points

handles=getHandles;

filename=handles.model.sfincs.domain(ad).input.cstfile;

fid=fopen(filename,'wt');
for ip=1:handles.model.sfincs.domain(ad).coastline.length
    fprintf(fid,'%10.1f %10.1f\n',handles.model.sfincs.domain(ad).coastline.x(ip),handles.model.sfincs.domain(ad).coastline.y(ip));
end
fclose(fid);

setHandles(handles);


%%
function delete_coastline_points

handles=getHandles;

handles=ddb_sfincs_plot_coastline_points(handles,'delete','domain',ad);

setHandles(handles);

%%
function plot_coastline_points

handles=getHandles;

handles=ddb_sfincs_plot_coastline_points(handles,'plot','domain',ad);

setHandles(handles);
