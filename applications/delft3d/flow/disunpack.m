function DISout = disunpack(DISin)
%DISUNPACK        Rewrites BCT_IO indexed table 2 struct with a field per data type <<beta version!>>
%
%    DISout = dispack(DISin,<keyword,value>)
%    DISout = dispack(DISin,OPT)
%
% works presently only for parameters (left) to become fieldname (right)
%
% *.dis
%
% 'total discharge (t)  end A'  > QA
% 'total discharge (t)  end B'  > QB
%
% *.bct
%
% 'Water elevation (Z)  End A'  > etaA
% 'Water elevation (Z)  End B'  > etaB
% 'flux/discharge rate'         > Q
% 'Salinity'                    > salinity
% 'Temperature'                 > temperature
% 'Sediment1'                   > sediment1
%
% Parameter names other than flux/discharge rate are converted 
% automatically to fieldnames (based on their name in the dis file). 
% This is required as some names (e.g. for sediments) are user defined
%
%See also: BCT_IO, DELFT3D_IO_DIS

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

% $Id: disunpack.m 3090 2010-09-23 11:31:33Z boer_g $
% $Date: 2010-09-23 19:31:33 +0800 (Thu, 23 Sep 2010) $
% $Author: boer_g $
% $Revision: 3090 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/disunpack.m $

ReferenceTimeFirst = DISin.Table(1).ReferenceTime;

for itable = 1:DISin.NTables

   %disp(['processing table: ',num2str(itable)])

   %% Check for consistent ReferenceTime times
   %-----------------------------------------
   
   if ~(ReferenceTimeFirst==DISin.Table(itable).ReferenceTime)
      error('disunpack: ReferenceTime of different tables are different')
   end

   %% Extract data from multi-dimensional table into struct field
   %-----------------------------------------
   
   H.parameternames = {'QA',...               %       *.bct
                       'QB',...               %       *.bct
                       'Q'};                  % *.dis
   for ipar = 3:length(DISin.Table(1).Parameter)
       H.parameternames{ipar+1} = lower(DISin.Table(1).Parameter(ipar).Name);
   end
   % units determined from file
   H.tablenames     = {'total discharge (t)  end A',... % *.bct
                       'total discharge (t)  end B',... % *.bct
                       'flux/discharge rate'};
   for ipar = 3:length(DISin.Table(1).Parameter)
       H.tablenames{ipar+1} = DISin.Table(1).Parameter(ipar).Name;
   end
                   

    DISout.data(itable).datenum  = time2datenum(DISin.Table(itable).ReferenceTime) + ...
                                                DISin.Table(itable).Data(:,1)./60./24; % minutes to days
    DISout.data(itable).datenum_units = 'days';
    
   %% Loop over Table names
   %-----------------------------------------

    for ipar=1:length(H.parameternames)

       parametername      = char(H.parameternames{ipar});
       parameternameunit  = [parametername,'_units'];
       tablename          = char(H.tablenames{ipar});
       
       for ifield = 1:length(DISin.Table(itable).Parameter);
       
          if strcmpi(DISin.Table(itable).Parameter(ifield).Name,tablename);
       
          DISout.data(itable).(parameternameunit) = DISin.Table(itable).Parameter(ifield).Unit;
          DISout.data(itable).(parametername    ) = DISin.Table(itable).Data(:,ifield);
           
          end
        
       end % ifield
       
       %% Calculate cumulative columes from Q
       %-----------------------------------------
       
       if strcmpi(parametername,'Q')

         DISout.data(itable).volume_units = 'm3';

         if    strcmpi(DISin.Table(itable).Interpolation,'Linear')
         
         DISout.data(itable).volume = cumtrapz(DISout.data(itable).datenum*24*3600,... % [s],...
                                               DISout.data(itable).Q)                  % [m3/s]
                                               
         

         elseif strcmpi(DISin.Table(itable).Interpolation,'Block')

         dt                         = diff(DISout.data(itable).datenum).*24.*3600;    % [s]
         DISout.data(itable).volume = cumsum([0; DISout.data(itable).Q(1:end-1).*dt]);% [m3/s] * [s]

         end

       end
        
    end
    
   %% Copy meta-information
   %-----------------------------------------

    DISout.data(itable).Name           =         DISin.Table(itable).Name         ;
    DISout.data(itable).Contents       =         DISin.Table(itable).Contents     ;
    DISout.data(itable).Location       =         DISin.Table(itable).Location     ;
    DISout.data(itable).TimeFunction   =         DISin.Table(itable).TimeFunction ;
    DISout.data(itable).ReferenceTime  = num2str(DISin.Table(itable).ReferenceTime);
   %DISout.data(itable).TimeUnit       =         DISin.Table(itable).TimeUnit     ;
    DISout.data(itable).Interpolation  =         DISin.Table(itable).Interpolation;
   %DISout.data(itable).Parameter      =         DISin.Table(itable).Parameter    ; 
   
end

%% EOF