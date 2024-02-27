function netstruc=loadnetstruc(filename)

netstruc=dflowfm.readNet(filename);





% netstruc.nodeX=nodexp.Value;
% netstruc.nodeY=nodeyp.Value;
% netstruc.nodeZ=zeros(1,nnodes);
% netstruc.linkNodes=enodes.Value';
% netstruc.linkType=nc_varget(fname,'NetLinkType');
%     try
% netstruc.elemNodes=nc_varget(fname,'NetElemNode');
%     end
%     try
% netstruc.bndLink=nc_varget(fname,'BndLink');
%     end
    
    
    %% Finalize
% unloadlibrary('io_netcdf');

