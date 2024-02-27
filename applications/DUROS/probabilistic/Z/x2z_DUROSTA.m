function [z ErosionVolume result] = x2z_DUROSTA(x, varnames, resistance, varargin)
%x2z_DUROSTA: Limit state function based on the DUROSTA model
%
%   Calculates the Z value based on representations of several stochasts
%   and the DUROSTA dune erosion model. It is necessary to provide the
%   location of the DUROSTA executable as the first varargin item.
%
%   Syntax:
%   [z ErosionVolume] = x2z_DUROSTA(x, varnames, resistance, varargin)
%
%   Input:
%   x               = representative values of the stochasts
%   varnames        = names of the stochasts
%   resistance      = resistance value for calculation of Z
%   varargin        = PropertyValue
%                       1: path to the DUROSTA executable
%                       2: x-coordinates of profile (optional)
%                       3: z-coordinates of profile (optional)
%                       4: flag that determines whether temporary files are
%                           deleted (default: true)
%
%   Output:
%   z               = calculated Z values
%   ErosionVolume   = calculated erosion volumes
%   result          = result struct of DUROSTA routines
%
%   Example
%   [z ErosionVolume] = x2z_DUROSTA(x, varnames, resistance)
%
%   See also FORM MC DUROSTA_Run

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

% Created: 14 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: x2z_DUROSTA.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/Z/x2z_DUROSTA.m $

%% settings

% retrieve exe directory
if length(varargin) >= 1
    exeDir = varargin{1};
else
    error('Path to DUROSTA executable not defined');
end

if length(varargin) >= 3 && ~isempty([varargin{2:3}])
    xInitial = varargin{2};
    zInitial = varargin{3};
    xInitial = xInitial(~isnan(zInitial));
    zInitial = zInitial(~isnan(zInitial));
else
    [xInitial zInitial] = SimpleProfile('xmin', -250, 'zmin', -20);
    [xInitial zInitial] = modifySimpleProfile('x', xInitial, 'z', zInitial, 'flip', {'z'}, 'shift', [250 0]);
end

if length(varargin) >= 4 && varargin{4} == false
    DELETE_TEMP_FILES = false;
else
    DELETE_TEMP_FILES = true;
end

%% calculate z value

% allocate return variables
z = [];
ErosionVolume = [];
result = struct();
retreat = [];

% set variable values
VAR = struct();
tmpNames = {''};
for i = 1:size(x,2)
    VAR.(char(varnames{i})) = x(:,i);
    for j = 1:size(x,1)
        tmpNames{j} = [tmpNames{j} char(varnames{i}) '=' num2str(x(j,i)) '_'];
    end
end

% check fieldnames
requiredFields = {'D50', 'R', 'tstop', 'Hsig_t', 'Tp_t', 'WL_t', 'alpha'};
definedFields = fieldnames(VAR);
missingFields = setdiff(requiredFields, definedFields);

for i = missingFields
    if ~isempty(char(i))
        VAR.(char(i)) = [0];
    end
end

for i = 1:size(x,1)
    
    % reference for retreat distance
    zRef = VAR.WL_t(i);
    xRef = max(findCrossings(xInitial, zInitial, [min(xInitial) max(xInitial)]', ones(2,1) * zRef));
    
    % calculate fall velocity
    w = getFallVelocity('D50', VAR.D50(i));
    
    % set DUROSTA input variables
    D = CreateDurostaVar( ...
        'DSED', VAR.D50(i), ...
        'DTMAX', 0.1, ...
        'DZMAX', 0.1, ...
        'RK', VAR.R(i), ...
        'WSED', w, ...
        'XK', xRef, ...
        'Tstart', 0, ...
        'Tstop', VAR.tstop(i), ...
        'Hs', VAR.Hsig_t(i), ...
        'Tp', VAR.Tp_t(i), ...
        'WL', VAR.WL_t(i), ...
        'xInitial', xInitial, ...
        'zInitial', zInitial, ...
        'WaveAngle', VAR.alpha(i), ...
        'dx', 2, ...
        'OutputSteps', [] ...
    );

    % calculate optimal grid
    [gridX gridZ gridDX gridN] = DUROSTA_makegrid(xInitial, zInitial, VAR.WL_t(i));
    D.Input.Grid = [gridX ; gridDX];
    
    % write temporary input file
    fname = [char(tmpNames(i)) 'ID' num2str(round(rand*1000))];
%     [pathstr, fname, ext] = fileparts(tempname);
    fname = DUROSTA_Inp_File(D, [pwd filesep fname '.inp']);
    try
        % calculate dune erosion and read result file, if exists
        
        if exist(fname, 'file')
            DUROSTA_Run(fname, [exeDir filesep 'uni-de.exe'], 'quiet', 1);
            
            [pathstr, fpart, ext] = fileparts(fname);
            if exist([pathstr filesep fpart '.tek'], 'file')
                result = DUROSTA_Process_Results(D, fname);

                % retrieve resulting erosion volume from result struct
                ErosionVolume(i) = result.Output.Volumes.Data(2);

                % retrieve resulting volume from result struct
                xFinal = result.Output.FinalProfileX;
                zFinal = result.Output.FinalProfileZ;

                % calculate new crossing with surge level and calculate retreat
                % distance
                x = max(findCrossings(xFinal, zFinal, [min(xFinal) max(xFinal)]', ones(2,1) * zRef));
                retreat(i) = x - xRef;
            else
                % throw error
                [pathstr, fpart, ext] = fileparts(fname);
                disp(['ERROR: TEK file not found [' num2str(i) '; ' fpart ']']);

                ErosionVolume(i) = NaN;
                retreat(i) = NaN;
            end
        else
            % throw error
            [pathstr, fpart, ext] = fileparts(fname);
            disp(['ERROR: INP file not found [' num2str(i) '; ' fpart ']']);

            ErosionVolume(i) = NaN;
            retreat(i) = NaN;
        end
    catch
        % throw error
        err = lasterror;
        [pathstr, fpart, ext] = fileparts(fname);
        disp(['ERROR: ' err.message ' [' num2str(i) '; ' fpart ']']);
        
        ErosionVolume(i) = NaN;
        retreat(i) = NaN;
    end
    
    % delete temporary files after saving DAF info
    [pathstr, fpart, ext] = fileparts(fname);
    
    if DELETE_TEMP_FILES
        delete([pathstr filesep fpart '.*']);
    else
        result.Output.file = [pathstr filesep fpart '.daf'];
    end
    
    % store resistance variable
    z(i,:) = resistance - retreat(i);
end