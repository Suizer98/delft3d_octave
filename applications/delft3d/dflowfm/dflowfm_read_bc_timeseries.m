function [BC,status] = dflowfm_read_bc_timeseries(modeldir, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reads time series from all bc files in modeldir
%
% Input:
%   - modeldir: folder with time series bc file
%   - varargin: optional argument 'yesplot',0/1 to plot all timeseries in a
%               single figure
% Output:
%   - BC structure array with all meta information and the timeseries
%   - status: 0 if not ok, 1 if ok
%
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 IHE Delft / Deltares
%       Dano Roelvink, Johan Reyns
%
%       d.roelvink@un-ihe.org
%
%       Westvest 7
%       2611AX Delft
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
status = 0;
OPT.yesplot   = 0;
OPT = setproperty(OPT, varargin{:});
bc=dir(fullfile(modeldir,'*.bc'));
try
    ibc=0;
    for i=1:length(bc)
        fname=fullfile(modeldir,bc(i).name);
        fid=fopen(fname,'r');
        while 1
            s=1;
            while ~strcmp(s,'[forcing]')
                try
                    s=strtrim(fgetl(fid));
                    eof=0;
                catch
                    eof=1;
                    break
                end
            end
            if eof==1
                fclose(fid);
                break
            end
            ibc=ibc+1;
            BC(ibc).seriesName     = getvalue(fid,'Name');
            BC(ibc).seriesFunction = getvalue(fid,'Function');
            BC(ibc).seriesInterp   = getvalue(fid,'Time-interpolation');
            BC(ibc).seriesTimeQnty = getvalue(fid,'Quantity');
            BC(ibc).seriesTimeUnit = getvalue(fid,'Unit');
            BC(ibc).seriesValQnty  = getvalue(fid,'Quantity');
            BC(ibc).seriesValUnit  = getvalue(fid,'Unit');
            if strfind(lower(BC(ibc).seriesTimeUnit),'minutes')
                tfac = 1;
            else if strfind(lower(BC(ibc).seriesTimeUnit),'seconds')
                    tfac = 60;
                else if strfind(lower(BC(ibc).seriesTimeUnit),'hours')
                        tfac = 1/60;
                    else
                        error('Invalid time unit used. Please use seconds, minutes or hours.');
                    end
                end
            end
            v=[1 1];
            ii=0;
            while length(v)==2
                try
                    v=str2num(fgetl(fid));
                    ii=ii+1;
                    BC(ibc).t(ii)=v(1);
                    BC(ibc).val(ii)=v(2);
                catch
                    v=[];
                end
            end
            BC(ibc).time=BC(ibc).t/tfac;
             % find reference time
            loc= strfind(lower(BC(ibc).seriesTimeUnit),'since')+6;
            reftime=datenum(BC(ibc).seriesTimeUnit(loc:end));
            BC(ibc).t=reftime+BC(ibc).time/60/24;
           
        end
    end
    status = 1
    
catch
    status = 0
    warning('Could not succesfully complete dflowfm_tim2har.');
end

if OPT.yesplot
    figure(1)
    nrow=floor(sqrt(length(BC)));
    ncol=ceil(length(BC)/nrow);
    for ibc=1:length(BC)
        subplot(nrow,ncol,ibc);
        plot(BC(ibc).t,BC(ibc).val,'k');
        datetick;
        title(BC(ibc).seriesName);
        xlabel ('time');
        ylabel ([BC(ibc).seriesValQnty(1:end-3),'[',BC(ibc).seriesValUnit,']']);
    end
end