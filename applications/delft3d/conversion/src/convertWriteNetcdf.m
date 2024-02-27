clc;
warning off all;

% Assign coordinates
X                = xh;
Y                = yh;
Z                = zh;

% Determine links between active nodes
NetNode_mask     = ~isnan(X) & ~isnan(Y);
nNetNode         = sum(NetNode_mask(:));
if length(size(X)==2);
    [ContourLink,NetLink] = quat2net(X,Y,'sub2ind',0); % subsind is used because we skip nan coordinates here
    vals                  = find(isnan(X));
else
    warning('NetLink calculation only implemented for curvi-linear meshes')
end
X                = X(NetNode_mask(:));
Y                = Y(NetNode_mask(:));
Z                = Z(NetNode_mask(:));

% Create file (add all NEFIS 'map-version' group info)
nc                   = struct('Name','/','Format','classic'); % hard-coded to allow D-Flow-FM library to read it
nc.Attributes(    1) = struct('Name','title'              ,'Value',  'D-Flow-FM grid file');
nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  'Deltares');
nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/writeNet.m $ $Id: writeNet.m 8313 2013-03-12 13:22:02Z scheel $');
nc.Attributes(end+1) = struct('Name','history'            ,'Value', ['Created on ',datestr(now,'yyyy-mm-ddTHH:MM:SS')]);
nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.4:Deltares-0.1');
nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ','Deltares']);
nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

% Create dimensions
nc.Dimensions(1)     = struct('Name','nNetNode'       ,'Length',nNetNode);
nc.Dimensions(2)     = struct('Name','nNetLink'       ,'Length',size(NetLink,1));
nc.Dimensions(3)     = struct('Name','nNetLinkPts'    ,'Length',2);
nc.Dimensions(4)     = struct('Name','nBndLink'       ,'Length',1);
nc.Dimensions(5)     = struct('Name','nNetElem'       ,'Length',1);
nc.Dimensions(6)     = struct('Name','nNetElemMaxNode','Length',7);

% Create variables
ifld     = 0;

ifld               = ifld + 1;
clear attr dims;
if spher == 0;
    attr(    1)    = struct('Name', 'units'         , 'Value', 'm');
    attr(end+1)    = struct('Name', 'standard_name' , 'Value', 'projection_x_coordinate');
    attr(end+1)    = struct('Name', 'long_name'     , 'Value', 'x-coordinate of net nodes');
    attr(end+1)    = struct('Name', 'grid_mapping'  , 'Value', 'projected_coordinate_system');
else
    attr(    1)    = struct('Name', 'units'         , 'Value', 'degrees_east');
    attr(end+1)    = struct('Name', 'standard_name' , 'Value', 'longitude');
    attr(end+1)    = struct('Name', 'long_name'     , 'Value', 'x-coordinate of net nodes');
    attr(end+1)    = struct('Name', 'grid_mapping'  , 'Value', 'wgs84');
end
attr(end+1)        = struct('Name', 'actual_range'  , 'Value', [nan nan]);
nc.Variables(ifld) = struct('Name'       , 'NetNode_x'     , ...
                            'Datatype'   , 'double'        , ...
                            'Dimensions' , nc.Dimensions(1), ...
                            'Attributes' , attr            , ...
                            'FillValue'  , []); % this doesn't do anything

ifld               = ifld + 1;
clear attr dims;
if spher == 0;
    attr(    1)    = struct('Name', 'units'         , 'Value', 'm');
    attr(end+1)    = struct('Name', 'standard_name' , 'Value', 'projection_y_coordinate');
    attr(end+1)    = struct('Name', 'long_name'     , 'Value', 'y-coordinate of net nodes');
    attr(end+1)    = struct('Name', 'grid_mapping'  , 'Value', 'projected_coordinate_system');
else
    attr(    1)    = struct('Name', 'units'         , 'Value', 'degrees_north');
    attr(end+1)    = struct('Name', 'standard_name' , 'Value', 'latitude');
    attr(end+1)    = struct('Name', 'long_name'     , 'Value', 'y-coordinate of net nodes');
    attr(end+1)    = struct('Name', 'grid_mapping'  , 'Value', 'wgs84');
end
attr(end+1)        = struct('Name', 'actual_range'  , 'Value', [nan nan]);
nc.Variables(ifld) = struct('Name'       , 'NetNode_y'     , ...
                            'Datatype'   , 'double'        , ...
                            'Dimensions' , nc.Dimensions(1), ...
                            'Attributes' , attr            , ...
                            'FillValue'  , []); % this doesn't do anything

ifld               = ifld + 1;
clear attr dims;
attr(    1)        = struct('Name', 'units'         , 'Value', 'm');
attr(end+1)        = struct('Name', 'positive'      , 'Value', 'up');
attr(end+1)        = struct('Name', 'standard_name' , 'Value', 'sea_floor_depth');
attr(end+1)        = struct('Name', 'long_name'     , 'Value', 'Bottom level at net nodes (flow element''s corners)');
attr(end+1)        = struct('Name', 'coordinates'   , 'Value', ['NetNode_x NetNode_y']);
attr(end+1)        = struct('Name', 'grid_mapping'  , 'Value', 'projected_coordinate_system');
attr(end+1)        = struct('Name', 'actual_range'  , 'Value', [1 2]);
attr(end+1)        = struct('Name', '_FillValue'    , 'Value', -999); % this initializes at NaN rather than 9.9692e36
nc.Variables(ifld) = struct('Name'       , 'NetNode_z'     , ...
                            'Datatype'   , 'double'        , ...
                            'Dimensions' , nc.Dimensions(1), ...
                            'Attributes' , attr            , ...
                            'FillValue'  , []); % this doesn't do anything
                        
ifld               = ifld + 1;
clear attr dims;
attr(    1)        = struct('Name', 'standard_name' , 'Value', 'netlink');
attr(end+1)        = struct('Name', 'long_name'     , 'Value', 'link between two netnodes');
nc.Variables(ifld) = struct('Name'       , 'NetLink'           , ...
                            'Datatype'   , 'int32'             , ...
                            'Dimensions' , nc.Dimensions([3 2]), ...
                            'Attributes' , attr                , ...
                            'FillValue'  , []); % this doesn't do anything

ifld               = ifld + 1;
clear attr dims;
attr(    1)        = struct('Name', 'long_name'     , 'Value', 'type of netlink');
attr(end+1)        = struct('Name', 'valid_range'   , 'Value', int32([0 2]));
attr(end+1)        = struct('Name', 'flag_values'   , 'Value', int32([0 1 2]));
attr(end+1)        = struct('Name', 'flag_meanings' , 'Value', 'closed_link_between_2D_nodes link_between_1D_nodes link_between_2D_nodes');
nc.Variables(ifld) = struct('Name'       , 'NetLinkType'     , ...
                            'Datatype'   , 'int32'           , ...
                            'Dimensions' , nc.Dimensions([2]), ...
                            'Attributes' , attr              , ...
                            'FillValue'  , []); % this doesn't do anything
                        
ncwriteschema(netfile, nc);

% Fill variables (always)      
ncwrite(netfile,'NetNode_x',X(:));
ncwrite(netfile,'NetNode_y',Y(:));
ncwrite(netfile,'NetNode_z',Z(:));
ncwriteatt(netfile,'NetNode_x','actual_range',[min(X(:)) max(X(:))]);
ncwriteatt(netfile,'NetNode_y','actual_range',[min(Y(:)) max(Y(:))]);
ncwriteatt(netfile,'NetNode_z','actual_range',[min(Z(:)) max(Z(:))]);
ncwrite(netfile,'NetLink',NetLink');
ncwrite(netfile,'NetLinkType',repmat(int32(2),[1 size(NetLink,1)]));

% Clear the screen
clc;