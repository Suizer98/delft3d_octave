function varargout = fft_filter(varargin)
%FFT_FILTER  High/low pass fourier filter for time series
%
%   Retrieves physical amplitudes and phases from 
%   a signal using FFT.
%
%   [xnew] = fft_anal(x,t)
%   where Fs is determined with numerical accuracy 
%   of 100*eps (~ 2e-14) from time vector.
%
%   [xnew]  = fft_anal(x,Fs)
%   where t is reconstructed form Fs.
%
%   x    = data time series at times t
%   xnew = filtered data time series at times t
%   t    = Time vector with resolution 1/Fs
%   Fs   = Sampling frequency
%
%   Argument, value pairs:
%
%      fft_anal(x,t,'argument',value)
%
%      padwithzeros 0/1: to indicate whether to pad 
%                        with zeros or not. Note that this
%                        influences the base frequency (default 0).
%      
%      inspection   0/1: to indicate whether to plot
%                        signal, amplitudes and phases (default 1)
%
%      highpass    frequency:
%                        spectrum is set to zero BELOW this
%                        frequency (default 0).
%                        The frequency itself is kept if it is
%                        a frequency exactly an integer multiple
%                        of the base frequency
%
%      lowpass     frequency:
%                        spectrum is set to zero ABOVE this
%                        frequency (default Inf)
%                        The frequency itself is kept if it is
%                        a frequency exactly an integer multiple
%                        of the base frequency
%
%      [amplitudes,frequencies,phases] = fft_anal(x,t,'plot',0/1)
%
%   Uses code from from www.mathworks.com:
%
%   What is the Proper Scaling of FFT Magnitude for a Signal with Two Frequencies?
%   @ http://www.mathworks.com/support/tech-notes/1700/1702.html
%
%   Using FFT to Obtain Simple Spectral Analysis Plots
%   @ http://www.mathworks.com/support/tech-notes/1700/1703.html
%
%   Signal Processing Toolbox:Discrete Fourier Transform
%   @ http://www.mathworks.com/access/helpdesk/help/toolbox/signal/basics30.html
%
%   See also: fft, fft_anal, harmanal, thompson1983

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------   

disp('UNDER CONSTRUCTION')

   tolerance = 100*eps;
   
%% Arguments in
%% ------------------------

   x          = varargin{1};
   if length(varargin{2})==1
       Fs         = varargin{2};
       t           = [0:length(x)-1].*Fs; % zero (vs one) based ?
   else
       t          = varargin{2};
       if sum(diff(t,2)<tolerance)==length(t)-2; % check whether time vector is equidistant, by taking 2nd derivative





          Fs = 1/diff(t(1:2));                      % if yes then sampling frequency is 1 over time step
       else
          error('Time vector t should be equidistant. Note: syntax: fft_filter(X,T), not fft_filter(t,x)')
       end
   end
   
   
   i_argin = 3;
   padwithzeros = 0;
   inspection   = 1; 
   lowpass      = Inf; 
   highpass     = 0; 
   
   % remaining number of arguments is always even now
   while i_argin<=nargin,
       switch lower ( varargin{i_argin})
       % all keywords lower case
       case 'padwithzeros'
         i_argin       = i_argin+1;
         padwithzeros  = varargin{i_argin};
       case 'inspection'
         i_argin       = i_argin+1;
         inspection    = varargin{i_argin};
       case 'lowpass'
         i_argin       = i_argin+1;
         lowpass       = varargin{i_argin};
       case 'highpass'
         i_argin       = i_argin+1;
         highpass      = varargin{i_argin};
       otherwise
         error(sprintf('Invalid string argument (caps?) to fft_anal %s.',...
         varargin{i_argin}));
       end
         i_argin       = i_argin+1;
   end;
   
%% Error handling

   if ~(length(x)==length(t))
      error('length signal and time vector should be equal')
   end
      
%% FFT
   
   % Use next highest power of 2 greater than or equal to 
   % length(x) to calculate FFT. 
   if padwithzeros
      NFFT= 2^(nextpow2(length(x))); 
   else
      NFFT= length(x);
   end   
   
   
   % Take fft, padding with zeros so that length(FFTX) is equal to 
   % NFFT 
   FFTX = fft(x,NFFT);
   
%% Scale FFT results

   % Calculate the numberof unique points 
   NumUniquePts = ceil((NFFT+1)/2); 
   
   % This is an evenly spaced frequency vector with 
   % NumUniquePts points. 
   f = (0:NumUniquePts-1)*Fs/NFFT; 
   
   make0lowpass  = find(f > lowpass );
   make0highpass = find(f < highpass);
   
%% Apply filters
%% ------------------------

   FFTX1 = FFTX;
   % set lower freqencies to zero at both ends
   % to pass higher frequencies in middle
   FFTX1(1:max(make0highpass)           ) = 0;
   FFTX1(end:-1:end-max(make0highpass)+2) = 0;
   
   % set higher freqencies to zero in middle
   % to pass lower frequencies at ends
   FFTX1(make0lowpass:end-make0lowpass+2) = 0;

%% Transform back to signal
%% ------------------------

   x1 = real(ifft(FFTX1));
   
%% Plot for inspection
%% ------------------------

if inspection

   f_all= (0:NFFT-1)*Fs/NFFT;
   fmax = f_all(end) + f_all(2);
   
   % Generate the plot, title and labels. 
   temporaryfigure = figure;
   subplot(2,1,1)
   plot  (f_all,FFTX.*conj(FFTX),'.-b'); 
   hold on
   plot  (f_all,FFTX1.*conj(FFTX1),'o-r'); 
   plot  (f_all,FFTX.*conj(FFTX) - FFTX1.*conj(FFTX1),'o-g'); 
   vline (lowpass)
   vline (highpass)
   vline (fmax -lowpass)
   vline (fmax-highpass)
   
   set(gca,'yscale','log')

   %fill3 ([fmax   lowpass   lowpass  fmax],[0 0 ymax ymax],[-1 -1 -1 -1],'r')
   %fill3 ([0      highpass  highpass 0   ],[0 0 ymax ymax],[-1 -1 -1 -1],'r')
   
   
   title ('Spectrum'); 
   xlabel('P [1/timeunit]'); 
   ylabel('Power [data unit^2/timeunit]'); 
   grid on
   
   subplot(2,1,2)
   plot  (t,x,'.-b'); 
   hold on
   plot  (t,x1,'.-r'); 
   plot  (t,x-x1,'.-g'); 
   title ('Signal'); 
   xlabel('Time [timeunit]'); 
   ylabel('Data [data unit]'); 
   grid on
   legend('original (old) signal','filtered (new) signal','removed (residue) signal')

   disp('Press key to continue')
   pause
   
   try
   close(temporaryfigure)
   end

end
   
%% Arguments out
%% ------------------------

   if nargout <2
      varargout = {x1};
   elseif nargout==2
      varargout = {x1};
   end
   

%% --------------------------------------------------------------------

function out = odd(in)
%ODD
% out = odd(x) is 1 where x is odd.
%
% SEE ALSO: mod, sign

out = mod(in,2)==1;
