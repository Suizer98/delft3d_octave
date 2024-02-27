
function [P1,scale]=get_psd(himt,density,Args)
% 
% Written by Daniel Buscombe, various times in 2012 and 2013
% while at
% School of Marine Science and Engineering, University of Plymouth, UK
% then
% Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
% please contact:
% dbuscombe@usgs.gov
% for lastest code version please visit:
% https://github.com/dbuscombe-usgs
% see also (project blog):
% http://dbuscombe-usgs.github.com/
%====================================
%   This function is part of 'dgs-gui' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================
[rows,cols] = size(himt);

W1=cell(1,size([1:density:rows],2));

for j=1:density:rows
    
    x=himt(j,:); x=x(:);
    tr=polyval(polyfit([1:length(x)]',x,1),[1:length(x)]');
    x=x-tr;
    
    %     x=diag(him); x=x(:);
    
    J1=fix((log(cols*1/Args.S0)/log(2))/Args.Dj);
    
    if Args.Pad == 1
        base2 = fix(log(cols)/log(2) + 0.4999);   % power of 2 nearest to N
        Y=zeros(1,cols+(2^(base2+1)-cols));
        Y(1:cols) = x - mean(x);
    else
        Y=x;
    end
    n = length(Y);
    
    k = [1:fix(n/2)];
    k = k.*((2.*pi)/(n*1));
    k = [0., k, -k(fix((n-1)/2):-1:1)];
    
    %....compute FFT of the (padded) time series
    f = fft(Y);    % [Eqn(3)]
    
    %....construct SCALE array & empty PERIOD & WAVE arrays
    scale = Args.S0*2.^((0:J1)*Args.Dj);
    wave = zeros(J1+1,n);  % define the wavelet array
    wave = wave + 1i*wave;  % make it complex
    % loop through all scales and compute transform
    for a1 = 1:J1+1
        [daughter,fourier_factor,coi,dofmin]=wave_bases(Args.Mother,k,scale(a1),-1);
        wave(a1,:) = ifft(f.*daughter);  % wavelet transform[Eqn(4)]
    end
    
    wave = wave(:,1:cols);  % get rid of padding before returning
        
    sinv=1./(scale');
    wave=sinv(:,ones(1,cols)).*(abs(wave).^2);
    
    twave=zeros(size(wave));
    npad=2.^ceil(log2(cols));
    k = 1:fix(npad/2);
    k = k.*((2.*pi)/npad);
    k2=[0., k, -k(fix((npad-1)/2):-1:1)].^2;
    
    snorm=scale./1;
    for ii=1:size(wave,1)
        F=exp(-.5*(snorm(ii)^2)*k2);
        smooth=ifft(F.*fft(wave(ii,:),npad));
        twave(ii,:)=smooth(1:cols);
    end
    scale=scale./2;
    
    if isreal(wave)
        twave=real(twave);
    end
    
    W1{j}=var(twave,[],2);
    
    keep W1 j himt rows cols Args scale
    
end

P1=mean((cell2mat(W1)),2);
P1=P1./sum(P1);


if max(scale) > (cols/3)
    f=find(scale>(cols/3),1,'first');
    scale=scale(1:f);
    P1=P1(1:f);
end
P1=P1./sum(P1);

P1(1)=P1(1)/10;
P1=P1./sum(P1);






