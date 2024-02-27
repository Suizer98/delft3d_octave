function nctools_test(varargin)
%NCTOOLS_TEST  Test file for nctools library
%
%      nctools_test()
%
%   Test script for testing the snctools and mexnc library.
%   It writes and reads a netcdf file with both java and mexnc interface.
%   It throws a message when nctools failed.
%
%   Example:
%   nctools_test
%
%   See also: nctools

%   --------------------------------------------------------------------
%   Copyright (C) 2009 <COMPANY>
%       
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% Created: 09 Mar 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: nctools_test.m 717 2009-07-21 11:22:34Z baart_f $
% $Date: 2009-07-21 19:22:34 +0800 (Tue, 21 Jul 2009) $
% $Author: baart_f $
% $Revision: 717 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/tests/nctools_test.m $
% $Keywords:

%% Define test value
value     = rand(100,1); % random value

%% Run test for java interface
setpref ('SNCTOOLS', 'USE_JAVA', true ); % this requires SNCTOOLS 2.4.8 or better
writetest('nctools_test_java_true',value)

%% Run test for mexnc interface
setpref ('SNCTOOLS', 'USE_JAVA', false); % this requires SNCTOOLS 2.4.8 or better
writetest('nctools_test_java_false_mexnc',value)

%% Run test for native matlab interface
%  TO DO

end


%% Write test
function writetest(ncbasename,value)

   %% define test case
   filename  = fullfile(tempdir,[ncbasename,'.nc']);
   disp(['Test result = ',filename])
   varstruct = struct('Name', 'temp', 'Nctype', 'double', 'Dimension', {{ 'temp' }});
   
   %% do test case
   
if exist(filename)==2;delete(filename);end                    % remove file
             nc_create_empty(filename);                       % create file
            nc_add_dimension(filename,'temp', length(value)); % create dimension
                   nc_addvar(filename, varstruct);            % create variable 
                   nc_varput(filename,'temp', value);
        newvalue = nc_varget(filename,'temp');
   
   %% report
   msg = sprintf('Data not succesfully written and read. SNCTOOLS java was %d', getpref('SNCTOOLS', 'USE_JAVA'));
   assert(all(value == newvalue), msg);
end