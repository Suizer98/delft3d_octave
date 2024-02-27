function [varargout] = harmanal(t,h,varargin);
%HARMANAL  harmonic analysis of timeseries
%
%  FIT     = harmanal(t,signal,<keyword,value>)
%  [A,phi] = harmanal(t,signal,<keyword,value>)
%
%  performs a harmonic analysis on IRREGULARLY 
%  spaced, scalar time series signal h according to :
%                __
%    h(t) = b0 + \ [Ai*cos(wi*t) + Bi*sin(wi*t)]
%                /_ i
%                __
%    h(t) = b0 + \ [Hi*cos(wi*t - phi_i)]
%                /_ i
%
% where t contains the times at which data points are available.
%   Note: the units in which t is specified should be seconds
%   Note: when using the matlab datenum convention for dates, 
%   which is in days, make sure that you make days from e.g. seconds
%   t when you pass it to this function by dividing it with 
%   with 24*3600. (all data are in SI units, i.e. seconds for time).
% where h is the signal to be analysed.
% where  coef'        contains [bo   A1     B1    ...      An     Bn   ]
%        ampltitudes' contains [sqrt(A1^2 + B1^2) ... sqrt(An^2 + Bn^2)]
%        phases'      contains [atan(B1/A1)       ... atan(Bn/An)      ] in radians
%
% The following <keyword,value> pairs are implemented, of which
% one of [T,omega,freq<ency>] is required:
%     * omega           angular velocity         (one of 3 is required)
%     * T               period                   (one of 3 is ,,)
%     * freq            frequency                (one of 3 is ,,)
%     * parameter       name of harmonically reconstructed time series (default 'hfit')
%     * names           name of component        (optional for output)
%     * plotspectrum    whether to plot spectrum (default 0)
%     * plottimeseries  whether to plot spectrum (default 0)
%     * plotM           whether to plot spectrum (default 0)
%     * screenoutput    whether to plot spectrum (default 1)
%     * errors          whether to plot spectrum (default 1)
%     * timeseries      matrix defined at same times t as h, to which 
%                       a coefficient will be fitted too (default []).
%
% For proper workings of the inversion matrix, t and h should 
% have size [1 length(h)]. If not, internally the matrices are 
% transposed. The resulting hfit is returned with the size of h 
% (to be able to calculate h - hfit easily).
%
% Example: Extract the very same period T you impose:
%
%     t   = linspace(0,2*pi,100);
%     T   = pi;
%     FIT = harmanal(t,cos(2*pi*t./T),'T',T);
%     FIT.hamplitudes
%     FIT.hphases    
%
% See also: T_TIDE, FFT_ANAL, FFT_FILTER, HARMANAL_PREDICT

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2009 Delft University of Technology
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
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% TO DO: file output to some international standard

%% input

   OPT.plotspectrum     = 0;
   OPT.plottimeseries   = 0;
   OPT.plotM            = 0;
   OPT.screenoutput     = 1;
   OPT.errors           = 1;
   OPT.parameter        = 'hfit';
   OPT.freq             = []; 
   OPT.omega            = []; 
   OPT.names            = []; 
   OPT.T                = [];
   OPT.timeseries       = [];
   OPT.transformFun     = @(x) x;% @(x) log10(x);
   OPT.transformFunInv  = @(x) x;% @(x) 10.^x;
   
   if nargin==0
       varargout = { OPT};
       return
   end
   
   if nargin>3
      nextarg = 1;
   else
      error('at least one <keyword,value> pair required: tide/frequency/period')
   end
   
   OPT = setproperty(OPT,varargin{nextarg:end});
   
   if ~(OPT.transformFun(OPT.transformFunInv(1))==1)
      error('transformFunInv(x) is not the inverse of transformFun(x) for x=1')
   end

%% Add and reformat (optional) fieldnames
   errtxt = ('warning, ONLY mean used, no period "T", (radial) frequency "freq" ("omega") given\n');
   if isempty(OPT.omega);
      if     ~isempty(OPT.freq );OPT.omega = 2.*pi.*OPT.freq;
      elseif ~isempty(OPT.T    );OPT.omega = 2.*pi./OPT.T;
      else
         if OPT.screenoutput;fprintf(1,errtxt);end
      end
   end
   if isempty(OPT.freq );
      if     ~isempty(OPT.omega);OPT.freq = OPT.omega./2./pi;
      elseif ~isempty(OPT.T    );OPT.freq = 1./OPT.T;
      else
         if OPT.screenoutput;fprintf(1,errtxt);end
      end
   end
   if isempty(OPT.T    );
      if     ~isempty(OPT.omega);OPT.T    = 2.*pi./OPT.omega;
      elseif ~isempty(OPT.freq );OPT.T    = 1./OPT.freq     ;
      else
         if OPT.screenoutput;fprintf(1,errtxt);end
      end
   end
   
   nw     = length(OPT.omega);
   
   if isempty(OPT.names)
      OPT.names = num2str([1:nw]');
   elseif iscell(OPT.names)
       OPT.names1 = [];
       for i=1:length(OPT.names)
           OPT.names1 = strvcat(OPT.names1, char(OPT.names(i)));
       end
      OPT.names = OPT.names1;
   end
   
   meanname = 'mean';
   if size(OPT.names,1) < length(meanname)
      namewidth = length(meanname);% for mean component
      OPT.names = pad(OPT.names,length(meanname),' ');
   else    
      namewidth = length(OPT.names(1,:));% for mean component
   end   
   
   sizehin = size(h);
   if ~(size(t,1)==1); t = t';end
   if ~(size(h,1)==1); h = h';end
   
   if ~isempty(OPT.timeseries)
   if ~(size(OPT.timeseries,1)==1)
    OPT.timeseries = OPT.timeseries';
   end
   end
   
   nc = size(OPT.timeseries,1); % size 2 is time
   if nc>0 & OPT.screenoutput==1
      disp(['Message: harmanal: fitting ',num2str(nc),' non-harmonic functions'])
   end

%% REMOVE NANS FROM DATA

   mask2keep = ~(isnan(t) | isnan(h));
   
%% mean component
   if sum(OPT.omega==0)==0
   %   OPT.omega     = [0       OPT.w];
   %   OPT.freq      = [0       OPT.f];
   %   OPT.T         = [realmax OPT.T];
   %   OPT.names     = strvcat('mean',OPT.names);
   elseif sum(OPT.omega==0)==1
      error('Cannot include mean component (frequency==0)')
   elseif sum(OPT.omega==0)>1
      error('Mean component (frequency==0) added more than once')
   end
   
%% specify least square solution      
   
   % if ~(size(t,2)==size(h,2))
   %    error('Orientation h and t wrong: dim = 1 should be different datasets and dim 2 time')
   % end
   
   % b0 = column(1)
   % Ai = column(1 + 2*iw-1)
   % Bi = column(1 + 2*iw  )
   
   % Pre allocate coefficients array containing 
   % b0, A1, B1, ... , A2, B2
   % ------------------------------------------
   coef = repmat(0,1,2*nw+1+nc);
   
   % Fill matrix M that gives relation between h on the left hand side and 
   %        __
   %  b0 +  \ [Ai*cos(wi*t) + Bi*sin(wi*t)]]
   %        /_ i
   %
   % on the right hand side according to h = M * coef
   % ------------------------------------------
   %M      = repmat(0,  2*nw+1   ,length(t));
    M      = repmat(0,  2*nw+1+nc,sum(mask2keep(:)));
   
   M(1,:) = 1; 
   
   for iw=1:nw
      M(1 + 2*iw-1,:) = cos(OPT.omega(iw).*t(mask2keep)); % Ai*cos(wi*t)
      M(1 + 2*iw  ,:) = sin(OPT.omega(iw).*t(mask2keep)); % Bi*sin(wi*t)
   end
   
   for ic=1:nc
      M(1 + 2*nw+ic,:) = OPT.timeseries(ic,mask2keep);  % Ci*f(t)
   end

%% get least square solution to tidal parameters
   
      if OPT.plotM
         newfig1 = figure;
            hist(M(:))
            % DONT PLOT surf(M), IS TOO BIG
            pause
         try
         close(newfig1)
         end
      end
      
      coef  = OPT.transformFun(h(mask2keep))/M;
      
%% rewrite to get tidal parameters

     %FIT.(OPT.parameter)             = coef*M;
      FIT.(OPT.parameter)             = nan.*zeros(size(h));
      FIT.(OPT.parameter)(mask2keep)  = OPT.transformFunInv(coef*M);
      
      % TO DO reconstruct hfit to fill NaN gaps
      % with HARMANAL_PREDICT
      
      a = coef(2:2:2*nw+1);
      b = coef(3:2:2*nw+1);
      c = coef(  2*nw+2:end);

      %            sqrt[(Ai)^2 + (Bi)^2]
      amplitudes = sqrt(a.^2 + ...
                        b.^2);
                        
      amplitude_order = ranknumber(amplitudes);
   
      %            atan(Bi/Ai))
      % If you want the right phase for a sinus base fucntion,
      % subtract 90 degrees, for a cosinus don't.

      phases     = - atan2(a,...
                           b) + pi/2;
      
   
      % all in range 0 360
      phases(phases<0) = phases(phases<0)+2*pi;
      
   
% CHECK amplitudes and phases
   
   %   FIT.hfit2 = coef(1) + zeros(size(h));
   %   for iw=1:length(OPT.w)
   %   FIT.hfit2  = FIT.hfit2  + amplitudes(iw).* cos(OPT.omega(iw).*t - phases(iw));
   %   end
   
%% PLOT SPECTRUM
   
       if OPT.plotspectrum
   
          newfig1 = figure;
   
             subplot(2,1,1)
             bar   (OPT.freq,amplitudes)
             hold   on
             text  (OPT.freq,amplitudes,OPT.names,'rotation',45)
             title ('Amplitudes')
             xlabel(' Frequency ')
             grid   on
             
             subplot(2,1,2)
             bar   (OPT.freq,rad2deg(phases))
             hold   on
             text  (OPT.freq,rad2deg(phases),OPT.names,'rotation',45)
             title (' Phases')
             xlabel(' Frequency ')
             grid   on
   
          newfig2 = figure;
   
             subplot(2,1,1)
             plot  (OPT.freq,amplitudes,'o')
             hold   on
             text  (OPT.freq,amplitudes,OPT.names,'rotation',45)
             title ('Amplitudes')
             xlabel(' Frequency ')
             set   (gca,'yscale','log')
             grid   on
             
             subplot(2,1,2)
             bar   (OPT.freq,rad2deg(phases))
             hold   on
             text  (OPT.freq,rad2deg(phases),OPT.names,'rotation',45)
             title (' Phases')
             xlabel(' Frequency ')
             grid   on
   
   
          newfig3= figure;
            
            plot    (amplitudes,amplitudes,'+')
            hold    ('on')
            text    (amplitudes,amplitudes,...
                     OPT.names,'rotation',-45);
            title   (['Amplitudes [m] '])
            grid    ('on')
            set     (gca,'xscale','log')
            set     (gca,'yscale','log')
            % axis    ([1e-3 1 1e-3 1]) % does not work for fluxes
   
   
          pause
          try
          close (newfig1)
          end
          try
          close (newfig2)
          end
          try
          close (newfig3)
          end
          
       end %if OPT.plot

%% PLOT TIMESERIES

       if OPT.plottimeseries 
   
          newfig1 = figure;
          subplot(2,1,1)
          plot   (t,h,'k')
          hold   ('on')
          plot   (t,FIT.(OPT.parameter),'g')
          plot   (t,h-FIT.(OPT.parameter),'b')
          title  ('Time series')
          xlabel (' Time [s]')
          legend ('h','h_{fit}','residual (data - harmonic fit)')
          grid   ('on')
   
          subplot(2,1,2)
          plot   (t,FIT.(OPT.parameter)-h,'b')
          title  ('Time series')
          xlabel (' Time [s]')
          legend ('residual')
          grid   ('on')
   
          pause
          try
          close (newfig1)
          end
       end
       
       if OPT.errors
       FIT.residue  = h(:) - FIT.(OPT.parameter)(:);
       FIT.rmserror = nanrms(FIT.residue(:));
       FIT.minerror = nanmin(FIT.residue(:));
       FIT.maxerror = nanmax(FIT.residue(:));
       end       
      
%% DISPLAY
   
      if OPT.screenoutput==1
   
         spaces  = repmat(' ',[1 namewidth  ]);
         spaces1 = repmat('-',[1 namewidth  ]);
         spaces2 = repmat(' ',[1 namewidth-length(meanname)]);
         
         
         disp(['no | seq| ',spaces ,' |      T     |     f      |   Ampl.    |   Phase    |     Ai     |     Bi     |'])
        %disp(['[#]| [#]| ',spaces ,' |     [h]    |     [1/h]  |   [m]      |   [deg]    |     [m]    |     [m]    |'])
         disp(['---+----+-',spaces1,'-+------------+------------+------------+------------+............+............+'])
        %disp(['   |    | ',spaces ,' |            |            |            |            |            |            |'])
         
              disp([num2str(0                  ,'%0.3i')  , '| ',...
                    num2str(0                  ,'%0.3i')  , '| ',...
                    meanname,spaces2               ,           ' | ',...
                    num2str(0                  ,'%010.4g'),' | ',...
                    num2str(0                  ,'%010.4g'),' # ',...
                    num2str(coef(1)            ,'%010.4g'),' | ',...
                    num2str(0                  ,'%010.4g'),' | ',...
                    num2str(0                  ,'%010.4g'),' | ',...
                    num2str(0                  ,'%010.4g'),' | '])
         
           for iw=1:nw
              disp([num2str(iw                 ,'%0.3i') ,  '| ',...
                    num2str(amplitude_order(iw),'%0.3i') ,  '| ',...
                    OPT.names(iw,:)              ,           ' | ',...
                    num2str(OPT.T(iw)/3600       ,'%010.4g'),' | ',...
                    num2str(OPT.freq(iw)*3600    ,'%010.4g'),' # ',...
                    num2str(amplitudes(iw)     ,'%010.4g'),' | ',...
                    num2str(rad2deg(phases(iw)),'%010.4g'),' | ',...
                    num2str(coef(1 + 2*iw-1)   ,'%010.4g'),' | ',...
                    num2str(coef(1 + 2*iw  )   ,'%010.4g'),' | '])
           end
           disp(['---+----+-',spaces1,'-+------------+------------+------------+------------+............+............+'])
           if OPT.errors
              disp(['rms error  ',spaces,'| ',repmat(' ',1,26),num2str(FIT.rmserror       ,'%010.4g'),' | '])
              disp(['min error  ',spaces,'| ',repmat(' ',1,26),num2str(FIT.minerror       ,'%010.4g'),' | '])
              disp(['max error  ',spaces,'| ',repmat(' ',1,26),num2str(FIT.maxerror       ,'%010.4g'),' | '])
           end
           
         disp(['---+----+-',spaces1,'-+------------+------------+------------+'])
      
      end
   
      %if (1/(t(end)-t(1))) < (min(diff(sort(OPT.freq(:)))))
      [dummy, closest_components] = min(abs(diff(OPT.freq)));

      if isempty(closest_components)
          if nw==1
          T_rayleigh = 1/OPT.freq(1); % one component only
          else
          T_rayleigh = -Inf;
          end
      else
          T_rayleigh = (1/(OPT.freq(closest_components+1)-OPT.freq(closest_components)));
      end
      
%% RAYLEIGH CHECK      
      
      if (t(end)-t(1)) >= T_rayleigh
      
         if OPT.screenoutput==1
         disp(['Rayleigh criterion: OK']);
         end

      else

         %% Always display when not OK
         
         if OPT.screenoutput==1 % overrule with e.g. -1
         disp(['Rayleigh criterion: NOT OK for ',...
               deblank(OPT.names(closest_components,:)),...
               ' & ',...
               deblank(OPT.names(closest_components+1,:)),' dt=',...
               num2str(t(end)-t(1)),' T_rayleigh=',...
               num2str(T_rayleigh)]);
         end

      end
      if OPT.screenoutput==1
      disp(['  df_{min} possible data / present with specified components = ',...
             num2str(1/(t(end)-t(1))),' / ',...
             num2str(min(diff(sort(OPT.freq(:)))))]);
      end
      
%% NYQUIST CHECK       

      if  nw > 0
      if (1/2/min(diff(t))) > (max(OPT.freq))
          if OPT.screenoutput==1
          disp('Nyquist criterion: OK')
          end
      else
          disp('Nyquist criterion: NOT OK')
      end
      
      if OPT.screenoutput==1
      disp(['  f_{max} possible / present with dataset                    = ',...
            num2str(1/2/min(diff(t))),' / ',...
            num2str(max(OPT.freq))]);
      disp(['----------',spaces1,'--------------------------------------------------------------------------------'])
      end
      end

%% RETURN VALUES

   if nargout==1
   
      FIT.(OPT.parameter) = reshape(FIT.(OPT.parameter), sizehin);
      FIT.a               = a         ;
      FIT.b               = b         ;
      FIT.c               = c         ;
      FIT.coef            = coef      ;
      FIT.hamplitudes     = amplitudes;
      FIT.amplitude_order = amplitude_order;
      FIT.hphases         = phases    ;
      FIT.freq            = OPT.freq  ;
      FIT.omega           = OPT.omega ;
      FIT.T               = OPT.T     ;
      FIT.names           = OPT.names ;
      FIT.mean            = coef(1)   ;
      FIT.transformFun    = OPT.transformFun   ;
      FIT.transformFunInv = OPT.transformFunInv;
      
      varargout = {FIT};
   elseif nargout==2
      varargout = {amplitudes,phases};
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = ranknumber(X)
%RANKNUMBER
%
% rankno = ranknumber(X) returns array with same size as X, with each 
% element containing the rank number of the value of X at that position.
%
% See also:

   [sortedX,I]= sort(X);
   r = []; % if X==[]
   for j = 1:length(X)
      r(I(j)) = j;
   end
   r = length(X) - r + 1;
   % disp(num2str([(1:length(X))', X,ranknumber']));
   
