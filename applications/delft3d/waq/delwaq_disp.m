function varargout = delwaq_disp(Struct,varargin)
%DELWAQ_DISP   Display substances, locations from WAQ *.map or *.his file
%
% delwaq_disp(S) shows all SubsName's    with numbers
%                      and SegmentName's with numbers
%
% S is the delwaq file handle struct 
% S = delwaq('open','filename') or the (full) filename
%
%See also: DELWAQ, DELWAQ_SUBSNAME2INDEX, DELWAQ_SEGMENTNAME2INDEX
%          DELWAQ_TIME, DELWAQ_MESHGRID2DCORCEN

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delwaq_disp.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delwaq_disp.m $

   %% make sure S is the delwaq file handle struct
   %% and not the filename
   %% ----------------------------
   if ischar(Struct)
   Struct = delwaq('open',Struct);
   end

   %% Substance names, for history and map file
   %% ----------------------------
   disp('Nr.   SubsName:')
   disp('---   ------------->')

   for i=1:length(Struct.SubsName)
   disp([num2str(i,'%0.3d'),' : ''',char(Struct.SubsName(i)),'''']);
   end
   disp('---   ------------->')
      
   %% Segment names, only for history file
   %% ----------------------------
   if isfield(Struct,'SegmentName')
      disp(' ')
      disp('Nr.   SegmentName:')
      disp('---   ------------->')
      for i=1:length(Struct.SegmentName)
      disp([num2str(i,'%0.3d'),' : ''',char(Struct.SegmentName(i)),'''']);
      end
      disp('---   ------------->')
   end      

   %% Time step names, for history and map file
   %% ----------------------------
   
   disp('Reading times ...')
   T          = delwaq_time(Struct,'mod',Inf);
   T.nt       = length(T.datenum);
   
   disp('Nr.   Date:')
   disp('---   ------------->')
   disp([num2str(   1,'%0.3d'),' : ',datestr(T.datenum(  1),0)]);
   disp([num2str(T.nt,'%0.3d'),' : ',datestr(T.datenum(end),0)]);
   
   dt = diff(T.datenum).*24.*3600;
   if     ~isempty(dt) & length(unique(dt))==1
      disp(['dt = ',num2str(dt(1)),' s'])
   elseif ~isempty(dt)
      disp('at non-equidistant time step')
      disp(['dt_min = ',num2str(max(dt)),' s'])
      disp(['dt_max = ',num2str(min( 1)),' s'])
   end
      disp('---   ------------->')
 
   %% End
   %% ----------------------------

   if nargout==1
      varargout = {Struct};
   end
   
%% EOF   