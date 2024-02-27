%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18353 $
%$Date: 2022-09-08 19:39:21 +0800 (Thu, 08 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_is_interrupt.m 18353 2022-09-08 11:39:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_is_interrupt.m $
%

function is_interr=D3D_is_interrupt(simdef,varargin)

simdef=D3D_simpath(simdef);

switch simdef.D3D.structure
    case 1
        kl=search_text_ascii(simdef.file.dia,'*** ERROR Flow exited abnormally',1);
    case 2
        kl=search_text_ascii(simdef.file.dia,'** INFO   : Simulation did not reach stop time',1);
end
is_interr=true;
if numel(kl)>1
    messageOut(NaN,sprintf('Simulation run more than once: %s',simdef.D3D.dire_sim));
    kl=kl(end);
end
if isempty(kl) || isnan(kl)
    is_interr=false;
end

end %function