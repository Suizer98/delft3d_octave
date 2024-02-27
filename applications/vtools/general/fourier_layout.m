
%% PREAMBLE

clc
clear

%% INPUT

%% space parameters
Fs=1/0.005; %[1/m] sampling frequency. [Hz] if the signal is time.                    
dx=1/Fs; %[m] spatial step.
nx=1000; %[-] number of points of the sample. Needs to be multiple of 2.

%% domain (no input)

x=(0:nx-1)*dx; %[m] space vector
f2=(0:nx-1)*(Fs/nx); %[1/m] frequency domain double-sided spectrum
f1=Fs*(0:(nx/2))/nx; %[1/m] frequency domain single-sided spectrum

L=x(end); %[m] length of the domain

%% variable

%spatial example 1
mu=3; %[m] mean of the Gaussian bell (x_0).
etab_max=1e-3; %variable, e.g. [m] (amplitude of the perturbation in flow depth).
sig=0.1; %[m] standard deviation of the Gaussian bell.

y=etab_max.*exp(-(x-mu).^2/sig^2); %variable e.g., [m]

%spatial example 2
% y=0.1*sin(2*pi*1.*x)+0.2*sin(2*pi*5.*x);

%% CALC

%% fft

yf=fft(y); %double-sided spectrum Fourier coefficients
% pf=abs(yf).^2/nt;    % power of the DFT (also correct, but check the units above)
pf=abs(yf).^2/dx;    % power of the DFT

S2=yf/nx; %double-sided spectrum
S1=S2(1:nx/2+1); %single-sided spectrum
S1(2:end-1)=2*S1(2:end-1);

S2_abs=abs(yf/nx); %absolute double-sided spectrum
S1_abs=S2_abs(1:nx/2+1); %single-sided spectrum
S1_abs(2:end-1)=2*S1_abs(2:end-1);

%% ifft double-sided spectrum

% nm=10; %number of modes to reconstruct
nm=nx; %number of modes to reconstruct

%ifft reconstruction
yf(nm+1:end)=0; %remove modes
y_rec_ifft=ifft(yf); %reconstruct

y_rec_manual_1=NaN(nm,nx);
y_rec_manual_2=NaN(nm,nx);
y_rec_manual_3=NaN(nm,nx);
for km=1:nm
    %matlab notation
    if km==1
        noise_add_fac=1;
    else
        fi=-((1:1:nx)-1)*(km-1);
        noise_add_fac=exp(-2*pi*1i/nx*fi);
    end
    y_rec_manual_1(km,:)=1/nm.*yf(km).*noise_add_fac;
    
    %nice notation
    lambda_loc=2*L/(km-1);
    k_loc=2*pi/lambda_loc;
    k_fou=2*(nx-1)/nx*k_loc;
    y_rec_manual_2(km,:)=S2(km).*exp(k_fou*1i.*x);
    
    %using frequency double-sided
    k_fou=2*pi*f2(km);
    y_rec_manual_3(km,:)=S2(km).*exp(k_fou*1i.*x);
end

y_rec_manual_1_sum=sum(y_rec_manual_1,1);
y_rec_manual_2_sum=sum(y_rec_manual_2,1);
y_rec_manual_3_sum=sum(y_rec_manual_2,1);

%they are all equal
% abs_min(y_rec_manual_1_sum,y_rec_ifft);
% abs_min(y_rec_manual_2_sum,y_rec_ifft);
% abs_min(y_rec_manual_3_sum,y_rec_ifft);

%% ifft single-sided spectrum

nm1=numel(f1);
y_rec_manual_s1_1=NaN(nm1,nx);
for km=1:nm1
    k_fou=2*pi*f1(km);
    y_rec_manual_s1_1(km,:)=S1(km)*exp(1i*k_fou*x);   
end

y_rec_manual_s1_sum=sum(y_rec_manual_s1_1,1);

%they are all equal
% abs_min(y_rec_manual_s1_sum,y_rec_ifft,'tol',1e-8);

%% PLOT 

%% reconstruction

figure
hold on
plot(x,y,'k*');
plot(x,y_rec_ifft)
plot(x,y_rec_manual_1_sum)
plot(x,y_rec_manual_2_sum)
plot(x,y_rec_manual_3_sum)
plot(x,y_rec_manual_s1_sum)

%% power

figure
plot(1./f2,pf);

%  varname_1='water level [m]';
%  varname_2='spectral power [m^2/s]';
 
%  varname_1='streamwise velocity [m/s]';
%  varname_2='spectral power [m^2/s^3]';

%% amplitudes

figure
plot(f1,S1_abs,'-*')


%% Negative frequencies explanation

%% INPUT

dx=0.1; %[m] sampling period, space step       
nx=100; %[-] number of samples

%initial condition parameters
A=1; %[m] amplitude
lambda=2; %[m] wave length

%% CALC

%% domain

fsx=1/dx; %[1/m] sampling frequency    
x=(0:nx-1)*dx; %[m] space domain
L=x(end); %[m] domain length
fx2=(0:nx-1)*fsx/nx; %[1/m] double-sided frequency domain

%% initial condition

z=A(1).*cos(2*pi*x/lambda(1)); %total noise

%% Fourier

cf=fft2(z); %forier coefficients

%% plot

figure
hold on
plot(fx2,abs(cf))
xlabel('frequency [1/m]')

%% negative frequencies

%maximum values of the fourier coefficients
[~,idx_s]=sort(abs(cf),'descend');
idx_m=idx_s(1:2); %indices of the maximum 2 values
fxp=fx2(idx_m); %frequencies of the maximum 2 values

z=A(1).*cos(2*pi*x/lambda(1)); %[m] original signal
z1p=A(1).*cos(2*pi*x.*fxp'); %[m] using result from FFT

figure
hold on
plot(x,z,'-o')
plot(x,z1p(1,:),'-s') %using positive frequencies
plot(x,z1p(2,:),'-d') %using negative frequencies

%the result is the same!

%% negative frequencies

%if the sampling is different, the nagtive frequencies can be better visualized

x2=0:dx/2:L;

z=A(1).*cos(2*pi*x2/lambda(1)); %[m] original signal
z1p=A(1).*cos(2*pi*x2.*fxp'); %[m] using result from FFT

figure
hold on
plot(x2,z,'-o')
plot(x2,z1p(1,:),'-s') %using positive frequencies
plot(x2,z1p(2,:),'-d') %using negative frequencies
