function varargout = stretch(method0,par1,par2,varargin)
%STRETCH generate exponentially increasing series 
%
%   par3 = stretch(method,par1,par2)
%   par3 = stretch(method,par1,par2,<keyword,value>)
%
%   Calculates numerically by iteration the 1 missing
%   parameter par3 of the 3 parameters (s,f,n) in the 
%   following equation that specifies a 1D grid where 
%   each cell is a factor f bigger than the previous:
%
%       n-1                                        
%      +---                                      
%       \                                        
%   s =  | (f^n)                                 
%       /                                        
%      +---                                      
%        0                                       
%   which can be evaluated as:
%   alls = cumsum(f.^[0:n-1]); s = alls(end);                          
%
%   Not vectorized !
%
%   Example with f=2 and n=5 (with base=0)
%
%    1 2  <4 > <  8   > <       16     >   = ds
%   +-+--+----+--------+----------------+
%   |1| 2| 3  |   4    |        5       |  = #
%   +-+--+----+--------+----------------+
%   0 1  3    7        15               31 = s
%
%   Valid <keyword,value> pairs are:
%   * 'guess'     first guess value for par3 to speed up iteration
%   * 'accuracy'  accuracy for s     (in 'sn2f', default 1e-10)
%   * 'fiddle'    allow f to vary    (in 'sf2n', nan)
%   * 'base'      base=0: f.^[0:n-1] (in 'nf2s', default 0)
%                 base=1: f.^[1:n  ] 
%                 base=x: f.^[x:n+x-1]  wherte is for example log(y)/log(f*)
%
%   par1, par2 and par3 are used for the values of the
%   1st , 2nd  and 4rd  symbols in the method specification
%   string respectively, which is one of:
%
%   'sn2f','sn2f' exact within given accuracy (default 1e-10)
%
%   'nf2s','fn2s' evaluates equation given above.
%
%   'sf2n''fs2n'  never exact with the given f. stretch returns the first n
%                 for which s is bigger than the speficied s.
%                 With this option also the new (bigger) s is be returned upon request:
%
%                 n        = stretch('sf2n',s,n)
%                 [n,snew] = stretch('sf2n',s,n)
%
%                 A better step would be to find for the given n or (n-1) the 
%                 appropriate smaller (or bigger) f with the same method 'sn2f' 
%                 so that the match for s is exact. Therefore we have to allow 
%                 f to change:
%
%                 [n,f]    = stretch('sf2n',s,f,'fiddle',dn); 
%
%                 This changes f to match s and uses for n=n-dn, use dn = 0 
%                 for smaller f and f or 1 for bigger f.
%                 (dn=nan does not fiddle with f, and has an inexact match for s).
%
%See also: LINSPACE

%   --------------------------------------------------------------------
%   Copyright (C) March 2006 Delft University of Technology
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

% $Id: stretch.m 4963 2011-08-01 09:54:58Z boer_g $
% $Date: 2011-08-01 17:54:58 +0800 (Mon, 01 Aug 2011) $
% $Author: boer_g $
% $Revision: 4963 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/stretch.m $
% $Keywords$

%% Input
% ----------------

f0       = 1;
n0       = 1;
s0       = 1;
guess    = nan;
accuracy = 1e-10;
fiddle   = nan;
base     = 0;

i=1;
while i<=nargin-3,
  if ischar(varargin{i}),
    switch lower(varargin{i})
    case 'guess'   ;i=i+1;guess    = varargin{i};
    case 'accuracy';i=i+1;accuracy = varargin{i};
    case 'fiddle'  ;i=i+1;fiddle   = varargin{i};
    case 'base'    ;i=i+1;base     = varargin{i};
    otherwise
       error(sprintf('Invalid string argument: %s.',varargin{i}));
    end
  end;
  i=i+1;
end;

  
%% Method
% ----------------

switch lower(method0)

   case 'ns2f'
      n = par1;
      s = par2;
      method = 'ns2f';
   case 'sn2f'
      s = par1;
      n = par2;
      method = 'ns2f';

   case 'nf2s'
      n = par1;
      f = par2;
      method = 'nf2s';
   case 'fn2s'
      f = par1;
      n = par2;
      method = 'nf2s';

   case 'sf2n'
      s = par1;
      f = par2;
      method = 'sf2n';
   case 'fs2n'
      f = par1;
      s = par2;
      method = 'sf2n';

   otherwise
   
      error(['Method not recognized: ',method])
end

%% Calculate
% ----------------

switch method

case 'nf2s'
   
      %if base==0
      %alls = cumsum(f.^[0:n-1]);
      %elseif base==1
      %alls = cumsum(f.^[1:n  ]);
      %else
      %   error(['base should be 0 or 1, not: ',num2str(base)])
      %end
      
      alls = cumsum(f.^[base:n+base-1]);
      
      s    = alls(end);  
      
      if nargout<2      
         varargout = {s};
      end

case 'ns2f'

      if ~isnan(guess)
      f0         = guess;
      end
      
      s0         = cumsum(f0.^[base:n+base-1]);
      finished   = false;
      iter       = 0;
      epslimit   = 1e-12;
      f          = f0;
      
      while ~finished
      
         f0   = f;
         iter = iter + 1;
         
         %% We reduce the adapation of f 
         %  with the relative error
         %  when we get clopser to the solution
         %  This adaption is not applied
         %  when the error is larger than 99%
         %  because then f would be increased !!
         err  = min(abs((s0(end)) - s)/s,0.99);

         if     (s0(end) - s) > accuracy
            f  = f.*0.98;
            f  = f0 + (f-f0).*err;
            s0 = cumsum(f.^[base:n+base-1]);
         elseif (s0(end) - s) < -accuracy
            f  = f.*1.02;
            f  = f0 + (f-f0).*err;
            s0 = cumsum(f.^[base:n+base-1]);
         else
            finished = true;
         end

         %semilogy(iter,f,'.')
         %hold on
         %disp(num2str([iter s0(end) (s0(end) - s) f0]))
         %if mod(iter,100)==0
         %   semilogy(iter,f,'.')
         %   hold on
         %   disp(num2str([s0(end) (s0(end) - s) f0]))
         %   pausedisp
         %end
         
      end
      
      if nargout<2
         varargout = {f};
      end

case 'sf2n'

      %% CAN NEVER BE PRECISE: eventual s will be bigger than s
      %                            s
      %  +-------------------------+      
      %  |  |   |    |      |      : |
      %   1  2   3    4       5
      %                            +-+ too much   

      n  = 1;
      dx = f;
      x  = dx;

      %disp(num2str([n x]))
      
      while x(end) < s
      
         n  = n + 1;
         dx = [dx  f^n];
         x  = cumsum(dx);
         
      end
      
      if isnan(fiddle)
         if nargout<2
            varargout = {n};
         elseif nargout==2
            varargout = {n,x};
         end
      elseif isnumeric(fiddle) & nargout==2
      
         n = n-fiddle;
      
         f = stretch('ns2f',n,s,'guess',f);
         varargout = {n,f};
         
      else
         disp('n        = stretch(''sf2n'',s,n)')
         disp('[n,snew] = stretch(''sf2n'',s,n)')
         disp('[n,f]    = stretch(''sf2n'',s,n,''fiddle'',..)')      
         error('choose for syntax one of above')
      end

end

%% EOF
