%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: grain_size_dX.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/grain_size_dX.m $
%
%computes the grain size <dX> such that percentage <perc> passes 
%considering the fraction for each grain size <Fa>. 
%
%INPUT:
%   -dk = characteristic grain size [L]; double(nf,1)
%   -Fa = fraction content for each dk [-] \in [0,1]; double(nf,1);
%   -perc = percentage passing [-] \in [0,100]; double(1,1);
%
%OUPUT
%   -dX = grain size for <perc> passing [L]; double(1,1);
%
%e.g
%
%dk=[0.001,0.002,0.003];
%Fa=[0.1,0.2,0.7];
%perc=50;
%dX=grain_size_dX(dk,Fa,perc);
%figure
%hold on
%plot(dk,cumsum(Fa),'*-')
%scatter(dX,perc/100)

function dX=grain_size_dX(dk,Fa,perc)

%% PARSE

percf=perc/100;
dk=reshape(dk,[],1);
Fa=reshape(Fa,[],1);

if numel(dk)~=numel(Fa)
    error('dimensions do not agree')
end
if min(Fa)<0-1e-6 || max(Fa)>1+1e-6
    error('fractions<0 or fractions>1')
end
% if perc<=0
%     error('percentage must be larger than 0')
% end
if perc<1
    warning('are you sure you want to compute d%f?',perc)
end
if perc>100
    error('percentage cannot be larger than 100')
end

%% CALC

%padding dk (assumption!)
dk=[dk(1)/2;dk;dk*2];
Fa=[0;Fa;0];

Fac=cumsum(Fa);
Fac(end)=1+1e-8; %trick to be able to ask for perc=100, it affects the padding value only. 
idx_i=find(Fac<=percf,1,'last');
idx_f=find(Fac>percf,1,'first');

if idx_f<=idx_i
    error('something is wrong here')
end

dX=interp1(Fac([idx_i,idx_f]),dk([idx_i,idx_f]),percf);

end %function
