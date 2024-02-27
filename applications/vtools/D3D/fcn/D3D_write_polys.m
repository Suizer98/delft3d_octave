%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18081 $
%$Date: 2022-05-27 22:37:49 +0800 (Fri, 27 May 2022) $
%$Author: chavarri $
%$Id: D3D_write_polys.m 18081 2022-05-27 14:37:49Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_polys.m $
%
function D3D_write_polys(path_out,stru_in)

% L000005
%           56           2
%    1.9385889E+05   4.4052012E+05
%    1.9380717E+05   4.4048145E+05

if ~isstruct(stru_in)
    error('Input must be a structure with field <xy> at least')
end

npol=numel(stru_in);

if ~isfield(stru_in,'name')
    for kpol=1:npol
        stru_in(kpol).name=sprintf('L%06d',kpol);
    end %kpol
end
    
fid=fopen(path_out,'w');

for kpol=1:npol
    
    [nv,ni]=size(stru_in(kpol).xy);
    str_w=repmat('    %9.8E',1,ni);
    str_we=strcat(str_w,'\n');
    
    
    if isa(stru_in(kpol).name,'double')
        fprintf(fid,'L%06d \n',stru_in(kpol).name); 
    elseif isa(stru_in(kpol).name,'char')
        fprintf(fid,'%s \n',stru_in(kpol).name); 
    end
    fprintf(fid,'           %d           %d \n',nv,ni); 
    for kv=1:nv
        fprintf(fid,str_we,stru_in(kpol).xy(kv,:)); 
    end

end

fclose(fid);

end %function
