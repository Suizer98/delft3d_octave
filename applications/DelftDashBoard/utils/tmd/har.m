function [hc,amp,fi,hhat,con]=har(time,h,nc);
% Harmonically analyze tidal time series, taking nodal corrections into
%   account. (Hence, appropriate to multi-year time series like satellite
%   altimetry.)
%
% For regular, adequately sampled time series like hourly GPS or bottom
%   pressure records, use the 'T_TIDE' package from Rich Pawlowicz,
%   http://www2.ocgy.ubc.ca/~rich/#T_Tide, based on the classic FORTRAN
%   tidal analysis packages written by Mike Foreman
%   (http://www.pac.dfo-mpo.gc.ca/sci/osap/projects/tidpack/tidpack_e.htm).
%
% INPUTS:  time(n) (days) in Matlab 'datenum' format;
%          h(n - tidal time series measured at time;
%          nc  - number of constituents (if not specified, nc=8);
%
%          nc=1->con=['m2  '];
%          nc=2->con=['m2  ';'k1  '];
%          nc=3->con=['m2  ';'k1  ';'o1  ';]
%          nc=4->con=['m2  ';'s2  ';'k1  ';'o1  ';]
%          nc=5->con=['m2  ';'s2  ';'k1  ';'o1  ';'p1  '];
%          nc=6->con=['m2  ';'s2  ';'n2  ';'k1  ';'o1  ';'p1  '];
%          nc=8->con=['m2  ';'s2  ';'n2  ';'k2  '; ...
%                     'k1  ';'o1  ';'p1  ';'q1  '];
%
% OUTPUTS: hc   - harmonic constant vector (complex);
%          amp  - amplitude vector;
%          fi   - phase, degrees;
%          hhat - time series reconstructed using HC.m;
%          con  - constituent IDs (ncx4 character string).
%
% USAGE: [hc,amp,fi,hhat,con]=har(time,h,nc);
%
% Written by Lana Erofeeva (COAS, Oregon State University);
%
% Modified 18-March-2005 by Laurie Padman (ESR), to change time input to
%   Matlab 'datenum' time for consistency with other TMD package routines.
%
%=========================================================================

if(nargin<3); % nc not specified.
    nc=8;
end

time=time-datenum(1992,1,1);  % Correct to time-relative-1/1/1992 for
%                                 consistency with OSU OTIS

[n,m]=size(time);
if n==1, time=time';end
[n,m]=size(h);
if n==1, h=h';end
L=length(time);
if nc==8,
    con=['m2  ';'s2  ';'n2  ';'k2  ';'k1  ';'o1  ';'p1  ';'q1  '];
elseif nc==1,
    con=['m2  ';];
elseif nc==2,
    con=['m2  ';'k1  '];
elseif nc==3,
    con=['m2  ';'k1  ';'o1  '];
elseif nc==4,
    con=['m2  ';'s2  ';'k1  ';'o1  '];
elseif nc==5,
    con=['m2  ';'s2  ';'k1  ';'o1  ';'p1  '];
elseif nc==6,
    con=['m2  ';'s2  ';'n2  ';'k1  ';'o1  ';'p1  '];
end

% Get basic constituent properties from constit.m
for k=1:nc
    [ispec(k),amp(k),ph(k),omega(k),alpha(k),cNum]=constit(con(k,:));
end

h=h-mean(h);    % Remove mean from time series

% Get nodal amplitude and phase corrections
[pu,pf]=nodal(time+48622,con);

A=[];      % Define matrix A to be solved in a least-squares sense
for k=1:nc
    a=  pf(:,k).*cos(omega(k)*time*86400.+ph(k)+pu(:,k));
    b= -pf(:,k).*sin(omega(k)*time*86400.+ph(k)+pu(:,k));
    A=[A a b];
end
%A=A;
% W=diag(diag(ones(L)));
% solve lsq problem
% [x,dx]=lscov(A,h,W);
% solve lsq problem (A*x=h);
R=qr(A);
x=R\(R'\(A'*h));
r=h-A*x;
e=R\(R'\(A'*r));
x=x+e;
% find phase
for k=1:nc
    fi(k)=atan2(-x(2*k),x(2*k-1));
end
% find amplitude
for k=1:nc
    amp(k)=abs(i*x(2*k)+x(2*k-1));
end
amp=amp';
fi=fi';
% check fit
hhat=zeros(1,L);
for k=1:nc
    arg=  pf(:,k).*x(2*k-1).*cos(omega(k)*time*86400+ph(k)+pu(:,k))...
        - pf(:,k).*x(2*k)  .*sin(omega(k)*time*86400+ph(k)+pu(:,k));
    hhat=hhat+arg';
end
fi=fi*(180/pi);                     % Convert to degrees
fi(find(fi<0))=fi(find(fi<0))+360;  % Convert to (0,360)
hc=x(1:2:end)+i*x(2:2:end);
return