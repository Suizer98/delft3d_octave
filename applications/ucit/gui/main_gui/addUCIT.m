function addUCIT (basepath, actionpath)
% ADDUCIT   adds the proper UCIT paths to the matlab path
%
% Routine adds paths relevant to UCIT to the MATLAB path. For purposes of speed
% the routine uses system commands to get the directory info. Once all paths are
% added, the user directories are removed from the path. The proper user directory
% will be added later by UCIT's startup routine.
%
% Syntax:
% addUCIT (basepath, actionpath)
%
% Input:
% basepath   = path from which to start the inventory of directories and files
% actionpath = path containing actionroutines
%
% Output:
%
% See also: ucit, mcsettings, addMcTools

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, January 2008)
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% -------------------------------------------------------------------- 

% $Id: addUCIT.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

%% Add all paths in the UCIT directory
if ispc
    [a,b]=system(['dir /b /ad /s ' '"' basepath '"']); % "'s added to enable spaces in directory and filenames
    s=strrep(b,char(10),';');
else
    [a,b]=system(['find ' basepath ' -type d']);
    s=strrep(b,char(10),':');
end

addpath(s);
disp('*** ucit tools enabled! ***')

%% Add all paths in the UCIT_Actions directory
if ~isempty(actionpath)
    if ispc
        [a,b]=system(['dir /b /ad /s ' actionpath filesep]);
        s=strrep(b,char(10),';');
    else
        [a,b]=system(['find ' basepath filesep '..' ' -type d']);
        s=strrep(b,char(10),':');
    end
    addpath(s);
    disp('*** ucit actions enabled! ***')
else
    disp('*** ucit actions not available! ***')
end

%% Remove user directories ... the proper user directory will be added later
id = 'dummy';
while ~isempty(id)
    id=fileparts(which('ucit.ini'));
    try rmpath(id);catch id = []; end
end
