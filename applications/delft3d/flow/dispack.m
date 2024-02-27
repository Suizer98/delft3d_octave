function DISout = dispack(DISin,varargin)
%DISPACK          rewrites BCT_IO result to have column instead of a struct field per data type <<beta version!>>
%
%    DISout = dispack(DISin,<keyword,value>)
%    DISout = dispack(DISin,OPT)
%
% where the following <keyword,value> pairs have been implemented:
% * ReferenceTimeMask: remove all data before refenrece tiem, 
%                      because delft3d-flow cannot handle those.
%
% work now for parameters (left) to become fieldname (right)
%
% *.dis
%
% 'total discharge (t)  end A'  < QA
% 'total discharge (t)  end B'  < QB
%
% *.bct
%
% 'flux/discharge rate'         < Q
% 'Salinity'                    < salinity
% 'Temperature'                 < temperature
%
%See also: BCT_IO, DELFT3D_IO_BCT, DELFT3D_IO_DIS

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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: dispack.m 13260 2017-04-13 12:37:27Z nederhof $
% $Date: 2017-04-13 20:37:27 +0800 (Thu, 13 Apr 2017) $
% $Author: nederhof $
% $Revision: 13260 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/dispack.m $

% for block remove last data point, so array sizes determine block or linear

   %% Set defaults for keywords
   %------------------------

   OPT.ReferenceTimeMask = 1;

   %% Return defaults
   %------------------------

   if nargin==0
      varargout = {OPT};
      return
   end

   iargin = 1;
   while iargin<=nargin-1,
     if isstruct(varargin{iargin})
        OPT = mergestructs('overwrite',OPT,varargin{iargin});
     elseif ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       case 'referencetimemask' ;iargin=iargin+1;OPT.referencetimemask  = varargin{iargin};
       otherwise
          error(['Invalid string argument: %s.',varargin{i}]);
       end
     end;
     iargin=iargin+1;
   end; 
 
   %% Start
   %------------------------
 
   ReferenceTimeFirst = DISin.data(1).ReferenceTime;
   
   for itable = 1:length(DISin.data)
   
      %disp(['processing table: ',num2str(itable)])
   
      %% Check for consistent ReferenceTime times
      %-----------------------------------------
      
      if isnumeric(ReferenceTimeFirst)
         if ~(ReferenceTimeFirst==DISin.data(itable).ReferenceTime)
            error('disunpack: ReferenceTime of different tables are different')
         end
      else
         if ~strcmpi(ReferenceTimeFirst,DISin.data(itable).ReferenceTime)
             error('disunpack: ReferenceTime of different tables are different')
         end
      end
   
      %% Extract data from multi-dimensional table into struct field
      %-----------------------------------------
      
      H.parameternames = {'QA',...                         %       *.bct
                          'QB',...                         %       *.bct
                          'Q',...                          % *.dis
                          'salinity',...                   % *.dis
                          'temperature',...
                          'flow_magnitude',...
                          'flow_direction'};                  % *.dis
   
      H.parameterunits = {'[m3/s]',...                     %       *.bct
                          '[m3/s]',...                     %       *.bct
                          '[m3/s]',...                     % *.dis
                          '[ppt]',...                      % *.dis
                          '[°C]',...                       % *.dis
                          '[m/s]',...                        % *.dis
                          '[deg]'};                          % *.dis
   
      H.tablenames     = {'total discharge (t)  end A',... %       *.bct
                          'total discharge (t)  end B',... %       *.bct
                          'flux/discharge rate',...        % *.dis
                          'Salinity',...                   % *.dis
                          'Temperature',...                % *.dis
                          'Flow magnitude',...
                          'Flow direction'};                  % *.dis

                          
      %% Check number of substances
      %-----------------------------------------
      
      fldnames = fieldnames(DISin.data(itable));

      % add user-defined constituents (e.g. sediment)
      fldnames_def = {'datenum', 'datenum_units', 'Q_units', 'Q', 'volume_units', 'volume',...
          'salinity_units', 'salinity', 'temperature_units','temperature',...
          'Name', 'Contents', 'Location',...
          'TimeFunction', 'ReferenceTime','Interpolation'};
      A = ~ismember(fldnames,fldnames_def);
      Ainew = find(A==1);
      for ia = 2:2:length(Ainew)
          newpari = length(H.parameternames)+1;
          H.parameternames(newpari) = fldnames(Ainew(ia));
          H.parameterunits(newpari) = {DISin.data(itable).(char(fldnames(Ainew(ia-1))))};
          H.tablenames(newpari) = fldnames(Ainew(ia));
      end
      % end of add user-defined constituents
      
      ncolumns = 1; % start with one for time
   
      for ipar=1:length(H.parameternames)
         if any(strcmp(H.parameternames{ipar},fldnames));
         ncolumns = ncolumns + 1;
         end
      end
      
      %% Mask
      %-----------------------------------------

      mask = 1:length(DISin.data(itable).datenum);
      if any(DISin.data(itable).datenum < time2datenum(DISin.data(itable).ReferenceTime))
         if OPT.ReferenceTimeMask
            warning(['Removed all data before reference time ',DISin.data(itable).ReferenceTime])
            mask = DISin.data(itable).datenum > time2datenum(DISin.data(itable).ReferenceTime);
         else
            warning(['Some data are before reference time ',DISin.data(itable).ReferenceTime,', which Delft3D does not swallow.'])
         end
      end      
      
      ntimes = length(DISin.data(itable).datenum(mask));
      
      %% Insert time columns
      %-----------------------------------------
   
      DISout.Table(itable).Data      = repmat(nan,[ntimes ncolumns]);
   
      DISout.Table(itable).Data(:,1) = (DISin.data(itable).datenum(mask) - ...
                                        time2datenum(DISin.data(itable).ReferenceTime)).*24.*60;
                                        

                                        
      DISout.Table(itable).Parameter(1).Name = 'time';
      DISout.Table(itable).Parameter(1).Unit = '[min]';
                                        
   
      %% Loop over Table names
      %-----------------------------------------
   
      column = 1; % start with one for time
         
      for ipar=1:length(H.parameternames)
      
         H.parametername      = char(H.parameternames{ipar});
         H.parameterunit      = char(H.parameterunits{ipar});
         H.tablename          = char(H.tablenames{ipar});
         
         for ifield = 1:length(fldnames);
         
            fldname = fldnames{ifield};
            
            if strcmpi(fldname,H.parametername);
            
            column = column + 1;
         
           %disp([num2str(itable),'  ',num2str(ifield),'  ',num2str(column),'  ',fldname,'  ',H.tablename,'  ',H.parameterunit])
            
            DISout.Table(itable).Parameter(column).Name = H.tablename;
            DISout.Table(itable).Parameter(column).Unit = H.parameterunit;
            disp (H.parametername)
            DISout.Table(itable).Data   (:,column)      = DISin.data(itable).(H.parametername)(mask);
             
            end
          
          end % ifield
          
      end
       
      %% Copy meta-information
      %-----------------------------------------
   
      DISout.Table(itable).Name          =         DISin.data(itable).Name          ;
      DISout.Table(itable).Contents      =         DISin.data(itable).Contents      ;
      DISout.Table(itable).Location      =         DISin.data(itable).Location      ;
      DISout.Table(itable).TimeFunction  =         DISin.data(itable).TimeFunction  ;
      DISout.Table(itable).ReferenceTime = str2num(DISin.data(itable).ReferenceTime );
      DISout.Table(itable).TimeUnit      = 'minutes';
      DISout.Table(itable).Interpolation =         DISin.data(itable).Interpolation ;
      
   end % itable
   
   DISout.NTables = length(DISout.Table);

%% EOF