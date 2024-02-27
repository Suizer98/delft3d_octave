function varargout = get_d3d_output_times(varargin);
%GET_D3D_OUTPUT_TIMES
% 
% The function get_d3d_output_times gets the output times from any Delft3D
% trim-*.dat or trih-*.dat file (and stores it in the specified output argument) as datenums
%
% The functions' results are the same as qpread(file_ID,'dataset','times')
% or (a part of) vs_time(file_ID), though it can be up to 50(!) times faster
%
% The function can be called in 3 different ways:
% 
% (1) Call get_d3d_output_times and select a valid file from the pop-up menu
% (2) Add the file-location (as a text-string) input argument in the function
% (3) Use a file structure handle, generated from e.g. vs_use or qpfopen
%     Usefull when multiple operations are executed in your script
%
% (*) A second output argument can be added to get the files' timestep (in seconds)
%
%
% Examples:
%
% (1)
% Call 'get_d3d_output_times' and select any trim-*.dat
% or trih-*.dat file from the pop-up menu.
%
% (2)
% trim_times = get_d3d_output_times('d:\Delft3D\Any_d3d_output_folder\trim-example.dat');
%
% (3)
% file_handle = vs_use('d:\Delft3D\D3d_output_folder\trih-example.dat')
% trih_times = get_d3d_output_times(file_handle);
% or
% trih_times = get_d3d_output_times(vs_use('d:\Delft3D\D3d_output_folder\trih-example.dat'));
%
% (*)
% [trih_times timestep] = get_d3d_output_times(...);
%
% Use datestr(get_d3d_output_times(...)) to quickly get to regular dates and times
%
% See also: vs_time qpread

warning('WarnTests:convertTest','vs_time has expanded functionality, and can handle more NEFIS types. \nOnly use this script when interested in considerable speed increase with less functionality/output.')

%   --------------------------------------------------------------------
%       Freek Scheel 2013
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
%
%       Please contact me if errors occur.
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


if isempty(varargin);
    file_name = [];
    [file_name file_dir] = uigetfile('*.dat','Select a Delft3D trim or trih file');
    if file_name==0
        error('No trim-*.dat or trih-*.dat file selected');
    end
    file_ID = vs_use([file_dir file_name],'quiet');
elseif isstruct(varargin{1,1})==1;
    file_ID = varargin{1,1};
elseif isstr(varargin{1,1})==1;
    file_ID = vs_use(varargin{1,1},'quiet');
end

if isempty(file_ID)==1
    error('Please specify a trim-*.dat or trih-*.dat file');
end

file_type = file_ID.DatExt((find(file_ID.DatExt==filesep,1,'last')+1):(find(file_ID.DatExt==filesep,1,'last')+4));

if strcmp(file_type,'trim')==1;
    groupnames = vs_disp(file_ID);
    for ii=1:size(groupnames,2);
        if strcmp(groupnames{1,ii},'map-info-series');
            group_ind_info = ii;
        elseif strcmp(groupnames{1,ii},'map-const');
            group_ind_const = ii;
        end
    end
    group_info    = vs_disp(file_ID,groupnames{1,group_ind_info},[]);
    timestep_secs = (vs_get(file_ID,groupnames{1,group_ind_const},{1},'TUNIT','quiet') * vs_get(file_ID,groupnames{1,group_ind_const},{1},'DT','quiet'));
    ref_time_datenum  = datenum(num2str(vs_get(file_ID,groupnames{1,group_ind_const},{1},'ITDATE',{1},'quiet')),'yyyymmdd');
    sim_start_datenum = ref_time_datenum+(((vs_get(file_ID,groupnames{1,group_ind_info},{1},'ITMAPC',{1},'quiet'))/(60*24))*(timestep_secs/60));
    sim_end_datenum   = ref_time_datenum+(((vs_get(file_ID,groupnames{1,group_ind_info},{group_info.SizeDim},'ITMAPC',{1},'quiet'))/(60*24))*(timestep_secs/60));
    if group_info.SizeDim > 1
        varargout{1} = [sim_start_datenum:(sim_end_datenum-sim_start_datenum)/(group_info.SizeDim-1):sim_end_datenum]';
    elseif group_info.SizeDim == 1
        varargout{1} = [sim_start_datenum];
    end
elseif strcmp(file_type,'trih')==1;
    groupnames = vs_disp(file_ID);
    for ii=1:size(groupnames,2);
        if strcmp(groupnames{1,ii},'his-info-series');
            group_ind_info = ii;
        elseif strcmp(groupnames{1,ii},'his-const');
            group_ind_const = ii;
        end
    end
    group_info    = vs_disp(file_ID,groupnames{1,group_ind_info},[]);
    timestep_secs = (vs_get(file_ID,groupnames{1,group_ind_const},{1},'TUNIT','quiet') * vs_get(file_ID,groupnames{1,group_ind_const},{1},'DT','quiet'));
    ref_time_datenum  = datenum(num2str(vs_get(file_ID,groupnames{1,group_ind_const},{1},'ITDATE',{1},'quiet')),'yyyymmdd');
    sim_start_datenum = ref_time_datenum+(((vs_get(file_ID,groupnames{1,group_ind_info},{1},'ITHISC',{1},'quiet'))/(60*24))*(timestep_secs/60));
    sim_end_datenum   = ref_time_datenum+(((vs_get(file_ID,groupnames{1,group_ind_info},{group_info.SizeDim},'ITHISC',{1},'quiet'))/(60*24))*(timestep_secs/60));
    if group_info.SizeDim > 1
        varargout{1} = [sim_start_datenum:(sim_end_datenum-sim_start_datenum)/(group_info.SizeDim-1):sim_end_datenum]';
    elseif group_info.SizeDim == 1
        varargout{1} = [sim_start_datenum];
    end
        
else
    error('This filetype is not supported, please consider a trim-*.dat or trih-*.dat file');
end

if nargout == 2;
    varargout{2}=(((sim_end_datenum-sim_start_datenum)/(group_info.SizeDim-1))*24*60*60);
elseif nargout>2;
    error('Too many output arguments specified, use 1 or 2 instead, see the function help');
else
    ...
end



