%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17637 $
%$Date: 2021-12-09 05:21:26 +0800 (Thu, 09 Dec 2021) $
%$Author: chavarri $
%$Id: Villemonte_cdd.m 17637 2021-12-08 21:21:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/Villemonte_cdd.m $
%
%The option for Sieben's approximation is based on <D-Flow_FM_Technical_Reference_Manual.pdf> 
%Version: 1.1.0; SVN Revision: 72877; 27 September 2021 but correcting for the erratas based on checking the source code.
%

function [c_dd,c_dm,c_dr,S]=Villemonte_cdd(E1,E2,varargin)


%% parameters

OPT.type=1; %1=true Villemonte, 2=implemented in Delft3D FM (Arjan Sieben) 

OPT.c1=1; %C 1 is a user-specified calibration coefficient. The Tabellenboek measurements correspond to the default value C 1 = 1,
OPT.c2=10; %C 2 is a user-specified calibration coefficient. It has a default value C 2 = 10, which is the value for hydraulically smooth weirs. For hydraulically rough weirs, the recommended value is C 2 = 50.
OPT.m1=4; %user-specified ramp of the upwind slope toward the weir ratio of ramp length and height, [ ? ], default 4.0
OPT.m2=4; %user-specified ramp of the downwind slope from the weir ratio of ramp length and height [ ? ], default 4.0
% OPT.m=1/2; %in Villemonte it is 0.385 but the power of the submergence ratio is different. See <Yossef18> referencing to Ali13
OPT.L=3; %L crest is the length of the weir’s crest [ m ] in the direction across the weir (i.e., in the direction of the flow).
OPT.d1=zeros(size(E1)); %sill height (distance from bed level to crest height)

OPT=setproperty(OPT,varargin{:});

c1=OPT.c1;
c2=OPT.c2;
m1=OPT.m1;
m2=OPT.m2;
% m=OPT.m;
L=OPT.L;
d1=OPT.d1;
if all(d1==0) 
    if OPT.type==1
        warning('Weir height is not specified and its effect neglected')
        d1=inf;
    elseif OPT.type==2
%         error('you need to specify a sill height')
    end
end
if numel(d1)==1
    d1=d1.*ones(size(E1));
elseif any(size(d1)~=size(E1))
    error('dimensions do not agree')
end


%%

switch OPT.type
    case 1 %Villemonte (see also e.g. Swamee88 (J. Hydraul. Eng. 1988.114:945-949))
        %c_dm
        c_dm=0.611+0.075.*E1./d1;
        
        %p
        p=1.5;
        
        %m
        m=0.385;
    case 2 % Sieben
        %c_dm
        w=exp(-0.5*E1./L);
        G2=4/5+13/20*exp(-m2/10);
        G1=1-1/4*exp(-m1/2);
        b1=w.*G1+(1-w).*G2;
        cd0=c1.*b1;
        %in <D-Flow_FM_Technical_Reference_Manual.pdf> the critical discharge
        %is defined as 2/3E*sqrt(2g/3E) but we define it as Cd*2/3*sqrt(2g)E^(3/2)
        %they differ by 1/sqrt(3)
        c_dm=1/sqrt(3)*cd0;
        
        %p
        D=d1./E1;
        F=1-exp(-m2/c2);
        B1=1+D.*F;
        B2=1+D;
        A=1./B1.^2-1./B2.^2;
        p=27/4./cd0.^2./A;
        
        %m
        m=1/2;
        
        %check
%         if any(p)==inf || isnan(p) || any(p<0)
%             error('ups...')
%         end
end

S=E2./E1;
S(S>1)=1; %rounding error can happen
S(S<0)=0;
aux=1-S.^p;
aux(aux<0)=0;
c_dr=aux.^m;

c_dd=c_dm.*c_dr;

end %function