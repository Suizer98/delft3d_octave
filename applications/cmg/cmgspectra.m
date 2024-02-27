function results=cmgspectra(varargin)
%auto- and cross- spectral computation, outputs are powers, not power density.
% 
% results=cmgspectra(x,[y],[nfft],[noverlap],[window],[fs],[p],[dflag])
% 
% x = time-series, vector or matrix
% y = second time-series, optional. if present, both auto- and cross- spectra
% 	are calculated, and both x and y must NOT be a matrix.
% nfft = length of each section to be FFT'ed (default=256)
% noverlap = length of overlap (default=nfft/2)
% window = (default=hanning(nfft))
% fs = sampling frequency (default=2)
% p = confidence interval (default=0.95)
% dflag = detrending mode (default='linear')
% 
% You can obtain a default parameter by leaving it out
% or inserting an empty matrix [], e.g. cmgspectra(x,y,[],128,[],2), in which
% nfft and window are set to default, p and dflag are left out (default)
% 
% results = structure array containing the following
% 	results.spec (M x 5 for auto-; M x 19 for cross- spectra)
% 	results.freq
% 	results.npieces --used in averaging in the plot routine
% 	results.nfft
% 	results.conf (a scalor, confidence level)
% 	results.window
% 	results.name
% 	results.averaged
% 
% jpx @ usgs, 01-04-01
% 

if nargin<1 help(mfilename);return;end;
[msg,x,y,nfft,noverlap,window,fs,p,dflag]=specchk(varargin);
if isequal(window, boxcar(nfft))
	results.window=0;
else
	results.window=1;
end;
error(msg);
if size(x,1)==1 x=x(:);end;
xspec=0;
uf{1}=cmgdataclean(x);
if ~isempty(y)
	if size(y,1)==1 y=y(:);end;
	xspec=1;
	uf{2}=cmgdataclean(y);
end;
for i=1:length(uf)
	ngaps=cmgidgaps(uf{i},100);
	if ngaps>0
		error(['Gaps in [' inputname(i) '] need to be bridged before running spectra.']);	
	end;
end;

npieces=fix((length(uf{1})-noverlap)/(nfft-noverlap));
nopadindx=1 : npieces*(nfft-noverlap) + noverlap;
npieces=fix((length(nopadindx)-noverlap)/(nfft-noverlap));

if xspec
	if size(uf{1},2)>1 | size(uf{2},2)>1
		errordlg('Cross-spectrum canNOT be performed on ADCP variable in this version.','Error');
		return;
	end;
	% auto-spectra
	allspec=[];
	for i=[1 2]
		[thespec,theconf,thefreq]= psd(uf{i}(nopadindx),nfft,fs,...
			window,noverlap,p,dflag);
			
		thespec([1 end])=thespec([1 end])/2; % see PWELCH.m
		
		allspec=[allspec thespec(:)];
	end;
	allspec=2*allspec./nfft; % Saving the variances, as in PROSPECT
	allspec(end,:)=allspec(end,:)/2;
	allspec=[allspec,thespec./theconf(:,1),thespec./theconf(:,2)];
	
	% cross-spectra
	[thespec,theconf,thefreq]= csd(uf{1}(nopadindx),uf{2}(nopadindx),nfft,fs,...
		window,noverlap,p,dflag);
		
	thespec([1 end])=thespec([1 end])/2; % see PWELCH.m
	
	thespec=2*thespec./nfft; % Saving the variances, as in PROSPECT
	thespec(end)=thespec(end)/2;
	cosp=real(thespec);
	quadsp=imag(thespec);
	coh=sqrt(abs(thespec).^2 ./(allspec(:,1).*allspec(:,2)));
	phas=atan2(quadsp,cosp)*180/pi;
	xfer=sqrt(abs(thespec).^2 )./allspec(:,1);
	
	thespec=[cosp quadsp xfer coh phas];
	allspec=[allspec thespec];
	allspec=allspec(2:end,:);
	thefreq=thefreq(2:end,1);
	nyqf=thefreq(end);
	thespec=nan*ones(length(thefreq),19);
	thespec(:,[1:6 7 9 11])=allspec;
	as=thespec;
	% Computing rotary spectra
	clksp=0.5*(as(:,1) + as(:,2) + 2*as(:,6));
	aclksp=0.5*(as(:,1) + as(:,2) - 2*as(:,6));
	rotcoef=2*as(:,6)./(as(:,1) + as(:,2));
	elliptheta2=atan2(2*as(:,5), (as(:,1) - as(:,2))) *180/pi;
	dum1=4*as(:,5).^2 + (as(:,1) - as(:,2)).^2;
	dum2=4*(clksp.*aclksp);
	ellipstab=sqrt(dum1./dum2);
	
	thespec(:,[13:17])=[clksp aclksp rotcoef elliptheta2 ellipstab];
	thespec(:,19)=(1./thefreq)/3600; % period in hours
	
	dum.spec=thespec;dum.freq=thefreq;dum.npieces=npieces;dum.conf=p;dum.window=results.window;
	dum=cmgspecavg(dum,2); %computing confidence interval.
	thespec=dum.spec;thefreq=dum.freq;npieces=dum.npieces;p=dum.conf;
	
	results.name=[inputname(1),', ' inputname(2)];
	if isempty(inputname(1)) | isempty(inputname(2))
		results.name='first, second';
	end;
else
	for j=1:size(uf{1},2)	
		[thespec,theconf,thefreq]= psd(uf{i}(nopadindx,j),nfft,fs,...
			window,noverlap,p,dflag);				
		thespec([1 end],1)=thespec([1 end],1)/2; % see PWELCH.m
		
		thespec=[2*thespec(2:end-1,1); thespec(end,1)]./nfft; % Saving the variances, as in PROSPECT 
		theconf=[2*theconf(2:end-1,:); theconf(end,:)]./nfft;
		thefreq=thefreq(2:end,1); %not listing the zero frequency
		nyqf=thefreq(end);
		
		thespec=[thespec,thespec./theconf(:,1),thespec./theconf(:,2)];
		thespec=[thespec,ones(length(thefreq),1),(1./thefreq)/3600];
		
		adcpspec(:,:,j)=thespec;
	end;
	thespec=adcpspec;
	results.name=inputname(1);
	if isempty(inputname(1))
		results.name='auto';
	end;
end;
results.spec=thespec;
results.freq=thefreq;
results.npieces=npieces;
results.conf=p;
results.nfft=nfft;
results.averaged='NO';


return;

function [msg,x,y,nfft,noverlap,window,Fs,p,dflag] = specchk(P)
%SPECCHK Helper function for SPECTRUM
%   SPECCHK(P) takes the cell array P and uses each cell as 
%   an input argument.  Assumes P has between 1 and 7 elements.

%   Author(s): T. Krauss, 4-6-93

msg = [];
if length(P{1})<=1
    msg = 'Input data must be a vector, not a scalar.';
    x = [];
    y = [];
elseif (length(P)>1),
    if (all(size(P{1})==size(P{2})) & (length(P{1})>1) ) | ...
       length(P{2})>1,   % 0ne signal or 2 present?
        % two signals, x and y, present
        x = P{1}; y = P{2}; 
        % shift parameters one left
        P(1) = [];
    else 
        % only one signal, x, present
        x = P{1}; y = []; 
    end
else  % length(P) == 1
    % only one signal, x, present
    x = P{1}; y = []; 
end

% now x and y are defined; let's get the rest

if length(P) == 1
    nfft = min(length(x),256);
    window = hanning(nfft);
    noverlap = 0;
    Fs = 2;
    p = 0.95;
    dflag = 'linear';
elseif length(P) == 2
    if isempty(P{2}),   dflag = 'linear'; nfft = min(length(x),256); 
    elseif isstr(P{2}), dflag = P{2};       nfft = min(length(x),256); 
    else              dflag = 'linear'; nfft = P{2};   end
    window = hanning(nfft);
    noverlap = 0;
    Fs = 2;
    p = 0.95;
elseif length(P) == 3
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    if isempty(P{3}),   dflag = 'linear'; noverlap = 0;
    elseif isstr(P{3}), dflag = P{3};       noverlap = 0;
    else              dflag = 'linear'; noverlap = P{3}; end
    window = hanning(nfft);
    Fs = 2;
    p = 0.95;
elseif length(P) == 4
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    if isstr(P{4})
        dflag = P{4};
        window = hanning(nfft);
    else
        dflag = 'linear';
        window = P{4};  window = window(:);   % force window to be a column
        if length(window) == 1, window = hanning(window); end
        if isempty(window), window = hanning(nfft); end
    end
    if isempty(P{3}), noverlap = 0;  else noverlap=P{3}; end
    Fs = 2;
    p = 0.95;
elseif length(P) == 5
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    window = P{4};  window = window(:);   % force window to be a column
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{3}), noverlap = 0;  else noverlap=P{3}; end
    if isstr(P{5})
        dflag = P{5};
        Fs = 2;
    else
        dflag = 'linear';
        if isempty(P{5}), Fs = 2; else Fs = P{5}; end
    end
    p = 0.95;
elseif length(P) == 6
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    window = P{4};  window = window(:);   % force window to be a column
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{3}), noverlap = 0;  else noverlap=P{3}; end
    if isempty(P{5}), Fs = 2;     else    Fs = P{5}; end
    if isstr(P{6})
        dflag = P{6};
        p = 0.95;
    else
        dflag = 'linear';
        if isempty(P{6}), p = .95;    else    p = P{6}; end
    end
elseif length(P) == 7
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    window = P{4};  window = window(:);   % force window to be a column
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{3}), noverlap = 0;  else noverlap=P{3}; end
    if isempty(P{5}), Fs = 2;     else    Fs = P{5}; end
    if isempty(P{6}), p = .95;    else    p = P{6}; end
    if isstr(P{7})
        dflag = P{7};
    else
        msg = 'DFLAG parameter must be a string.'; return
    end
end

% NOW do error checking
if (nfft<length(window)), 
    msg = 'Requires window''s length to be no greater than the FFT length.';
end
if (noverlap >= length(window)),
    msg = 'Requires NOVERLAP to be strictly less than the window length.';
end
if (nfft ~= abs(round(nfft)))|(noverlap ~= abs(round(noverlap))),
    msg = 'Requires positive integer values for NFFT and NOVERLAP.';
end
if ~isempty(p),
    if (prod(size(p))>1)|(p(1,1)>1)|(p(1,1)<0),
        msg = 'Requires confidence parameter to be a scalar between 0 and 1.';
    end
end
% if min(size(x))~=1,
%     msg = 'Requires vector (either row or column) input.';
% end
% if (min(size(y))~=1)&(~isempty(y)),
%     msg = 'Requires vector (either row or column) input.';
% end
if (length(x)~=length(y))&(~isempty(y)),
    msg = 'Requires X and Y be the same length.';
end

return;