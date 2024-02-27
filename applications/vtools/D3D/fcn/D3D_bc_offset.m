%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17536 $
%$Date: 2021-10-30 03:38:05 +0800 (Sat, 30 Oct 2021) $
%$Author: chavarri $
%$Id: D3D_bc_offset.m 17536 2021-10-29 19:38:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_bc_offset.m $
%
%applies an offset to a BC

function D3D_bc_offset(fpath_wl,offset)

fpath_wl_mod=strrep(fpath_wl,'.bc','_offset_inval.bc');
fid_w=fopen(fpath_wl_mod,'w');
fid_r=fopen(fpath_wl,'r');

kl=0;
while ~feof(fid_r)
    lin=fgets(fid_r);
    tok=regexp(lin,'([+-]?(\d+(\.\d+)?)|(\.\d+))\s+([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens');
    if isempty(tok) 
        fprintf(fid_w,lin);
    else
        if any(ismember(lin,'=')) %the regexp gets: Unit = minutes since 2011-12-22 00:00:00
            fprintf(fid_w,lin);
        else
            fprintf(fid_w,'%s %f \n',tok{1,1}{1,1},str2double(tok{1,1}{1,2})+offset);
        end
    end
    kl=kl+1;
    fprintf('line %d \n',kl)
end

fclose(fid_w);
fclose(fid_r);

