function [ampt,amps,sv,mv]=cmgeof(x,varargin)
% Empirical Orthogonal Function analysis
% 
% syntax: [ampt,amps,sv,mv] = cmgeof(x, [options]);
% 
% Input:
% 	x: data matrix (M x N), M observations and N variables. May be complex.
% 	options: entered as a string/value pair. available options are -
% 		['modes', num]: the first [num] number of modes are printed,
% 				default num=N
% 		['normalized', flag]: input data is not normalized if flag=0
% 				(default), input data is normalized if flag=1. If 
% 				normalized the amplitude are not correct.
% 		['covyes', flag]: input data is a covariance matrix if flag=1.
% Output:
% 	ampt = temporal amplitude of each mode (M x num). plotted to a figure
% 	amps = spatial amplitude of each mode (N x num).
% 		If complex EOF, the on-screen print-out of both amplitudes have this format
% 				AMP*exp(PHASE*i)
% 		where PHASE is in degrees
% 	sv = site variance in percentage (N x num).
% 	mv = modal variance in percentage (num x 1).
% 
% All computations are based on Noble and Ramp (2000), 
% Deep-Sea Res. II (47), 871-906; and Kundu and Allen (1976)
% JPO (6) 181-199
% 
% jpx @ usgs, 01-25-01
% jpx @ usgs, 03-22-01
% jpx @ usgs, 02-21-02
% jpx @ usgs, 07-09-02
% 
if nargin<1, help(mfilename);return;end;
opslen=mod(length(varargin),2);
if opslen
	error('options must be entered in string/value pairs.');
end;
[m,n]=size(x);
if n<2 & isreal(x)
	error('Input data must have more than 1 column');
end;
num=n;
donorm=0;
covyes=0;
while length(varargin)
	s1=varargin{1};
	switch lower(s1(1:4))
	case 'mode'
		num=varargin{2};
	case 'norm'
		donorm=varargin{2};
	case 'covy'
		covyes=varargin{2};
	end;
	varargin(1:2)=[];
end;
if num>n | num<1
	num=n;
end;
if covyes
	if ~isequal(tril(x),rot90(flipud(triu(x)),-1)) %is symmetric?
		error('The input covariance matrix must be symmetric!');
	end;
	z=x;
	c=z;
else	
	if donorm
		if isreal(x)
			z=detrend(x);
			z=(z-ones(m,1)*mean(z))./(ones(m,1)*std(z));
		else
			xr=real(x);
			xi=imag(x);
			zr=detrend(xr);
			zi=detrend(xi);
			zr=(zr-ones(m,1)*mean(zr))./(ones(m,1)*std(zr));
			zi=(zi-ones(m,1)*mean(zi))./(ones(m,1)*std(zi));
			z=zr+zi*sqrt(-1);
		end;
	else
		z=x;
	end;
	c=cov(z);
end; 
vv=diag(c);
totalv=sum(vv); % total variance

[eigvec,eigval]=eig(c);
mv=diag(eigval);
[mv,jj]=sort(mv); %sorting in ascending order

mv=flipud(mv); % now in the right order - descending
jj=flipud(jj);
eigval=mv';

eigvec=eigvec(:,jj); % put them in the right order too

if covyes
	ampt=nan*ones(1,length(mv));
	fprintf('\nTemporal amplitude can not be computed when the input is a convariance matrix.\n');
else	
	% eigvec=eigvec./(ones(n,1)*max(abs(eigvec)))
	ampt=z*eigvec; % temporal amplitudes
	ampt=ampt./sqrt((ones(m,1)*mv'));
end;
% std(ampt)
mv=mv*ones(1,length(mv));

sv=mv'.*eigvec.^2; 

amps=sqrt(2*sv); % spatial amplitudes

vv=vv*ones(1,length(vv));
sv=100*sv./vv; % site variances

mv=100*diag(mv)/totalv; % modal variances

if num<n
	ampt=ampt(:,1:num);
	amps=amps(:,1:num);
	sv=sv(:,1:num);
	mv=mv(1:num);
end;

myformat=[];
myformat2=[];
fprintf('\n');
for i=1:num
	fprintf('Mode%2d\t',i);
	myformat=[myformat '%6.2f\t'];
	myformat2=[myformat2 '%6.2fexp(%4ii)\t'];
end;

fprintf('\n----------------------------\n');
if ~isreal(x)
% 	t1=abs(ampt);t2=round(180/pi*angle(ampt));
% 	nn=2*num;
% 	tt(:,1:2:nn)=t1;
% 	tt(:,2:2:nn)=t2;
% 	fprintf('Temporal Amplitudes\n');
% 	fprintf([myformat2 '\n'],tt');
	tt=[];
	t1=abs(amps);t2=round(180/pi*angle(amps));
	tt(:,1:2:nn)=t1;
	tt(:,2:2:nn)=t2;
	fprintf('Spatial Amplitudes\n');
	fprintf([myformat2 '\n'],tt');
else
%	fprintf('Temporal Amplitudes\n');
% 	fprintf([myformat '\n'],ampt');
	
	fprintf('Spatial Amplitudes\n');
	fprintf([myformat '\n'],amps');
end;
if donorm
	fprintf('***Amplitudes are incorrect because of normalization.\n');
end;
fprintf('\nSite variances (%%)\n');
fprintf([myformat '\n'],sv');

fprintf('\nModal variances (%%)\n');
fprintf([myformat '\n'],mv);

myformat3=[];
for i=1:n
	myformat3=[myformat3 '%6.2f\t'];
end;

fprintf('\n Eigenvalue\n');
fprintf([myformat '\n'],eigval(1:num)');

fprintf('\n Eigenvector\n');
fprintf([myformat3 '\n'],eigvec');

fprintf('\n Covariance\n');
% fprintf([myformat3 '\n'],tril(c)');
for i=1:n
	myformat3=[];
	for j=1:i
		myformat3=[myformat3 '%6.2f\t'];
	end;
	fprintf([myformat3 '\n'],c(i,1:i));
end;

fprintf('----------------------------\n');
if ~covyes
	plot(ampt);
end;
return;