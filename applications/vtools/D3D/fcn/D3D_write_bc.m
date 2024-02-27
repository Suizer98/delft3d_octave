%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17818 $
%$Date: 2022-03-14 18:41:37 +0800 (Mon, 14 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_write_bc.m 17818 2022-03-14 10:41:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_bc.m $
%
function D3D_write_bc(fpath,bc)

%% RENAME

nbc=numel(bc);

%% CALC
fid=fopen(fpath,'w');

for kbc=1:nbc
    
    % [forcing]
    % Name                            = rmm_rivpli_1_hagestein_lek_0001
    % Function                        = timeseries
    % Time-interpolation              = linear
    % Quantity                        = time
    % Unit                            = minutes since 2007-01-01 00:00:00 +01:00
    % Quantity                        = dischargebnd
    % Unit                            = m3/s
    nq=numel(bc(kbc).quantity);
    nt=size(bc(kbc).val,1);
    
    fprintf(fid,'[forcing] \n');
    if any(contains(bc(kbc).quantity,'lateral')) %at a point
        %ATTENTION! this is not robust enough. I am not sure it works well for all cases.
        fprintf(fid,'Name                            = %s \n',bc(kbc).name);
    else %along pli
        fprintf(fid,'Name                            = %s_0001 \n',bc(kbc).name);
    end
    fprintf(fid,'Function                        = %s \n',bc(kbc).function);
    fprintf(fid,'Time-interpolation              = %s \n',bc(kbc).time_interpolation);
    for kq=1:nq
        fprintf(fid,'Quantity                        = %s \n',bc(kbc).quantity{kq});
        fprintf(fid,'Unit                            = %s \n',bc(kbc).unit{kq});
    end
    for kt=1:nt
        fprintf(fid,' %f %f \n',bc(kbc).val(kt,:));
    end %kt

end %kbc

fclose(fid);
% messageOut(NaN,sprintf('File created: %s',fpath))

end %function