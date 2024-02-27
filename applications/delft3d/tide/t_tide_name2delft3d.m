function delft3d_names = t_tide_name2delft3d(t_tide_names)
%T_TIDE_NAME2DELFT3D   returns Delft3D tidal constituent name given t_tide name
%
% delft3d_name = t_tide_name2delft3d(t_tide_name)
%
% * returns t_tide_name when t_tide_name is not present in 
%   conversion table.
%
% * case insensitive
%
% * vectorized
%
% See web:  T_TIDE (http://www.eos.ubc.ca/~rich/) 
% See also: DELFT3D_NAME2T_TIDE, BCT2BCA, BCA2BCT, NC_T_TIDE, dflowfm.analyseHis

% 2008 Jul 22: added A0/Z0

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

% $Id: t_tide_name2delft3d.m 12974 2016-11-04 14:58:18Z belisats.x.1 $
% $Date: 2016-11-04 22:58:18 +0800 (Fri, 04 Nov 2016) $
% $Author: belisats.x.1 $
% $Revision: 12974 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/tide/t_tide_name2delft3d.m $

   char_output = 0;
   if ischar(t_tide_names)
      t_tide_names = cellstr(t_tide_names);
      char_output  = true;
   end
   
   delft3d_names = t_tide_names;

   for iname=1:length(t_tide_names)

          if strmatch('Z0'  ,upper(t_tide_names{iname})); delft3d_names{iname} = 'A0'       ;
      elseif strmatch('RHO' ,upper(t_tide_names{iname})); delft3d_names{iname} = 'RO1'      ;
      elseif strmatch('SIG' ,upper(t_tide_names{iname})); delft3d_names{iname} = 'SIGMA1'   ;
      elseif strmatch('THE1',upper(t_tide_names{iname})); delft3d_names{iname} = 'THETA1'   ;
      elseif strmatch('PHI1',upper(t_tide_names{iname})); delft3d_names{iname} = 'FI1'      ;
      elseif strmatch('UPS1',upper(t_tide_names{iname})); delft3d_names{iname} = 'UPSILON1' ;
      elseif strmatch('EPS2',upper(t_tide_names{iname})); delft3d_names{iname} = 'EPSILON2' ;            
      elseif strmatch('LDA2',upper(t_tide_names{iname})); delft3d_names{iname} = 'LABDA2'   ;
      elseif strmatch('2MK5',upper(t_tide_names{iname})); delft3d_names{iname} = '3MO5'     ;            
      elseif strmatch('3MK7',upper(t_tide_names{iname})); delft3d_names{iname} = '2MSO7'    ;
      elseif strmatch('NO1' ,upper(t_tide_names{iname})); delft3d_names{iname} = 'M1'       ;
      elseif strmatch('ALP1',upper(t_tide_names{iname})); delft3d_names{iname} = '';disp(['NO Delft3D match found for ',t_tide_names{iname},', skipped.'])
      elseif strmatch('2SK5',upper(t_tide_names{iname})); delft3d_names{iname} = '';disp(['NO Delft3D match found for ',t_tide_names{iname},', skipped.'])
      else
        %disp(['NO Delft3D match found for ',t_tide_name,', name left unchanged.'])
                                                          delft3d_names{iname} = t_tide_names{iname};
      end  

   end % iname
   
   if char_output
      delft3d_names = char(delft3d_names);
   end

%% EOF