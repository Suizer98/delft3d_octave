%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_aru_arv.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_aru_arv.m $
%


%%

% clear
% clc
% 
% paths=generate_paths_delft3d_4rijn2017v1;
% paths_grd_in=paths.paths_grd_in;
% paths_aru_in=paths.paths_aru_in;
% paths_arv_in=paths.paths_arv_in;
% paths_arl_out=paths.paths_arl_out;
% add_D3D_paths

function D3D_convert_aru_arv(paths_grd_in,paths_aru_in,paths_arv_in,paths_arl_out)

%%

nd=numel(paths_grd_in);

aux_t=[];

for kd=1:nd
    
    %read grid
    grid   = delft3d_io_grd('read',paths_grd_in{kd,1});
%     x_u    = grid.u.x';
%     y_u    = grid.u.y';
%     x_v    = grid.v.x';
%     y_v    = grid.v.y';
    x_u    = grid.u_full.x';
    y_u    = grid.u_full.y';
    x_v    = grid.v_full.x';
    y_v    = grid.v_full.y';
    
    dim_max(1,:)=size(x_u);
    dim_max(2,:)=size(x_v);

    %aru
    for kf=1:2
        if kf==1 %aru
            ar=delft3d_io_aru_arv('read',paths_aru_in{kd,1});
        else %arv
            ar=delft3d_io_aru_arv('read',paths_arv_in{kd,1});
        end
        
        ne=numel(ar.data);
        %do not preallocate aux, a point may lay outside the grid
        kc=1;
        for ke=1:ne
%             if ar.data{1,ke}.m<dim_max(kf,1) && ar.data{1,ke}.n<dim_max(kf,2) %always true if using _full grid
            if kf==1 %aru
                x_aux=x_u(ar.data{1,ke}.m,ar.data{1,ke}.n);
                y_aux=y_u(ar.data{1,ke}.m,ar.data{1,ke}.n);
            else %arv
                x_aux=x_v(ar.data{1,ke}.m,ar.data{1,ke}.n);
                y_aux=y_v(ar.data{1,ke}.m,ar.data{1,ke}.n);
            end %kf
            if ~isnan(x_aux) && ~isnan(y_aux)
                aux(kc,1)=x_aux;
                aux(kc,2)=y_aux;
                aux(kc,3)=0;
                aux(kc,4)=ar.data{1,ke}.definition;
                aux(kc,5)=ar.data{1,ke}.percentage;
                
                kc=kc+1;
            end %write or not
        end %ke

        %combine
        aux_t=[aux_t;aux];
    end %kf
    
    
end %kd

%test NaN
isnan(aux_t(:,1));

%% write

matrix=aux_t;
file_name=paths_arl_out;

nx=size(matrix,2);
ny=size(matrix,1);

    %check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
write_str_x='%f %f %f %d %f \n'; %string to write in x

for ky=1:ny
    fprintf(fileID_out,write_str_x,matrix(ky,:));
end

fclose(fileID_out);


% end %function
