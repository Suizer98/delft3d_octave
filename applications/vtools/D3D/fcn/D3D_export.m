%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17700 $
%$Date: 2022-02-01 16:11:39 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_export.m 17700 2022-02-01 08:11:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_export.m $
%
%get data from 1 time step in D3D, output name as in D3D

function D3D_export(fpath_out,sim_id,br_id,x_wr,x_v_wr,refdata_wr,y_v_wr,zlab_wr,z_m_wr)

            
nx=numel(x_v_wr);
str_x=repmat('%16.4f, ',1,nx);
str_x(end-1:end)='';
str_x=[str_x,' \r\n'];

ny=numel(y_v_wr);
%as date
%             str_y='';
%             for ky=1:ny
%                 str_y=sprintf('%s, %s',str_y,datestr(y_v_wr(ky),'yyyymmdd HH:MM'));
%             end
%             str_y(1:2)='';

str_yz=repmat('%16.4f, ',1,ny);
str_yz(end-1:end)='';
str_yz=[str_yz,' \r\n'];

fid=fopen(fpath_out,'w');
                                
fprintf(fid,'simulation      : %s \r\n',sim_id);
fprintf(fid,'branch          : %s \r\n',br_id);
fprintf(fid,'x (%03d rows)    : %s \r\n',nx,x_wr);
% fprintf(fid,'y (%03d columns) : time [yyyymmdd HH:SS] \r\n',ny);
fprintf(fid,'y (%03d columns) : seconds since %s \r\n',ny,refdata_wr);
fprintf(fid,'z               : %s \r\n',zlab_wr);
fprintf(fid,'x-vector: \r\n');
fprintf(fid,str_x,x_v_wr);
fprintf(fid,'y-vector: \r\n');
% fprintf(fid,'%s \r\n',str_y); %print as date
fprintf(fid,str_yz,y_v_wr); %print as seconds
fprintf(fid,'z-matrix: \r\n');
for kx=1:nx
    fprintf(fid,str_yz,z_m_wr(kx,:));
end %kx
fclose(fid);

end %function