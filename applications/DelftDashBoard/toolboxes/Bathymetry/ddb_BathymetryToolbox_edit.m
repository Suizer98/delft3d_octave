function ddb_BathymetryToolbox_edit(varargin)
%DDB_BATHYMETRYTOOLBOX_MERGE  Mergeg bathymetry data here
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_BathymetryToolbox_export(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_BathymetryToolbox_export
%
%   See also

% .

% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_BathymetryToolbox_merge.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Bathymetry/ddb_BathymetryToolbox_merge.m $
% $Keywords: $

%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    
    % setUIElements('bathymetrypanel.merge');
    ddb_plotBathymetry('activate');
else
    opt=lower(varargin{1});
    switch opt
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'loadpolygon'}
            loadPolygon;
        case{'savepolygon'}
            savePolygon;
        case{'loadsamples'}
            loadSamples;
        case{'addsamples'}
            addSamples;
        case{'savesamples'}
            saveSamples;
        case{'deletesamples'}
            deleteSamples;
        case{'changedepth'}
            changeDepth;
        case{'interpolate'}
            interpolate;
        case{'cellaveraging'}
            cellAveraging;
        case{'internaldiffusion'}
            internalDiffusion;
        case{'smoothing'}
            smoothing;
        case{'savenetfile'}
            saveNetFile;
    end
end

%%
function drawPolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.bathymetry.edit.polygonhandle=gui_polyline('draw','tag','bathymetryeditpolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)

deletePolygon;

handles=getHandles;
handles.toolbox.bathymetry.edit.nrpolygons=1;
iac=handles.toolbox.bathymetry.edit.nrpolygons;
handles.toolbox.bathymetry.edit.polygon(iac).handle=h;
handles.toolbox.bathymetry.edit.polygon(iac).x=x;
handles.toolbox.bathymetry.edit.polygon(iac).y=y;
handles.toolbox.bathymetry.edit.polygon(iac).length=length(x);
handles.toolbox.bathymetry.edit.polygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.bathymetry.edit.activepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolygon

handles=getHandles;

iac=handles.toolbox.bathymetry.edit.activepolygon;
if handles.toolbox.bathymetry.edit.nrpolygons>0
    h=handles.toolbox.bathymetry.edit.polygon(iac).handle;
    if ~isempty(h)
        delete(h);
    end
end

handles.toolbox.bathymetry.edit.polygon=removeFromStruc(handles.toolbox.bathymetry.edit.polygon,iac);
handles.toolbox.bathymetry.edit.polygonnames=removeFromCellArray(handles.toolbox.bathymetry.edit.polygonnames,iac);

handles.toolbox.bathymetry.edit.nrpolygons=max(handles.toolbox.bathymetry.edit.nrpolygons-1,0);
handles.toolbox.bathymetry.edit.activepolygon=min(handles.toolbox.bathymetry.edit.activepolygon,handles.toolbox.bathymetry.edit.nrpolygons);

if handles.toolbox.bathymetry.edit.nrpolygons==0
    handles.toolbox.bathymetry.edit.polygon=[];
    handles.toolbox.bathymetry.edit.polygon(1).x=[];
    handles.toolbox.bathymetry.edit.polygon(1).y=[];
    handles.toolbox.bathymetry.edit.polygon(1).length=0;
    handles.toolbox.bathymetry.edit.polygon(1).handle=[];
    handles.toolbox.bathymetry.edit.nrpolygons=0;
    handles.toolbox.bathymetry.edit.polygonnames={''};
    handles.toolbox.bathymetry.edit.activepolygon=1;
end

setHandles(handles);

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.bathymetry.edit.nrpolygons
    if handles.toolbox.bathymetry.edit.polygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.bathymetry.edit.polygon(iac).x=x;
handles.toolbox.bathymetry.edit.polygon(iac).y=y;
handles.toolbox.bathymetry.edit.polygon(iac).length=length(x);
handles.toolbox.bathymetry.edit.activepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadPolygon

handles=getHandles;

% Clear all
handles.toolbox.bathymetry.edit.polygon=[];
handles.toolbox.bathymetry.edit.polygon(1).x=[];
handles.toolbox.bathymetry.edit.polygon(1).y=[];
handles.toolbox.bathymetry.edit.polygon(1).length=0;
handles.toolbox.bathymetry.edit.polygon(1).handle=[];
handles.toolbox.bathymetry.edit.nrpolygons=0;
handles.toolbox.bathymetry.edit.polygonnames={''};

h=findobj(gca,'Tag','bathymetryeditpolygon');
delete(h);

data=tekal('read',handles.toolbox.bathymetry.edit.polygonfile,'loaddata');
handles.toolbox.bathymetry.edit.nrpolygons=length(data.Field);
handles.toolbox.bathymetry.edit.activepolygon=1;
for ip=1:handles.toolbox.bathymetry.edit.nrpolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.bathymetry.edit.polygon(ip).x=x;
    handles.toolbox.bathymetry.edit.polygon(ip).y=y;
    handles.toolbox.bathymetry.edit.polygon(ip).length=length(x);
    handles.toolbox.bathymetry.edit.polygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','bathymetryeditpolygon','marker','o', ...
        'changecallback',@changePolygon);
    handles.toolbox.bathymetry.edit.polygon(ip).handle=h;
end

setHandles(handles);

%%
function savePolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.bathymetry.edit.polygonfile,'wt');
for ip=1:handles.toolbox.bathymetry.edit.nrpolygons
    fprintf(fid,'%s\n',handles.toolbox.bathymetry.edit.polygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.bathymetry.edit.polygon(ip).length 2]);
    for ix=1:handles.toolbox.bathymetry.edit.polygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.bathymetry.edit.polygon(ip).x(ix) handles.toolbox.bathymetry.edit.polygon(ip).y(ix)]);
    end
end
fclose(fid);

%%
function loadSamples

handles=getHandles;

% Clear all
handles.toolbox.bathymetry.edit.samples=[];
handles.toolbox.bathymetry.edit.nrsamples=0;

h=findobj(gca,'Tag','bathymetryeditsamples');
delete(h);

wb = waitbox('Loading samples ...');
xyz=load(handles.toolbox.bathymetry.edit.samplesfile);
try
    close(wb);
end

handles.toolbox.bathymetry.edit.nrsamples=size(xyz,1);

handles.toolbox.bathymetry.edit.samples.x=xyz(:,1);
handles.toolbox.bathymetry.edit.samples.y=xyz(:,2);
handles.toolbox.bathymetry.edit.samples.z=xyz(:,3);

h=fastscatter(handles.toolbox.bathymetry.edit.samples.x,handles.toolbox.bathymetry.edit.samples.y,handles.toolbox.bathymetry.edit.samples.z);
set(h,'Tag','bathymetryeditsamples');
set(h,'HitTest','off');
handles.toolbox.bathymetry.edit.samples.handle=h;

setHandles(handles);

%%
function addSamples

handles=getHandles;

% Clear all

h=findobj(gca,'Tag','bathymetryeditsamples');
delete(h);

wb = waitbox('Loading samples ...');
xyz=load(handles.toolbox.bathymetry.edit.samplesfile);
try
    close(wb);
end

handles.toolbox.bathymetry.edit.samples.x=[handles.toolbox.bathymetry.edit.samples.x;xyz(:,1)];
handles.toolbox.bathymetry.edit.samples.y=[handles.toolbox.bathymetry.edit.samples.y;xyz(:,2)];
handles.toolbox.bathymetry.edit.samples.z=[handles.toolbox.bathymetry.edit.samples.z;xyz(:,3)];

h=fastscatter(handles.toolbox.bathymetry.edit.samples.x,handles.toolbox.bathymetry.edit.samples.y,handles.toolbox.bathymetry.edit.samples.z);
set(h,'Tag','bathymetryeditsamples');
set(h,'HitTest','off');
handles.toolbox.bathymetry.edit.samples.handle=h;

handles.toolbox.bathymetry.edit.nrsamples=length(handles.toolbox.bathymetry.edit.samples.x);

setHandles(handles);

%%
function deleteSamples

handles=getHandles;

% Clear all
h=findobj(gca,'Tag','bathymetryeditsamples');
delete(h);
handles.toolbox.bathymetry.edit.samples.handle=[];

xp=handles.toolbox.bathymetry.edit.polygon(1).x;
yp=handles.toolbox.bathymetry.edit.polygon(1).y;

if ~isempty(xp)
    inp=inpolygon(handles.toolbox.bathymetry.edit.samples.x,handles.toolbox.bathymetry.edit.samples.y,xp,yp);
else
    inp=zeros(size(handles.toolbox.bathymetry.edit.samples.x))+1;
end
handles.toolbox.bathymetry.edit.samples.x=handles.toolbox.bathymetry.edit.samples.x(~inp);
handles.toolbox.bathymetry.edit.samples.y=handles.toolbox.bathymetry.edit.samples.y(~inp);
handles.toolbox.bathymetry.edit.samples.z=handles.toolbox.bathymetry.edit.samples.z(~inp);

if ~isempty(handles.toolbox.bathymetry.edit.samples.x)
    h=fastscatter(handles.toolbox.bathymetry.edit.samples.x,handles.toolbox.bathymetry.edit.samples.y,handles.toolbox.bathymetry.edit.samples.z);
    set(h,'Tag','bathymetryeditsamples');
    set(h,'HitTest','off');
    handles.toolbox.bathymetry.edit.samples.handle=h;
end

setHandles(handles);

%%
function saveSamples

handles=getHandles;

xyz=[handles.toolbox.bathymetry.edit.samples.x handles.toolbox.bathymetry.edit.samples.y handles.toolbox.bathymetry.edit.samples.z];

save(handles.toolbox.bathymetry.edit.samplesfile,'-ascii','xyz');


%%
function changeDepth

handles=getHandles;

netstruc=handles.model.dflowfm.domain(ad).netstruc;

opt=handles.toolbox.bathymetry.edit.depth_change_option;
unifval=handles.toolbox.bathymetry.edit.uniform_value;

xp=handles.toolbox.bathymetry.edit.polygon(1).x;
yp=handles.toolbox.bathymetry.edit.polygon(1).y;

znew=netstruc_change_depth(netstruc,opt,unifval,xp,yp);

handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z=znew;

handles = ddb_DFlowFM_plotBathymetry(handles, 'plot');

setHandles(handles);

%%
function internalDiffusion

handles=getHandles;

netstruc=handles.model.dflowfm.domain(ad).netstruc;

opt=handles.toolbox.bathymetry.edit.depth_change_option;
unifval=handles.toolbox.bathymetry.edit.uniform_value;

xp=handles.toolbox.bathymetry.edit.polygon(1).x;
yp=handles.toolbox.bathymetry.edit.polygon(1).y;

wb = waitbox('Internal diffusion ...');
znew=netstruc_internal_diffusion(netstruc,xp,yp);
try
    close(wb);
end

handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z=znew;

handles = ddb_DFlowFM_plotBathymetry(handles, 'plot');

setHandles(handles);

%%
function smoothing

handles=getHandles;

netstruc=handles.model.dflowfm.domain(ad).netstruc;

xp=handles.toolbox.bathymetry.edit.polygon(1).x;
yp=handles.toolbox.bathymetry.edit.polygon(1).y;

wb = waitbox('Smoothing ...');
znew=netstruc_smoothing(netstruc,xp,yp,'maxiter',1);
try
    close(wb);
end

handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z=znew;

handles = ddb_DFlowFM_plotBathymetry(handles, 'plot');

setHandles(handles);

%%
function interpolate

handles=getHandles;

netstruc=handles.model.dflowfm.domain(ad).netstruc;

xp=handles.toolbox.bathymetry.edit.polygon(1).x;
yp=handles.toolbox.bathymetry.edit.polygon(1).y;

xs=handles.toolbox.bathymetry.edit.samples.x;
ys=handles.toolbox.bathymetry.edit.samples.y;
zs=handles.toolbox.bathymetry.edit.samples.z;

%znew=netstruc_interpolate(netstruc,xs,ys,zs,xp,yp);

%handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z=znew;

handles = ddb_DFlowFM_plotBathymetry(handles, 'plot');

setHandles(handles);

%%
function cellAveraging

handles=getHandles;

netstruc=handles.model.dflowfm.domain(ad).netstruc;

xp=handles.toolbox.bathymetry.edit.polygon(1).x;
yp=handles.toolbox.bathymetry.edit.polygon(1).y;

xs=handles.toolbox.bathymetry.edit.samples.x;
ys=handles.toolbox.bathymetry.edit.samples.y;
zs=handles.toolbox.bathymetry.edit.samples.z;

wb = waitbox('Cell averaging ...');
znew=netstruc_cell_averaging(netstruc,xs,ys,zs,xp,yp);
try
    close(wb);
end

handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z=znew;

handles = ddb_DFlowFM_plotBathymetry(handles, 'plot');

setHandles(handles);


%%
function saveNetFile

handles=getHandles;

[filename,ok]=gui_uiputfile('*_net.nc', 'Net File Name',handles.model.dflowfm.domain(ad).netfile);
if ~ok
    return
end

handles.model.dflowfm.domain(ad).netfile=filename;

cs.name=handles.screenParameters.coordinateSystem.name;
switch lower(handles.screenParameters.coordinateSystem.type(1:3))
    case{'pro','car'}
        cs.type='projected';
    otherwise
        cs.type='geographic';
end

netstruc2netcdf(handles.model.dflowfm.domain(ad).netfile,handles.model.dflowfm.domain(ad).netstruc,'cs',cs);

setHandles(handles);
