function [zsin zsout uin uout reflc] = Guza_split_waves(t,zsi,umi,zb,boundopt,quietopt)
% [zsin zsout uin uout] = Guza_split_waves(t,zs,um,zb,boundopt,quietopt)
% t is timevector (s)
% zsi = total surface elevation vector (m+SWL)
% um = depth-averaged current vector (m/s)
% zb = bed level at location of zs and um (m+SWL)
% boundopt = 'boundin', 'boundout', 'boundall', 'free', 'boundupper',
% 'sqrt(gh)'
% quietopt = boolean to display messages to screen

if ~exist('quietopt','var')
    quietopt =0;
end

% Constants
g = 9.81;

% average water level and velocity
zsm = mean(zsi);
umm = mean(umi);
if ~quietopt
    display(['Mean water level found is : ' num2str(zsm,'% 5.2f') 'm']);
    display(['Mean velocity found is    : ' num2str(umm,'% 5.2f') 'm/s']);
end

% average water depth
h = zsm-zb;

% adjust to zero-centered water level and velocity
zs = zsi-zsm;
um = umi-umm;

% detrend signals
t = t(:);
zsd=detrend(zs(:));
umd=detrend(um(:));
zsm = zsm + (zs(:)-zsd);
zs = zsd;
umm = umm + (um(:)-umd);
um = umd;

if strcmp(boundopt,'sqrt(gh)')
    % in timespace
    hh = zs+h;
    c = sqrt(9.81*hh);
    q = umd.*hh;
    ein = (zs.*c+q)./(2.*c);
    eout = (zs.*c-q)./(2.*c);
    zsin = ein+zsm;
    zsout = eout+zsm;
    uin   = (sqrt(1./hh.^2).*c.*ein)+umm;
    uout  = -(sqrt(1./hh.^2).*c.*eout)+umm;
else
    % into Fourrier space
    n=length(zs);
    Z=fft(zs,n);%Z=Z(1:floor(length(Z)/2));
    U=fft(um,n);%U=U(1:floor(length(U)/2));
    df=1/(t(end)-t(1));
    ff = df*[0:1:round(length(t)/2) -1*floor(length(t)/2)+1:1:-1]'+0.5*df;
    w=2*pi*ff;
    k=disper(w,mean(h),9.81);
    c=w./k;
    
    % hf cutoff
    filterfreq = 0.01; % filter length over 0.01Hz
    minfreq = 0.03; % 33s wave is longest considered in primary spectrum
    incl = find(ff>=minfreq);
    ftemp = ff(incl);
    vartemp = real(Z).^2;vartemp=vartemp(incl);
    window = max(1,round(filterfreq/df));
    vartemp = filterwindow(vartemp,window);
    fp = ftemp(find(vartemp==max(vartemp),1,'last'));
    Tp=1/fp;
    hfc = min(10*fp,max(ff));
    if ~quietopt
        display(['Peak period found is      : ' num2str(Tp,'% 5.2f') 's']);
    end
    
    % cutoff high frequency c
    c=max(c,wavevelocity(1/hfc,h));
    
    % find the properties of the peak waves (used for bound components)
    [cp cgp]=wavevelocity(Tp,h);
    
    % select frequencies that are thought to be bound
    switch boundopt
        case 'boundin'
            freein  = abs(ff)>0.5*fp;   % free above half the peak frequency
            boundin = abs(ff)<=0.5*fp;  % bound below half the peak frequency
            freeout = true(size(ff));
            boundout= false(size(ff));
        case 'boundout'
            freein  = true(size(ff));
            boundin = false(size(ff));
            freeout = abs(ff)>0.5*fp;   % free above half the peak frequency
            boundout= abs(ff)<=0.5*fp;  % bound below half the peak frequency
        case 'boundall'
            freein  = abs(ff)>0.5*fp;   % free above half the peak frequency
            boundin = abs(ff)<=0.5*fp;  % bound below half the peak frequency
            freeout = abs(ff)>0.5*fp;   % free above half the peak frequency
            boundout= abs(ff)<=0.5*fp;  % bound below half the peak frequency
        case 'free'
            freein  = true(size(ff));
            boundin = false(size(ff));
            freeout = true(size(ff));
            boundout= false(size(ff));
        case 'boundupper'
            fac = 2;
            freein  = abs(ff)<fac*fp;   % free above half the peak frequency
            boundin = abs(ff)>=fac*fp;  % bound below half the peak frequency
            freeout = abs(ff)<fac*fp;   % free above half the peak frequency
            boundout= abs(ff)>=fac*fp;  % bound below half the peak frequency
    end
    
    % find the velocity for all fourier components
    cin(freein,1)=c(freein,1);
    
    cout(freeout,1)=c(freeout,1);
    cout(boundout,1)=cgp;
    switch boundopt
        case 'boundupper'
            cin(boundin,1)=cp;
            cout(boundout,1)=cp;
        otherwise
            cin(boundin,1)=cgp;
            cout(boundout,1)=cgp;
    end
    % maximize to the long wave celerity
    cin = min(cin,sqrt(9.81*h));
    cout = min(cout,sqrt(9.81*h));
    
    % cut off hf noise
    mm = round(hfc/df);
    set = zeros(length(Z),1);
    set(2:mm-1) = 1;
    set(length(um)-mm+3:length(um)) = 1;
    
    ein   = real(ifft(set.*((Z.*cout+U.*h)./(cin+cout))));
    eout  = real(ifft(set.*((Z.*cout-U.*h)./(cin+cout))));
    zsin  = ein +zsm;
    zsout = eout+zsm;
    uin   = real(ifft(set.*(sqrt(1./h^2).*cin.*fft(ein))))+umm;
    uout  = -real(ifft(set.*(sqrt(1./h^2).*cout.*fft(eout))))+umm;
    % uin   = sqrt(g./h).*(zsin-zsm)+umm;
    % uout  = sqrt(g./h).*(zsout-zsm)+umm;
end

reflc = std(zsout).^2./std(zsin).^2;

if ~quietopt
    display(['Energy reflection found is: ' num2str(reflc,'% 5.2f') ' [-]']);
    figure;
    subplot(2,1,1);
    plot(t,zsi,'r',t,zsin,'b',t,zsout,'b--',t,zsin+zsout-zsm,'g--',t,zsm,'k--');
    title('water level');
    legend('zs measured','zsin','zsout','zsin+zsout','mean zs');
    subplot(2,1,2);
    plot(t,umi,'r',t,uin,'b',t,uout,'b--',t,uin+uout-umm,'g--',t,umm,'k--');
    title('velocity');
    legend('u measured','uin','uout','uin+uout','u mean');
end