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
%$Id: initial_noise.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/initial_noise.m $
%
%initial_noise adds noise to the data
%
%[etab]=initial_noise(etab,input)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%180516
%   -V. Created for the first time.
%200403
%   -V. Added trench possibility.

function [y,z]=initial_noise(y,z,input)
% version='1';
% fprintf(fid_log,'initial_condition_construction: %s\n',version);

%%
%% RENAME
%%

xcen=input.mdv.xcen;
xedg=input.mdv.xedg;

switch input.ini.noise
    case 1
        
    case 2
        trench_x=input.ini.trench.x;
        dz=input.ini.trench.dz; 
end

%% 

switch input.ini.noise
    case 1
        y=y+input.ini.noise_param(1)*sin(2*pi/input.ini.noise_param(2)*xcen);
    case 2
        %x coordinate
        [~,xc(1)]=min(abs(xedg-trench_x(1)));
        [~,xc(2)]=min(abs(xedg-trench_x(2)));
%         nxcp=xc(2)-xc(1)+1; %number of xcells in the patch
        
        y(xc(1):xc(2))=y(xc(1):xc(2))+dz;
        z(xc(1):xc(2))=z(xc(1):xc(2))-dz;

end

end %function
