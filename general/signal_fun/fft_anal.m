function varargout = fft_anal(varargin)
%FFT_ANAL  Fourier analysis of time series
%
%   Retrieves physical amplitudes and phases from 
%   a signal using FFT.
%
%   [Struct]                        = fft_anal(x,t or Fs)
%   [amplitudes,frequencies]        = fft_anal(x,t or Fs)
%   [amplitudes,frequencies,phases] = fft_anal(x,t or Fs)
%   [...]                           = fft_anal(x,t,n)
%   where
%   t      is evaluated from frequency Fs [when length(2nd argument)==1] or
%   Fs     is determined with numerical accuracy 
%          100*eps (~ 2e-14) from time vector t [when length(2nd argument) > 1].
%   x      is data time series at times t
%   t      is Time vector with resolution 1/Fs
%   Fs     is Sampling frequency
%   Struct is amplitudes:  [1x 73 double]
%             phases:      [1x 73 double]
%             fit:         [1x144 double]
%             frequencies: [1x 73 double]
%   n      is required components with a frequency of n*Fs
%             calculated as [t(end) - t(1)] / (lenght(t) -1)
%             or            [t(  2) - t(1)]
%             - When n=nan, no inverse fft is performed and fit=[](default)
%             - Make sure to include n=0 for the mean
%             - when n = 1:length(t)/2 all components are included
%               (same result as n=nan)
%
%   Argument, value pairs as in [...] = fft_anal(x,t,'inspection',0/1)
%
%      fft_anal(x,t,P/V Pairs) specifies additional property name/value pairs:
%
%      padwithzeros 0/1: whether to pad with zeros or not.
%                        Note that this influences the base frequency.
%      inspection   0/1: whether to plot signal, amplitudes and phases
%      tolerance   real: to detemine whether t is equidistant, depends on units of t [s or datenum etc.]
%
%   Uses code from from www.mathworks.com:
%   - What is the Proper Scaling of FFT Magnitude for a Signal with Two Frequencies?
%     @ http://www.mathworks.com/support/tech-notes/1700/1702.html
%   - Using FFT to Obtain Simple Spectral Analysis Plots
%     @ http://www.mathworks.com/support/tech-notes/1700/1703.html
%   - Signal Processing Toolbox:Discrete Fourier Transform
%     @ http://www.mathworks.com/access/helpdesk/help/toolbox/signal/basics30.html
%   © G.J. de Boer, g.j.deboer@tudelft.nl, June 2005
%
%   See also: fft, fft_filter, harmanal

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
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

   OPT.tolerance    = 100*eps;
   OPT.debug        = 0;
   OPT.padwithzeros = 0;
   OPT.inspection   = 1; 
   
   if odd(nargin)
      n       = varargin{3};
      i_argin = 4;
   else
      n       = nan; %0:length(t)/2;;
      i_argin = 3;
   end
   
   % remaining number of arguments is always even now
   while i_argin<=nargin,
       switch lower ( varargin{i_argin})
       % all keywords lower case
       case 'tolerance'   ;i_argin= i_argin+1;OPT.tolerance    = varargin{i_argin};
       case 'padwithzeros';i_argin= i_argin+1;OPT.padwithzeros = varargin{i_argin};
       case 'inspection'  ;i_argin= i_argin+1;OPT.inspection   = varargin{i_argin};
       otherwise
         error(sprintf('Invalid string argument (caps?) to fft_anal %s.',...
         varargin{i_argin}));
       end
         i_argin       = i_argin+1;
   end;
   
   
%% Arguments in

   x          = varargin{1};
   if length(varargin{2})==1
       Fs         = varargin{2};
       t           = [0:length(x)-1].*Fs; % zero (vs one) based ?
   else
       t          = varargin{2};
       
       number_of_times_tolerance_exceeded = sum(diff(t,2)<OPT.tolerance);
       
       if number_of_times_tolerance_exceeded==length(t)-2; % check whether time vector is equidistant, by taking 2nd derivative
          Fs = 1/diff(t(1:2));                   % if yes then sampling frequency is 1 over time step
       else
          error(['t should be equidistant. Note: syntax: fft_anal(x,t), NOT fft_anal(t,x). Deviation around dt is: ',num2str(range(unique(diff(t))))])
       end
   end
   
%% Error handling

   if ~(length(x)==length(t))
      error('length signal and time vector should be equal')
   end
      
%% FFT
  
   % Use next highest power of 2 greater than or equal to 
   % length(x) to calculate FFT. 
   if OPT.padwithzeros
      NFFT= 2^(nextpow2(length(x))); 
   else
      NFFT= length(x);
   end   
   
   % Take fft, padding with zeros so that length(FFTX) is equal to 
   % NFFT 
   FFTX = fft(x,NFFT); 
   
   % Transform back with selected components (Nyquist still fuzzy)

      if ~isnan(n)

            % Only keep required components
            % and throw away (set to 0) all others
            
            % x o o o o o o > spectrum
            % + + + + + + +
            %
            % 1 2 3 4 5 6 7 = position if FFTX array
            % 0 1 2 3 3 2 1 = n
            % m     n n
            % e     y y
            % a     q q
            % n     u u
            %       i i
            %       s s
            %       t t


            FFTX1             = FFTX;
            mask              = isnan(FFTX1);
            mask(      1 + n) = true;
            mask(end + 1 - n) = true; % Nyquist component might be set to 1 twice !

            if OPT.debug
            tmp = FFTX1;
            end
            FFTX1(~mask)      = 0;
            if OPT.debug
            [tmp' FFTX1']
            end

            fit = real(ifft(FFTX1));

            % Calculate the numberof unique points 
            NumUniquePts1 = ceil((NFFT+1)/2); 
   
            % FFT is symmetric, throw away second half 
            FFTX1 = FFTX1(1:NumUniquePts1); 
   
            [amplitudes1,phases1] = fftx2amplitudes_phases(FFTX1,NFFT,length(x));

            %% Transform back to signal using only required components
            
         else
            
            fit = [];
            
         end
   
%% Scale FFT results

   % Calculate the number of unique points 
   NumUniquePts = ceil((NFFT+1)/2); 
   
   % FFT is symmetric, throw away second half 
   FFTX = FFTX(1:NumUniquePts); 
   
   [amplitudes,phases] = fftx2amplitudes_phases(FFTX,NFFT,length(x));
   
   % This is an evenly spaced frequency vector with 
   % NumUniquePts points. 
   f = (0:NumUniquePts-1)*Fs/NFFT; 
   
%% Plot for inspection

if OPT.inspection

   % Generate the plot, title and labels. 
   temporaryfigure = figure;
   subplot(3,1,1)
   plot  (f,amplitudes ,'.-'); 
   title ('Amplitude spectrum'); 
   xlabel('Frequency [1/timeunit]'); 
   ylabel('Amplitude [data unit]'); 
   grid on
   set(gca,'yscale','log')
   
   subplot(3,1,2)
   plot  (f,phases,'.-'); 
   title ('Phase spectrum'); 
   set(gca,'ylim',[-pi-eps pi+eps])
   set(gca,'ytick',[-1:.5:1].*pi)
   set(gca,'yticklabel',{'-pi','-pi/2','0','pi/2','pi'})
   xlabel('Frequency [1/timeunit]'); 
   ylabel('Phase [rad]'); 
   grid on
   
   subplot(3,1,3)
   plot  (t,x,'.'); 
   title ('Signal'); 
   xlabel('Time [timeunit]'); 
   ylabel('Data [data unit]'); 
   grid on

   if ~isnan(n)
      subplot(3,1,1)
      hold on
      plot  (f,amplitudes1,'ro-'); 
      
      subplot(3,1,2)
      hold on
      plot  (f,phases1,'ro-'); 
      
      subplot(3,1,3)
      hold on
      plot  (t,fit,'r'); 
   end

   disp('Press key to continue')
   pause

   try
   close(temporaryfigure)
   end

end
   
%% Arguments out

   if nargout <2
   S.amplitudes  = amplitudes;
   S.phases      = phases    ;
   S.fit         = fit       ;
   S.frequencies = f         ;
      varargout = {S};
   elseif nargout==2
      varargout = {amplitudes,f};
   elseif nargout==3
      varargout = {amplitudes,f,phases};
   end
   

function out = odd(in)
%ODD
% out = odd(x) is 1 where x is odd.
%
% SEE ALSO: mod, sign

out = mod(in,2)==1;

function [amplitudes,phases] = fftx2amplitudes_phases(FFTX,NFFT,lenght_x)

   % Take the magnitude of fft of x 
   amplitudes = abs(FFTX); 
  %phases     = unwrap(angle(FFTX)); 
   phases     = angle(FFTX); 
   
   % Scale the fft so that it is not a function of the 
   % length of x 
   amplitudes = amplitudes/lenght_x; 
   % On 
   % http://www.mathworks.com/access/helpdesk/help/toolbox/signal/basics30.html
   % It is noted that:
   %         The resulting FFT amplitude is A*n/2,where 
   %         A is the original amplitude and 
   %         n is the number of FFT points.
   %         This is true only if the number of FFT points
   %         is greater than or equal to the number of data
   %         samples. If the number of FFT points is less, 
   %         the FFT amplitude is lower than the original 
   %         amplitude by the above amount. 
   %  So can it be concluded that:
   %         Here the signal is padded with zeros so
   %         it can be divided by the length of the 
   %         input data.
   
   
   % DO NOT Take the square of the magnitude of fft of x. 
   % AS WE WANT TO KNOW AMPLITUDES AND NOT POWER
   % MX = MX.^2; 
   
   
   % Multiply by 2 because you 
   % threw out second half of FFTX above 
   amplitudes = amplitudes*2; 
   
   
   % DC Component should be unique. 
   amplitudes(1) = amplitudes(1)/2; 
   
   
   % Nyquist component should also be unique.
   if ~rem(NFFT,2) 
      % Here NFFT is even; therefore, Nyquist point is included. 
      amplitudes(end) = amplitudes(end)/2; 
   end 
