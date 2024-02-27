%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: grainsize_dX.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/grainsize_dX.m $
%
%compute DX
%
%INPUT:
%   - Fak = volume fraction content of all size fractions [-] [nf,ns]
%   - dk = characteristic grain sizes [m] [nf,1]
%   - dlim = limit value [%] [1,1]; e.g. 90

function dX=grainsize_dX(Fak,dk,dlim)

dlim_frac=dlim/100;

[nf,nx]=size(Fak);

dint=[dk(1);sqrt(dk(1:end-1).*dk(2:end));dk(end)];
cFak=zeros(nf+1,nx);
cFak(2:end,:)=cumsum(Fak,1);

dX=NaN(1,nx);
for kx=1:nx
    idx_inf=find(cFak(:,kx)<=dlim_frac,1,'last');
%     dX(1,kx)=interp1(cFak(idx_inf:idx_inf+1,kx),dint(idx_inf:idx_inf+1),dlim_frac); %slowest thing in the world
    dX(1,kx)=dint(idx_inf)+diff(dint(idx_inf:idx_inf+1))/diff(cFak(idx_inf:idx_inf+1))*(dlim_frac-cFak(idx_inf));
end

end %function