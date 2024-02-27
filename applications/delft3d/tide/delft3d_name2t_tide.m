function t_tide_names = delft3d_name2t_tide(delft3d_names)
%DELFT3D_NAME2T_TIDE   returns t_tide tidal constituent name given Delft3D name
%
% t_tide_name = delft3d_name2t_tide(delft3d_name)
%
% * returns delft3d_name when delft3d_name is not present in 
%   conversion table.
%
% * case insensitive
%
% * vectorized
%
% See web:  T_TIDE (http://www.eos.ubc.ca/~rich/) 
% See also: T_TIDE_NAME2DELFT3D, BCT2BCA, BCA2BCT, NC_T_TIDE, dflowfm.analyseHis

% 2008 Jul 22: added A0/Z0

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
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

% $Id: delft3d_name2t_tide.m 12974 2016-11-04 14:58:18Z belisats.x.1 $
% $Date: 2016-11-04 22:58:18 +0800 (Fri, 04 Nov 2016) $
% $Author: belisats.x.1 $
% $Revision: 12974 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/tide/delft3d_name2t_tide.m $
   
   char_output = 0;
   if ischar(delft3d_names)
      delft3d_names = cellstr(delft3d_names);
      char_output   = true;
   end
   
   t_tide_names = delft3d_names;
   
   for iname=1:length(delft3d_names)

          if strmatch('A0'      ,upper(delft3d_names{iname})); t_tide_names{iname} = 'Z0'  ;
      elseif strmatch('RO1'     ,upper(delft3d_names{iname})); t_tide_names{iname} = 'RHO' ;
      elseif strmatch('SIGMA1'  ,upper(delft3d_names{iname})); t_tide_names{iname} = 'SIG' ;
      elseif strmatch('THETA1'  ,upper(delft3d_names{iname})); t_tide_names{iname} = 'THE1';
      elseif strmatch('FI1'     ,upper(delft3d_names{iname})); t_tide_names{iname} = 'PHI1';
      elseif strmatch('UPSILON1',upper(delft3d_names{iname})); t_tide_names{iname} = 'UPS1';
      elseif strmatch('EPSILON2',upper(delft3d_names{iname})); t_tide_names{iname} = 'EPS2';            
      elseif strmatch('LABDA2'  ,upper(delft3d_names{iname})); t_tide_names{iname} = 'LDA2';
      elseif strmatch('3MO5'    ,upper(delft3d_names{iname})); t_tide_names{iname} = '2MK5';            
      elseif strmatch('2MSO7'   ,upper(delft3d_names{iname})); t_tide_names{iname} = '3MK7';
      elseif strmatch('M1'      ,upper(delft3d_names{iname})); t_tide_names{iname} = 'NO1';
      %  no equivalent                                         t_tide_names{iname} = 'ALP1';            
      %  no equivalent                                         t_tide_names{iname} = '2SK5';
      else
        %disp(['NO Delft3D match found for ',t_tide_name,', name left unchanged.'])
                                                               t_tide_names{iname} = delft3d_names{iname};
      end  
      
   end % iname
   
   if char_output
      t_tide_names = char(t_tide_names);
   end

%% EOF
