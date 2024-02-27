function thestruct=cmgcdemodulate(pd,pl,overlap,t,u,varargin)
% Complex demodulation of a vector or scalar variable
% 
% Syntax: thestruct=cmgcdemodulate(pd,pl,overlap,t,u,[v])
% Input:
% 	pd = the period (in hours) of interest, maybe an [Mx1] array
% 	pl = segement length (in hours)
% 	overlap=overlap (in hours)
% 	t = time variable (in true julian dates), [Nx1]
% 	u = time-series of interest, [Nx1]
% 	v = same as u, optional
% Output: the output parameters are stored in a Struct that contains the following fields
% 	time = new time at midpoint of segment, in true julian date
% 	ap, pp = amplitude and phase of counterclockwise components
% 	am, pm = amplitude and phase of clockwise components, output
% 		only when v is present
% 
% The ellipse parameters may be computed from the above output
% 	semi-major axis = ap + am
% 	semi-minor axis = ap - am
% 	inclination (angle between major and u) = 0.5*(pp+pm)
% 
% Based on algorithm in "Data analyses methods in
% physical oceanography" by W.J. Emery and R.E. Thomson
% page: 402 - 404
% 
% jpx @ usgs, 03-16-01
% jpx @ usgs, 08-26-02

if nargin<5
	help(mfilename);
	return;
end;
iscomp=0;
if length(varargin)>0
	v=varargin{1};
	iscomp=1;
else
	v=0*u;
end;

dt=diff(t(1:2))*24;
if pl*dt<= max(pd) % segments are too short
	error('Each segment must span at least one cycle of the frequency of interest.');
end;
if length(u)<40*length(pd)  % Why 40?, because it seems a good round number
	warning('There should be many more data points than freq. components.');
end;

t=t*24; % from julian date to hr
freq=2*pi./pd;

% overlap=0;
npieces=fix((length(u)-overlap)/(pl-overlap));

t=t(:);
u=u(:);
v=v(:);
if iscomp
	fac=1;
else
	fac=2;
end;

for i=1:npieces
	indx=(i-1)*(pl-overlap) + 1 : i*(pl-overlap) + overlap;
	newt(i,1)=t(ceil(indx(pl/2)))/24;
% 	newt(i,1)=t(indx(1))/24;
	y=[u(indx);v(indx)];

	tt=t(indx)-t(1);
	for j=1:length(freq)
		ang=freq(j)*tt;
		D1=[cos(ang) -sin(ang) cos(ang) sin(ang)];
		D2=[sin(ang) cos(ang) -sin(ang) cos(ang)];
		D=[D1;D2];
		z=D\y;
		
% 		zp=z(1)+sqrt(-1)*z(2);
% 		zm=z(3)+sqrt(-1)*z(4);
		zp=z(2)+sqrt(-1)*z(1);
		zm=z(4)+sqrt(-1)*z(3);
		ap(i,j)=fac*abs(zp);
		pp(i,j)=180/pi*angle(zp);
		am(i,j)=fac*abs(zm);
		pm(i,j)=180/pi*angle(zm);
	end;
end;
thestruct.time=newt;
thestruct.ap=ap;
thestruct.pp=pp;
fprintf('\n=======Output from complex demodulation==============\n');
fprintf('Time at the middle of the first segement: %s\n',num2str(gregorian(newt(1))));
% fprintf('Time at the beginning of the first segement: %s\n',num2str(gregorian(newt(1))));
fprintf('Segment length: %d hours\n',pl);
fprintf('Delta_T in raw data: %g hours\n',diff(t(1:2)));
if iscomp
	thestruct.am=am;
	thestruct.pm=pm;
	thestruct.semimajor=ap+am;
	thestruct.semiminor=ap-am;
	thestruct.inclination=0.5*(pp+pm);
	fprintf('\n		AP		PP		AM		PM		Semimajor	Semiminor	Inclination\n');
	for j=1:length(freq)
		fprintf('\nPeriod of interest: %g hours\n',2*pi/freq(j));
		temp=[ap(:,j) pp(:,j) am(:,j) pm(:,j) thestruct.semimajor(:,j),...
			thestruct.semiminor(:,j) thestruct.inclination(:,j)];
		disp(temp);
	end;
else
	fprintf('\n	Amplitude 	Phase\n');
	for j=1:length(freq)
		fprintf('\nPeriod of interest: %g hours\n',2*pi/freq(j));
		disp([ap(:,j) pp(:,j)]);
	end;
end;
fprintf('===============End of Output========================\n');

return;		