function nc_kickstarter_data_add(ncfile, dims, vars)
%NC_KICKSTARTER_ADDDATA  Adds data previously read to design netCDF file into a netCDF file
%
%   Adds data previously read by the nc_kickstarter_data_read function into
%   the netCDF file that is generated with the help of that read function.
%   It also determines whether dimension bounds variables are available and
%   fill them.
%
%   Syntax:
%   nc_kickstarter_adddata(ncfile, dims, vars)
%
%   Input:
%   ncfile    = Path to netCDF file where data should be added
%   dims      = Structure with dimension data (e.g. struct('x',x,'y',y))
%   vars      = Structure with variable data (e.g. struct('depth',d))
%
%   Output:
%   none
%
%   Example
%   nc_kickstarter_adddata(ncfile, dims, vars)
%
%   See also nc_kickstarter_data_read, nc_kickstarter

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nc_kickstarter_data_add.m 9139 2013-08-29 09:16:59Z hoonhout $
% $Date: 2013-08-29 17:16:59 +0800 (Thu, 29 Aug 2013) $
% $Author: hoonhout $
% $Revision: 9139 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/kickstarter/nc_kickstarter_data_add.m $
% $Keywords: $

%% add dims and vars

if exist(ncfile, 'file')
    
    % add dims
    f = fieldnames(dims);
    for i = 1:length(f)
        if nc_isvar(ncfile,f{i})
            nc_varput(ncfile,f{i},dims.(f{i}));
        end
        
        % add bounds
        bnd = [f{i} '_bounds'];
        if nc_isvar(ncfile,bnd) && numel(dims.(f{i})) > 1
            dims.(bnd) = nc_cf_cor2bounds(dims.(f{i}));
            nc_varput(ncfile,bnd,dims.(bnd));
        end
    end
    
    % add vars
    f = fieldnames(vars);
    for i = 1:length(f)
        if nc_isvar(ncfile,f{i})
            nc_varput(ncfile,f{i},vars.(f{i}));
        end
    end
    
    % check for missing vars
    info = nc_info(ncfile);
    idx = ~ismember({info.Dataset.Name},[fieldnames(dims);fieldnames(vars)]) & ...
                   ~cellfun(@isempty,{info.Dataset.Dimension});
    if any(idx)
        fprintf('\nMissing variables detected!\nSome variables slipped through the automated guidance of creating this netCDF file.\nPlease add the contents yourself using the following commands:\n');
        missing_vars = {info.Dataset(idx).Name};
        for i = 1:length(missing_vars)
            fprintf('    >> nc_varput(ncfile, ''%s'', %s);\n',missing_vars{i},missing_vars{i});
        end
    end

else
    error('File does not exist [%s]',ncfile);
end