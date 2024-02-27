function err = copyfiles(inpdir, outdir)
%COPYFILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   err = copyfiles(inpdir, outdir)
%
%   Input:
%   inpdir =
%   outdir =
%
%   Output:
%   err    =
%
%   Example
%   copyfiles
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: copyfiles.m 5864 2012-03-21 10:55:48Z boer_we $
% $Date: 2012-03-21 18:55:48 +0800 (Wed, 21 Mar 2012) $
% $Author: boer_we $
% $Revision: 5864 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/misc/copyfiles.m $
% $Keywords: $

%% Copies all files (and not the directories!) to new folder
err=[];
if ~isdir(inpdir)
    err=[inpdir ' not found!'];
    return
end
if ~isdir(outdir)
    err=[outdir ' not found!'];
    return
end

flist=dir([inpdir filesep '*']);
for i=1:length(flist)
    switch lower(flist(i).name)
        case{'.','..','.svn'}
        otherwise
        if ~isdir([inpdir filesep flist(i).name])
            copyfile([inpdir filesep flist(i).name],outdir);
        else
            copyfile([inpdir filesep flist(i).name],[outdir filesep flist(i).name])
        end
    end
end

