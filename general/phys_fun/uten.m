function [u10,Cdn]=uten(u,h)
%function [u10,Cdn]=uten(u,h)
% u10 is the estimate of wind speed(m/s) at 10m
% Cdn is the estimate of drag coefficient
% u is measured wind stress(nx1)
% h is height of wind sensor above surface(meters)(nx1)

%   Solution is found iteratively as described
%   in "Large and Pond" Journal of Physical
%   Oceanography Vol 11, 1981 pp324-336
%
%   method has been 'vectorized' for efficiency in matlab

%Parameters
tol=0.2; %acceptable error tolorance
k=0.41;  %Von Karmen's constant

%check for correct number of args
if nargchk(2,2,nargin)
	eval(['help uten']);
	error('Incorrect Input');
end

% set matricies
utmp=u;u10=zeros(size(u));Cdn=zeros(size(u));

%keep looping until all values are within tol
while max(abs(u10-utmp)) > tol,   
	u10=utmp;
        %first set Cdn's for u < 11 m/s
	I=find(u10 < 11);
	Cdn(I)=(1.2E-03)*ones(size(I));

	%next set Cdn's for u >= 11 m/s
	I=find(u10 >=11);
	Cdn(I)=(0.49+0.065*u10(I))*.001;
	
	%now calculate new utmps
	utmp=u./(1+(sqrt(Cdn)/k).*log(h/10));
end
