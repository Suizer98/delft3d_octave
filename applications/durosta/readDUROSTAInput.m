function D = readDUROSTAInput(fname, varargin)
%readDUROSTAInput: convert DUROSTA input file back to struct created by DUROSTA_Inp_File function
%
%   This function does the opposite of the DUROSTA_Inp_File function and
%   creates a DUROSTA data structure and fills it with values from a
%   DUROSTA input file. The resulting data structure can be used as input
%   for the DUROSTA_Inp_File function to recreate the original input file.
%
%   Syntax:
%   D = readDUROSTAInput(fname, varargin)
%
%   Input:
%   fname           = name of input file
%   varargin        = 'PropertyName' PropertyValue pairs (optional)
%                       [for future use]
%
%   Output:
%   D               = struct with data from input file
%
%   Example
%   D = readDUROSTAInput(fname)
%
%   See also DUROSTA_Inp_File DUROSTA_Run DUROSTA_Process_Results

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

% $Id: readDUROSTAInput.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/durosta/readDUROSTAInput.m $

%% settings

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% read input data

% create empty result struct
D = CreateDurostaVar();

% check whether file exists
file = dir(fname);
if ~isempty(file) && isfield(file, 'name')
    
    [pathstr, name, ext] = fileparts(fname);
    
    % define counters
    lineID = 1;
    blockID = 1;
    blockLength = -1;
    blockLineID = 1;
    
    % open file and walk through lines
    fid = fopen(fullfile(pathstr, file.name));
    while true
        
        % get line
        line = fgetl(fid);
        if ~ischar(line); break; end;
        
        % split line at spaces
        [matchstr splitstr] = regexp(line, '\s+', 'match', 'split');
        
        % store data in line based on block number
        switch blockID
            case 1
                % header
            case 2
                % parameters
                switch lower(splitstr{1})
                    case 'dx'
                        D.settings.Input.dx = str2double(splitstr{2});
                    otherwise
                        D.settings.Params.(splitstr{1}) = str2double(splitstr{2});
                end
            case 3
                % grid
                D.Input.Grid(end + 1, :) = [str2double(splitstr{1}) str2double(splitstr{2})];
            case 4
                % time steps
                if blockLineID == 1
                    D.Input.Tstart = str2double(splitstr{1});
                elseif blockLineID == blockLength + 1
                    D.Input.Tstop = str2double(splitstr{1});
                else
                    D.settings.Output.OutputSteps(end + 1) = str2double(splitstr{1});
                end
            case 5
                % output information
                if blockLineID == 1
                    D.settings.Output.VertProfRes = str2double(splitstr{2});
                else
                    D.settings.Output.VertProfLoc(end + 1) = str2double(splitstr{1});
                end
            case 6
                % profile
                if blockLineID > 1
                    D.Input.xInitial(end + 1) = str2double(splitstr{1});
                    D.Input.zInitial(end + 1) = str2double(splitstr{2});
                end
            case 7
                % revetments and beachwalls
                if blockLineID > 1
                    if str2double(splitstr{2}) > -999
                        D.Input.Revetment(end + 1, :) = [str2double(splitstr{1}) str2double(splitstr{2})];
                    end
                end
            otherwise
                switch blockID
                    case 8; field = 'WL';               % water levels
                    case 9; field = 'Hs';               % wave heights
                    case 10; field = 'Tp';              % wave periods
                    case 11; field = 'WaveAngle';       % incident wave angles
                    case 12; field = 'LongVel';         % longshore velocities
                    case 13; field = 'LongVelGrad';     % longshore velocity gradients
                end
                
                if blockLineID > 1
                    if blockLength == 2
                        if blockLineID == 2
                            D.Input.(field)(end + 1) = str2double(splitstr{2});
                        end
                    else
                        D.Input.(field)(end + 1, :) = [str2double(splitstr{1}) str2double(splitstr{2})];
                    end
                end
        end
        
        % get block length, if available
        if blockID >= 4 && blockLineID == 1
            if strcmpi(splitstr{1}, 'BASFUN')
                blockLength = str2double(splitstr{3});
            else
                blockLength = str2double(splitstr{2});
            end
        end
        
        % check whether block end is reached, increase counters accordingly
        if blockID >= 4 & blockLineID > blockLength; blockID = blockID + 1; blockLineID = 0; end;
        if blockID == 3 & str2double(splitstr{2}) == 0; blockID = 4; blockLineID = 0; end;
        if blockID == 2 & strcmpi(splitstr{1}, 'END'); blockID = 3; blockLineID = 0; end;
        if blockID == 1 & lineID == 1; blockID = 2; blockLineID = 0; end;
        
        lineID = lineID + 1;
        blockLineID = blockLineID + 1;
    end
    
    fclose(fid);
end