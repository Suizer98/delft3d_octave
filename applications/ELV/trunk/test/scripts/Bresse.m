%Bresse solution of the backwater curve

%THINGS TO IMPLEMENT:
%   -check the kind of backwater curve at add a warning if the numerical
%   solution does not match the expected trend based on the kind of bwc

function out=Bresse(in)

%% RENAME

s=in.s; %streamwise position with known flow depth, positive downstream [m]
s2=in.s2; %streamwise position in which we want to know the flow depth, positive downstream [m]
ib=in.ib; %bed slope [-]
Cf=in.Cf; %dimensionless friction coefficient [-]
h=in.h; %flow depth at 's' [m]
H=in.H; %normal flow depth [m]

%% CLASSIFY

% g=9.81; %gravity constant [m/s^2]
% q=sqrt(H^3*ib*g/Cf); %specific flow discharge [m^2/s]
% hc=(q^2/g)^(1/3); %critical depth [m]
% 
% if ib==0
%     type=1; %H
% elseif ib<0
%     type=2; %A
% elseif Cf==ib
%     type=3; %C
% elseif Cf<ib
%     if h>H
%        type=41'; %M1 
%     elseif h>hc
%         %M2
%     else
%         %M3
%     end
% elseif Cf>ib
%     type=5; %S
% end

%% PARAMETERS

a=ib/Cf;
x=h/H;

%% CALCULATION

%depth
F=@(x2_v)x-x2_v-(1-a^3)*(psi(x)-psi(x2_v))-ib/H*(s-s2); %function to find the 0

% if type==41;
    x2_0=x;
% end

x2=fzero(F,x2_0);

%length scale of the bwc
x2_L12=(x+1)/2; %obtained by imposing (h2-H)/(h-H)=0.5
L12=H/ib*(x-x2_L12-(1-a^3)*(psi(x)-psi(x2_L12)));

%% OUT

h2=x2*H;

out.L12=L12;
out.h2=h2;

end

%% -------------------
% END OF MAIN FUNCTION
% --------------------
%%

%% psi(x)
function out=psi(x)

out=1/6*log((x^2+x+1)/(x-1)^2)-sqrt(3)/3*acot((2*x+1)/sqrt(3));

end
