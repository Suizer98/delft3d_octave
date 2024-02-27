%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 16:11:11 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: elder.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/elder.m $
%
%

function [nu,nu_s]=elder(h,u,ci,varargin)

parin=inputParser;

addOptional(parin,'friction_type',1);

parse(parin,varargin{:});

friction_type=parin.Results.friction_type;

g=9.81;
kappa=0.41;

switch friction_type
    case 1 %C_f (non-dimensional)
        cf=ci;
    case 2 %C (Chezy)
        cf=g/ci^2;
end

ust=sqrt(cf)*u;
nu=1/6*kappa*h*ust;
nu_s=5.93*h*ust;

end %function

