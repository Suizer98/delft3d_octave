function S = sfincs_read_binary_map(data_fol)

% Settings
orig_fol = pwd;
cd(data_fol)
inpfile = ['sfincs.inp'];

% Read inp
inp     = sfincs_initialize_input;
inp     = sfincs_read_input(inpfile,inp);

% Change paths from Linux to Windows
keywords=fieldnames(inp);
for vv = 1:length(keywords)
    path_unix           = inp.(keywords{vv});
    path_win            = strrep(path_unix, '\', '/');
    inp.(keywords{vv})  = path_win;
end

% Make grid
[xg,yg,xz,yz]= sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);
S.x          = xz;
S.y          = yz;

% Read index file
fid=fopen([inp.indexfile],'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read mask
fid=fopen([inp.mskfile],'r');
mskv=fread(fid,np,'integer*1');
fclose(fid);
S.msk=zeros(inp.nmax,inp.mmax);
S.msk(indices) = mskv;

% Read depth file
fid=fopen([inp.depfile],'r');
zbv=fread(fid,np,'real*4');
fclose(fid);
S.zb=NaN(inp.nmax,inp.mmax);
S.zb(indices) = zbv;

%% Read zsmax file
it=0;
fid=fopen(['zsmax.dat'],'r');
while 1
    idummy=fread(fid,1,'integer*4');
    if isempty(idummy)
        break
    end
    it              = it+1;
    zsv             = fread(fid,np,'real*4');
    idummy          = fread(fid,1,'integer*4');
    zs0             = zeros(inp.nmax,inp.mmax);
    zs0(zs0==0)     = NaN;
    zs0(indices)    = zsv;
    zs0(S.msk~=1)   = NaN;
    S.zsmax(it,:,:) = zs0;
    S.t(it)         = (it-1)*inp.dtmaxout;
end
fclose(fid);

%% Read tmax file
it=0;
try
    fid=fopen(['tmax.dat'],'r');

    while 1
        idummy=fread(fid,1,'integer*4');
        if isempty(idummy)
            break
        end
        it              = it+1;
        zsv             = fread(fid,np,'real*4');
        idummy          = fread(fid,1,'integer*4');
        zs0             = zeros(inp.nmax,inp.mmax);
        zs0(zs0==0)     = NaN;
        zs0(indices)    = zsv;
        zs0(S.msk~=1)   = NaN;
        S.tmax(it,:,:)  = zs0;
    end
    fclose(fid);
    
catch
    S.tmax = NaN(size(S.zsmax));
end

%% Read tmax file
it=0;
try
    fid=fopen(['velmax.dat'],'r');

    while 1
        idummy=fread(fid,1,'integer*4');
        if isempty(idummy)
            break
        end
        it              = it+1;
        zsv             = fread(fid,np,'real*4');
        idummy          = fread(fid,1,'integer*4');
        zs0             = zeros(inp.nmax,inp.mmax);
        zs0(zs0==0)     = NaN;
        zs0(indices)    = zsv;
        zs0(S.msk~=1)   = NaN;
        S.vmax(it,:,:)  = zs0;
    end
    fclose(fid);
    
catch
    S.vmax = NaN(size(S.zsmax));
end

cd(orig_fol)
end
