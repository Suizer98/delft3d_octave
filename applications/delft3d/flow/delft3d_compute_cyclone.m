function delft3d_compute_cyclone(tc,fname,varargin)
%DELFT3D_COMPUTE_CYCLONE  Computes tropical cyclone
%
%   Computes tropical cyclone based on best track data from Unisys for
%   example. Uses the wes.exe and merge_spw.exe programs. Based on 
%   ddb_computeCyclone by Maarten van Ormondt
%
%   Syntax:
%   delft3d_compute_cyclone(tc, filename)
%
%   Input:
%       tc    = struct with at least date, name, meta, time, lon, lat, vmax and p
%       fname = filename (without extension) of resulting spiderweb grid (string)
%
% note that tc.p is the pressure and not the pressure drop!!!
%
%   Optional input:
%       perquadrant (default = 1);
%       nrRadialBins (default = 500);
%       nrDirectionalBins (default = 36);
%       radius (default = 1000);
%       method (default = 4);
%       initDir (default = 0);
%       initSpeed (default = 0);
%       deleteTemporaryFiles (default = false);
%       wes_exe = (default 'C:\delftdashboard\data\toolboxes\TropicalCyclone\wes.exe');
%       merge_spw_exe = (default 'c:\delftdashboard\data\toolboxes\TropicalCyclone\merge_spw.exe');
% 
%   Output:
%   spiderweb .spw file
%
%   Example
%       tc_fname = 'Haiyan_track_unisys.dat';
%       tc = readBestTrackUnisys(tc_fname);
%       spw_fname = 'Haiyan_cyclone';
%       delft3d_compute_cyclone(tc,spw_fname)
%
%   Don't forget to add wind as a process in the Delft3D mdf:
%       Sub1   = #  W #
%   and fill in the keywords Filwnd, Filweb and AirOut in the Delft3D mdf,
%   for example:
%       Filwnd = #dummy.wnd#
%       Filweb = #Haiyan_cyclone.spw#
%       AirOut = true
%
%   See also writeBestTrackUnisys readBestTrackUnisys DelftDashBoard

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 ARCADIS
%       Bart Grasmeijer
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
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
% Created: 22 Oct 2014
% Created with Matlab version: 8.4.0.150421 (R2014b)

% $Id: delft3d_compute_cyclone.m 11287 2014-10-22 15:08:42Z bartgrasmeijer.x $
% $Date: 2014-10-22 23:08:42 +0800 (Wed, 22 Oct 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 11287 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_compute_cyclone.m $
% $Keywords: $

%%

OPT.perquadrant = 1;
OPT.nrRadialBins = 500;
OPT.nrDirectionalBins = 36;
OPT.radius = 1000;
OPT.method = 4;
OPT.initDir = 0;
OPT.initSpeed = 0;
OPT.deleteTemporaryFiles = false;
OPT.wes_exe = 'C:\delftdashboard\data\toolboxes\TropicalCyclone\wes.exe';
OPT.merge_spw_exe = 'c:\delftdashboard\data\toolboxes\TropicalCyclone\merge_spw.exe';
OPT.bg_pres = 1013.25;
bg_press_Pa = OPT.bg_pres * 100;  % Same, in Pa


% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

[fpath,fname,fext]=fileparts(fname);

if OPT.perquadrant == 4
    nq=4;
else
    nq=1;
end

% Create polygon file for visualization
if ~isempty(fpath)
    fid=fopen([fpath,filesep,fname '.pol'],'wt');
else
    fid=fopen([fname '.pol'],'wt');
end
fprintf(fid,'%s\n',fname);
fprintf(fid,'%i %i\n',length(find(~isnan(tc.time))),2);
for j=1:length(find(~isnan(tc.time)))
    fprintf(fid,'%6.3f %6.3f\n',tc.lon(j),tc.lat(j));
end
fclose(fid);

for iq=1:nq
    
    if OPT.perquadrant == 4
        iqstr=['_' num2str(iq)];
    else
        iqstr='';
    end
    if ~isempty(fpath)
        fid=fopen([fpath,filesep,fname iqstr '.inp'],'wt');
    else
        fid=fopen([fname iqstr '.inp'],'wt');
    end
    
    fprintf(fid,'%s\n','COMMENT             = WES run');
    fprintf(fid,'%s\n','COMMENT             = Grid: none');
    fprintf(fid,'%s\n',['CYCLONE_PAR._FILE   = trackfile' iqstr '.trk']);
    fprintf(fid,'%s\n',['SPIDERS_WEB_DIMENS. = ' num2str(OPT.nrRadialBins) '  ' num2str(OPT.nrDirectionalBins)]);
    fprintf(fid,'%s\n',['RADIUS_OF_CYCLONE   = ' num2str(1000*OPT.radius,'%3.1f')]);
    fprintf(fid,'%s\n','WIND CONV. FAC (TRK)= 1.00');
    fprintf(fid,'%s\n','NO._OF_HIS._DATA    = 0');
    fprintf(fid,'%s\n','HIS._DATA_FILE_NAME = wes_his.inp');
    fprintf(fid,'%s\n','OBS._DATA_FILE_NAME =');
    fprintf(fid,'%s\n','EXTENDED_REPORT     = yes');
    
    fclose(fid);
    
    % Track file
    
    fid=fopen([fpath,filesep,'trackfile' iqstr '.trk'],'wt');
    
    usr=getenv('username');
    usrstring='* File created by unknown user';
    if size(usr,1)>0
        usrstring=['* File created by ' usr];
    end
    
    fprintf(fid,'%s\n','* File for tropical cyclone');
    fprintf(fid,'%s\n','* File contains Cyclone information ; TIMES in UTC');
    fprintf(fid,'%s\n',usrstring);
    fprintf(fid,'%s\n','* UNIT = Kts, Nmi ,Pa');
    fprintf(fid,'%s\n','* METHOD= 1:A&B;           4:Vm,Pd; Rw default');
    fprintf(fid,'%s\n','*         2:R100_etc;      5:Vm & Rw(RW may be default - US data; Pd = 2 Vm*Vm);');
    fprintf(fid,'%s\n','*         3:Vm,Pd,RmW,     6:Vm (Indian data); 7: OLD METHOD - Not adviced');
    fprintf(fid,'%s\n','* Dm    Vm');
    fprintf(fid,'%3.1f %3.1f\n',OPT.initDir,OPT.initSpeed);
    fprintf(fid,'%s\n','*    Date and time     lat     lon Method    Vmax    Rmax   R100    R65    R50    R35  Par B  Par A  Pdrop');
    fprintf(fid,'%s\n','* yyyy  mm  dd  HH     deg     deg    (-)   (kts)    (NM)   (NM)   (NM)   (NM)   (NM)    (-)    (-)   (Pa)');
    e=1e30;
    
    met=OPT.method;
    for j=1:length(find(~isnan(tc.time)))
        dstr=datestr(tc.time(j),'yyyy  mm  dd  HH');
        switch met
            case 1
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f %6.1f %1.0e\n',dstr,tc.lat(j),tc.lon(j),met,tc.vmax(j,iq),e,e,e,e,e,tc.trackB(j,iq),tc.trackA(j,iq),e);
            case 2
                
                if tc.trackR35(j,iq)<0 || tc.trackR50(j,iq)<0
                    % Not enough input.
                    if bg_press_Pa-tc.p(j,iq)<0
                        % switch to method 6
                        fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,tc.lat(j),tc.lon(j),6,tc.vmax(j,iq),e,e,e,e,e,e,e,e);
                    else
                        if tc.trackRMax(j,iq)>=0
                            % RMax available. Switch to method 3.
                            fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,tc.lat(j),tc.lon(j),3,tc.vmax(j,iq),tc.trackRMax(j,iq),e,e,e,e,e,e,bg_press_Pa-tc.p(j,iq));
                        else
                            % Switch to method 4.
                            fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,tc.lat(j),tc.lon(j),4,tc.vmax(j,iq),e,e,e,e,e,e,e,bg_press_Pa-tc.p(j,iq));
                        end
                    end
                else
                    fmt='  %s  %6.2f  %6.2f      %i  %6.1f ';
                    if tc.trackRMax(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        tc.trackRMax(j,iq)=e;
                    end
                    if tc.trackR100(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        tc.trackR100(j,iq)=e;
                    end
                    if tc.trackR65(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        tc.trackR65(j,iq)=e;
                    end
                    if tc.trackR50(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        tc.trackR50(j,iq)=e;
                    end
                    if tc.trackR35(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        tc.trackR35(j,iq)=e;
                    end
                    fmt=[fmt ' %1.0e %1.0e %1.0e\n'];
                    fprintf(fid,fmt,dstr,tc.lat(j),tc.lon(j),met,tc.vmax(j,iq),tc.trackRMax(j,iq),tc.trackR100(j,iq),tc.trackR65(j,iq),tc.trackR50(j,iq),tc.trackR35(j,iq),e,e,e);
                end
                
                
            case 3
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,tc.lat(j),tc.lon(j),met,tc.vmax(j,iq),tc.trackRMax(j,iq),e,e,e,e,e,e,bg_press_Pa-tc.p(j,iq));
            case 4
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,tc.lat(j),tc.lon(j),met,tc.vmax(j,iq),e,e,e,e,e,e,e,bg_press_Pa-tc.p(j,iq));
            case 5
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,tc.lat(j),tc.lon(j),met,tc.vmax(j,iq),tc.trackRMax(j,iq),e,e,e,e,e,e,e);
            case 6
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,tc.lat(j),tc.lon(j),met,tc.vmax(j,iq),e,e,e,e,e,e,e,e);
        end
    end
    
    fclose(fid);
    
    if ~isempty(fpath)
        cd(fpath);
    else
        cd
    end
    if (exist([OPT.wes_exe],'file'))
        system(['"', OPT.wes_exe,'" ', fname, iqstr, '.inp']);
    else
        fname = which('wes.exe');
        if (exist(fname,'file'))
            system([fname ' ' fname iqstr '.inp']);
        else
            GiveWarning('text','ERROR: The wes.exe program could not be found; cyclone winds cannot be created.');
            return;
        end
    end
    
    if OPT.deleteTemporaryFiles
        delete(['trackfile' iqstr '.trk']);
        delete([fname iqstr '.inp']);
        delete([fname iqstr '_wes.dia']);
    end
    
end

if OPT.perquadrant==4
    % Merge files
    fid=fopen([fname '.inp'],'wt');
    fprintf(fid,'%s\n','COMMENT             = WES run');
    fprintf(fid,'%s\n',['NE QUADRANT         = ' fname '_1.spw']);
    fprintf(fid,'%s\n',['SE QUADRANT         = ' fname '_2.spw']);
    fprintf(fid,'%s\n',['SW QUADRANT         = ' fname '_3.spw']);
    fprintf(fid,'%s\n',['NW QUADRANT         = ' fname '_4.spw']);
    fclose(fid);
    system(['"', OPT.merge_spw_exe,'" ', fname, iqstr, '.inp']);
    movefile([fname '_merge.spw'],[fname '.spw']);
    
    if OPT.deleteTemporaryFiles
        delete([fname '_1.spw']);
        delete([fname '_2.spw']);
        delete([fname '_3.spw']);
        delete([fname '_4.spw']);
        delete([fname '.inp']);
        delete([fname '_wes.dia']);
    end
end
