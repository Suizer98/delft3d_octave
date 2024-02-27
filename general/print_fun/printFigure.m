function printFigure(varargin)
%PRINTFIGURE  routine to save a figure to a .png-file
%
%   Routine saves the figure with figurehandle 'fh' to a predefined
%   location (including the figure file name). If no location defined, the
%   figure file will called like the caller function with '_Figure.png' at
%   the end in the path of the caller function. If printFigure is called
%   from the command window without a specified location, the figure will
%   be called 'printFigure.<ext>' and saved in the current working directory.
%   If permission is not 'overwrite' and the file name (either predefined 
%   or automatically generated) already exists, '_#' will be added to the 
%   file name, # being an integer. # will start with 1 and be highered 
%   until the file name is unique.
%
%   Syntax:
%   printFigure(fh, location, permission, ddriver, resolution)
%   printFigure(fh,...
%       'resolution', '-r300')
%   printFigure('fh', fh)
%
%   Input:
%   fh         = figure handle
%   location   = string containing destination path and figure filename
%                without extension
%   permission = optional, if permission is set to 'overwrite', then a
%                possible existing file with the specified filename will be
%                overwritten
%   ddriver    = optional, device driver (see help print), default is '-dpng'
%   resolution = optional, resolution of plot, default is '-r300'
%
%   Example
%   printFigure
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 13 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: printFigure.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/print_fun/printFigure.m $
% $Keywords:

%% check and inventorise input
% input can be specified directly, provided that the order of the input
% arguments corresponds with propertyName (specified below), or as
% propertyName propertyValue pairs. Also a combination is possible as long
% as it starts with direct input (in the right order), followed by
% propertyName propertyValue pairs (regardless of order).

% derive identifier of the argument just before the first propertyName or 
% alternatively the identifier of the last input argument (if no
% propertyName propertyValue pairs are used)
idPropName = [cellfun(@ischar, varargin) true];
id = find(idPropName, 1, 'first')-1;

% define propertyNames and (default) propertyValues (most are empty by default)
propertyNameValue = {...
    'fh', gcf;...
    'location', [];...
    'permission', '';...
    'ddriver', '-dpng';...
    'resolution', '-r300'};

propertyNameValue(1:id,2) = varargin(1:id);

% create property structure, including the directly specified input
OPTstructArgs = reshape(propertyNameValue', 1, 2*size(propertyNameValue,1));
OPT = struct(OPTstructArgs{:});

% update property structure with input specified as propertyName
% propertyValue pairs
OPT = setproperty(OPT, varargin{id+1:end});

%% create figure file name if not defined
if isempty(OPT.location)
    ST = dbstack;
    if length(ST)>1
        location = [evalin('caller','pwd') filesep,ST(2).name '_Figure']; % creates a figure file with the name of the caller function with '_Figure' at the end in the path of the caller function 
    else
        location = fullfile(cd, 'printFigure'); % creates a figure file called 'printFigure' in the current working directory
    end
else
    location = OPT.location;
end

%% remove possible extension from location (right extension will be added during printing
dotlocation = findstr(location, '.');
if ~isempty(dotlocation)
    location = location(1:dotlocation(end)-1);
end

%% make sure that file name is not '.png' only
if max(findstr(location, filesep)) == length(location)
    location = [location 'printFigure'];
end

[directory figurefilename] = fileparts(location);

%% print figure to tempfile in tempdir
print(OPT.fh, OPT.ddriver, OPT.resolution, [tempdir figurefilename])
[dummy1 dummy2 extension] = fileparts(getFileName(tempdir, '*', [], 1));
location = [location extension];

%% make sure that existing figure file is not overwritten
if exist(location, 'file')
    disp([location, ' already exists']);
    [directory figurefilename extension] = fileparts(location);
    if ~strcmp(OPT.permission, 'overwrite')
        id = 0;
        while exist(location, 'file') % as long as file name is not unique, higher # (in '_#')
            id=id+1;
            location = [directory filesep figurefilename '_' num2str(id) extension]; % add '_#' to the file name
        end
        disp(['Figure has been saved to <a href="' location '">' location '</a>']);
    else
        disp('File has been overwritten by new figure');
    end
else
    disp(['Figure has been saved to <a href="' location '">' location '</a>']);
end

%% move figure file from tempdir to final location
movefile([tempdir figurefilename extension], location)