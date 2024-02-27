%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17700 $
%$Date: 2022-02-01 16:11:39 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: inpolygon_chunks.m 17700 2022-02-01 08:11:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/inpolygon_chunks.m $
%
%inpolygon in chunks

function in_bol=inpolygon_chunks(nodesX,nodesY,x_pol,y_pol,nc)

np=numel(nodesX);
npc=floor(np/nc);
idx=1:npc:np;
idx(end)=np+1;
in_bol=false(np,1);

tic;
for kc=1:nc
    idx_loc=idx(kc):1:idx(kc+1)-1;
    in_bol(idx_loc)=inpolygon(nodesX(idx_loc),nodesY(idx_loc),x_pol,y_pol);
    fprintf('%4.2f %% in %5.0f s idx_s = %d idx_f = %d \n',kc/nc*100,toc,idx_loc(1),idx_loc(end));
end

end %function