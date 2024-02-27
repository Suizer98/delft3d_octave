function varargout = delft3d_part_io_inp(varargin)
%DELFT3D_PART_IO_INP   Reads Delft3D-PART *.inp file into struct (BETA VERSION)
%
% DAT = delft3d_part_io_inp        % launches file load GUI
% DAT = delft3d_part_io_inp(fname)
% 
% Beta version, G.J. de Boer, Mar 28nd 2006
%
% See also: DELFT3D_WAQ_IO_INP, DELFT3D_IO_MDF

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl (also: gerben.deboer@wldelft.nl)
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

mfile_version = '1.0, March 28nd 2006, beta';

%% cells are difficult to store as non-matlab files (HDF etc)
%% so we try to avoid them
no_cellstr    = 1;

   %% 0 - command line file name or 
   %%     Launch file open GUI
   %% ------------------------------------------

   %% No file name specified if even number of arguments
   %% i.e. 2 or 4 input parameters
   % -----------------------------
   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'*.inp' ,'Delft3d-PART input file (*.inp)'; ...
         '*.*'   ,'All Files (*.*)'}, ...
         'Delft3d-PART *.inp file');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         DAT.filename   = [];
         iostat         = 0;
      else
         DAT.filename   = [pathname, shortfilename];
         iostat         = 1;
      end

   %% No file name specified if odd number of arguments
   % -----------------------------
   
   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      DAT.filename   = varargin{1};
      iostat         = 1;
   end
   
   %% I - Check if file exists (actually redundant after file GUI)
   %% ------------------------------------------

   tmp = dir(DAT.filename);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',DAT.filename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0

      DAT.filedate     = tmp.date;
      DAT.filebytes    = tmp.bytes;
   
      fid              = fopen   (DAT.filename,'r');
      
      %% II - Check if can be opened (locked etc.)
      %% ------------------------------------------

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',DAT.filename])
         else
            iostat = -1;
         end
      
      elseif fid > 2

         %% II - Check if can be read (format etc.)
         %% ------------------------------------------

         try
         
            n = 0; % number of lines that have been read
            
            %% Read 5 identification lines 
            %% ------------------------------------------
            
           [DAT.data.run_identification{1},n]  = waq_fgetl_string(fid,n);
           [DAT.data.run_identification{2},n]  = waq_fgetl_string(fid,n);
           [DAT.data.run_identification{3},n]  = waq_fgetl_string(fid,n);
           [DAT.data.run_identification{4},n]  = waq_fgetl_string(fid,n);
           [DAT.data.run_identification{5},n]  = waq_fgetl_string(fid,n);
            
            if no_cellstr
            DAT.data.run_identification        = char(DAT.data.run_identification);
            end
            
           [DAT.data.hydfile,n]                = waq_fgetl_string(fid,n);
      
           [numbers,n]                         = waq_fgetl_number(fid,n);
            DAT.data.type_of_model             = numbers(1);
            DAT.data.type_of_model_FYI         = ['1 - tracer (basic module)';
            					  '2 - (obsolete option)    ';
						  '3 - red tide model       ';
						  '4 - oil model            ';
						  '5 - (obsolete option)    '];
            
            DAT.data.tracks                    = numbers(2);
            DAT.data.extra_output              = numbers(3);
            DAT.data.sedimentation_erosion     = numbers(4);
            
           [numbers,n]                         = waq_fgetl_number(fid,n);
            DAT.data.numerical_scheme          = numbers(1);
            DAT.data.timestep                  = numbers(2);
      
           [numbers,n]                         = waq_fgetl_number(fid,n);
            DAT.data.vert_disperion_option     = numbers(1);
            DAT.data.vert_disp_scale           = numbers(2);
            DAT.data.vert_disp_coeff           = numbers(3);
            DAT.data.vert_disp_FYI             = ['vert. disp option(*)0=constant 1=depth averaged';
                                                  'disp_coeff.(m2/s)                              '];
      
           [DAT.data.no_of_substances,n]       = waq_fgetl_number(fid,n);
	                

            %% TO DO pre-allocate
      
            for i=1:DAT.data.no_of_substances
           [DAT.data.substance_name,n]         = waq_fgetl_string(fid,n);
            end
            
            if no_cellstr
            DAT.data.substance_name = char(DAT.data.substance_name);
            end

      
           [DAT.data.no_of_particles       ,n] = waq_fgetl_number(fid,n);
            
           [DAT.data.roughness             ,n] = waq_fgetl_number(fid,n);
           [DAT.data.hor_diff_a_coeff      ,n] = waq_fgetl_number(fid,n);
           [DAT.data.hor_diff_b_coeff      ,n] = waq_fgetl_number(fid,n);
            DAT.data.hor_diff_FYI              = 'D = a*t^b';
           [DAT.data.winddrag_in_percent   ,n] = waq_fgetl_number(fid,n);
           [DAT.data.density_of_water      ,n] = waq_fgetl_number(fid,n);
            DAT.data.density_of_water_FYI      = 'kg m^{-3}';
            
            %% Wind
            %% --------------------

           [DAT.data.no_of_wind_data,n]        = waq_fgetl_number(fid,n);
            %% TO DO pre-allocate
            for i=1:DAT.data.no_of_wind_data
           [numbers,n]                         = waq_fgetl_number(fid,n);
            DAT.data.wind_times(i,:)           = numbers(1:4);
            %DAT.data.wind_dd(i,:)             = numbers(1);
            %DAT.data.wind_hh(i,:)             = numbers(2);
            %DAT.data.wind_mm(i,:)             = numbers(3);
            %DAT.data.wind_ss(i,:)             = numbers(4);
            DAT.data.wind_speed      (i,:)     = numbers(5);
            DAT.data.wind_direction  (i,:)     = numbers(6);
            end
            
           [DAT.data.no_of_model_specific_paramters,n] = waq_fgetl_number(fid,n);
            
            %% Timers
            %% --------------------
            
           [DAT.data.simulation_start_time    ,n] = waq_fgetl_number(fid,n);
           [DAT.data.simulation_stop_time     ,n] = waq_fgetl_number(fid,n);
           [DAT.data.DELWAQ_take_over_time    ,n] = waq_fgetl_number(fid,n);
           [DAT.data.map_file_start_time      ,n] = waq_fgetl_number(fid,n);
           [DAT.data.map_file_stop_time       ,n] = waq_fgetl_number(fid,n);
           [DAT.data.map_file_time_step       ,n] = waq_fgetl_number(fid,n);
           [DAT.data.his_file_start_time      ,n] = waq_fgetl_number(fid,n);
           [DAT.data.his_file_stop_time       ,n] = waq_fgetl_number(fid,n);
           [DAT.data.his_file_time_step       ,n] = waq_fgetl_number(fid,n);
           [DAT.data.reference_date_for_output,n] = waq_fgetl_number(fid,n);
      
            %% Observation points
            %% --------------------

           [DAT.data.no_of_observation_points,n] = waq_fgetl_number(fid,n);
            %% TO DO pre-allocate	      
            for i=1:DAT.data.no_of_observation_points
           [numbers,n]                          = waq_fgetl_number(fid,n);
            DAT.data.observation_points_x(i)    = numbers(1);
            DAT.data.observation_points_x(i)    = numbers(2);
            end				      
      					      
            %% Zoom grid		      
            %% --------------------

           [DAT.data.zoom_grid_output_method,n]= waq_fgetl_number(fid,n);
      
           [numbers                         ,n]= waq_fgetl_number(fid,n);
            DAT.data.recovery_times            = numbers(1:4);
            %DAT.data.recovery_dd              = numbers(1);
            %DAT.data.recovery_hh              = numbers(2);
            %DAT.data.recovery_mm              = numbers(3);
            %DAT.data.recovery_ss              = numbers(4);
            DAT.recovery_factors               = numbers(5);
      
           [numbers                         ,n]= waq_fgetl_number(fid,n);
            DAT.data.zoom_grid_x_start         = numbers(1);
            DAT.data.zoom_grid_x_end           = numbers(2);
      
           [numbers                         ,n]= waq_fgetl_number(fid,n);
            DAT.data.zoom_grid_y_start         = numbers(1);
            DAT.data.zoom_grid_y_end           = numbers(2);
      
           [numbers                         ,n]= waq_fgetl_number(fid,n);
            DAT.data.zoom_grid_nx              = numbers(1);
            DAT.data.zoom_grid_ny              = numbers(2);
      
            %% Instant release
            %% --------------------

           [DAT.data.no_of_instantaneous_releases           ,n] = waq_fgetl_number(fid,n);
            %% TO DO pre-allocate
            for i=1:DAT.data.no_of_instantaneous_releases
           [DAT.data.instant_release_name{i}                ,n] = waq_fgetl_string(fid,n);
   					     
           [numbers                                         ,n] = waq_fgetl_number(fid,n);
            DAT.data.instant_release_times(i,:)                 = numbers(1:4);
            %DAT.data.instant_release_dd(i)                     = numbers(1);
            %DAT.data.instant_release_hh(i)                     = numbers(2);
            %DAT.data.instant_release_mm(i)                     = numbers(3);
            %DAT.data.instant_release_ss(i)                     = numbers(4);
      
           [numbers                                         ,n] = waq_fgetl_number(fid,n);
            DAT.data.instant_release_x(i)                       = numbers(1);
            DAT.data.instant_release_y(i)                       = numbers(2);
      
           [numbers                                         ,n] = waq_fgetl_number(fid,n);
            DAT.data.instant_release_radius_option(i)           = numbers(1);
            DAT.data.instant_release_radius(i)                  = numbers(2);
      
           [DAT.data.instant_release_percent_of_particles(i),n] = waq_fgetl_number(fid,n);
           [DAT.data.instant_release_released_mass(i)       ,n] = waq_fgetl_number(fid,n);
      
            end
            
            if no_cellstr
            DAT.data.instant_release_name = char(DAT.data.instant_release_name);
            end
      
            DAT.data.instant_release_radius_option_FYI       = ['(0=user-defined radius;1=formula Fay-Hoult)';
                                                                'radius[m]                                  '];
            
            %% Continuous releases
            %% --------------------

           [DAT.data.no_of_continuous_releases,n] = waq_fgetl_number(fid,n);
            %% TO DO pre-allocate
            for i=1:DAT.data.no_of_continuous_releases
            end
      
            %% User releases
            %% --------------------

           [DAT.data.no_of_user_defined_releases,n]     = waq_fgetl_number(fid,n);
            %% TO DO pre-allocate
            for i=1:DAT.data.no_of_user_defined_releases
            end
      
            %% Decay rates
            %% --------------------

           [DAT.data.no_of_decay_rates              ,n] = waq_fgetl_number(fid,n);
            for i=1:DAT.data.no_of_decay_rates
           [numbers                                 ,n] = waq_fgetl_number(fid,n);
            DAT.data.decay_times(i,:)                   = numbers(1:4);
            %DAT.data.decay_dd  (i)                     = numbers(1);
            %DAT.data.decay_hh  (i)                     = numbers(2);
            %DAT.data.decay_mm  (i)                     = numbers(3);
            %DAT.data.decay_ss  (i)                     = numbers(4);
            DAT.data.decay_rates(i)                     = numbers(5);
            end
            
            %% Settling
            %% --------------------

           [DAT.data.settling_velocity_exp4c          ,n]  = waq_fgetl_number(fid,n);
           [DAT.data.settling_velocity_grid_refinement,n]  = waq_fgetl_number(fid,n);
      
           [DAT.data.no_of_settling_values            ,n]  = waq_fgetl_number(fid,n);
            for i=1:DAT.data.no_of_settling_values
           [numbers                                   ,n]  = waq_fgetl_number(fid,n);
            DAT.data.settling_times(i,:)                = numbers(1:4);
            %DAT.data.settling_dd(i,:)                  = numbers(1);
            %DAT.data.settling_hh(i,:)                  = numbers(2);
            %DAT.data.settling_mm(i,:)                  = numbers(3);
            %DAT.data.settling_ss(i,:)                  = numbers(4);         end
            DAT.data.settling_A0    (i)                 = numbers( 5);
            DAT.data.settling_A1    (i)                 = numbers( 6);
            DAT.data.settling_period(i)                 = numbers( 7);
            DAT.data.settling_phase (i)                 = numbers( 8);
            DAT.data.settling_vmin  (i)                 = numbers( 9);
            DAT.data.settling_vmax  (i)                 = numbers(10);
            end
      
         catch
         
            if nargout==1
               error(['Error reading file: ',DAT.filename])
            else
               iostat = -1;
            end      
         
         end % try
      
         fclose(fid);

      end %  if fid <0

   end % if length(tmp)==0
   
   DAT.iomethod = ['© read_inp_part.m  by G.J. de Boer (TU Delft), g.j.deboer@tudelft.nl,',mfile_version]; 
   DAT.read_at  = datestr(now);
   DAT.iostatus = iostat;
   
   %% Function output
   %% -----------------------------

   if nargout    < 2
      varargout= {DAT};
   elseif nargout==2
      varargout= {DAT, iostat};
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = waq_fgetl_string(fid,nbefore)

[rec,n]            = fgetl_no_comment_line(fid,';',0); % 0 = allow no empty lines
commas             = strfind(rec,'''');
string             = rec(commas(1) +1:commas(2)-1);

if nargin==2
   n = n + nbefore;
end

if nargout==1
   varargout = {string};
else
   varargout = {string,n};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = waq_fgetl_number(fid,nbefore)

[rec,n]            = fgetl_no_comment_line(fid,';',0); % 0 = allow no empty lines
start_of_comment   = strfind(rec,';');

if isempty(start_of_comment)
   number          = str2num(rec);
else   
   number          = str2num(rec(1:start_of_comment-1));
end   

if nargin==2
   n = n + nbefore;
end

if nargout==1
   varargout = {number};
else
   varargout = {number,n};
end