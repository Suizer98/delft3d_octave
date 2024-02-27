function getMeteo(meteoname, meteoloc, t0, t1, xlim, ylim, outdir, cycleInterval, dt, pars, pr, varargin)
%GETMETEO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   getMeteo(meteoname, meteoloc, t0, t1, xlim, ylim, outdir, cycleInterval, dt, pars, pr, varargin)
%
%   Input:
%   meteoname     =
%   meteoloc      =
%   t0            =
%   t1            =
%   xlim          =
%   ylim          =
%   outdir        =
%   cycleInterval =
%   dt            =
%   pars          =
%   pr            =
%   varargin      =
%
%
%
%
%   Example
%   getMeteo
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

% $Id: getMeteo.m 12583 2016-03-17 05:03:50Z ormondt $
% $Date: 2016-03-17 13:03:50 +0800 (Thu, 17 Mar 2016) $
% $Author: ormondt $
% $Revision: 12583 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/getMeteo.m $
% $Keywords: $

%%

usertcyc=0;
outputMeteoName=meteoname;

% Estimate last analyzed time, assume 8 hour delay
tLastAnalyzed=rounddown(now-8/24,0.25);

includesFirstTime=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case{'cycle'}
                % user-specified cycle
                tcyc=varargin{i+1};
                usertcyc=1;
            case{'outputmeteoname'}
                % user-specified output name
                outputMeteoName=varargin{i+1};
            case{'tlastanalyzed'}
                % Time of last analyzed data
                tLastAnalyzed=varargin{i+1};
            case{'includesfirsttime'}
                % Cycle includes t0
                includesFirstTime=varargin{i+1};
        end
        %     elseif iscell(varargin{i})
        %         for j=1:length(varargin{i})
        %             pars{j}=varargin{i}{j};
        %         end
    end
end

dcyc=cycleInterval/24;
dt=dt/24;

if ~exist(outdir,'dir')
    mkdir(outdir);
end


if cycleInterval>1000
    % All data in one nc file
    tt=[t0 t1];            
%    getMeteoFromNomads3(meteoname,outputMeteoName,0,0,tt,xlim,ylim,outdir,pars,pr);
    [lon,lat,err]=getMeteoFromNomads4(meteoname,outputMeteoName,floor(now),0,tt,xlim,ylim,outdir,pars,pr);
else

    if includesFirstTime
        firstCycle=t0;
    else
        firstCycle=t0-dcyc;
    end

    lon=[];
    lat=[];

    for t=firstCycle:dcyc:t1
        
        tnext=t+dt;
        
        if ~usertcyc
            tcyc=t;
        end
        
        cycledate=floor(tcyc);
        cyclehour=(tcyc-floor(tcyc))*24;
        
        if tnext>tLastAnalyzed
            % Next meteo output not yet available, so get the
            % rest of the data from this cycle and then exit
            % loop after this
            tt=[t t1];
        else
            if includesFirstTime
                tt=[t t+dcyc-dt];
            else
                tt=[t t+dcyc];
            end
        end
        
        tt(2)=min(tt(2),t1);
        
%        switch lower(meteoloc)
%            case{'nomads'}
                [lon,lat,err]=getMeteoFromNomads5(meteoname,outputMeteoName,cycledate,cyclehour,tt,xlim,ylim,outdir,pars,pr,'lon',lon,'lat',lat);
%        end
        
        if tnext>tLastAnalyzed
            break;
        end
        
    end
end

