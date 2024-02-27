function ddb_ModelMakerToolbox_sfincs_buq(varargin)
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
    
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotModelMaker('activate');
    ddb_plotsfincs('update','active',1,'visible',1);

    h=findobj(gca,'Tag','sfincs_refinement_polygon');
    if ~isempty(h)
        set(h,'Visible','on');
        uistack(h,'top');
    end
    
    handles=getHandles;
    ddb_sfincs_plot_buq_blocks(handles, 'update','domain',ad,'visible',1);
    
    for j=1:10
        dx=handles.toolbox.modelmaker.dX/2^j;
        cs=handles.screenParameters.coordinateSystem.type;
        if strcmpi(cs,'geographic')
            handles.toolbox.modelmaker.sfincs.buq.refinement_level_strings{j}=[num2str(dx,'%0.4f') ' deg'];
        else
            handles.toolbox.modelmaker.sfincs.buq.refinement_level_strings{j}=[num2str(dx,'%0.1f') ' m'];
        end
    end
    setHandles(handles);
    
    gui_updateActiveTab;
%    handles=getHandles;
%    ddb_sfincs_plot_mask(handles, 'update','domain',ad,'visible',1);


else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'select_refinement_polygon'}
            select_refinement_polygon;
        case{'select_refinement_level'}
            select_refinement_level;
        case{'draw_refinement_polygon'}
            draw_refinement_polygon;
        case{'delete_refinement_polygon'}
            delete_refinement_polygon;
        case{'load_refinement_polygon'}
            load_refinement_polygon;
        case{'save_refinement_polygon'}
            save_refinement_polygon;


            
        case{'generate_buq_grid'}
            generate_buq;
    end
end




%%
function select_refinement_polygon
handles=getHandles;
iac=handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon;
ilev=handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).refinement_level;
handles.toolbox.modelmaker.sfincs.buq.active_refinement_level=ilev;
setHandles(handles);
gui_updateActiveTab;

%%
function select_refinement_level
handles=getHandles;
iac=handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).refinement_level=handles.toolbox.modelmaker.sfincs.buq.active_refinement_level;
setHandles(handles);

%%
function draw_refinement_polygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_handle=gui_polyline('draw','tag','sfincs_refinement_polygon','marker','o', ...
    'createcallback',@create_refinement_polygon,'changecallback',@change_refinement_polygon, ...
    'closed',1);

setHandles(handles);

%%
function create_refinement_polygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons=handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons+1;
iac=handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon=iac;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).refinement_level=handles.toolbox.modelmaker.sfincs.buq.active_refinement_level;
setHandles(handles);
gui_updateActiveTab;

%%
function delete_refinement_polygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon;
if handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons>0
    h=handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.buq.refinement_polygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.buq.refinement_polygon,iac);
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names=removeFromCellArray(handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names,iac);

handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons=max(handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons-1,0);
handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon=min(handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon,handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons);

if handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons==0
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon=[];
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons=0;
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names={''};
    handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon=1;
end

setHandles(handles);

%%
function change_refinement_polygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons
    if handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function load_refinement_polygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon=[];
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).x=[];
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).y=[];
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).length=0;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons=0;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names={''};

h=findobj(gca,'Tag','sfincs_refinement_polygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.buq.refinement_polygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincs_refinement_polygon','marker','o', ...
        'changecallback',@changeIncludePolygon);
    handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).handle=h;
end

setHandles(handles);

%%
function save_refinement_polygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_file,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(ip).y(ix)]);
    end
end
fclose(fid);







%%
function generate_buq

handles=getHandles;

id=ad;

x00  = handles.toolbox.modelmaker.xOri;
y00  = handles.toolbox.modelmaker.yOri;
rot  = handles.toolbox.modelmaker.rotation;

dxb  = 15*handles.toolbox.modelmaker.dX;
dyb  = 15*handles.toolbox.modelmaker.dY;
mmax = ceil(handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.dX/dxb);
nmax = ceil(handles.toolbox.modelmaker.nY*handles.toolbox.modelmaker.dY/dyb);

dxb  = 1*handles.toolbox.modelmaker.dX;
dyb  = 1*handles.toolbox.modelmaker.dY;
mmax = handles.toolbox.modelmaker.nX;
nmax = handles.toolbox.modelmaker.nY;


pol  = handles.toolbox.modelmaker.sfincs.buq.refinement_polygon;
% for j=1:length(pol)
%     pol(j).refinement_level=5;
% end
tic
buq  = buq_make_grid_v02(x00,y00,nmax,mmax,dxb,dyb,rot,pol);
toc
tic
buq  = buq_find_neighbors(buq);
toc
handles.model.sfincs.domain(id).buq=buq;

[xz,yz]=quadtree_get_cell_coordinates(buq);
zz=zeros(size(xz));
handles.model.sfincs.domain(id).gridx=xz;
handles.model.sfincs.domain(id).gridy=yz;
handles.model.sfincs.domain(id).gridz=zz;
handles.model.sfincs.domain(id).mask=zeros(size(xz))+1;

handles.model.sfincs.domain(id).input.qtrfile='sfincs.qtr';
buq_save_buq_file(buq, handles.model.sfincs.domain(id).mask, handles.model.sfincs.domain(id).input.qtrfile);


% [xg,yg]=buq_get_block_coordinates(buq);
%figure(1)
%clf
% % patch(xg,yg,c);axis equal;colorbar;caxis([0 80]);colormap('jet');
% % hold on
% % xt=xg(1,:);
% % yt=yg(1,:);
% % text(xt,yt,str);
% % shite=1

handles=ddb_sfincs_plot_buq_blocks(handles,'plot','domain',id,'active',1);

% ppp = plot(xg,yg,'k');axis equal;
%hold on
%plot(pol(1).x,pol(1).y);

% %% Grid coordinates and type
% % These are the centre points !!!
% xg=handles.model.sfincs.domain(id).gridx;
% yg=handles.model.sfincs.domain(id).gridy;
% zg=handles.model.sfincs.domain(id).gridz;
% 
% %% Update model data
% handles.model.sfincs.domain(id).gridz=zg;
% 
% %% Now make the mask matrix
% zmin=handles.toolbox.modelmaker.sfincs.zmin;
% zmax=handles.toolbox.modelmaker.sfincs.zmax;
% 
% xy_in=handles.toolbox.modelmaker.sfincs.buq.refinement_polygon;
% xy_ex=handles.toolbox.modelmaker.sfincs.buq.excludepolygon;
% xy_closedboundary=handles.toolbox.modelmaker.sfincs.buq.closedboundarypolygon;
% xy_outflowboundary=handles.toolbox.modelmaker.sfincs.buq.openboundarypolygon;
% 
% if xy_in(1).length==0
%     xy_in=[];
% end
% if xy_ex(1).length==0
%     xy_ex=[];
% end
% if xy_closedboundary(1).length==0
%     xy_closedboundary=[];
% end
% if xy_outflowboundary(1).length==0
%     xy_outflowboundary=[];
% end
% 
% msk=sfincs_make_mask(xg,yg,zg,[zmin zmax],'includepolygon',xy_in,'excludepolygon',xy_ex,'closedboundarypolygon',xy_closedboundary,'outflowboundarypolygon',xy_outflowboundary);
% %msk=hurrywave_make_mask(xg,yg,zg,[zmin zmax],'includepolygon',xy_in,'excludepolygon',xy_ex,'closedboundarypolygon',xy_closedboundary,'outflowboundarypolygon',xy_outflowboundary);
% msk(isnan(zg))=0;
% handles.model.sfincs.domain(id).mask=msk;
% 
% %% And save the files
% indexfile=handles.model.sfincs.domain(id).input.indexfile;
% bindepfile=handles.model.sfincs.domain(id).input.depfile;
% binmskfile=handles.model.sfincs.domain(id).input.mskfile;
% 
% % handles.model.sfincs.domain(id).input.inputformat='asc';
% 
% if strcmpi(handles.model.sfincs.domain(id).input.inputformat,'bin')
%     sfincs_write_binary_inputs(zg,msk,indexfile,bindepfile,binmskfile);
% %    hurrywave_write_binary_inputs(zg,msk,indexfile,bindepfile,binmskfile);
% else
%     sfincs_write_ascii_inputs(zg,msk,bindepfile,binmskfile);
% end
% 
% handles = ddb_sfincs_plot_mask(handles, 'plot');
% 
setHandles(handles);


