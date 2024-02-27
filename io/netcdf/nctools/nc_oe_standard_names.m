function varargout = nc_oe_standard_names(varargin)
%NC_OE_STANDARD_NAMES  Routine facilitates adding variables that are part of standard-name glossaries
%
%   Routine facilitates adding variables that are part of standard-name glossaries (CF-1.4, OE-1.0, VO-1.0).
%   Works with both the Maltab and SNC netcdf libraries.
%
%   Syntax:
%      nc_oe_standard_names(varargin)
%
%   Example:
%
%      nc_oe_standard_names('outputfile', outputfile, ...
%                           'varname', {'time'}, ...
%                           'oe_standard_name', {'time'}, ...
%                           'dimension', {'time'}, ...
%                           'timezone', '+01:00')
%
%   Standard names supported:
%        (OE-1.0) 'time'
%        (OE-1.0) 'cone_resistance'
%        (OE-1.0) 'sleeve_friction'
%        (OE-1.0) 'pore_pressure'
%
%   See also nc_oe_standard_names_generate

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Van Oord
%       Mark van Koningsveld
%
%       mrv@vanoord.com
%
%       Watermanweg 64
%       POBox 8574
%       3009 AN Rotterdam
%       Netherlands
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

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: nc_oe_standard_names.m 4583 2011-05-19 08:50:31Z thijs@damsma.net $
% $Date: 2011-05-19 16:50:31 +0800 (Thu, 19 May 2011) $
% $Author: thijs@damsma.net $
% $Revision: 4583 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_oe_standard_names.m $
% $Keywords: $

%% settings

% defaults
fillValues.double =  typecast(uint8([0    0    0    0    0    0  158   71]),'DOUBLE');            
fillValues.float  =  typecast(uint8([                    0    0  240  124]),'SINGLE');
fillValues.int    =  typecast(uint8([                    1    0    0  128]),'INT32' );
fillValues.short  =  typecast(uint8([                              1  128]),'INT16' );
fillValues.byte   =  typecast(uint8(                                  129 ),'INT8'  );
fillValues.char   =  char(0);

OPT = struct(...
    'nc_library',       'snc', ...                           % snc or matlab 
    'ncid',             '', ...                              % nectdf id (only for matlab library)
    'outputfile',       {[]}, ...                            % name of the nc file. 
    'varname',          {{{'test1'};{'test2'}}}, ...         % variable name
    'oe_standard_name', {{{'test1'};{'test2'}}}, ...         % cf (climate forecasting) standard name
    'dimension',        {{{'test1'};{'test2'}}}, ...	     % dimension names					
    'dimid',            [], ...                              % dimension id's for use with matlab nc library only
    ...                                                      %   It is (a little) faster to indicate dimid's than dimension names
    'timezone',         '+01:00' , ...                       % timezone
    'deflate',          false , ...                          % only for netcdf4 files, internally deflates (compresses) variables in NC file
    'additionalAtts',   {[]}, ...                            % append these attributes to the default attributes. Must be in form
    ...                                                      %    {'name1','name2','name3';'value1','value2','value3'}
    'fillValues',       fillValues ...                       % fill values for different variable classes     
    ); 

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%% check some basic input properties
if size(OPT.oe_standard_name,1) ~= size(OPT.dimension,1)
    error('nc_oe_standard_names:argChk', 'Input arguments not of equal length')
end

switch OPT.nc_library
    case 'snc'
        if isempty(OPT.outputfile)
            error('nc_oe_standard_names:outputChk',  'No outputfilename indicated')
        end
    case 'matlab'
        if isempty(OPT.ncid)
            error('nc_oe_standard_names:outputChk',  'No ncid indicated')
        end
    otherwise
        error('nc_oe_standard_names:outputChk',  'unknown nc_library, only snc and matlab are supported')
end

%% one by one add each variable
for i = 1:size(OPT.oe_standard_name,1)
    switch OPT.oe_standard_name{i}
        case 'time'
            % add variable: time
            Variable = struct(...
               'Name',       OPT.varname{i} , ...
               'Nctype',    'double', ... 
               'Dimension', {OPT.dimension(i,:)}, ... 
               'Attribute', struct( ... 
                   'Name', ... 
                   {'standard_name', 'long_name', 'units', '_FillValue'}, ...
                   'Value', ... 
                   {'time', 'time', ['days since 1970-01-01 00:00:00' ' ' OPT.timezone], OPT.fillValues.double} ...
                   ) ...
                );
 
        case 'cone_resistance'
            % add variable: cone_resistance
            Variable = struct(...
               'Name',       OPT.varname{i} , ...
               'Nctype',    'double', ... 
               'Dimension', {OPT.dimension(i,:)}, ... 
               'Attribute', struct( ... 
                   'Name', ... 
                   {'standard_name', 'long_name', 'units', '_FillValue'}, ...
                   'Value', ... 
                   {'cone_resistance', 'cone resistance', 'MPa', OPT.fillValues.double} ...
                   ) ...
                );
 
        case 'sleeve_friction'
            % add variable: sleeve_friction
            Variable = struct(...
               'Name',       OPT.varname{i} , ...
               'Nctype',    'double', ... 
               'Dimension', {OPT.dimension(i,:)}, ... 
               'Attribute', struct( ... 
                   'Name', ... 
                   {'standard_name', 'long_name', 'units', '_FillValue'}, ...
                   'Value', ... 
                   {'sleeve_friction', 'sleeve friction', 'kPa', OPT.fillValues.double} ...
                   ) ...
                );
 
        case 'pore_pressure'
            % add variable: pore_pressure
            Variable = struct(...
               'Name',       OPT.varname{i} , ...
               'Nctype',    'double', ... 
               'Dimension', {OPT.dimension(i,:)}, ... 
               'Attribute', struct( ... 
                   'Name', ... 
                   {'standard_name', 'long_name', 'units', '_FillValue'}, ...
                   'Value', ... 
                   {'pore_pressure', 'pore pressure', 'kPa', OPT.fillValues.double} ...
                   ) ...
                );
 
    end

    % append additional attributes
    for jj = 1:size(OPT.additionalAtts,2)
        Variable.Attribute(end+1).Name  = OPT.additionalAtts{1,jj};
        Variable.Attribute(end+0).Value = OPT.additionalAtts{2,jj};
    end
    
    % add variable to output file
    switch OPT.nc_library
        case 'snc'
            nc_addvar(OPT.outputfile, Variable);
            varargout = {[]};
        case 'matlab'
            varid = netcdf_addvar(OPT.ncid, Variable );
            if OPT.deflate
                netcdf.defVarDeflate(OPT.ncid,varid,false,true,2);
            end
            varargout = {varid};
    end
end
