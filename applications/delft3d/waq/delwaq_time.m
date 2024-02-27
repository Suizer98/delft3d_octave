function varargout = delwaq_time(Struct,varargin)
%DELWAQ_TIME   read time vector from delwaq *.map file
%
% D = DELWAQ_TIME(Struct)
%
% where D has a field 'datenum' and Struct comes 
% from Struct = delwaq('open',...)
%
% DELWAQ_TIME(Struct,'datenum',1) returns only a datenum vector and no
% struct with field 'datenum'.
%
% NOTE: DELWAQ *.map file do not require an equidistant timevector.
%                    and also allows for double occurences.
%
%See also: DELWAQ, DELWAQ_SUBSNAME2INDEX, DELWAQ_DISP
%          DELWAQ_TIME, DELWAQ_MESHGRID2DCORCEN,VS_TIME

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: delwaq_time.m 11898 2015-04-23 16:09:31Z scheel $
% $Date: 2015-04-24 00:09:31 +0800 (Fri, 24 Apr 2015) $
% $Author: scheel $
% $Revision: 11898 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delwaq_time.m $

   %% Set defaults for keywords

      OPT.mod       = 100; % display notification eveyr 100 steps, set 1 or Inf for no disp
      OPT.ndigits   = ceil(log10(Struct.NTimes));
      OPT.fmt       = ['%0.',num2str(OPT.ndigits),'d'];
      OPT.datenum   = 0; 
      OPT.quiet     = false;
      
   %% Return defaults

      if nargin==0
         varargout = {OPT};
         return
      end
      
   % Cycle keywords in input argument list to overwrite default values.
   % Align code lines as much as possible to allow for block editing in textpad.
   % Only start <keyword,value> pairs after the REQUIRED arguments. 
      
      iargin = 1;
      
      while iargin<=nargin-1,
        if isstruct(varargin{iargin})
           OPT = mergestructs('overwrite',OPT,varargin{iargin});
        elseif ischar(varargin{iargin}),
          switch lower(varargin{iargin})
          case 'mod'      ;iargin=iargin+1;OPT.mod     = varargin{iargin};
          case 'ndigits'  ;iargin=iargin+1;OPT.ndigits = varargin{iargin};
          case 'fmt'      ;iargin=iargin+1;OPT.fmt     = varargin{iargin};
          case 'datenum'  ;iargin=iargin+1;OPT.datenum = varargin{iargin};
          case 'quiet'    ;iargin=iargin+1;OPT.quiet   = varargin{iargin};
          otherwise
             error(['Invalid string argument: %s.',varargin{i}]);
          end
        end;
        iargin=iargin+1;
      end; 
      
   %% Initialize
      
      T.datenum       = repmat(NaN,[1 Struct.NTimes]);
      T.datenum_units = 'days since 0 Jan. 0000 00:00';
      T.timezone      = '';
      
      OPT.Substance   = Struct.SubsName{1}; % dummy
      OPT.Segment     = 1;                  % dummy
   
   %% Time loop

      for it=1:Struct.NTimes
      
         [T.datenum(it),Dummy_Data]=delwaq('read',Struct,OPT.Substance,OPT.Segment,it);
          
         % disp([num2str(it),' ',datestr(T.datenum(it),31)])
         
         if ~OPT.quiet
             if mod(it+1,OPT.mod)==1
                disp(['delwaq_time progress: ',num2str(it,OPT.fmt),' / ',num2str(Struct.NTimes,OPT.fmt)])
             end
         end
      
      end % for it=1:Struct.NTimes
      
      if OPT.datenum
          varargout = {T.datenum};
      else
          varargout = {T};
      end

%% EOF