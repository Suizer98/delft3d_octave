%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17078 $
%$Date: 2021-02-19 13:31:44 +0800 (Fri, 19 Feb 2021) $
%$Author: chavarri $
%$Id: addTiles.m 17078 2021-02-19 05:31:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/addTiles.m $
%
%add tiles to figure

function addTiles(path_tiles,unitx,unity)

%% RENAME 

%% ADD

load(path_tiles,'tiles')
[nx,ny,~]=size(tiles);
for kx=1:nx
    for ky=1:ny
         surf(tiles{kx,ky,1}.*unitx,tiles{kx,ky,2}.*unity,zeros(size(tiles{kx,ky,2})),tiles{kx,ky,3},'EdgeColor','none')
    end
end
