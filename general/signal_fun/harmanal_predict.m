function varargout = harmanal_predict(t,varargin) 
%HARMANAL_PREDICT  harmonic prediction of timeseries
%
%  h = harmanal_predict(t,<keyword,value>)
%
%  performs a harmonic prediction on IRREGULARLY 
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
%   which is in days, make sure that you make seconds from
%   t when you pass it to this function by multiplying it with 
%   with 24*3600. (all data are in SI units, i.e. seconds for time).
% where h is the signal to be analysed.
% The following <keyword,value> pairs are implemented, 
% of which one of [T,omega,freq<ency>] is required:
%     * mean            b0
%     * hampltitudes    [sqrt(A1^2 + B1^2) ... sqrt(An^2 + Bn^2)], see harmanal
%     * hphases         [atan(B1/A1)       ... atan(Bn/An)      ] in radians, , see harmanal
%
%     * omega           angular velocity         (one of 3 is required)
%     * T               period                   (one of 3 is ,,)
%     * freq            frequency                (one of 3 is ,,)
%
% Example 1:  You can pass the output struct FIT of HARMANAL 
%             as input to harmanal_predict (using additional setproperty 
%             keywords to neglect redundant fields in FIT):
%
%    h = harmanal_predict(t,FIT,'onExtraField','silentIgnore')
%
% Example 2:
%    
%    plot(harmanal_predict(0:365,'T',[365.25 365.25/2],'hamplitudes',[1 1],'hphases',[0 pi]))
%
% These
%
% See also: HARMANAL, t_predic

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: harmanal_predict.m 7052 2012-07-27 12:44:44Z boer_g $
% $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $
% $Author: boer_g $
% $Revision: 7052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/harmanal_predict.m $
% $Keywords: $

%% input

   OPT.freq             = []; 
   OPT.omega            = []; 
   OPT.T                = [];
   OPT.mean             = 0;
   OPT.hamplitudes      = [];
   OPT.hphases          = [];
   OPT.screenoutput     = 0;
   OPT.transformFun     = @(x) x;% @(x) log10(x);
   OPT.transformFunInv  = @(x) x;% @(x) 10.^x;
   
   if nargin==0
       varargout = { OPT};
       return
   end
   
   OPT = setproperty(OPT,varargin{:});

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
   
%% reconstruct

h = zeros(size(t)) + OPT.mean;
for ic=1:length(OPT.hamplitudes)
    
    h = h + OPT.hamplitudes(ic).*cos(OPT.omega(ic).*t - OPT.hphases(ic));
    
end

h = OPT.transformFunInv(h);

varargout = {h};