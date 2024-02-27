%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17120 $
%$Date: 2021-03-22 15:37:52 +0800 (Mon, 22 Mar 2021) $
%$Author: chavarri $
%$Id: D3D_export_1d_net.m 17120 2021-03-22 07:37:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_export_1d_net.m $
%
%export kml of 1d network

function D3D_export_1d_net(path_net,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'epsg',28992,@isnumeric);
addOptional(parin,'path_kml',strrep(path_net,'.nc','.kml'),@isnumeric);

parse(parin,varargin{:});
epsg_in=parin.Results.epsg;
path_kml=parin.Results.path_kml;

%% READ

geom_node_count=ncread(path_net,'network1d_geom_node_count');
geom_x=ncread(path_net,'network1d_geom_x');
geom_y=ncread(path_net,'network1d_geom_y');
br_name=ncread(path_net,'network1d_branch_id')';

[geom_long,geom_lat]=convertCoordinates(geom_x,geom_y,'CS1.code',epsg_in,'CS2.code',4326);

%% ORDER

nb=numel(geom_node_count);
geom_node_count_cs=[0;cumsum(geom_node_count)];
geom_br=cell(nb,1);
for kb=1:nb
%     geom_br{kb,1}=[geom_x(geom_node_count_cs(kb)+1:geom_node_count_cs(kb+1)),geom_y(geom_node_count_cs(kb)+1:geom_node_count_cs(kb+1))];
geom_br{kb,1}=[geom_long(geom_node_count_cs(kb)+1:geom_node_count_cs(kb+1)),geom_lat(geom_node_count_cs(kb)+1:geom_node_count_cs(kb+1))];
end

%% WRITE

fid=fopen(path_kml,'w');


%header
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>           \n');
fprintf(fid,'<!--x=x+                  -->                    \n');
fprintf(fid,'<!--y=y+                  -->                    \n');
fprintf(fid,'<kml xmlns="http://earth.google.com/kml/2.1">    \n');
fprintf(fid,'<Document>                                       \n');
fprintf(fid,'	<name>rijn-flow-model_net</name>              \n');
fprintf(fid,'	<Style id="style_1">                          \n');
fprintf(fid,'		<LineStyle>                               \n');
fprintf(fid,'			<color>FF0000FF</color>               \n');
fprintf(fid,'			<width>1</width>                      \n');
fprintf(fid,'		</LineStyle>                              \n');
fprintf(fid,'		<PolyStyle>                               \n');
fprintf(fid,'			<fill>0</fill>                        \n');
fprintf(fid,'		</PolyStyle>                              \n');
fprintf(fid,'	</Style>                                      \n');


%loop on branches
for kb=1:nb
    fprintf(fid,'	<Placemark>                                   \n');
    fprintf(fid,'		<name>%s</name>                            \n',br_name(kb,:));
    fprintf(fid,'		<styleUrl>style_1</styleUrl>              \n');
    fprintf(fid,'		<LineString>                              \n');
    % fprintf(fid,'			<tessellate>1</tessellate>            \n');
    fprintf(fid,'			<coordinates>                         \n');

    %coordinates
    np=size(geom_br{kb,1},1);
    for kp=1:np
        fprintf(fid,'            %f,%f \n',geom_br{kb,1}(kp,1),geom_br{kb,1}(kp,2));
    end %kp

    fprintf(fid,'			</coordinates>  \n');
    fprintf(fid,'		</LineString>       \n');
    fprintf(fid,'	</Placemark>            \n');

    %display
%     messageOut(NaN,sprintf('branch finished %4.3f %%',kb/nb*100));

end %kb

%EOF

fprintf(fid,'	</Document>  \n');
fprintf(fid,'</kml>          \n');

fclose(fid);

messageOut(NaN,sprintf('file written: %s',path_kml));

%% PLOT internal
if 0
figure
hold on
for kb=1:nb
plot(geom_br{kb,1}(:,1),geom_br{kb,1}(:,2))
end
end