function DAT = expressionsfromstring(string,var_names,varargin)
%EXPRESSIONSFROMSTRING    interprets space delimited expressions like a=3
%
% DAT = expressionsfromstring(string,var_names)
%
% reads space delimited expressions like a=3
% from a string for the variable names passed in 
% the cell var_names into a struct.
%
% Example of string:
% expressionsfromstring('MUD alpha=1. rhom=1300. nu=0.01 layer=0.01',..
%                      {'rhom','nu','layer','alpha'})
%
% DAT = 
%      rhom: 1300
%        nu: 0.0100
%     layer: 0.0100
%     alpha: []
%
% Keyword,values paris are:
% * 'empty' false/true (default)  Var_names that are not present 
%                                 are added as empty matrices by
% See also: STRTOKENS2CELL

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
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

% $Id: expressionsfromstring.m 7052 2012-07-27 12:44:44Z boer_g $
% $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $
% $Author: boer_g $
% $Revision: 7052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/expressionsfromstring.m $

%% for testing/debugging
% clear DAT
% var_names = {'rhom','nu','layer','alpha'};
% string    = 'MUD alpha=1. rhom=1300. nu=0.01 layer=0.01';

%% Handle keyword/value pairs
   
   OPT.empty = true;
   
   OPT = setproperty(OPT,varargin{:});

   equalsigns     = findstr(string,'=');
   
   if isempty(string)
       DAT = [];
   else
   
%% option: only assign values to requested var_names, that can appear in any order in var_names
   
   for ivar=1:length(var_names)
   
      var_name       = var_names{ivar};
      var_name_index = findstr(string,var_name);
   
      if length(var_name_index) >1
      %% Case with keyword 'rho' and other keyword '_rho_'
      %% Check that it opens and closes with a space.
         for j=1:length(var_name_index)
            if strcmp(strtok(string(var_name_index(j):end)),var_name)
               var_name_index = var_name_index(j);
               break
            end
         end
      end
      
      if isempty(var_name_index)
         if OPT.empty
            DAT.(var_name) = [];
         end
      else
         var_equalsign  = find(equalsigns > var_name_index);
         var_equalsign  = var_equalsign(1);
         rest_of_string = string(equalsigns(var_equalsign)+1:end);
         var_value      = str2num(strtok(rest_of_string));
         DAT.(var_name) = var_value;
      end
   end
   
   end

%% EOF