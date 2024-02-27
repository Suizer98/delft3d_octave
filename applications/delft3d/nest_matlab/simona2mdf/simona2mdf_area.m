function mdf = simona2mdf_area(S,mdf,name_mdf, varargin)

% simona2mdf_area : gets grid related quantities out of the parsed siminp tree

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});


siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'GRID'});

%
% Get grid related information
%
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.GRID.CURVILINEAR.RGFFILE')
    mdf.filcco    = siminp_struc.ParsedTree.MESH.GRID.CURVILINEAR.RGFFILE;
    mdf.anglat    = siminp_struc.ParsedTree.MESH.GRID.AREA.LATITUDE;
elseif simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.GRID.GENERALIZED_SPHERICAL.RGFFILE')
       % CSM
    mdf.filcco    = siminp_struc.ParsedTree.MESH.GRID.GENERALIZED_SPHERICAL.RGFFILE;
elseif simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.GRID.SPHERICAL')
       % CSMv5 Create grid!
    mmax = siminp_struc.ParsedTree.MESH.GRID.AREA.MMAX - 1;
    nmax = siminp_struc.ParsedTree.MESH.GRID.AREA.NMAX - 1;
    x0   = siminp_struc.ParsedTree.MESH.GRID.AREA.LONGITUDE;
    y0   = siminp_struc.ParsedTree.MESH.GRID.AREA.LATITUDE;
    dx   = siminp_struc.ParsedTree.MESH.GRID.SPHERICAL.STEPLAMBDA;
    dy   = siminp_struc.ParsedTree.MESH.GRID.SPHERICAL.STEPFI;
    for m = 1: mmax
        for n= 1: nmax
            xcoor(m,n) = x0 + (m-0.5)*dx;
            ycoor(m,n) = y0 + (n-0.5)*dy;
        end
    end
    mdf.filcco = simona2mdf_rmpath([name_mdf '.grd']);
    wlgrid('write','Filename',[name_mdf '.grd'],'X',xcoor,'Y',ycoor,'CoordinateSystem','Spherical');
else
    simona2mdf_message('Recti-linear coordinates not implemented','Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
end

%
% copy grid file to Delft3D-directory
%

if ~isempty(mdf.filcco)
    if ~exist([mdf.pathd3d filesep simona2mdf_rmpath(mdf.filcco)],'file');
        copyfile([mdf.pathsimona filesep mdf.filcco],[mdf.pathd3d filesep simona2mdf_rmpath(mdf.filcco)]);
    end
%  mdf        = rmfield(mdf,'pathsimona');
%  mdf        = rmfield(mdf,'pathd3d');
   mdf.filcco = simona2mdf_rmpath(mdf.filcco);
end

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.GRID.AREA')
   mdf.grdang    = siminp_struc.ParsedTree.MESH.GRID.AREA.ANGLEGRID;
   mdf.mnkmax(1) = siminp_struc.ParsedTree.MESH.GRID.AREA.MMAX;
   mdf.mnkmax(2) = siminp_struc.ParsedTree.MESH.GRID.AREA.NMAX;
   mdf.mnkmax(3) = siminp_struc.ParsedTree.MESH.GRID.AREA.KMAX;

   %
   % For now: assume uniform layer thicknesses
   %
   siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'VERTICAL'});
   if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.VERTICAL')
       mdf.thick =  cell2mat({siminp_struc.ParsedTree.MESH.VERTICAL.LAYER(:).THICKNESS});
   else
       mdf.thick(1:mdf.mnkmax(3)) = 100./mdf.mnkmax(3);
   end
end

%
% The enclosure
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BOUNDARIES' 'ENCLOSURES'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BOUNDARIES.ENCLOSURES.E')
    enc = siminp_struc.ParsedTree.MESH.BOUNDARIES.ENCLOSURES.E;

    MN = [];
    for i_enc = 1: length(enc)
        MN = [MN ; reshape(enc(i_enc).COORDINATES,2,[])'];
    end

    file_enc   = [name_mdf '.enc'];
    mdf.filgrd = file_enc;
    enclosure ('write',file_enc,MN);
    mdf.filgrd = simona2mdf_rmpath(mdf.filgrd);
end

