function handles=ddb_ModelMakerToolbox_sfincs_generateBathymetry(handles,id,datasets,varargin)

icheck=1;
overwrite=1;
filename=[];
modeloffset=0;

%% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'check'}
                icheck=varargin{i+1};
            case{'overwrite'}
                overwrite=varargin{i+1};
            case{'filename'}
                filename=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
            case{'modeloffset'}
                modeloffset=varargin{i+1};
        end
    end
end

%% Check should NOT be performed when called by CSIPS toolbox
if icheck
    % Check if there is already a grid
    if isempty(handles.model.sfincs.domain(id).gridx)
        ddb_giveWarning('Warning','First generate or load a grid');
        return
    end
    % File name
    if isempty(handles.model.sfincs.domain(id).input.depfile)
%        handles.model.sfincs.domain(id).input.depfile=[handles.model.sfincs.domain.attName '.dep'];
        handles.model.sfincs.domain(id).input.depfile='sfincs.dep';
    end
    [filename,ok]=gui_uiputfile('*.dep', 'Depth File Name',handles.model.sfincs.domain(id).input.depfile);
    if ~ok
        return
    end
    [pathstr,name,ext]=fileparts(filename);
    handles.model.sfincs.domain(id).input.depfile=filename;
    if isempty(handles.model.sfincs.domain(id).buq)
        handles.model.sfincs.domain(id).input.indexfile=[name '.ind'];
    end
    handles.model.sfincs.domain(id).input.mskfile=[name '.msk'];
    % Check if there is already data in depth matrix
    dmax=max(max(handles.model.sfincs.domain(id).gridz));
    if isnan(dmax)
        overwrite=1;
    else
        ButtonName = questdlg('Overwrite existing bathymetry?', ...
            'Delete existing bathymetry', ...
            'Cancel', 'No', 'Yes', 'Yes');
        switch ButtonName,
            case 'Cancel',
                return;
            case 'No',
                overwrite=0;
            case 'Yes',
                overwrite=1;
        end
    end
end

xg=handles.model.sfincs.domain(id).gridx;
yg=handles.model.sfincs.domain(id).gridy;
zg=handles.model.sfincs.domain(id).gridz;

%% Grid coordinates and type
% These are the centre points !
if ~isempty(handles.model.sfincs.domain(id).buq)
    gridtype='unstructured';
else
    gridtype='structured';
end

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);

%% Update model data
handles.model.sfincs.domain(id).gridz=zg;

%% Now make the mask matrix
zmin=handles.toolbox.modelmaker.sfincs.zmin;
zmax=handles.toolbox.modelmaker.sfincs.zmax;

% xyinc=handles.toolbox.modelmaker.sfincs.include_xy;
% xyexc=handles.toolbox.modelmaker.sfincs.exclude_xy;
% xyinc=handles.toolbox.modelmaker.sfincs.mask.includepolygon;
% xyexc=handles.toolbox.modelmaker.sfincs.mask.excludepolygon;

xyinc=[];
xyexc=[];

msk=zeros(size(xg))+1;

% msk=sfincs_make_mask(xg,yg,zg,[zmin zmax],'includepolygon',xyinc,'excludepolygon',xyexc);
msk(isnan(zg))=0;
% % zg(msk==0)=NaN;
handles.model.sfincs.domain(id).mask=msk;


%% And save the files
indexfile=handles.model.sfincs.domain(id).input.indexfile;
bindepfile=handles.model.sfincs.domain(id).input.depfile;
binmskfile=handles.model.sfincs.domain(id).input.mskfile;

% handles.model.sfincs.domain(id).input.inputformat='asc';

if strcmpi(handles.model.sfincs.domain(id).input.inputformat,'bin')
    sfincs_write_binary_inputs(zg,msk,indexfile,bindepfile,binmskfile);
else
    sfincs_write_ascii_inputs(zg,msk,bindepfile,binmskfile);
end

% handles = ddb_sfincs_plot_bathymetry(handles, 'plot');

handles = ddb_sfincs_plot_mask(handles, 'plot');

% %% Subgrid
% dr='.\';
% subgridfile='sfincs.sbg';
% bathy=datasets;
% manning_input=[0.02 0.02 0.0];
% cs=handles.screenParameters.coordinateSystem;
% refi=5;
% refj=5;
% uopt='minmean';
% maxdzdv=10;
% usemex=1;
% nbin=5;
% 
% global bathymetry
% bathymetry=handles.bathymetry;
% 
% bathy.zmin=-9999;
% bathy.zmax= 9999;
% 
% sfincs_make_subgrid_file_v8(dr,subgridfile,bathy,manning_input,cs,nbin,refi,refj,uopt,maxdzdv,usemex);
% 

%%
% figure(100)
% pcolor(xg,yg,zg);shading flat;axis equal;colorbar;caxis([-2 10]);
% figure(101)
% pcolor(xg,yg,msk);shading flat;axis equal;colorbar;caxis([0 2]);

% % Depth file
% %handles.model.sfincs.domain(id).depthsource='file';
% % gridz=handles.model.sfincs.domain(id).gridz';
% %gridz(isnan(gridz))=-99;
% %gridz=min(gridz,20);
% 
% %xy=landboundary('read','texas_land.pli');
% %xy=landboundary('read','mackay_include.pol');
% %msk=sfincs_make_mask(xg',yg',gridz,[-2 10],'includepolygon',xy);
% % msk(isnan(gridz))=0;
% %gridz(msk==0)=NaN;
% 
% %gridz=max(gridz,-2);
% 
% % gridz(msk==0)=NaN;
% 
% %% Create domain
% 
% % Binary input
% 
% % Index file
% indices=find(msk>0);
% mskv=msk(msk>0);
% fid=fopen(inp.indexfile,'w');
% fwrite(fid,length(indices),'integer*4');
% fwrite(fid,indices,'integer*4');
% fclose(fid);
% 
% % Depth file
% zv=gridz(~isnan(gridz));
% 
% % fg=gcf;
% % figure(200);
% % plot(zv,'b');hold on
% % zv=max(zv,-4);
% % plot(zv,'r');hold on
% % figure(fg);
% 
% % zv=zeros(size(zv))+5;
% 
% fid=fopen(inp.depfile,'w');
% fwrite(fid,zv,'real*4');
% fclose(fid);
% 
% % Mask file
% fid=fopen(inp.mskfile,'w');
% fwrite(fid,mskv,'integer*1');
% fclose(fid);
% 
% %     % ASCII input
% %
% %     % Depth file
% %     z(isnan(z))=-999;
% %     save([name filesep depfile],'-ascii','z');
% %
% %     % Mask file
% %     dlmwrite([name filesep mskfile],msk,'delimiter',' ');
% 
% %     % Create geomask file
% %     dlon=0.01;
% %     ddb_cfm_make_geomask(name,[name '.xml'],inp.indexfile,inp.mskfile,inp.geomskfile,inp.mmax,inp.nmax,dlon)
% dlon=0.00100;
% 
% handles.model.sfincs.domain(id).input.geomskfile='sfincs.geomsk';
% 
% inp=handles.model.sfincs.domain(id).input;
% cs=handles.screenParameters.coordinateSystem;
% sfincs_make_geomask_file(inp.geomskfile,inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation,inp.indexfile,inp.mskfile,dlon,cs);
% %sfincs_make_geomask_file(geomaskfile,x0,y0,dx,dy,mmax,nmax,rotation,indexfile,maskfile,dlon,cs)
% 
% %gridz(gridz<0)=NaN;
% %gridz(isnan(gridz))=-99;
% % save(filename,'-ascii','gridz');
% 
% 
% 
% 
% %ddb_wldep('write',filename,handles.model.sfincs.domain(id).gridz);
% % Workaround
% %handles.model.sfincs.domain(id).bedlevel=filename;
% %handles.model.sfincs.domain(id).depthsource='file';
% % Plot
% % handles=ddb_sfincs_plotBathy(handles,'plot',id);
