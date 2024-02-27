function degUC = degN2degunitcirle(degN)
%DEGN2DEGUNITCIRCLE   convert directions between conventions
%
% degUC = DEGN2DEGUNITCIRLE(degN) converts a wind direction
% on a unit circle (degrees cartesian) to a direction in a
% nautical convention (degrees north).
%
% In a unit circle it is the angle between the arrow
% head and the horizontal east.
%
% In a nautical convention it is the angle between the arrow
% tail and the vertical up.
%
% Note that in the unit circle the direction is zero if
% the arrow points towards OUTWARDS towards the east,
% while in the nautical convention it is zero when the direwction
% is INWARDS towards the south.
%
%
% Degrees North            Unit circle
% Nautical convention      Cartesian convention
% Positive inward to (0,0) Positive outward from (0,0)
%
%                                           
% INWARD arrow                OUTWARD arrow
%
% > from N=0/360 >            <    to N=90   <  
%      /       \                   /     \    
% from W=270    from E=90     to W=180     to E=0/360
%      \       /                   \     /    
% < from S=180   <            >    to S=270  >  
%                                           
% angle between tail and   angle between tip and horizontal
% vertical up.
%
%See also: DEGUNITCIRCLE2DEGN, DEGUC2DEGN

degUC = mod(- degN + 270,360); % - degN  - 90

