function handles = ddb_DFlowFM_readExternalForcing(handles)
% ddb_DFlowFM_readExternalForcing  One line description goes here.

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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_DFlowFM_readExternalForcing.m 16914 2020-12-14 15:10:42Z ormondt $
% $Date: 2020-12-14 23:10:42 +0800 (Mon, 14 Dec 2020) $
% $Author: ormondt $
% $Revision: 16914 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_readExternalForcing.m $
% $Keywords: $

%% Reads DFlow-FM external forcing (ext and bc files)
% Reorders boundaries and merges boundaries with the same pli file

boundary=delft3dfm_read_ext_file(handles.model.dflowfm.domain.extforcefilenew);

boundary=ddb_reorder_fm_boundaries(boundary);


s=[];
n=0;
fid=fopen(fname,'r');

while 1
    str=fgetl(fid);
    if str==-1
        break
    end
    str=deblank2(str);
    if ~isempty(str)
        if strcmpi(str(1),'*')
            % Comment line
        else
            
            nis=find(str=='=');
            switch lower(str(1:6))
                case{'quanti'}
                    n=n+1;
                    s(n).quantity=deblank2(str(nis+1:end));
                case{'filety'}
                    s(n).filetype=deblank2(str(nis+1:end));
                case{'filena'}
                    s(n).filename=deblank2(str(nis+1:end));
                case{'method'}
                    s(n).method=deblank2(str(nis+1:end));
                case{'locati'}
                    s(n).locationfile=deblank2(str(nis+1:end));
                case{'forcin'}
                    s(n).forcingfile=deblank2(str(nis+1:end));
            end
            
        end
        
    end
end
fclose(fid);

% Clear boundary info
boundaries=[];
boundaries(1).name='';
handles.model.dflowfm.domain.activeboundary=1;
handles.model.dflowfm.domain.nrboundaries=0;
handles.model.dflowfm.domain.boundarynames={''};
nb=0;

for ii=1:length(s)
    switch lower(s(ii).quantity)
        case{'waterlevelbnd'}
            nb=nb+1;
            plifile=s(ii).locationfile;
            name=plifile(1:end-4);
            [x,y]=landboundary('read',plifile);
            boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,nb,handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop);
            boundaries(nb).type=s(ii).quantity;
            boundaries(nb).name=name;
            boundaries(nb).forcingfile=s(ii).forcingfile;
            handles.model.dflowfm.domain.bcfile=s(ii).forcingfile;
            handles.model.dflowfm.domain.boundarynames{nb}=name;            
        case{'riemannbnd'}
            nb=nb+1;
            plifile=s(ii).locationfile;
            name=plifile(1:end-4);
            [x,y]=landboundary('read',plifile);
            boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,nb,handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop);
            boundaries(nb).type=s(ii).quantity;
            boundaries(nb).forcingfile=s(ii).forcingfile;
            handles.model.dflowfm.domain.boundarynames{nb}=name;            
            handles.model.dflowfm.domain.bcfile=s(ii).forcingfile;
        case{'normalvelocitybnd'}
            nb=nb+1;
            plifile=s(ii).locationfile;
            name=plifile(1:end-4);
            [x,y]=landboundary('read',plifile);
            boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,nb,handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop);
            boundaries(nb).type=s(ii).quantity;
            boundaries(nb).forcingfile=s(ii).forcingfile;
            handles.model.dflowfm.domain.boundarynames{nb}=name;            
            handles.model.dflowfm.domain.bcfile=s(ii).forcingfile;
        case{'dischargebnd'}
            nb=nb+1;
            plifile=s(ii).locationfile;
            name=plifile(1:end-4);
            [x,y]=landboundary('read',plifile);
            boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,nb,handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop);
            boundaries(nb).type=s(ii).quantity;
            boundaries(nb).forcingfile=s(ii).forcingfile;
            handles.model.dflowfm.domain.boundarynames{nb}=name;            
            handles.model.dflowfm.domain.bcfile=s(ii).forcingfile;
        case{'spiderweb'}
            handles.model.dflowfm.domain.spiderwebfile=s(ii).filename;
            handles.model.dflowfm.domain.wind=1;
        case{'windx'}
            handles.model.dflowfm.domain.windufile=s(ii).filename;
            handles.model.dflowfm.domain.wind=1;
        case{'windy'}
            handles.model.dflowfm.domain.windvfile=s(ii).filename;
            handles.model.dflowfm.domain.wind=1;
        case{'atmosphericpressure'}
            handles.model.dflowfm.domain.airpressurefile=s(ii).filename;
            handles.model.dflowfm.domain.airpressure=1;
        case{'rain'}
            handles.model.dflowfm.domain.rainfile=s(ii).filename;
            handles.model.dflowfm.domain.rain=1;
    end
end

for ii = 1:length(boundaries)
    
    % Now read time series / component files
    if exist(handles.model.dflowfm.domain.bcfile,'file')
        [A] = textread(handles.model.dflowfm.domain.bcfile,'%s');
        for jj = 1:length(boundaries(ii).nodes)
            id = find(strcmpi(A, boundaries(ii).nodes(jj).name));
            if ~isempty(id)
                
                % Reading time series
                if strcmp(A{ (id+3) ,1}, 'timeseries')
                    
                    % Set the bc-file
                    nodename=boundaries(ii).nodes(jj).name;
                    id = find(strcmpi(A, nodename));
                    %                id = find(strcmpi(A, boundaries(ii).cmpfile(jj)));
                    boundaries(ii).nodes(jj).bc.Function   = A{id+3,1};
                    boundaries(ii).nodes(jj).bc.Timeinterpolation  = A{id+6,1};
                    boundaries(ii).nodes(jj).bc.Quantity1  = A{id+9,1};
                    boundaries(ii).nodes(jj).bc.Unit1      = [A{id+12,1},' ', A{id+13,1},' ', A{id+14,1},' ', A{id+15,1}];
                    boundaries(ii).nodes(jj).bc.Quantity2  = A{id+18,1};
                    boundaries(ii).nodes(jj).bc.Unit2      = A{id+21,1};
                    
                    % Get values
                    endvalue = 0; idvalue = id+22; count = 1;
                    while endvalue == 0
                        try
                            time(count) = str2num(A{idvalue,1}); idvalue = idvalue+1;
                            value(count) = str2num(A{idvalue,1}); idvalue = idvalue+1; count = count+1;
                        catch
                            endvalue = 1;
                        end
                    end
                    
                    % Save value
                    boundaries(ii).nodes(jj).timeseries.time    = time;
                    boundaries(ii).nodes(jj).timeseries.value   = value;
                    boundaries(ii).nodes(jj).cmptype            = 'timeseries';
                    
                    % Reading harmonic  (TO DO)
                elseif strcmp(A{ (id+3) ,1}, 'harmonic')
                    
                    
                    % Save value
                    boundaries(ii).nodes(jj).cmptype            = 'harmonic';
                    
                    % Reading harmonic
                elseif strcmp(A{ (id+3) ,1}, 'astronomic')
                    
                    % Set the bc-file
                    id = find(strcmpi(A, boundaries(ii).nodes(jj).name));
                    boundaries(ii).nodes(jj).bc.Function   = A{id+3,1};
                    boundaries(ii).nodes(jj).bc.Quantity1  = [A{id+6,1}, ' ', A{id+7,1}];
                    boundaries(ii).nodes(jj).bc.Unit1      = A{id+10,1};
                    boundaries(ii).nodes(jj).bc.Quantity2  = [A{id+13,1}, ' ', A{id+14,1}];
                    boundaries(ii).nodes(jj).bc.Unit2      = A{id+17,1};
                    boundaries(ii).nodes(jj).bc.Quantity3  = [A{id+13,1}, ' ', A{id+21,1}];
                    boundaries(ii).nodes(jj).bc.Unit3      = A{id+24,1};
                    
                    % Get value
                    endvalue = 0; idvalue = id+25; count = 1;
                    while endvalue == 0
                        try
                            values(count).con = A{idvalue,1}; idvalue = idvalue+1;
                            values(count).amp = str2num(A{idvalue,1}); idvalue = idvalue+1;
                            values(count).phi = str2num(A{idvalue,1}); idvalue = idvalue+1;
                            
                            if isempty(values(count).con) || isempty(values(count).amp) || isempty(values(count).phi)
                                endvalue = 1;
                            else
                                count = count+1;
                            end
                            
                        catch
                            endvalue = 1;
                        end
                    end
                    
                    % Save values
                    nnnn = length(values);
                    for xx = 1:nnnn-1
                        boundaries(ii).nodes(jj).astronomiccomponents(xx).component = values(xx).con;
                        boundaries(ii).nodes(jj).astronomiccomponents(xx).amplitude = values(xx).amp;
                        boundaries(ii).nodes(jj).astronomiccomponents(xx).phase     = values(xx).phi;
                    end
                end
            end
        end
    end
end

handles.model.dflowfm.domain.nrboundaries=length(boundaries);
handles.model.dflowfm.domain.boundaries=boundaries;
