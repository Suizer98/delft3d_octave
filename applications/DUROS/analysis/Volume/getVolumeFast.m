function [Volume] = getVolumeFast(x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary)
%GETVOLUMEFAST   generic routine to determine volumes on transects
%
% Alternative to getVolume routine. Routine determines volumes on transects. 
% The routine has stricter input requirements than getVolume, but runs ~50
% times faster. Boundaries can only have one variable, and are thus restricted
% to horizontal or vertical planes.
%
%   [Volume] = getVolumeFast(x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary)
%
%   input:
%       x                   = column array with x points (increasing index and positive x in seaward direction)
%       z                   = column array with z points
%       UpperBoundary       = upper horizontal plane of volume area 
%       LowerBoundary       = lower horizontal plane of volume area 
%       LandwardBoundary    = landward vertical plane of volume area 
%       SeawardBoundary     = seaward vertical plane of volume area 
%
% -------------------------------------------------------------
% Version:      Version 1.0, July 2008 (Version 1.0, July 2008)
% By:           <Thijs Damsma (email: t.damsma@student.tudelft.nl)>  
% -------------------------------------------------------------
%% check input
if ~isequal(length(x), length(z))
error('GETVOLUMEFAST:input','~length(x)=length(z)')
end
if UpperBoundary <= LowerBoundary
error('GETVOLUMEFAST:boundaries','UpperBoundary <= LowerBoundary')
end
if LandwardBoundary >= SeawardBoundary
error('GETVOLUMEFAST:boundaries','LandwardBoundary >= SeawardBoundary')
end
if LandwardBoundary < min(x(isfinite(z)))
error('GETVOLUMEFAST:boundaries','LandwardBoundary < min(x)')
end
if SeawardBoundary > max(x(isfinite(z)))
error('GETVOLUMEFAST:boundaries','LandwardBoundary > max(x)')
end
%% Z value of SeawardBoundary
temp=find(x>=SeawardBoundary,1,'first');
if x(temp)==SeawardBoundary
    z_SB=z(temp);
else
    x1=x(temp-1); x2=x(temp);
    z1=z(temp-1); z2=z(temp);
    z_SB=z1+((SeawardBoundary-x1)/(x2-x1)*(z2-z1));
end
x_SB=SeawardBoundary;
%% Z value of LandwardBoundary
temp=find(x>=LandwardBoundary,1,'first');
if x(temp)==LandwardBoundary
    z_LaB=z(temp);
else 
    x1=x(temp); x2=x(temp-1);
    z1=z(temp); z2=z(temp-1);
    z_LaB=z1+((LandwardBoundary-x1)/(x2-x1)*(z2-z1));
end
x_LaB=LandwardBoundary;
%% find all intersections along upper boundary.
temp=logical([~(diff(sign(z-UpperBoundary))==0); 0]);
temp2=find(temp==1);
if isempty(temp2)
    x_UB=NaN;
    z_UB=NaN;
else
    for i=1:length(temp2)
        if z(temp2(i))==UpperBoundary;
            x_UB(i,1)=x(temp2(i));
        else
            x1=x(temp2(i)); x2=x(temp2(i)+1);
            z1=z(temp2(i)); z2=z(temp2(i)+1);
            x_UB(i,1)= x1+((UpperBoundary-z1)/(z2-z1)*(x2-x1));
        end
    end
    z_UB=ones(i,1)*UpperBoundary;
end
%% find all intersections along lower boundary.
temp=logical([~(diff(sign(z-LowerBoundary))==0); 0]);
temp2=find(temp==1);
if isempty(temp2)
    x_LoB=NaN;
    z_LoB=NaN;
else
    for i=1:length(temp2)
        if z(temp2(i))==LowerBoundary;
            x_LoB(i,1)=x(temp2(i));
        else
            x1=x(temp2(i)); x2=x(temp2(i)+1);
            z1=z(temp2(i)); z2=z(temp2(i)+1);
            x_LoB(i,1)= x1+((LowerBoundary-z1)/(z2-z1)*(x2-x1));
        end
    end
    z_LoB=ones(i,1)*LowerBoundary;
end
%% volume
% combine datapoints in polygon to calculate volume
Poly=[LandwardBoundary min(UpperBoundary,z_LaB);... 
    x(x>LandwardBoundary & x<SeawardBoundary) z(x>LandwardBoundary & x<SeawardBoundary);...
    SeawardBoundary max(LowerBoundary,z_SB);...
    x_UB(x_UB>LandwardBoundary & x_UB<SeawardBoundary) z_UB(x_UB>LandwardBoundary & x_UB<SeawardBoundary);...
    x_LoB(x_LoB>LandwardBoundary & x_LoB<SeawardBoundary) z_LoB(x_LoB>LandwardBoundary & x_LoB<SeawardBoundary)]; 
% clip to upper/lower boundary
Poly(:,2)=min(Poly(:,2),ones(length(Poly),1)*UpperBoundary);
Poly(:,2)=max(Poly(:,2),ones(length(Poly),1)*LowerBoundary);
% inlined sorting of Poly
[ignore,ind]=sort(Poly(:,1)); 
Poly=Poly(ind,:);
% determine bin widths
Poly(1:end-1,3)=diff(Poly(:,1));
Poly(2:end,4)=diff(Poly(:,1));
% bin volumes
Poly(:,5)=(Poly(:,2)-LowerBoundary).*(Poly(:,3)+Poly(:,4))/2;
% total volume
Volume=sum(Poly(:,5));
%% plot (visualize proces)
% x2 = [SeawardBoundary LandwardBoundary LandwardBoundary SeawardBoundary SeawardBoundary]';
% z2 = [UpperBoundary UpperBoundary LowerBoundary LowerBoundary UpperBoundary]';
% 
% plot(x,z,x2,z2)
% hold on
% plot(x_SB,z_SB,'ko',x_LaB,z_LaB,'ro',x_UB,z_UB,'go',x_LoB,z_LoB,'co');
% plot(Poly(:,1),Poly(:,2),'r.')
% 
% hold off
% grid on
