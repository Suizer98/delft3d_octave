%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18070 $
%$Date: 2022-05-21 00:33:29 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: fprintf_structure.m 18070 2022-05-20 16:33:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/fprintf_structure.m $
%

function fprintf_structure(fid_log,stru)

if isnan(fid_log)
    fid_log=1;
end

fn=fieldnames(stru);
nf=numel(fn);
for kf=1:nf
    stru_loc=stru.(fn{kf});
    if isstruct(stru_loc)
        fprintf(fid_log,' \n');
        fprintf(fid_log,'BLOCK %s \n',fn{kf});
        fprintf_structure(fid_log,stru_loc);
    else
        if ischar(stru_loc) 
            fprintf(fid_log,'%s: %s \n',fn{kf},stru_loc);
        elseif isa(stru_loc,'double')
            fprintf(fid_log,'%s: %f \n',fn{kf},stru_loc);
        elseif islogical(stru_loc)
            fprintf(fid_log,'%s: %d \n',fn{kf},stru_loc);
        elseif iscell(stru_loc)
            nc=numel(stru_loc);
            for kc=1:nc
                fprintf(fid_log,'%s: %s \n',fn{kf},stru_loc{kc});
            end
        else
            error('add')
        end
    end
end

end %function

