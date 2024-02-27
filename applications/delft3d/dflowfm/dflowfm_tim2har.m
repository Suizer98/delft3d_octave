function status = dflowfm_tim2har(modeldir, outputdir, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Converts time series bc file to a harmonic bc version
%
% Input:
%   - modeldir: folder with time series bc file
%   - outputdir: folder in which to write harmonic file
%   Optionally:
%   - ncomp: number of harmonic components extracted from time series
%   (default: 8)
%   - tstart: start time in time series in minutes (default: 0)
%   - tstop: stop time in time series in minutes (default: 1490)  
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
OPT.ncomp  = 8;
OPT.tstart = 0;
OPT.tstop   = 1490;
OPT = setproperty(OPT, varargin{:});
bc=dir(fullfile(modeldir,'*.bc'));
try
ibc=0;
for i=1:length(bc)
    fname=fullfile(modeldir,bc(i).name);
    fid=fopen(fname,'r');
    fio=fopen(fullfile(outputdir,bc(i).name),'w');
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
            fclose(fio);
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
        [BC(ibc).amp,BC(ibc).phase,BC(ibc).period,BC(ibc).offset]= ...
            time2har(BC(ibc).time,BC(ibc).val,OPT.ncomp,OPT.tstart,OPT.tstop);
        fprintf(fio,'[forcing]\n');
        fprintf(fio,'Name        = %s \n',BC(ibc).seriesName);
        fprintf(fio,'Function    = harmonic \n');
        fprintf(fio,'Offset      = %6.3f \n',BC(ibc).offset);
        fprintf(fio,'Quantity    = harmonic component \n');
        fprintf(fio,'Unit        = minutes \n');
        fprintf(fio,'Quantity    = %s amplitude \n',BC(ibc).seriesValQnty);
        fprintf(fio,'Unit        = %s \n', BC(ibc).seriesValUnit);
        fprintf(fio,'Quantity    = %s phase \n',BC(ibc).seriesValQnty);
        fprintf(fio,'Unit        = deg \n');
        icomp=[1,2:2:OPT.ncomp];
        out(1,:)=BC(ibc).period(icomp);
        out(2,:)=BC(ibc).amp(icomp);
        out(3,:)=BC(ibc).phase(icomp);
        fprintf(fio,'%10.2f %10.2f %8.2f \n',out);
        fprintf(fio,'\n');
    end
end
   status = 1

catch
   status = 0
   warning('Could not succesfully complete dflowfm_tim2har.');
end   