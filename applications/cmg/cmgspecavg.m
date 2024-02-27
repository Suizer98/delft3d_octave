function theSpec = cmgspecavg(specStruct,varargin)
%Band-averaging spectra, PROSPECT style. REQUIRE spectral output from cmgspectra.m
% 
% theSpec = cmgspecavg(specStruct,[nfreq])
% 
% specStruct = Structure array from cmgspectra.m that contains these fields:
% 	.spec: auto- (size of M x 5) or cross- (size of M x 19) power spectra
% 	.freq: (M x 1) frequency in Hz
% 	.npieces: number of pieces 
% 	.conf: confidence level 
% 	.window: no window(=0); hanned (=1)
% 	.nfft: nfft
% nfreq = a (N x 2) matrix specifying a varing number of frequencies in each band, e.g.
% 	[4 5;
% 	10 15;
% 	28 30]
% 	specify that there are to be 4 frequencies in the first 5 band
% 	10 in the next 15 bands, and 28 in the next 30 bands. optional.
% the output, theSpec, is also a structure array
% 
% MODIFIED FROM Chuck's specav FUNCTION TO BAND-AVERAGE THE SPECTRUM IN
% PROSPECT STYLE.
% 
% jpx @ usgs, 3-24-2000
% jpx @ usgs, 01-09-01
% 
if nargin<1 
	help(mfilename);
	return;
elseif ~isstruct(specStruct)
	error([inputname(2) ' must be a structure array.'])
end;

theSpectra=specStruct.spec;
theFrequencies=specStruct.freq;
nPieces=specStruct.npieces;
theConfidenceLevel=specStruct.conf;
anywindow=specStruct.window;

nfreq0= [1 40;
		2 15;
		5  6;
		10 30;
		20 15;
		50 6;
		100 30;
		200 15;
		500 6;];
		
% get theFreqWayPoints
if length(varargin)<1
	auto=1;
	nfreq=nfreq0;
elseif length(varargin)<2
	if prod(size(varargin{1}))==1
		auto=varargin{1};
		nfreq=nfreq0;
	else
		auto=1;
		nfreq=varargin{1};
	end;
elseif length(varargin)==2
	auto=varargin{1};
	nfreq=varargin{2};
else
	error('Too many input arguments.');
end;

fl=length(theFrequencies);
if auto==2
	avgl=[1 1 1 1 1 1 1 1 1];
	bandl=[40 30 30 300 300 300 3000 3000 3000];
	cuml=cumsum(avgl.*bandl);
	avgl=[avgl(:); avgl(end)];
	
	theFreqWayPoints=theFrequencies;
else
	avgl=nfreq(:,1);
	bandl=nfreq(:,2);
	cuml=cumsum(avgl.*bandl);
	avgl=[avgl; avgl(end)];
	
	wpindx=1:avgl(1):cuml(1);
	for i=2:length(cuml)
		wpindx=[wpindx cuml(i-1)+1:avgl(i):cuml(i)];
	end;
	wpindx=wpindx(wpindx<=fl);
	
	theFreqWayPoints=theFrequencies(wpindx);
end;

% Rearrange if simple auto-spectrum.

s = theSpectra;
% [m, n] = size(s);
[m, n, bins] = size(s);

if n == 5
	temp = zeros(m, 19, bins);
	temp(:, [1 3 4 18 19], :) = s(:, [1 2 3 4 5], :);
	s = temp;
	[m, n, bins] = size(s);
end

% Frequencies.

f = theFrequencies(:);
fi = theFreqWayPoints(:);

if auto==2 
	as=s;
	nf=ones(m,1);
	as(:,18)=nf;
else
	df = diff(fi);   % Band-widths.
	nf = df ./ mean(diff(f));     % Number of frequencies per band.
	
	cf=[];
	i=1;
	for kk=1:bins
		as2(kk).avg=[];
	end;
	while length(f) >= avgl(i)
		sect=avgl(i)*bandl(i);
		if length(f)>=sect
			leng1=sect;
			leng2=bandl(i);
		else
			leng2=fix(length(f)/avgl(i));
			leng1=avgl(i)*leng2;
		end;
	
		cf=[cf; cmgavg(f(1:leng1),avgl(i))];
		
		for kk=1:bins
			dummy=cmgavg(s(1:leng1,:,kk),avgl(i));
			
			% Save the sum, not the mean of spectra
% 			dummy(:,[1 2 5 6 13 14])=avgl(i)*dummy(:,[1 2 5 6 13 14]);
			
			as2(kk).avg=[as2(kk).avg; dummy];
		end;
		
		f(1:leng1)=[];
		s(1:leng1,:,:)=[];
		i=i+1; 
	end;

	for i=1:bins
		as(:,:,i)=as2(i).avg;
	end;
	
	mmm=min(size(as,1),length(nf));
	as=as(1:mmm,:,:);
	nf=nf(1:mmm,1);
	cf=cf(1:mmm,1);
	% put nf and cf in the 18th and 19th columns of as
	for i=1:bins
		as(:,18,i)=nf(:);
		as(:,19,i)=1./cf(:)/3600; % period in hours
	end;
% 	as(:,19)=as(:,19)/3600; % in hours
end; %if auto==2

f=theFrequencies;
s=theSpectra;

% Compute the stats distributions here, saving lots of time
% Because the stats distribution for each band is the same

indx=find(cuml<m);
numnf=avgl(1:length(indx)+1);

numnf=numnf(:);

if anywindow %hanned
	cdeg = nPieces*ones(size(numnf));
	cdeg(numnf>2) = nPieces.*numnf(numnf>2)/2;
else
	cdeg = nPieces.* numnf;
end;
adeg = 2*cdeg;
degf = 2*cdeg - 2;
degf(degf < 1) = 1;
alpha = 1 - theConfidenceLevel;
	
if anywindow %hanned
	cdeg2 = nPieces*ones(size(nf));;
	cdeg2(nf>2) = nPieces.*nf(nf>2)/2;
else
	cdeg2 = nPieces.* nf;
end;
adeg2 = 2*cdeg2;
degf2 = 2*cdeg2 - 2;
degf2(degf2 < 1) = 1;

% Auto-spectral confidence factors.
bmax = adeg2 ./ mdrecover(mdchi(alpha/2, adeg),numnf,nf,bandl);
bmin = adeg2 ./ mdrecover(mdchi(1 - alpha/2, adeg),numnf,nf,bandl);

for kk=1:bins
	as(:,3,kk)=bmin;
	as(:,4,kk)=bmax;
end;

%%%% Need to ask Marlene what to do when cdeg=1 (i.e. npieces=1 without band average) %%%

mytest=cdeg2-1;
if any(mytest) & auto~=1
	mytest(mytest==0)=nan;
	% Coherence confidence level and phase-angle confidence.
	for kk=1:bins
		factor = alpha; 
		cohlevel = sqrt(1 - factor.^(1 ./ (mytest)));
		gamma2=abs(as(:,9,bins)).^2;
		
		as(:,10,bins)=cohlevel(:);  % the 10th column
		
		stat = mdrecover(mdsti(factor, degf),numnf,nf,bandl);
		num = 1-gamma2;
		den = degf2.*gamma2;
		arg = stat .* sqrt(num./den);
		arg(abs(arg) > 1) = NaN;
		dphik = asin(arg) .* 180 ./ pi;   % Degrees.
		
		as(:,12,bins)=dphik(:);  % the 12the column
		
		% Transfer-function confidence interval: x-to-y and y-to-x.
		dtf1 = sqrt((mdrecover(mdfi(theConfidenceLevel, 2, degf),numnf,nf,bandl) .* ...
						(1-gamma2) .* as(:,2,bins)) ./ (as(:,1,bins) .* (mytest)));
		
		dtf2 = sqrt((mdrecover(mdfi(theConfidenceLevel, 2, degf),numnf,nf,bandl) .* ...
						(1-gamma2) .* as(:,1,bins)) ./ (as(:,2,bins) .* (mytest)));
						
		as(:,8,bins)=dtf1(:);  % the 8th column
	end;
end;

as(~isfinite(as))=nan;
if size(theSpectra,2)==5   %restore the auto-spectra size
	as=as(:,[1 3 4 18 19],:);
end;

theSpec=specStruct;
theSpec.spec=as;
theSpec.freq=1./(as(:,end)*3600);
theSpec.averaged='YES';

function reald=mdrecover(mddata,numnf,nf,bandl)

% Recover the stats distribution to its full length
reald=[];jj=0;
for i=1:length(numnf)-1
	jj=jj+1;
	reald=[reald; mddata(i)*ones(bandl(i),1)];
end;
templ=length(reald);
reald=[reald; mddata(jj+1)*ones(length(nf)-templ,1)];

return