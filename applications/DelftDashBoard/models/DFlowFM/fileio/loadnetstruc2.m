function netstruc=loadnetstruc(filename)

[pathstr,name,ext] = fileparts(which(mfilename()));

%% Add library and header path
% TODO: AvD: later ship binary dlls in a more standard place than this:
addpath('d:\checkouts\opendelft3d\src\utils_lgpl\io_netcdf\packages\io_netcdf\dll\x64\Debug\');
addpath('d:\checkouts\opendelft3d\src\utils_lgpl\io_netcdf\packages\io_netcdf\include\');

% voeg juiste netcdf pad toe!!!
addpath('d:\checkouts\opendelft3d\src\third_party_open\netcdf\src\win32\2005\libsrc\x64\Debug\');


%% Load library and inspect it
loadlibrary('io_netcdf');
libfunctions('io_netcdf','-full');

%% Prepare reading UGRID file
mode         = 0; % READ_ONLY
ioncidp      = libpointer('int32Ptr', 0);
iconvtypep   = libpointer('int32Ptr', 0);
convversionp = libpointer('doublePtr', 0.0);

%% Prepare for mesh geometry
nmeshp = libpointer('int32Ptr', 0);
nnodep = libpointer('int32Ptr', 0);
nedgep = libpointer('int32Ptr', 0);
nfacep = libpointer('int32Ptr', 0);
nmaxfacenodesp = libpointer('int32Ptr', 0);


%% Open the file
ierr = calllib('io_netcdf','ionc_open',filename,mode,ioncidp,iconvtypep,convversionp);
fprintf('Opened file ''%s'', status: %d\nDetected conventions: %d, v%2.1f\n', filename, ierr, iconvtypep.Value, convversionp.Value);

%% Inquire number of meshes in the file
ierr = calllib('io_netcdf','ionc_get_mesh_count',ioncidp,nmeshp);

%% Inquire the mesh dimensions
imesh = 1; % Only inquire mesh #1 for now
ierr = calllib('io_netcdf','ionc_get_node_count',ioncidp,imesh,nnodep);
ierr = calllib('io_netcdf','ionc_get_edge_count',ioncidp,imesh,nedgep);
ierr = calllib('io_netcdf','ionc_get_face_count',ioncidp,imesh,nfacep);
ierr = calllib('io_netcdf','ionc_get_max_face_nodes',ioncidp,imesh,nmaxfacenodesp);
fprintf('Reading grid #%d from file ''%s'', status: %d\n#nodes:\t%d\n#edges:\t%d\n#faces:\t%d\n', imesh, filename, ierr, nnodep.Value, nedgep.Value, nfacep.Value)

%% Allocate and read the actual grid coordinates
nodexp = libpointer('voidPtrPtr', zeros(1,nnodep.Value));
nodeyp = libpointer('voidPtrPtr', zeros(1,nnodep.Value));
% enodexp = libpointer('voidPtrPtr', zeros(1,nedgep.Value));
% enodeyp = libpointer('voidPtrPtr', zeros(1,nedgep.Value));
% fnodexp = libpointer('voidPtrPtr', zeros(1,nfacep.Value));
% fnodeyp = libpointer('voidPtrPtr', zeros(1,nfacep.Value));
%nodezp = libpointer('voidPtrPtr', zeros(1,nnodep.Value));
enodes  = libpointer('int32Ptr', zeros(2,nedgep.Value));
%fnodes  = libpointer('int32Ptr', zeros(nmaxfacenodesp.Value,nfacep.Value));

%%
ierr = calllib('io_netcdf', 'ionc_get_node_coordinates', ioncidp, imesh, nodexp, nodeyp, nnodep);
% ierr = calllib('io_netcdf', 'ionc_get_node_coordinates', ioncidp, imesh, enodexp, enodeyp, nedgep);
% ierr = calllib('io_netcdf', 'ionc_get_node_coordinates', ioncidp, imesh, fnodexp, fnodeyp, nfacep);
ierr = calllib('io_netcdf', 'ionc_get_edge_nodes', ioncidp, imesh, enodes, nedgep);
%ierr = calllib('io_netcdf', 'ionc_get_face_nodes', ioncidp, imesh, fnodes, nfacep,nmaxfacenodesp);

xp=nodexp.Value;
yp=nodeyp.Value;
% xpe=enodexp.Value;
% ype=enodeyp.Value;
% xpf=fnodexp.Value;
% ypf=fnodeyp.Value;

ifig=gcf;

% figure(100)
% plot(xp,yp,'.');
% hold on
% plot(xpe,ype,'r.');
% plot(xpf,ypf,'g.');

% TODO: AvD: read face_nodes

% figure(ifig);

nnodes=nnodep.Value;


netstruc.node.x=nodexp.Value;
netstruc.node.y=nodeyp.Value;
netstruc.node.z=zeros(1,nnodes);
%netstruc.edge.linkNodes=enodes.Value';
netstruc.edge.NetLink=enodes.Value';
% netstruc.faceNodes=fnodes.Value';
% netstruc.linkType=nc_varget(fname,'NetLinkType');
%     try
% netstruc.elemNodes=nc_varget(fname,'NetElemNode');
%     end
%     try
% netstruc.bndLink=nc_varget(fname,'BndLink');
%     end
    
    
    %% Finalize
unloadlibrary('io_netcdf');

