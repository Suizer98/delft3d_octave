%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 16:11:11 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_bnd_pli_us.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bnd_pli_us.m $
%
%bnd file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bnd_pli_us(simdef)
%% RENAME

% dire_sim=simdef.D3D.dire_sim;
B=simdef.grd.B;
upstream_nodes=simdef.mor.upstream_nodes;
dy=simdef.grd.dy;
fname_pli_u=simdef.pli.fname_u;
fdir_pli=simdef.file.fdir_pli;

switch simdef.grd.type
    case 1
        switch upstream_nodes
            case 1
                cords=[0,B;0,0];
            otherwise
                y0=0;
                x0=0;
                for kun=1:upstream_nodes
                    cords(:,:,kun)=[x0,y0+dy*(kun-1);x0,y0+dy*kun];
                end
        end
	case 3
        %ideally the grid is generated with matlab and the coordinates are
        %put in automatically... whatch out with the '7'
%         switch upstream_nodes
%             case 1
%                 if B<1.75 %Struiksma                  
%                     cords=[1.12500000000000110e+01,-6.99999999999998130e+00;1.27500000000000120e+01,-6.99999999999998220e+00];
%                 else
%                     cords=[10.75,-1;12.75,-1];
%                 end
%             otherwise
%                 if B<1.75 %Struiksma83                  
%                     R=12;
%                     L1=7;
%                 else %Olesen85
%                     R=11.75;
%                     L1=1;
%                 end
%                 x0=R-B/2;
%                 for kun=1:upstream_nodes
%                     %this may be confusing as we add dy to x0. Flow goes up
%                     %at the boundary.
%                     cords(:,:,kun)=[x0+dy*(kun-1),-L1;x0+dy*kun,-L1];
%                 end
%         end
        grd=wlgrid('read',fullfile(simdef.D3D.dire_sim,'grd.grd'));
        switch upstream_nodes
            case 1
                kun=1;
                cords(:,:,kun)=[grd.X(1,1),grd.Y(1,1);grd.X(1,end),grd.Y(1,end)];
            otherwise
                for kun=1:upstream_nodes
                    cords(:,:,kun)=[grd.X(1,kun),grd.Y(1,kun);grd.X(1,kun+1),grd.Y(1,kun+1)];
                end
        end
                
end

    
%% FILE

for kun=1:upstream_nodes
kl=1;
data{kl, 1}=sprintf('%s_%02d',fname_pli_u,kun); kl=kl+1;
data{kl, 1}=        '    2    2'; kl=kl+1;
data{kl, 1}=sprintf('%0.7E  %0.7E %s_%02d_0001',cords(1,1,kun),cords(1,2,kun),fname_pli_u,kun); kl=kl+1;
data{kl, 1}=sprintf('%0.7E  %0.7E %s_%02d_0002',cords(2,1,kun),cords(2,2,kun),fname_pli_u,kun); %kl=kl+1;

%% WRITE

% file_name=fullfile(dire_sim,sprintf('Upstream_%02d.pli',kun));
file_name=fullfile(fdir_pli,sprintf('%s_%02d.pli',fname_pli_u,kun));
writetxt(file_name,data,'check_existing',false)

end