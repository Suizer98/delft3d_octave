%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_topo_faces_rec.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_topo_faces_rec.m $
%
function topo_faces=D3D_topo_faces_rec(nx,ny)

topo_faces=NaN(ny,nx);
nfa=nx*ny;
% topo_faces(1,1)=1;
kx=1;
ky=1;
for kfa=1:nfa
    topo_faces(ky,kx)=kfa;

if any(any(isnan(topo_faces)))
    %first direction
    kx=kx-1;
    ky=ky+1;
    try topo_faces(ky,kx);
        %nothing to be done
    catch
        %search first empty in x
        ky=1;
        x_n=find(isnan(topo_faces(ky,:)));
        while isempty(x_n)
            ky=ky+1;
            x_n=find(isnan(topo_faces(ky,:)));
        end
        kx=x_n(1);
    end
else
    %the matrix is full
end

end %function