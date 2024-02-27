%% Converts dhydro model to Delft3D Flow model (spherical models only). Simple mapping, no
%  
clear all;

%% initialise
fileMDU                  = 'p:\1204257-dcsmzuno\2013-2017\3D-DCSM-FM_4nm\A02b_s\DCSM-FM_4nm.mdu'; 
mdu                      = dflowfm_io_mdu('read',fileMDU);                                      
kmax                     = mdu.geometry.Kmx;
layerCount               = kmax:-1:1; % from D-Hydro sigma (bottom to top), to Delft3D-Flow sigma (top to bottom)
thick(1:kmax)            = 1/kmax;
CoordinateSystem         = 'Spherical';
itdate                   = datenum(num2str(mdu.time.RefDate),'yyyymmdd');
generate_bcc             = true;      % save time

%% Files
%  dhydro
[path_mdu,name_mdu,~] = fileparts(fileMDU);
name_mdf              = strrep(name_mdu,'FM','D3D');
if isempty(mdu.output.OutputDir) mdu.output.OutputDir = [path_mdu filesep 'DFM_OUTPUT_' name_mdu]; end
fileNet   = [path_mdu filesep mdu.geometry.NetFile];
fileMap   = [mdu.output.OutputDir filesep name_mdu '_0000_map.nc'];
fileExt   = [path_mdu filesep mdu.external_forcing.ExtForceFileNew];
fileLoc   = 'p:\11203715-004-dcsm-fm\models\model_input\bnd_cond\pli\DCSM-FM_OB_all_20181108.pli';
fileWl    = 'p:\11203715-004-dcsm-fm\models\model_input\bnd_cond\wl\FES2012\20191125\3D\DCSM-FM_OB_all_20191125.bc'; 
fileSal   = 'p:\1204257-dcsmzuno\2013-2017\3D-DCSM-FM_4nm\salinity_OB_all_20181108.bc';
fileTem   = 'p:\1204257-dcsmzuno\2013-2017\3D-DCSM-FM_4nm\temperature_OB_all_20181108.bc';
fileSLA   = 'p:\1204257-dcsmzuno\2013-2017\3D-DCSM-FM_4nm\A02b_s\SH_IBC_Global_mean_plus40cm.bc'; 

%  d3d
dirMDF    = 'p:\1204257-dcsmzuno\2013-2017\3D-DCSM-FM_4nm\A02b_s\mdf';
dirMDF    = '.';
if ~exist(dirMDF,'dir') mkdir(dirMDF); end
fileMdf   = [dirMDF filesep name_mdf '.mdf'];
fileGrd   = [dirMDF filesep name_mdf '.grd'];
fileEnc   = [dirMDF filesep name_mdf '.enc'];
fileDep   = [dirMDF filesep name_mdf '.dep'];
fileBnd   = [dirMDF filesep name_mdf '.bnd'];
fileBca   = [dirMDF filesep name_mdf '.bca'];
fileBcc   = [dirMDF filesep name_mdf '.bcc'];
restid    = [name_mdf '_fromDhydroMap'];
fileRst   = [dirMDF filesep 'tri-rst.' restid];
fileBc0   = [dirMDF filesep name_mdf '.bc0'];

%% Grid
%  reconstruct a grid from the net file
GRID                  = EHY_gridFromNet(fileNet);
GRID.missingvalue     = NaN;
GRID.CoordinateSystem = CoordinateSystem;

%  Write Grid
delft3d_io_grd('write',fileGrd,GRID,'ask',false);

%%  Depth values at corner points and mapping (for initial conditions etc)
%   Initialise 
Xcor = GRID.cor.x  ; Ycor = GRID.cor.y;
Xcen = GRID.cend.x ; Ycen = GRID.cend.y;
mmax = size(Xcor,1); nmax = size(Xcor,2);
Zcor (1:mmax,1:nmax) = NaN; net_ind_grd(1:mmax,1:nmax) = NaN;net_ind_cen(1:mmax,1:nmax) = NaN;
tol = 1e-6;

%  Read from net file
net  = EHY_getGridInfo(fileNet,{'XYcor' 'Z'});
tmp  = EHY_getGridInfo(fileMap,{'XYcen'    }); % Temporarily, want to reconstruct this from the net file
names = fieldnames(tmp); for i_name = 1: length(names) net.(names{i_name}) = tmp.(names{i_name}); end

%  Detrmine mapping and Zcor values 
for m = 1: mmax
    for n = 1: nmax
        ind_grd           = find(abs(Xcor(m,n) - net.Xcor) < tol & abs(Ycor(m,n) - net.Ycor) < tol);
        ind_cen           = find(abs(Xcen(m,n) - net.Xcen) < tol & abs(Ycen(m,n) - net.Ycen) < tol);
        if ~isempty(ind_grd)
            net_ind_grd(m,n)  = ind_grd;
            Zcor(m,n)         = -1.*net.Zcor(net_ind_grd(m,n));
        end
        if ~isempty(ind_cen)
            net_ind_cen(m,n)  = ind_cen;
        end
    end
end

%  Write map file
delft3d_io_dep('write',fileDep,Zcor','dummy',0,'location','cor');

%% Boundary conditions (to Do, get information out of the ext file)
ext       = dflowfm_io_extfile('read',fileExt);

pli       = dflowfm_io_xydata('read',fileLoc);
Xpli      = cell2mat(pli.DATA(:,1));
Ypli      = cell2mat(pli.DATA(:,2));
name_pli  = pli.DATA(:,3);

%  Boundary definition
%  not very elegant but will have to do for now, search for nearest pli
%  point at n = 1, m = 1, and n = nmax
%
Zcor(:,end + 1) = Zcor(:,end); Zcor(end+1,:) = Zcor(end,:);
mmax = size(Zcor,1); nmax = size(Zcor,2); 
for m = 1: mmax; for n = 1: nmax; Zcen(m,n) = mean(Zcor(max(1,m-1):m,max(1,n-1):n),'all'); end; end

%  List of mn coordinates ol all possible bnd points (including not active points)
m_tmp             = mmax:-1:1;
n_tmp(1:mmax)     = 1;
m_tmp             = [m_tmp      ones(1,nmax)];
n_tmp             = [n_tmp            1:nmax];
m_tmp             = [m_tmp            1:mmax];
n_tmp             = [n_tmp nmax*ones(1,mmax)];

%  Vector of x and y coordinaten of potential bnd points
nr_bnd_pnt = 0;
for i_tmp = 1: length(m_tmp)
    if ~isnan(Xcen(m_tmp(i_tmp),n_tmp(i_tmp)))
        nr_bnd_pnt = nr_bnd_pnt + 1;
        mn_tmp(nr_bnd_pnt,1) = m_tmp(i_tmp);
        mn_tmp(nr_bnd_pnt,2) = n_tmp(i_tmp);
        XX(nr_bnd_pnt) = Xcen(mn_tmp(nr_bnd_pnt,1),mn_tmp(nr_bnd_pnt,2));
        YY(nr_bnd_pnt) = Ycen(mn_tmp(nr_bnd_pnt,1),mn_tmp(nr_bnd_pnt,2));
    end
end

%  Find actual bnd points (nearest to pli points)
no_pli = length(Xpli);
for i_pli = 1: no_pli
    dist = nesthd_detlength(XX,YY,Xpli(i_pli),Ypli(i_pli),'Spherical',true);
    [~,index]   = min(dist);
    mn(i_pli,1) = mn_tmp(index,1);
    mn(i_pli,2) = mn_tmp(index,2);
    mn(i_pli,3) = i_pli;
end

%  Now: from points to segments
no_bnd = 0;
for i_pli = 1: no_pli - 1
    if  (mn(i_pli,1) == mn(i_pli+1,1)) || (mn(i_pli,2) == mn(i_pli+1,2))
        no_bnd = no_bnd + 1;
        BND.DATA(no_bnd).name     = [name_pli{i_pli}(end-3:end) '_' name_pli{i_pli+1}(end-3:end)];
        BND.DATA(no_bnd).bndtype  = 'Z';
        BND.DATA(no_bnd).datatype = 'A';
        BND.DATA(no_bnd).mn(1)    = mn(i_pli  ,1);
        BND.DATA(no_bnd).mn(2)    = mn(i_pli  ,2);
        BND.DATA(no_bnd).mn(3)    = mn(i_pli+1,1);
        BND.DATA(no_bnd).mn(4)    = mn(i_pli+1,2);
        BND.DATA(no_bnd).labelA   = name_pli{i_pli  }(end-3:end);
        BND.DATA(no_bnd).labelB   = name_pli{i_pli+1}(end-3:end);
        BND.DATA(no_bnd).indexA   = mn(i_pli  ,3);
        BND.DATA(no_bnd).indexB   = mn(i_pli+1,3);
        BND.DATA(no_bnd).alfa     = 0.0;
        BND.DATA(no_bnd).dir      = 'u';
        if  (mn(i_pli,2) == mn(i_pli+1,2)) BND.DATA(no_bnd).dir      = 'v'; end
        if strcmpi(BND.DATA(no_bnd).dir,'u') && BND.DATA(no_bnd).mn(2) ==    1  BND.DATA(no_bnd).mn(1) =    2    ; end
        if strcmpi(BND.DATA(no_bnd).dir,'u') && BND.DATA(no_bnd).mn(2) == nmax  BND.DATA(no_bnd).mn(2) = nmax - 1; end
        if strcmpi(BND.DATA(no_bnd).dir,'u') && BND.DATA(no_bnd).mn(4) ==    1  BND.DATA(no_bnd).mn(4) =    2    ; end
        if strcmpi(BND.DATA(no_bnd).dir,'u') && BND.DATA(no_bnd).mn(4) == nmax  BND.DATA(no_bnd).mn(4) = nmax - 1; end
        if strcmpi(BND.DATA(no_bnd).dir,'v') && BND.DATA(no_bnd).mn(1) ==    1  BND.DATA(no_bnd).mn(1) =    2    ; end
        if strcmpi(BND.DATA(no_bnd).dir,'v') && BND.DATA(no_bnd).mn(1) == mmax  BND.DATA(no_bnd).mn(1) = mmax - 1; end
        if strcmpi(BND.DATA(no_bnd).dir,'v') && BND.DATA(no_bnd).mn(3) ==    1  BND.DATA(no_bnd).mn(3) =    2    ; end
        if strcmpi(BND.DATA(no_bnd).dir,'v') && BND.DATA(no_bnd).mn(3) == mmax  BND.DATA(no_bnd).mn(3) = mmax - 1; end
    end
end

delft3d_io_bnd('write',fileBnd,BND);
for i_bnd = 1: no_bnd; BND.DATA(i_bnd).datatype = 'T'; end
[path,name,ext] = fileparts(fileBnd);
fileBnd_tmp     = [path filesep name '_timeseries' ext];
delft3d_io_bnd('write',fileBnd_tmp,BND);

% boundary definition in points structure (allow for writing using nesthd write functions)
bnd_points = nesthd_get_bnd_data (fileBnd_tmp,'Points',true);
delete(fileBnd_tmp);

clear mn_tmp m_tmp n_tmp XX YY

%% Connvert Water level bnd
wl_dhydro = dflowfm_io_extfile('read',fileWl);

for i_pli = 1: no_pli
    
    % dhydro
    Name                  = wl_dhydro(i_pli).Keyword.Name;
    Value                 = wl_dhydro(i_pli).Keyword.Value;
    nr_entry              = get_nr(Name,'Name');
    wl_d3d(i_pli).pntname = Value{nr_entry}(end-3:end);
    
    % from dhydro to d3d
    wl_d3d(i_pli).cmp_name = wl_dhydro(i_pli).values(:,1);
    wl_d3d(i_pli).cmp_amp  = cell2mat(wl_dhydro(i_pli).values(:,2));
    wl_d3d(i_pli).cmp_phas = cell2mat(wl_dhydro(i_pli).values(:,3));
end

% Write astronomical forcing file

fid = fopen(fileBca,'w+');
for i_pli = 1: no_pli
    fprintf(fid,'%4s \n',wl_d3d(i_pli).pntname);
    for i_cmp = 1: length(wl_d3d(i_pli).cmp_name)
        fprintf(fid,'%-8s %12.6f %12.6f \n',wl_d3d(i_pli).cmp_name {i_cmp}, ...
                                           wl_d3d(i_pli).cmp_amp  (i_cmp), ...
                                           wl_d3d(i_pli).cmp_phas (i_cmp));
    end
end
fclose(fid);
clear wl_dhydro

%% Connvert seaLevelAnomalies
SLA = nesthd_getSeriesFromBc(fileSLA,itdate,'names',name_pli);

for i_pli = 1: no_pli
    no_times             = length (SLA(i_pli).times);
    for i_time = 1: no_times
        bc0_d3d(i_pli).value(i_time,:) = (SLA(i_pli).value(i_time,:));
    end
end

% fill stracture with boundary values (single point structure)
no_bnd = length(BND.DATA);
for i_time = 1: no_times
    for i_bnd = 1: no_bnd
        bndval(i_time).value(i_bnd*2 - 1,1,1) = bc0_d3d(BND.DATA(i_bnd).indexA).value(i_time);
        bndval(i_time).value(i_bnd*2    ,1,1) = bc0_d3d(BND.DATA(i_bnd).indexB).value(i_time);
    end
end

%% write seaLevelAnomalies, start with filling nfs_inf structure to allow for using nesthd writing function
nfs_inf.times      = SLA(1).times; % assume all serie on the same time frame
nfs_inf.itdate     = itdate;
nfs_inf.kmax       = kmax;
nfs_inf.thick      = thick;
nfs_inf.from       = '';             % No need to flip layers since they allready have delft3d-flow orientation
add_inf.timeZone   = 0;

% finally write the sea level anomalies
nesthd_wrihyd_bct(fileBc0,bnd_points,nfs_inf,bndval,add_inf);
clear bndval

%% Transport boundary contions
if generate_bcc
    fileTranBc{1} = fileSal;
    fileTranBc{2} = fileTem;
    lstci         = length(fileTranBc);
    
    for l = 1: lstci
        
        % Read the data
        r1_dhydro(:,l) = nesthd_getSeriesFromBc(fileTranBc{l},itdate,'names',name_pli);
        
        for i_pli = 1: no_pli
            % d3d
            depth                = Zcen(mn(i_pli,1),mn(i_pli,2));
            lev_d3d(1)           = thick(1)/2*depth;
            for k = 2: kmax; lev_d3d(k) = lev_d3d(k-1) + 0.5*(thick(k-1) + thick(k))*depth; end
            
            % from dhydro to d3d (interpolate profile)
            no_times             = length (r1_dhydro(i_pli,l).times);
            for i_time = 1: no_times
                for k = 1: kmax
                    r1_d3d(i_pli,l).val(i_time,k) = max(interp1(-1.*r1_dhydro(i_pli,l).lev_dhydro,r1_dhydro(i_pli,l).value(i_time,:),lev_d3d(k),'linear','extrap'),0);
                end
            end
        end
    end
    
     
    %% Write the boundary conditions.
    %  Start with filling nfs_inf structure and add_inf structure to allow to use nesthd_wricon
    nfs_inf.times      = r1_dhydro(1,1).times; % assume all serie on the same time frame
    nfs_inf.namcon{1}  = 'Salinity';
    nfs_inf.namcon{2}  = 'Temperature';
    add_inf.genconc(1) = true;
    add_inf.genconc(2) = true;
    
    % fill stracture with boundary values (single point structure)
    for i_time = 1: no_times
        for l = 1: lstci
            for i_bnd = 1: no_bnd
                bndval(i_time).value(i_bnd*2 - 1,:,l) = r1_d3d(BND.DATA(i_bnd).indexA,l).val(i_time,:);
                bndval(i_time).value(i_bnd*2    ,:,l) = r1_d3d(BND.DATA(i_bnd).indexB,l).val(i_time,:);
            end
        end
    end
    
    % finally, write file
    nesthd_wricon_bcc(fileBcc,bnd_points,nfs_inf,bndval,add_inf);
    
end

%% Initial conditions
%  Read from map file
wl_dhydro   = EHY_getMapModelData(fileMap,'varName','wl' ,'t',1);
sal_dhydro  = EHY_getMapModelData(fileMap,'varName','sal','t',1);
tem_dhydro  = EHY_getMapModelData(fileMap,'varName','tem','t',1);

%  Initialise
kmax = size(sal_dhydro.val,3);
data.waterlevel (1:mmax,1:nmax       ) = 0.;
data.u          (1:mmax,1:nmax,1:kmax) = 0.;
data.v          (1:mmax,1:nmax,1:kmax) = 0.;
data.salinity   (1:mmax,1:nmax,1:kmax) = 0.;
data.temperature(1:mmax,1:nmax,1:kmax) = 0.;
net_ind_cen     (  1    , :     ) = net_ind_cen(  2,  : ); % Copy first and last row/column to avoid novalues at open boundaries
net_ind_cen     (end + 1, :     ) = net_ind_cen(end,  : );
net_ind_cen     ( :     ,  1    ) = net_ind_cen( : ,  2 );
net_ind_cen     ( :     ,end + 1) = net_ind_cen( : ,end);

%  mapping
for m = 1: mmax
    for n = 1: nmax
        if ~isnan(net_ind_cen(m,n))
            data.waterlevel  (m,n)            = wl_dhydro.val (1,net_ind_cen(m,n));
            for k = 1: kmax
                data.salinity    (m,n,layerCount(k)) = sal_dhydro.val(1,net_ind_cen(m,n),k);
                data.temperature (m,n,layerCount(k)) = tem_dhydro.val(1,net_ind_cen(m,n),k);
            end
        end
    end
end

%  write rst file
delft3d_io_restart('write',fileRst,data,'','','ask',false);

%% Finally, create a basic mdf file, starting point, from mdu file
mdf = delft3d_io_mdf('new');
mdf.keywords.filcco    = fileGrd;
mdf.keywords.filgrd    = fileEnc;
mdf.keywords.fildep    = fileDep;
mdf.keywords.filbnd    = fileBnd;
mdf.keywords.filana    = fileBca;
mdf.keywords.filbcc    = fileBcc;
mdf.keywords.filbc0    = fileBc0;
mdf.keywords.restid    = restid;

mdf.keywords.mnkmax(1) = mmax;
mdf.keywords.mnkmax(2) = nmax;
mdf.keywords.mnkmax(3) = kmax;
mdf.keywords.thick     = 100.*thick;

mdf.keywords.sub1      = 'ST  ';

mdf.keywords.itdate    = datestr(itdate,'yyyy-mm-dd');
mdf.keywords.tstart    = mdu.time.TStart;
mdf.keywords.tstop     = mdu.time.TStart + 1440; % Restrict to one day
mdf.keywords.dt        = round(mdu.time.DtMax/60.);

mdf.keywords.rettis(1:no_bnd)    = 0.0;
mdf.keywords.rettib(1:no_bnd)    = 0.0;

mdf.keywords.dicouv              = 1.0;
mdf.keywords.dpsopt              = 'MEAN';

mdf.keywords.flmap(1)            = mdf.keywords.tstart;
mdf.keywords.flmap(2)            = 60.;
mdf.keywords.flmap(3)            = mdf.keywords.tstop;

%  write the mdf file
delft3d_io_mdf('write',fileMdf,mdf.keywords);











