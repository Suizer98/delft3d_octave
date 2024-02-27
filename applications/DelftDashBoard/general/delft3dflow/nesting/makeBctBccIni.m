function varargout = makeBctBccIni(option, varargin)
%MAKEBCTBCCINI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   openBoundaries = makeBctBccIni(option, varargin)
%
%   Input:
%   option         =
%   varargin       =
%
%   Output:
%   openBoundaries =
%
%   Example
%   makeBctBccIni
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: makeBctBccIni.m 17170 2021-04-08 14:54:54Z ormondt $
% $Date: 2021-04-08 22:54:54 +0800 (Thu, 08 Apr 2021) $
% $Author: ormondt $
% $Revision: 17170 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/makeBctBccIni.m $
% $Keywords: $

%% Generates bct, bcc and ini files

flow=[];
opt=[];
openBoundaries=[];
workdir='';
inpdir='';
cs=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'xmlfile','nestxml'}
                nestxml=varargin{i+1};
                opt=readNestXML(nestxml);
        end
    end
end

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'inpdir','inputdir'}
                inpdir=[varargin{i+1} filesep];
            case{'runid'}
                runid=varargin{i+1};
            case{'workdir'}
                workdir=varargin{i+1};
            case{'flow'}
                flow=varargin{i+1};
            case{'openboundaries'}
                openBoundaries=varargin{i+1};
            case{'opt'}
                opt=varargin{i+1};
            case{'cs'}
                cs=varargin{i+1};
        end
    end
end

if isfield(opt,'runid')
    runid=opt.runid;
end

if isfield(opt,'inputDir')
    inpdir=opt.inputDir;
end

if isempty(flow)
    [flow,openBoundaries]=delft3dflow_readInput(inpdir,runid,varargin);
end

if isfield(opt,'cs')
    if ~isempty(opt.cs)
        % Coordinate system is defined in xml file
        flow.coordSysType=opt.cs.type;
        flow.coordSysName=opt.cs.name;
    end
end

%switch flow.cs
switch lower(flow.coordSysType(1:3))
%    case{'projected'}
    case{'pro','car'}
        % Take value from flow input
        opt.latitude=flow.latitude;
    otherwise
        % Take value from mean latitude in grid
        opt.latitude=nanmean(nanmean(flow.gridY));
end

switch lower(option)
    
    case{'bct'}
        
        %% BCT
        openBoundaries=generateBctFile(flow,openBoundaries,opt);
        delft3dflow_saveBctFile(flow,openBoundaries,[inpdir flow.bctFile]);
        
    case{'bcc'}
        
        %% BCC        
        openBoundaries=generateBccFile(flow,openBoundaries,opt);
        delft3dflow_saveBccFile(flow,openBoundaries,[inpdir flow.bccFile]);
        
    case{'ini'}
        
        %% INI
        generateIniFile(flow,opt,[inpdir flow.iniFile]);
        
end

% Delete TMP waterlevels
if exist([workdir 'TMPOCEAN_waterlevel.mat'],'file')
    delete([workdir 'TMPOCEAN_waterlevel.mat']);
end
if exist([workdir 'TMPOCEAN_current_u.mat'],'file')
    delete([workdir 'TMPOCEAN_current_u.mat']);
end
if exist([workdir 'TMPOCEAN_current_v.mat'],'file')
    delete([workdir 'TMPOCEAN_current_v.mat']);
end
if exist([workdir 'TMPOCEAN_salinity.mat'],'file')
    delete([workdir 'TMPOCEAN_salinity.mat']);
end
if exist([workdir 'TMPOCEAN_temperature.mat'],'file')
    delete([workdir 'TMPOCEAN_temperature.mat']);
end

%% Output
varargout{1} = openBoundaries;
varargout{2} = flow;
varargout{3} = opt;
