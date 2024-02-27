function varargout = delft3d_waq_io_inp(varargin)
%DELFT3D_WAQ_IO_INP   Reads Delft3D-PWAQ *.inp file into struct (BETA VERSION)
%
% DAT = delft3d_waq_io_inp        % launches file load GUI
% DAT = delft3d_waq_io_inp(fname)
%
% Reads up to halfway Block #5
%
% Beta version, G.J. de Boer, 2005-2007
%
% See also: FLOW2WAQ3D, FLOW2WAQ3D_COUPLING, WAQ2FLOW2D, WAQ2FLOWD3D,
%           DELFT3D_PART_IO_INP

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
%   --------------------------------------------------------------------

% $Id: delft3d_waq_io_inp.m 10245 2014-02-19 12:37:44Z bartgrasmeijer.x $
% $Date: 2014-02-19 20:37:44 +0800 (Wed, 19 Feb 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 10245 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_io_inp.m $

% DOne : handle INCLUDE statement in waq_fgetl_* by opening new file, replacing fid, and putting higher level fid on stack.
% TO DO: count number of lines n while doing fscanf

mfile_version = '1.0, Oct. 2006, beta';

%% cells are difficult to store as non-matlab files (HDF etc)
%% so we try to avoid them
no_cellstr    = 1;

global fid

%% 0 - command line file name or
%      Launch file open GUI

%% No file name specified if even number of arguments
%  i.e. 2 or 4 input parameters

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
    
elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
    DAT.filename   = varargin{1};
    iostat         = 1;
end

%% I - Check if file exists (actually redundant after file GUI)

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
    
    fid              = delft3d_waq_io_inp_fopen(DAT.filename,'r');
    
    %% II - Check if can be opened (locked etc.)
    
    if fid < 0
        
        if nargout==1
            error(['Error opening file: ',DAT.filename])
        else
            iostat = -1;
        end
        
    elseif fid > 2
        
        %% II - Check if can be read (format etc.)
        
        %         try
        
        %% Read meta info about file structure
        
        n = 1; % number of lines that have been read
        rec                                = fgetl         (fid);
        [number,rec]                        = strtok        (rec);
        DAT.width_of_input                 = str2num       (number);
        [number,rec]                        = strtok        (rec);
        DAT.width_of_output                = str2num       (number);
        comment                            = strtoknoquotes(rec);
        DAT.commentcharacter               = comment;
        
        % +------------------------------------------+
        % |                                          |
        % | first block: identification              |
        % |                                          |
        % +------------------------------------------+
        
        %% Read 4 identification lines
        
        [DAT.data.run_identification{1},n]      = waq_fgetl_string(fid,n,comment);
        [DAT.data.run_identification{2},n]      = waq_fgetl_string(fid,n,comment);
        [DAT.data.run_identification{3},n]      = waq_fgetl_string(fid,n,comment);
        [DAT.data.run_identification{4},n]      = waq_fgetl_string(fid,n,comment);
        
        if no_cellstr
            DAT.data.run_identification            = char(DAT.data.run_identification);
        end
        
        %% Read substances
        
        [numbers,n]                             = waq_fgetl_number(fid,n,comment);
        DAT.data.number_of_active_substances   = numbers(1);
        DAT.data.number_of_inactive_substances = numbers(2);
        DAT.data.number_substances             = DAT.data.number_of_active_substances + ...
            DAT.data.number_of_inactive_substances;
        
        DAT.data.substances.name           = [];
        for isub=1:DAT.data.number_substances
            [rec,n]                         = waq_fgetl(fid,n,comment);
            [number,rec]                    = strtok(rec);
            DAT.data.substances.index(isub) = str2num(number);
            DAT.data.substances.name        = strvcat(DAT.data.substances.name,...
                strtoknoquotes(rec));
        end
        
        % +------------------------------------------+
        % |                                          |
        % | second block of model input (timers)     |
        % |                                          |
        % +------------------------------------------+
        
        %% Timers
        
        [rec,n]                         = waq_fgetl(fid,n,comment);
        [number,rec]                    = strtok(rec);
        DAT.data.system_clock_in_sec   = str2num(number);
        [DAT.data.aux_in_days,rec]      = strtok(rec);
        
        [rec,n]                         = waq_fgetl(fid,n,comment);
        [DAT.data.integration_option,rec] = strtok(rec);
        
        if strtok(rec,'ANTICREEP')
            DAT.data.anticreep = true;
        else
            DAT.data.anticreep = false;
        end
        %[DAT.data.integration_option,n] = waq_fgetl_number(fid,n,comment);
        
        %% Detailed balance options
        
        [string,n]                      = waq_fgetl(fid,n,comment);
        string                         = strtrim(string);
        
        DAT.data.balance_options       = [];
        
        while strcmp(string(1:3),'BAL')
            
            DAT.data.balance_options       = [DAT.data.balance_options,string];
            [string,n]                     = waq_fgetl(fid,n,comment);
            string                        = strtrim(string);
            
        end
        
        %% Times
        % 1998/01/01-00:00:00      ; start time
        % 1999/01/01-00:00:00      ; stop time
        %              OR
        % 0000000                  ; start time
        % 365000000                ; stop time
        
        slashes = strfind(string,'/');
        if isempty(slashes)
            DAT.data.start_tss             = str2num(string(end-1:end-0));
            DAT.data.start_tmm             = str2num(string(end-3:end-1));
            DAT.data.start_thh             = str2num(string(end-5:end-3));
            DAT.data.start_tddd            = str2num(string(1    :end-6));
            DAT.data.start_time            = string;
        else
            DAT.data.start_time            = time2datenum(strtrim(string));
        end
        
        [string,n]                      = waq_fgetl(fid,n,comment);
        string                         = strtrim(string);
        
        slashes = strfind(string,'/');
        if isempty(slashes)
            DAT.data.stop_ss               = str2num(string(end-1:end-0));
            DAT.data.stop_mm               = str2num(string(end-3:end-1));
            DAT.data.stop_hh               = str2num(string(end-5:end-3));
            DAT.data.stop_ddd              = str2num(string(1    :end-6));
            DAT.data.stop_time             = string;
        else
            DAT.data.stop_time             = time2datenum(strtrim(string));
        end
        
        [DAT.data.constant_timestep,n]  = waq_fgetl_number(fid,n,comment);
        [DAT.data.time_step,n]          = waq_fgetl_number(fid,n,comment);
        
        %% Monitoring
        
        [DAT.data.monitoring_points_areas_usage,n]     = waq_fgetl_number(fid,n,comment);
        [DAT.data.number_of_monitoring_points_areas,n] = waq_fgetl_number(fid,n,comment);
        
        % line count goes awry here
        [string,n] = waq_fgetl(fid,n,comment);
        
        if strcmpi(strtok(string),'INCLUDE')
            
            [dummy,value]               = strtok(string);
            DAT.data.monitoring.INCLUDE = strtrim(value);
            
            [string,n] = waq_fgetl(fid,n,comment);
            
        else
            
            DAT.data.monitoring.name = {};
            
            for im = 1:DAT.data.number_of_monitoring_points_areas
                
                quotes = strfind(string,'''');
                name   = string(quotes(1)+1:1:quotes(end)-1);
                string = string(quotes(end)+1:end);
                
                DAT.data.monitoring.name{im} = name;
                
                % case where number_of_segments is on next line instead of directly after name
                [number_of_segments,string]                 = strtok(string);
                if isempty(number_of_segments);
                    [number_of_segments,n] = waq_fgetl_number(fid,n,comment);
                else
                    number_of_segments = str2num(number_of_segments);
                end
                DAT.data.monitoring.number_of_segments(im) = number_of_segments;
                
                if isempty(string)
                    for i=1:DAT.data.monitoring.number_of_segments(im)
                        vals(i) = waq_fgetl_number(fid,n,comment);
                    end
                else
                    nrofseg = sscanf(string,'%d',DAT.data.monitoring.number_of_segments(im));
                    if ~isnumeric(nrofseg)
                        vals = str2num(nrofseg);
                    else
                        vals = nrofseg;
                    end
                end
                
                DAT.data.monitoring.indices{im} = vals;
                
                while length(DAT.data.monitoring.indices{im}) < DAT.data.monitoring.number_of_segments(im)
                    
                    number_of_segments_left = DAT.data.monitoring.number_of_segments(im) - ...
                        length(DAT.data.monitoring.indices{im});
                    
                    % TO DO: count number of lines while doing fscanf
                    indices = fscanf(fid(end),'%d',number_of_segments_left);
                    
                    DAT.data.monitoring.indices{im} = [DAT.data.monitoring.indices{im} indices];
                    
                end
                
                [string,n] = waq_fgetl(fid,n,comment);
                
            end
            
        end
        
        DAT.data.monitoring_transects_usage = str2num(strtok(string));
        %[DAT.data.monitoring_transects_usage,n] = waq_fgetl_number(fid,n,comment);
        
        %% Output Timers
        
        % 1998/01/01-00:00:00       1999/01/01-00:00:00       1000000      ; monitoring
        % 1998/12/01-00:00:00       2000/01/01-00:00:00       0010000      ; map, dump
        % 1998/01/01-00:00:00       1999/01/01-00:00:00       0010000      ; history
        % OR
        %  0000000       365000000       1000000      ; monitoring
        %  334000000       365000000       0010000      ; map, dump
        %  0000000       365000000       0010000      ; history
        
        %% Monitoring
        
        [string,n]                          = waq_fgetl(fid,n,comment);
        string                             = strtrim(string);
        
        [DAT.data.monitoring_start,string] = strtok(string);
        [DAT.data.monitoring_stop ,string] = strtok(string);
        [DAT.data.monitoring_dt   ,string] = strtok(string);
        
        slashes = strfind(DAT.data.monitoring_start,'/');
        if isempty(slashes)
        else
            DAT.data.start = time2datenum(strtrim(DAT.data.monitoring_start));
            DAT.data.stop  = time2datenum(strtrim(DAT.data.monitoring_stop ));
        end
        
        %% Map
        
        [string,n]                          = waq_fgetl(fid,n,comment);
        string                             = strtrim(string);
        [DAT.data.map_start,string] = strtok(string);
        [DAT.data.map_stop ,string] = strtok(string);
        [DAT.data.map_dt   ,string] = strtok(string);
        
        slashes = strfind(DAT.data.map_start,'/');
        if isempty(slashes)
        else
            DAT.data.start = time2datenum(strtrim(DAT.data.map_start));
            DAT.data.stop  = time2datenum(strtrim(DAT.data.map_stop ));
        end
        
        %% History
        
        [string,n]                          = waq_fgetl(fid,n,comment);
        string                             = strtrim(string);
        [DAT.data.history_start,string] = strtok(string);
        [DAT.data.history_stop ,string] = strtok(string);
        [DAT.data.history_dt   ,string] = strtok(string);
        
        slashes = strfind(DAT.data.history_start,'/');
        if isempty(slashes)
        else
            DAT.data.start = time2datenum(strtrim(DAT.data.history_start));
            DAT.data.stop  = time2datenum(strtrim(DAT.data.history_stop ));
        end
        
        %  +------------------------------------------+
        %  |                                          |
        %  | third block of model input (grid layout) |
        %  |                                          |
        %  +------------------------------------------+
        
        %% Grid
        
        [DAT.data.number_of_segments,n] = waq_fgetl_number(fid,n,comment);
        
        [string,n]                          = waq_fgetl(fid,n,comment);
        string                             = strtrim(string);
        
        if strcmpi(strtok(string),'MULTIGRID')
            DAT.data.grid_layout_usage = 'MULTIGRID';
            [string,n]                          = waq_fgetl(fid,n,comment);
            string                             = strtrim(string);
        elseif strcmpi(strtok(string),'INCLUDE')
            DAT.data.grid_layout_usage = 'INCLUDE';
            [string,n]                          = waq_fgetl(fid,n,comment);
            string                             = strtrim(string);
        else
            DAT.data.grid_layout_usage = str2num(string);
        end
        
        %DAT.data.grid_layout_usage      = str2num(strtok(string));
        %[DAT.data.grid_layout_usage ,n] = waq_fgetl_number(fid,n,comment);
        
        %% Features
        
        if strcmpi(DAT.data.grid_layout_usage,'MULTIGRID')|| DAT.data.grid_layout_usage==2
            
            [DAT.data.features(1)    ,n] = waq_fgetl_number(fid,n,comment);% one time-independent contribution
            [DAT.data.features(2)    ,n] = waq_fgetl_number(fid,n,comment);% number of items
            [DAT.data.features(3)    ,n] = waq_fgetl_number(fid,n,comment);% only feature 2 is specified
            [DAT.data.features(4)    ,n] = waq_fgetl_number(fid,n,comment);% input in this file
            [DAT.data.features(5)    ,n] = waq_fgetl_number(fid,n,comment);% input option without defaults
            [DAT.data.features(6)    ,n] = waq_fgetl_number(fid,n,comment);% top segments
            [DAT.data.features(7)    ,n] = waq_fgetl_number(fid,n,comment);% middle segments
            [DAT.data.features(8)    ,n] = waq_fgetl_number(fid,n,comment);% bottom segments
            [DAT.data.features(9)    ,n] = waq_fgetl_number(fid,n,comment);% no time-dependent contributions
            
        else
            
            [DAT.data.features(1)    ,n] = waq_fgetl_number(fid,n,comment);% one time-independent contribution
            [DAT.data.features(2)    ,n] = waq_fgetl_number(fid,n,comment);% number of items
            [DAT.data.features(3)    ,n] = waq_fgetl_number(fid,n,comment);% only feature 2 is specified
            [DAT.data.features(4)    ,n] = waq_fgetl_number(fid,n,comment);% input in this file
            [DAT.data.features(5)    ,n] = waq_fgetl_number(fid,n,comment);% input option without defaults
            [DAT.data.features(6)    ,n] = waq_fgetl_number(fid,n,comment);% integrated segments
            [DAT.data.features(7)    ,n] = waq_fgetl_number(fid,n,comment);% no time-dependent contributions
        end
        
        %-%        [string,n]                   = waq_fgetl(fid,n,comment);
        %-%         string                      = strtrim(string);
        %-%
        %-%         if strcmpi(strtok(string),'INCLUDE')
        %-%
        %-%           [dummy,value]               = strtok(string);
        %-%           DAT.data.attributes.INCLUDE = strtrim(value);
        %-%
        %-%        % attributes_file looks like:
        %-%        %     1                ; Input option without Defaults
        %-%        % 18878*1
        %-%        % 94390*2
        %-%        % 18878*3
        %-%
        %-%         DAT.data.features(5)        = NaN;
        %-%         DAT.data.features(6)        = NaN;
        %-%         DAT.data.features(7)        = NaN;
        %-%         DAT.data.features(8)        = NaN;
        %-%
        %-%         else
        %-%        [DAT.data.features(9)    ,n] = waq_fgetl_number(fid,n,comment);%
        %-%        [DAT.data.features(9)    ,n] = waq_fgetl_number(fid,n,comment);%
        %-%        [DAT.data.features(9)    ,n] = waq_fgetl_number(fid,n,comment);%
        %-%        [DAT.data.features(9)    ,n] = waq_fgetl_number(fid,n,comment);%
        %-%         end
        %-%
        %-%        [DAT.data.features(9)    ,n] = waq_fgetl_number(fid,n,comment);% time-dependent contributions
        
        %% Volumes
        
        [DAT.data.first_volume_option,n] = waq_fgetl_number(fid,n,comment);
        [DAT.data.volumes_file       ,n] = waq_fgetl_string(fid,n,comment);
        
        %  +-----------------------------------------+
        %  |                                         |
        %  | fourth block of model input (transport) |
        %  |                                         |
        %  +-----------------------------------------+
        
        [DAT.data.exchanges_in_directions_123(1)     ,n] = waq_fgetl_number(fid,n,comment);% exchanges in direction 1
        [DAT.data.exchanges_in_directions_123(2)     ,n] = waq_fgetl_number(fid,n,comment);% exchanges in direction 2
        [DAT.data.exchanges_in_directions_123(3)     ,n] = waq_fgetl_number(fid,n,comment);% exchanges in direction 3
        
        [DAT.data.velocity_arrays                    ,n] = waq_fgetl_number(fid,n,comment);% dispersion arrays
        [DAT.data.dispersion_arrays                  ,n] = waq_fgetl_number(fid,n,comment);% velocity arrays
        
        [DAT.data.exchange_pointer_input             ,n] = waq_fgetl_number(fid,n,comment);% first form is used for input
        [DAT.data.exchange_pointer_option            ,n] = waq_fgetl_number(fid,n,comment);% exchange pointer option
        [DAT.data.pointers_file                      ,n] = waq_fgetl_string(fid,n,comment);% pointers file
        
        [DAT.data.first_dispersion_option_nr         ,n] = waq_fgetl_number(fid,n,comment);% first dispersion option nr
        [DAT.data.scale_factors_in_directions_123    ,n] = waq_fgetl_number(fid,n,comment);% scale factors in 3 directions
        [DAT.data.dispersion_in_1st_and_2nd_direction,n] = waq_fgetl_number(fid,n,comment);% dispersion in 1st and 2nd direction
        [DAT.data.dispersion_in_3rd_direction        ,n] = waq_fgetl_number(fid,n,comment);% dispersion in 3rd direction
        
        [DAT.data.area_option                        ,n] = waq_fgetl_number(fid,n,comment);% first area option
        [DAT.data.area_file                          ,n] = waq_fgetl_string(fid,n,comment);% area file
        
        [DAT.data.flow_option                        ,n] = waq_fgetl_number(fid,n,comment);% first flow option
        [DAT.data.flow_file                          ,n] = waq_fgetl_string(fid,n,comment);% flow file
        
        [DAT.data.length_vary                        ,n] = waq_fgetl_number(fid,n,comment);% length vary
        [DAT.data.length_option                      ,n] = waq_fgetl_number(fid,n,comment);% length option
        [DAT.data.length_file                        ,n] = waq_fgetl_string(fid,n,comment);% length file
        
        % +------------------------------------------+
        % |                                          |
        % | fifth block of model input (boundary condition)
        % |                                          |
        % +------------------------------------------+
        
        [string,n] = waq_fgetl_string(fid,n,comment);% length file
        string = ['''' string ''''];
        boundaries = {};
        while ~strcmpi(string(1),';')
            boundaries{end+1} = string;
            string = strtrim(fgetl(fid));n=n+1;
        end
        boundaries = str2line(boundaries,'s',' ');
        
        ind  = strfind(boundaries,'''');
        nbnd = length(ind)./2;
        ind = reshape(ind,[2 nbnd]);
        
        for ibnd=1:nbnd
            DAT.data.boundary{ibnd} = boundaries(ind(1,ibnd)+1:ind(2,ibnd)-1);
        end
        
        [DAT.data.Th_lags_number               ,n] = waq_fgetl_number(fid,n,comment);% length option
        [DAT.data.Th_lags_value                ,n] = waq_fgetl_number(fid,n,comment);% length option
        [DAT.data.Th_lags_Number_of_overridings,n] = waq_fgetl_number(fid,n,comment);% length option
        
        for i=1:DAT.data.Th_lags_Number_of_overridings
            [vals,n] = waq_fgetl_number(fid,n,comment);% length option
            
            DAT.data.Th_lags.boundary(i) = vals(1);
            DAT.data.Th_lags.value   (i) = vals(2);
            
        end
        
        %      % +------------------------------------------+
        %      % |                                          |
        %      % | sixth block of model input (waste loads) |
        %      % |                                          |
        %      % +------------------------------------------+
        %
        %
        %           [DAT.data.waste_loads_continuous_releases    ,n] = waq_fgetl_number(fid,n,comment);% no waste loads/continuous releases
        %
        %      % +------------------------------------------+
        %      % |                                          |
        %      % | seventh block of model input (process parameters)
        %      % |                                          |
        %      % +------------------------------------------+
        %
        %            string                          = strtrim(waq_fgetl(fid,n,comment))
        %
        %            iconstants=0;
        %            if strcmpi(strtok(string),'CONSTANTS')
        %
        %            string                        = strtrim(waq_fgetl(fid,n,comment));
        %            while ~strcmpi(strtok(string),'DATA')
        %            iconstants=iconstants+1;
        %            DAT.data.process_parameters_contants{iconstants} = string;
        %            string                                           = strtrim(waq_fgetl(fid,n,comment))
        %            end
        %
        %            DAT.data.process_parameters_data                 = repmat(NaN,[1 iconstants])
        %            iconstants=0;
        %            string                          = strtrim(waq_fgetl(fid,n,comment))
        %            while ~strcmpi(strtok(string),'PARAMETERS')
        %            iconstants=iconstants+1;
        %             str2num(string)
        %            DAT.data.process_parameters_data(iconstants)     = str2num(string);
        %            string                                           = strtrim(waq_fgetl(fid,n,comment))
        %            end
        %
        %            end
        
        DAT.number_of_lines_read       = n;
        
        disp('waq_io_inp IN PROGRESS, read WAQ *.inp file up to #4 BC.')
        
        %         catch
        %
        %            if nargout==1
        %               error(['Error reading file: ',DAT.filename])
        %            else
        %               iostat = -1;
        %            end
        %
        %         end % try
        
        fclose(fid);
        
    end %  if fid <0
    
end % if length(tmp)==0

DAT.read.with     = '$Id: delft3d_waq_io_inp.$'; % SVN keyword, will insert name of this function
DAT.read.at       = datestr(now);
DAT.read.iostatus = iostat;

%% Function output

if nargout    < 2
    varargout= {DAT};
elseif nargout==2
    varargout= {DAT, iostat};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function varargout = waq_fgetl(varargin)
        
        %global fid
        
        fid     = varargin{1};
        nbefore = varargin{2};
        n       = repmat(0,[1 length(fid)]);
        dn       = repmat(0,[1 length(fid)]);
        
        if nargin>2
            commentcharacter = [varargin{3},'#'];
        else
            commentcharacter = DAT.commentcharacter; %';#'; % DAT is 'global' due because waq_fgetl* are nested functions
        end
        
        if nargin>3
            basedir = varargin{4};
        else
            basedir = filepathstr(DAT.filename);
        end
        
        [rec,dn] = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
        n = n + dn;dn=0;
        
        if strcmpi(strtok(rec),'INCLUDE')
            indices = strfind(rec,'''');
            fname   = rec(indices(1)+1:indices(2)-1);
            fid(length(fid)+1) = delft3d_waq_io_inp_fopen([basedir,filesep,fname],'r');
            [rec,dn(length(fid))] = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
            n = n + dn;dn = 0;
            disp(['INCLUDE statement on line ',num2str(nbefore+n(1))])
        elseif isempty(rec)
            fid = fid(1:end-1);
            [rec,n]          = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
            
        end
        
        %% remove part at end of line after comment character
        start_of_comment   = Inf;
        for ic = 1:length(commentcharacter)
            index = strfind(rec,commentcharacter(ic));
            if ~isempty(index)
                start_of_comment   = min(index,start_of_comment);
            end
        end
        
        if ~isempty(start_of_comment) & ~isinf(start_of_comment)
            rec = rec(1:start_of_comment-1);
        end
        
        if nargin>1
            n = n + nbefore;
        end
        
        if nargout==1
            varargout = {rec};
        else
            varargout = {rec,n(length(fid))};
        end
        
    end % waq_fgetl

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function varargout = waq_fgetl_string(varargin)
        
        %global fid
        
        fid     = varargin{1};
        nbefore = varargin{2};
        n       = repmat(0,[1 length(fid)]);
        
        if nargin>2
            commentcharacter = [varargin{3},'#'];
        else
            commentcharacter = DAT.commentcharacter; %';#'; % DAT is 'global' due because waq_fgetl* are nested functions
        end
        
        if nargin>3
            basedir = varargin{4};
        else
            basedir = filepathstr(DAT.filename);
        end
        
        [rec,dn] = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
        n = n + dn;dn=0;
        
        if strcmpi(strtok(rec),'INCLUDE')
            indices = strfind(rec,'''');
            fname   = rec(indices(1)+1:indices(2)-1);
            fid(length(fid)+1) = delft3d_waq_io_inp_fopen([basedir,filesep,fname],'r');
            [rec,dn]          = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
            disp(['INCLUDE statement on line ',num2str(nbefore+n(1))])
        elseif isempty(rec)
            fid = fid(1:end-1);
            [rec,dn]          = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
        end
        
        commas             = strfind(rec,'''');
        if ~isempty(commas)
            string             = rec(commas(1) +1:commas(2)-1);
        else
            string = [];
        end
        
        if nargin>1
            n = n + nbefore;
        end
        
        if nargout==1
            varargout = {string};
        else
            varargout = {string,n};
        end
        
    end % waq_fgetl_string

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function varargout = waq_fgetl_number(varargin)
        
        %global fid
        
        fid     = varargin{1};
        nbefore = varargin{2};
        n       = repmat(0,[1 length(fid)]);
        
        if nargin>2
            commentcharacter = [varargin{3},'#'];
        else
            commentcharacter = DAT.commentcharacter; %';#'; % DAT is 'global' due because waq_fgetl* are nested functions
        end
        
        if nargin>3
            basedir = varargin{4};
        else
            basedir = filepathstr(DAT.filename);
        end
        
        [rec,dn] = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
        n = n + dn;dn=0;
        
        if strcmpi(strtok(rec),'INCLUDE')
            indices = strfind(rec,'''');
            fname   = rec(indices(1)+1:indices(2)-1);
            fid(length(fid)+1) = delft3d_waq_io_inp_fopen([basedir,filesep,fname],'r');
            [rec,dn]          = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
            disp(['INCLUDE statement on line ',num2str(nbefore+n(1))])
        elseif isempty(rec)
            fid = fid(1:end-1);
            [rec,dn]          = fgetl_no_comment_line(fid(end),commentcharacter,0); % 0 = allow no empty lines
        end
        
        start_of_comment   = Inf;
        for ic = 1:length(commentcharacter)
            index = strfind(rec,commentcharacter(ic));
            if ~isempty(index)
                start_of_comment   = min(index,start_of_comment);
            end
        end
        
        if isempty(start_of_comment) | ...
                isinf(start_of_comment)
            number          = str2num(rec);
        else
            number          = str2num(rec(1:start_of_comment-1));
        end
        
        if nargin>1
            n = n + nbefore;
        end
        
        if nargout==1
            varargout = {number};
        else
            varargout = {number,n};
        end
        
    end % waq_fgetl_number

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function varargout = strtoknoquotes(varargin)
        
        [tok,restofstr] = strtok(varargin{:});
        
        quotes = find(tok,'''');
        tok    = tok(quotes(unique([1+1:end-1])));
        
        if nargout==1
            varargout = {tok};
        elseif nargout==2
            varargout = {tok,restofstr};
        end
        
    end % strtoknoquotes(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function fid = delft3d_waq_io_inp_fopen(varargin)
        
        fid = fopen(varargin{:});
        if fid < 0
            error(['Error opening file: ',varargin{1}])
        end
        
    end % strtoknoquotes(varargin)

end % delft3d_waq_io_inp