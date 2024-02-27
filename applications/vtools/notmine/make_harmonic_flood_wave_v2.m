%
% initializations
% ===============
peakduration = 1*24;      % hours 
recurrencetime = 10*24; % hours 
peaktime = 24*5;   % hours 

modeltimescale = 0.1; 
baseflow = 1000/280;  %m3/s
peakflow = 5000/280;  %m3/s

m = 11; % power of number of sampling points (N = 2^m)
L = 8;  % number of approximating harmonic components

%
% derived
% ===============

modelpeakduration = peakduration*modeltimescale;     %hours
modelrecurencetime = recurrencetime*modeltimescale;  %hours
modelpeaktime = peaktime*modeltimescale;       %hours

N = (2^m) ; % number of discrete data
Dt = modelrecurencetime/N; %0.1 ;
T = N*Dt ;
ffreq = 2*pi/T ; % fundamental frequency
t = linspace(0,T,N+1) ;

f = norm_pdf((t-modelpeaktime)/(modelpeakduration))/(norm_pdf(0))*(peakflow-baseflow)+baseflow;

fhat = f ;
fhat(1) = (f(1)+f(N+1))/2 ;
fhat(N+1) = [] ;
F = fft(fhat,N) ;
%
% use only the first half of the DFTs
% ===================================
%
F=F(1:N/2) ;
k=0:(N/2-1) ;
omega=k*ffreq ; % in units of rads/sec
% extracting the coefficients
% ---------------------------
A = 2*real(F)/N ;
A(1)= A(1)/2 ;
B =-2*imag(F)/N ;

fapprox = A(1)*ones(size(t)) ;
for k=1:L
    fapprox = fapprox + A(k+1)*cos(omega(k+1)*t)...
        + B(k+1)*sin(omega(k+1)*t);
end


amplitude = sqrt(A.^2+ B.^2);
phase = atan2(-B,A);

fapprox2 = A(1)*ones(size(t)) ;
for k=1:L
    fapprox2 = fapprox2 + amplitude(k+1)*cos(omega(k+1)*(t)+phase(k+1)); 
end

dlmwrite('floodwave_deg_hour_via_DS.csv',[omega(1:L).'*180/pi, amplitude(1:L).',phase(1:L).'*180/pi],'delimiter',' ','precision',7)
dlmwrite('floodwave_minutes.csv',[(omega(1:L).'*180/pi).^(-1)*360*60, amplitude(1:L).',phase(1:L).'*180/pi],'delimiter',' ','precision',7)
figure
plot(t,f,t,fapprox,'b-', t(1:20:end),fapprox2(1:20:end),'r.');

% Used sources: 
% [1] https://pages.mtu.edu/~tbco/cm416/fft1.pdf
% [2] http://www.stat.ucla.edu/~dinov/courses_students.dir/04/Spring/Stat233.dir/STAT233_notes.dir/FourierSeries.html

