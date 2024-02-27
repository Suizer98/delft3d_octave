%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16814 $
%$Date: 2020-11-19 12:33:47 +0800 (Thu, 19 Nov 2020) $
%$Author: chavarri $
%$Id: phi_func.m 16814 2020-11-19 04:33:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/phi_func.m $
%
%phi_func does this and that
%
%phi = phi_func(theta, input)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:
%160503
%   -L. Created for the first time
%

function phi = phi_func(theta, input)

%% RENAME

type=input.mdv.fluxtype;

%%

if nargin == 1
    type = 0;
    disp('No flux limiter applied');
end
% Flux limiter function
n = max(max(size(theta)));

%Remove NaN
theta(isnan(theta)) = 1;
if type==0              % upwind
    phi = zeros(1,n); 
elseif type==1          % Lax-Wendroff
    phi = ones(1,n);
elseif type==2          % Beam-Warming
    phi = theta;
elseif type==3          % Fromm
    phi = 0.5*(1+theta);
elseif type==4          % minmod
    phi = minmod(ones(1,n),theta);
elseif type==5          % van Leer
    phi = (theta+abs(theta))./(ones(1,n)+abs(theta));
elseif type==6          % superbee
    phi = max(zeros(1,n), max(min(ones(1,n),2*theta), min(2*ones(1,n),theta)));
elseif type == 7        % MC
    phi = max(zeros(1,n), min(2,min((ones(1,n)+theta)/2,2*theta)));
elseif type == 8        % Koren
    phi = max(zeros(1,n), min(2,min((2*ones(1,n)+theta)/3,2*theta)));
else
    error('incorrect fluxtype')
end

%Remove NaN
phi(isnan(phi)) = 1; 
end

function phi = minmod(a,b)
% for vectors pointwise
phi = a.*(abs(a)<abs(b)).*(a.*b>0) + b.*(abs(b)<=abs(a)).*(a.*b>0);
end