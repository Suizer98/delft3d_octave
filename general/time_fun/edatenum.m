function elapsedtime = edatenum(varargin)
%EDATENUM   Elapsed time in seconds.
%
% EDATENUM(datenum1, datenum0,<timeunit>) returns the time in 
% seconds that has elapsed between datenumbers vectors 
% datenum1 and datenum0. Wrapper fot etime.
%
% EDATENUM(v,<timeunit>) uses
%  datenumbers1 = v(1,:);
%  datenumbers0 = v(2,:);
%
% Note the argument order convenction: first 1 than 0.
%
% Timeunit can be (default 's'):
% y<ear>,mo<nth>,d<ay>,h<our>,mi<nute>,s<econd>
%
% Note when datenums are single precision, edatenum
% can only return into multiples of quanta of about 45 min:
% for datenums around present:
% Example: diff(single(datenum(2010,1,1,[0 .7500],0,0))) = 0 !!
%
% See also: ETIME, DATENUM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: edatenum.m 5514 2011-11-22 10:39:21Z boer_g $
% $Date: 2011-11-22 18:39:21 +0800 (Tue, 22 Nov 2011) $
% $Author: boer_g $
% $Revision: 5514 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/edatenum.m $
% $Keywords: $

   timeunit = 's';
   
   if nargin==1
       datenumbers1 = varargin{1}(1,:);
       datenumbers0 = varargin{1}(2,:);
   end
   
   if nargin==2
     if ischar(varargin{2});
       datenumbers1 = varargin{1}(1,:);
       datenumbers0 = varargin{1}(2,:);
       timeunit     = varargin{2};
     else
       datenumbers1 = varargin{1};
       datenumbers0 = varargin{2};
     end
   end
   
   if nargin==3
       datenumbers1 = varargin{1};
       datenumbers0 = varargin{2};
       timeunit     = varargin{3};
   end
   
   [Y0,M0,D0,H0,MI0,S0] = datevec(datenumbers0);
   [Y1,M1,D1,H1,MI1,S1] = datevec(datenumbers1);
   
   T0 = [Y0 M0 D0 H0 MI0 S0];
   T1 = [Y1 M1 D1 H1 MI1 S1];
   
   elapsedseconds = etime(T1,T0);
   
   timeunit = lower(timeunit);
   
   if         strcmp(timeunit(1  ),'y' );   fac = 60*60*24*365.25;
   elseif     strcmp(timeunit(1  ),'m' );
       if     strcmp(timeunit(1:2),'mo');   fac = 60*60*24*30.5;
       elseif strcmp(timeunit(1:2),'mi');   fac = 60;
       end
   elseif     strcmp(timeunit(1  ),'d' );   fac = 60*60*24;
   elseif     strcmp(timeunit(1  ),'h' );   fac = 60*60;
   elseif     strcmp(timeunit(1  ),'s' );   fac = 1;
   else
      error(['Unknown time option: ''',timeunit,''', choose from y<ear>,mo<nth>,d<ay>,h<our>,m<inute>,s<econd>'])
   end
   
   elapsedtime = elapsedseconds./fac;

% EOF