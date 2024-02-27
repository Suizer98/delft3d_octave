%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 19:43:41 +0800 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: dam_break_analytical.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/dam_break_analytical.m $
%
%Analytical solution of dam break. Modified from existing in testbench. 
%
%
%INPUT:
%   -xD0 = lower limit of the domain [m].
%   -xDL = upper limit of the domain [m].
%   -dx  = space step for discretizing the domain [m].
%   -hl  = left (high) water depth [m].
%   -hr  = right (low) water depth [m].
%
%OUTPUT:
%
%OPTIONAL (pair input)
%   -x0 = initial position of dam (default = 0)

function [x,h,u]=dam_break_analytical(xD0,xDL,dx,hl,hr,tv,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);
addOptional(parin,'x0',0);

parse(parin,varargin{:})

g=parin.Results.g;
x0=parin.Results.x0;

%% LOOP ON TIME

% tv=(t0:dt:T); %time vector
nt=numel(tv);

x=cell(nt,1);
h=x;
u=x;

for kt=1:nt
    t=tv(kt);
    % Constants
    % hm      = 4./9.*(hl-hr);
    % cm      = sqrt(g.*hm);
    cm      = propagationspeed(hl,hr,g);
    % hm      = cm.^2./g;

    % Divide into four domains
    xA      = x0 -    t.*sqrt(g.*hl);
    xB      = x0 + 2.*t.*sqrt(g.*hl) - 3.*t.*cm;
    xC      = x0 +    t.*(2.*cm.^2.*(sqrt(g.*hl)-cm))./(cm.^2-g.*hr);

    % First part
    x1      = xD0:dx:xA;
    h1      = hl.*ones(1,length(x1));
    u1      = zeros(1,length(x1));

    % Second part: parabola
    x2      = xA:dx:xB;
    h2      = 4./9./g.*(sqrt(g.*hl) - (x2-x0)./2./t).^2;
    u2      = 2./3.*((x2-x0)./t + sqrt(g.*hl));

    % Third part
    x3      = xB:dx:xC;
    h3      = cm.^2./g.*ones(1,length(x3));
    u3      = 2.*(sqrt(g.*hl)-cm).*ones(1,length(x3));

    % Fourth part
    x4      = xC:dx:xDL;
    h4      = hr.*ones(1,length(x4));
    u4      = zeros(1,length(x4));

    % Collect data
    x{kt}       = [x1 x2 x3 x4];
    h{kt}       = [h1 h2 h3 h4];
    u{kt}       = [u1 u2 u3 u4];

end

end %function

%%
%% FUNCTIONS
%%

function [c2] = propagationspeed(h1,h0,g)

% g      = 9.81;
c1     = sqrt(g*h1);
c0     = sqrt(g*h0);
u20    = c0;
z0     = c0;
c20    = c0;
nter   = 200;
tol    = 1e-8;
diff_c20 = 1;
c20m1 = 0;
iter   = 0;

while diff_c20>tol && iter<nter

    aa        =  2*z0-u20;
    ab        = -c20;
    ac        = -z0;
    ad        =  0.5*c0.^2+u20*z0-z0.^2+0.5*(c20).^2;
    ba        = -c20.^2+c0.^2;
    bb        =  2*c20*u20-2*c20*z0;
    bc        =  c20.^2;
    bd        = -c20.^2*u20+c20.^2*z0-c0.^2*z0;
    ca        =  0.0;
    cb        =  2.0;
    cc        =  1.0;
    cd        =  2*c1-u20-2*c20;
    dd        =  aa*(bb*cc-bc*cb)-ab*(ba*cc-bc*ca)+ac*(ba*cb-bb*ca);
    d1        =  ad*(bb*cc-bc*cb)-ab*(bd*cc-bc*cd)+ac*(bd*cb-bb*cd);
    d2        =  aa*(bd*cc-bc*cd)-ad*(ba*cc-bc*ca)+ac*(ba*cd-bd*ca);
    d3        =  aa*(bb*cd-bd*cb)-ab*(ba*cd-bd*ca)+ad*(ba*cb-bb*ca);
    dz        =  d1/dd;
    dc2       =  d2/dd;
    du2       =  d3/dd;
    z0        =  z0+dz;
    c20       =  c20+dc2;
    u20       =  u20+du2;
    
    diff_c20=abs(c20-c20m1);
    c20m1=c20;
    iter=iter+1;
    
end

if iter==nter
    error('did not converge')
end

c2=c20;

end %function