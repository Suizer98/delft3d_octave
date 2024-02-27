%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_write_lat.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_lat.m $
%
function D3D_write_lat(fpath,lat)

%% RENAME

nlat=numel(lat);

%% CALC
fid=fopen(fpath,'w');

for klat=1:nlat

    % [lateral]
    % Id             = Lopikerwaard
    % Type           = discharge
    % locationType   = 2d
    % numCoordinates = 1
    % xCoordinates   = 123672.0000
    % yCoordinates   = 441333.0000
    % discharge      = ../../boundary_conditions/flow/run010_lateral.bc

    %add to ext file
    fprintf(fid,'[lateral]                                                         \n');
    fprintf(fid,'Id             = %s                                     \n',lat(klat).id);
    fprintf(fid,'Type           = discharge                                        \n');
    fprintf(fid,'locationType   = 2d                                               \n');
    fprintf(fid,'numCoordinates = 1                                                \n');
    fprintf(fid,'xCoordinates   = %f                                      \n',lat(klat).x_coordinates);
    fprintf(fid,'yCoordinates   = %f                                      \n',lat(klat).y_coordinates);
    fprintf(fid,'discharge      = %s                                      \n',lat(klat).discharge);
    
end %kbc

fclose(fid);
messageOut(NaN,sprintf('File created: %s',fpath))
end %function