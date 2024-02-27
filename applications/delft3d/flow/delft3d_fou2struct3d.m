function MAT = delft3d_fou2struct3d(TEK)
%DELFT3D_FOU2STRUCT3D   transforms fourier data to struct
%
% TEK = tekal('*.fou')
% MAT     = delft3d_fou2struct3d(TEK)
% MAT     = delft3d_fou2struct3d(TEK)
%
% Transforms the data in a tekal fourier file to a matlab struct.
% Handy for LAAAARGE fourier files.
%
% Note that the function does not allow one parameter (frequencies,layer) to be 
% determined twice (by performing the same analysis in two different time
% intervals of equal lenght). The last parameter encountered in the fourier file
% is then saved to the struct.
%
% Is is not possible to merge the fourier analysis of the velicities
% with the elliptical properties into one field for the 
% velocities. The cause for this is that the calculation of the elliptical
% properties is optional.
% 
% TEK and MAT are defined as global variables,
% so use these names also in the calling procedure and define them there 
% global as well to save memory.
%
% See also: DELFT3D_IO_FOU, FFT_ANAL, T_TIDE

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

% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id: delft3d_fou2struct3d.m 11454 2014-11-26 18:03:17Z youngtoti.x $
% $Date: 2014-11-27 02:03:17 +0800 (Thu, 27 Nov 2014) $
% $Author: youngtoti.x $
% $Revision: 11454 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_fou2struct3d.m $
% $Keywords:

global TEK MAT

if ischar(TEK)
   disp('Reading ASCII fourier file, please wait ...')
   TEK = tekal('open',TEK);
end

add_times2variable_name = 0; % default variable name is variable__layer__ncycles
                             % when performing a similar fourier analysis in different
                             % time intervals, the variable names are not unique

disp('Transforming TEKAL struct into matlab struct, please wait ...')
[MAT,OK] = tekal2hdf(TEK,add_times2variable_name);

if (~add_times2variable_name) & (~OK)
[MAT,OK] = tekal2hdf(TEK,add_ellips2fou,add_times2variable_name);
end

% #######################################

function [MAT,OK] = tekal2hdf(TEK,add_times2variable_name)

% Initialise

nfield            = length(TEK.Field);
first             = 1;
OK                = 1;
debugopt          = 0;

MAT.nodatavalue = nan;

for ifield = 1:nfield

   ncolumn = size(TEK.Field(ifield).Data,3);
   
% Read comment lines

   if first
   
      MAT.cen.x = squeeze(TEK.Field(ifield).Data(:,:,1));
      MAT.cen.y = squeeze(TEK.Field(ifield).Data(:,:,2));
      MAT.cor.x = squeeze(TEK.Field(ifield).Data(:,:,3));
      MAT.cor.y = squeeze(TEK.Field(ifield).Data(:,:,4));
      MAT.m     = squeeze(TEK.Field(ifield).Data(:,:,5));
      MAT.n     = squeeze(TEK.Field(ifield).Data(:,:,6));
      
      %if add_times2variable_name
      %MAT(ifield).how_does_this_struct_work = 'parametername__analysistype_tstart_tstop';
      %else
      %MAT(ifield).how_does_this_struct_work = 'parametername__analysistype';
      %end
   
   end
   
   Comments = TEK.Field(ifield).Comments;
   
   ncom = length(Comments);
   for icom=1:ncom
       if any(strfind(Comments{icom},'Results fourier analysis on'));ind = strfind(Comments{icom},':');TEK.Field(ifield).varname = strtrim(Comments{icom}(ind+1:end));end % mutually exclusive
       if any(strfind(Comments{icom},'Elliptic parameters of     '));ind = strfind(Comments{icom},':');TEK.Field(ifield).varname = strtrim(Comments{icom}(ind+1:end));end % mutually exclusive
       if any(strfind(Comments{icom},'Layer number'               ));ind = strfind(Comments{icom},':');TEK.Field(ifield).k       = str2num(Comments{icom}(ind+1:end));
       else
           TEK.Field(ifield).k=1;
       end
       if any(strfind(Comments{icom},'Reference date in YYYYMMDD' ));ind = strfind(Comments{icom},':');TEK.Field(ifield).itdate  = str2num(Comments{icom}(ind+1:end));end    
       if any(strfind(Comments{icom},'Starttime fourier analysis' ));ind = strfind(Comments{icom},':');TEK.Field(ifield).tstart  = str2num(Comments{icom}(ind+1:end));end    
       if any(strfind(Comments{icom},'Stoptime  fourier analysis' ));ind = strfind(Comments{icom},':');TEK.Field(ifield).tstop   = str2num(Comments{icom}(ind+1:end));end    
       if any(strfind(Comments{icom},'Number of cycles'           ));ind = strfind(Comments{icom},':');TEK.Field(ifield).ncyc    = str2num(Comments{icom}(ind+1:end));end    
       if any(strfind(Comments{icom},'Frequency'                  ));ind = strfind(Comments{icom},':');TEK.Field(ifield).freq    = str2num(Comments{icom}(ind+1:end));end    
   end
   
   % fou:  - Fourier amplitude for water levels
   %       - Fou amp u1 for velocities
   % amp:  - Fou amp u1
   % min:  - Minimum value for water levels
   %       - Min u1 for velocities
   % max:  - Maximum value for water levels
   %       - Max u1 for velocities
   % avg:  - when fou and ncycles==0

   analysis_type = lower(char(TEK.Field(ifield).ColLabels{7}(1:3)));
   
   if strcmp(analysis_type,'fou') & TEK.Field(ifield).ncyc ==0
      analysis_type = 'avg';
   end

   % Determine variable field names
   % based on meta information
   % - remove traling blanks
   % - allow only letters, and numbers
   % - only small case
   
   if add_times2variable_name
   parameter_name      = lower(mkvar([TEK.Field(ifield).varname,'_',...
                                      analysis_type,'__',...
                                      num2str(t_start ,'%0.9d'),'__',...
                                      num2str(t_stop  ,'%0.9d')]));
   else
   parameter_name      = lower(mkvar([TEK.Field(ifield).varname,'__',...
                                      analysis_type]));
   end
   
% Copy meta information to variable field
  
   MAT.(parameter_name).parameter          = TEK.Field(ifield).varname;
   
   if ~isfield(MAT.(parameter_name),'layer'             ) & ...
      ~isfield(MAT.(parameter_name),'frequency_deg_p_hr')
      f_k_combi = 1;
   else
      f_k_combi = length(MAT.(parameter_name).layer) + 1; % curent number of f_k_combi's
   end
   
   if debugopt
   disp([num2str(ifield),' ',parameter,'  ',num2str([f_k_combi layer frequency_deg_p_hr])])
   end

   MAT.(parameter_name).layer              (f_k_combi) = TEK.Field(ifield).k;
   MAT.(parameter_name).frequency_deg_p_hr (f_k_combi) = TEK.Field(ifield).freq;
   MAT.(parameter_name).t_start            (f_k_combi) = TEK.Field(ifield).tstart;
   MAT.(parameter_name).t_stop             (f_k_combi) = TEK.Field(ifield).tstop;
   MAT.(parameter_name).n_cycles           (f_k_combi) = TEK.Field(ifield).ncyc;
   
% Put all data blocks in variable field
   
   for icolumn = 7:ncolumn
   
      % Replace all non-letters and non-numbers with _
      
      variable_name = mkvar(char(TEK.Field(ifield).ColLabels{icolumn}));
      
      % Make a field for each variable
      
      % APPLY MASKS DEPENDING ON PARAMETER
      
      if strcmp(analysis_type,'fou')
         MAT.(parameter_name).(variable_name)(:,:,f_k_combi) = squeeze(TEK.Field(ifield).Data(:,:,icolumn));
      else
         MAT.(parameter_name).(variable_name)(:,:,f_k_combi) = squeeze(TEK.Field(ifield).Data(:,:,icolumn));
      end

   end
   
% Replace all nodata with nan using the KCS field
   
   dummyvalue_center = (MAT.(parameter_name).KCS==0);
   
   if first
      MAT.cen.x (dummyvalue_center) = nan;
      MAT.cen.y (dummyvalue_center) = nan;
      MAT.m     (dummyvalue_center) = nan;
      MAT.n     (dummyvalue_center) = nan;
   end
   
   for icolumn = 7:ncolumn
   
      variable_name = mkvar(char(TEK.Field(ifield).ColLabels{icolumn}));
      
      MAT.(parameter_name).(variable_name)(dummyvalue_center) = MAT.nodatavalue;

   end

   if first; first=0; end

   % - After processing try rmfield Data ?
   % - pack every field as a different variable ?
   % - remember all fields as single ?
   
   % tmpfile = gettmpfilename;
   % save(tmpfile,'MAT')
   % clear MAT
   %
   % TEK.Field(ifield).Data = rmfield(TEK.Field(ifield),'Data')
   %
   % MAT = load(tmpfile)
   
   disp(['Processed ',num2str(ifield),' of ',num2str(nfield)]);

end % for ifield = 1:nfield

clear TEK

end % function [MAT,OK] = tekal2hdf(TEK,add_times2variable_name)

%??? Error: File: fou2struct3d.m Line: 216 Column: 1
%The function "tekal2hdf" was closed 
% with an 'end', but at least one other function definition was not. 
% To avoid confusion when using nested functions, 
% it is illegal to use both conventions in the same file.

end % function, so all variables above are global within the scope of this file (part bewteen 'function' and this 'end')

