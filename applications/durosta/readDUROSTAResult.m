function D = readDUROSTAResult(name, varargin)
%readDUROSTAResult: create extended DUROSTA result struct based on INP, TEK, FUN and DAF files
%
%   This function first reads the DUROSTA input file in order to
%   reconstruct the original DUROSTA input struct. Then it adds the results
%   stored in the TEK file to this struct. At this point the resulting
%   struct is similar to the struct returned by the DUROSTA_Process_Results
%   function, but without the need to supply the original input structure.
%   Furthermore, thsi function extracts more raw data from the FUN and DAF
%   files resulting in a complete DUROSTA result structure.
%
%   WARNING:    THIS FUNCTION USES THE CLOSED SOURCE qpread FUNCTION
%               AVAILABLE IN THE MCTOOLS REPOSITORY !!!
%
%   Syntax:
%   D = readDUROSTAResult(name, varargin)
%
%   Input:
%   name            = name of input file
%   varargin        = 'PropertyName' PropertyValue pairs (optional)
%                       'readINP'   = determines whether INP file is read,
%                                       if available (default: true)
%                       'readTEK'   = determines whether TEK file is read,
%                                       if available (default: true)
%                       'readDAF'   = determines whether FUN and DAF files
%                                       are read, if available (default:
%                                       true)
%
%   Output:
%   D               = struct with data from all output files
%
%   Example
%   D = readDUROSTAResult(name)
%
%   See also QPREAD DUROSTA_Run DUROSTA_Process_Results readDUROSTAInput

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
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

% Created: 25 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: readDUROSTAResult.m 5590 2011-12-08 08:36:22Z heijer $
% $Date: 2011-12-08 16:36:22 +0800 (Thu, 08 Dec 2011) $
% $Author: heijer $
% $Revision: 5590 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/durosta/readDUROSTAResult.m $

%% settings

OPT = struct( ...
    'readINP', true, ...
    'readTEK', true, ...
    'readDAF', ~isempty(which('qpread')) ...
);

OPT = setproperty(OPT, varargin{:});

%% read results

% create empty result struct
D = CreateDurostaVar();

% define file names
[pathstr, fname, ext] = fileparts(name);

inp_file = dir(fullfile(pathstr, [fname '.inp']));
tek_file = dir(fullfile(pathstr, [fname '.tek']));
fun_file = dir(fullfile(pathstr, [fname '.fun']));
daf_file = dir(fullfile(pathstr, [fname '.daf']));

% read input data
if OPT.readINP && ~isempty(inp_file) && isfield(inp_file, 'name')
    try
        D = readDUROSTAInput(fullfile(pathstr, inp_file.name));
    catch
        disp(['Warning: couldn''t read INP file [' fname '.inp]']);
    end
end

% read result data from TEK file
if OPT.readTEK && ~isempty(tek_file) && isfield(tek_file, 'name')
    try
        D = DUROSTA_Process_Results(D, fullfile(pathstr, tek_file.name));
    catch
        disp(['Warning: couldn''t read TEK file [' fname '.tek]']);
    end
end

% read result data from DAF file
if OPT.readDAF && ~isempty(fun_file) && isfield(fun_file, 'name') && ~isempty(daf_file) && isfield(daf_file, 'name')

    % open daf file
    daf = qpfopen(fullfile(pathstr, daf_file.name));
    
    if ~isempty(daf)
        
        % extend output struct
        D.Output.RAW = struct();
        
        % retrieve short names for variables and add items to struct
        % accordingly
        for j = 1:length(daf.Quant.ShortName)
            D.Output.RAW.(genvarname(daf.Quant.ShortName{j})) = [];
        end

        % retrieve variable definitions
        dataProps = qpread(daf);

        % read grid data and add to result struct
        grid = qpread(daf, dataProps(1), 'griddata');
        D.Output.RAW.grid = grid.X';

        % read time data and add to result struct
        times = qpread(daf, dataProps(1), 'times');
        D.Output.RAW.times = times;

        % walk through variables
        for j = 1:length(dataProps)
            dataProp = dataProps(j);

            % retrieve data for specific variable and time
            data = qpread(daf, dataProp, 'data', 0);

            % add data to result struct if valid
            if isfield(data, 'Val') && dataProp.Quant1 > 0
                D.Output.RAW.(genvarname(daf.Quant.ShortName{dataProp.Quant1})) = data.Val;
            end
        end
    else
        disp(['Warning: couldn''t read DAF file [' fname '.daf]']);
    end
end