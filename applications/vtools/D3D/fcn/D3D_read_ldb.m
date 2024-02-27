%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18271 $
%$Date: 2022-08-01 22:24:23 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_read_ldb.m 18271 2022-08-01 14:24:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_ldb.m $
%

%For plotting:

% nldb=numel(ldb);
% for kldb=1:nldb
%     plot(ldb(kldb).cord(:,1),ldb(kldb).cord(:,2),'parent',han.sfig(kr,kc),'color','k','linewidth',prop.lw1,'linestyle','-','marker','none')
% end

function LINE=D3D_read_ldb(paths_ldb_in)

nd=numel(paths_ldb_in);

for kd=1:nd

    filldb = paths_ldb_in{kd,1};
    LINE   = [];
    ldb=landboundary('read',filldb);
    idx_ldb=cumsum(isnan(ldb(:,1)))+1; %add 1 to start at 1 rather than 0
    nldb=idx_ldb(end); 

    for kldb=1:nldb
        LINE(kldb).cord=ldb(idx_ldb==kldb,:);
    end %kldb

end %kd

end %function
