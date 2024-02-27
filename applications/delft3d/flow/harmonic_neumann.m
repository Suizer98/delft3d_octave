
function out=harmonic_neumann(outside,inside,distance)
% Computes harmonic neumann components based on WL components
% (neumann signals are consistent with D3d-FM definition)
% 
% out=harmonic_neumann(outside,inside,distance)
%
% Inputs:
% outside=[amplitude phase]: wl components "outside" the domain
% inside=[amplitude phase] : wl components "inside" the domain
% distance=distance between inside and outside points
%
% Note 1: the line connecting locations "inside-outside" must be (approx.)
% normal to the boundary section
% Note 2: matrices "outside" and "inside" must have same size and sequence
% of components (i.e. each line corresponds to the same freq. in both matrices)
%
% Outputs:
% out=[amplitude phase] of neumann components for each input component
%
c=outside(:,1)-inside(:,1).*exp(1i*(inside(:,2)-outside(:,2)).*pi/180);
modulus=abs(c);
arg=atan2(imag(c),real(c));

ampl=modulus./distance;
phase=outside(:,2)+arg*180/pi;phase(phase>360)=phase(phase>360)-360;phase(phase<0)=phase(phase<0)+360;
out=[ampl phase];

end


