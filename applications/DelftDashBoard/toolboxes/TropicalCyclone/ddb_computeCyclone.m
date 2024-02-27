function handles = ddb_computeCyclone(handles, filename)
%DDB_COMPUTECYCLONE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_computeCyclone(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_computeCyclone
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

% $Id: ddb_computeCyclone.m 17469 2021-08-28 14:23:53Z jay.veeramony.x $
% $Date: 2021-08-28 22:23:53 +0800 (Sat, 28 Aug 2021) $
% $Author: jay.veeramony.x $
% $Revision: 17469 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_computeCyclone.m $
% $Keywords: $

%%
inp=handles.toolbox.tropicalcyclone;

[path,name,ext]=fileparts(filename);

% Input file

if strcmpi(inp.quadrantOption,'perquadrant')
    nq=4;
else
    nq=1;
end

% Create polygon file for visualization
fid=fopen([name '.pol'],'wt');
fprintf(fid,'%s\n',name);
fprintf(fid,'%i %i\n',inp.nrTrackPoints,2);
for j=1:inp.nrTrackPoints
    fprintf(fid,'%6.3f %6.3f\n',inp.track.x(j),inp.track.y(j));
end
fclose(fid);

for iq=1:nq
    
    if strcmpi(inp.quadrantOption,'perquadrant')
        iqstr=['_' num2str(iq)];
    else
        iqstr='';
    end
    
    fid=fopen([name iqstr '.inp'],'wt');
    
    fprintf(fid,'%s\n','COMMENT             = WES run');
    fprintf(fid,'%s\n','COMMENT             = Grid: none');
    fprintf(fid,'%s\n',['CYCLONE_PAR._FILE   = trackfile' iqstr '.trk']);
    fprintf(fid,'%s\n',['SPIDERS_WEB_DIMENS. = ' num2str(inp.nrRadialBins) '  ' num2str(inp.nrDirectionalBins)]);
    fprintf(fid,'%s\n',['RADIUS_OF_CYCLONE   = ' num2str(1000*inp.radius,'%3.1f')]);
    fprintf(fid,'%s\n',['WIND CONV. FAC (TRK)= ' num2str(inp.windconversionfactor)]);
    fprintf(fid,'%s\n','NO._OF_HIS._DATA    = 0');
    fprintf(fid,'%s\n','HIS._DATA_FILE_NAME = wes_his.inp');
    fprintf(fid,'%s\n','OBS._DATA_FILE_NAME =');
    fprintf(fid,'%s\n','EXTENDED_REPORT     = yes');
    
    fclose(fid);
    
    % Track file
    
    fid=fopen(['trackfile' iqstr '.trk'],'wt');
    
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
    fprintf(fid,'%3.1f %3.1f\n',inp.initDir,inp.initSpeed);
    fprintf(fid,'%s\n','*    Date and time     lat     lon Method    Vmax    Rmax   R100    R65    R50    R35  Par B  Par A  Pdrop');
    fprintf(fid,'%s\n','* yyyy  mm  dd  HH     deg     deg    (-)   (kts)    (NM)   (NM)   (NM)   (NM)   (NM)    (-)    (-)   (Pa)');
    e=1e30;
    
    met=inp.method;
    for j=1:inp.nrTrackPoints
        dstr=datestr(inp.trackT(j),'yyyy  mm  dd  HH');
        switch met
            case 1
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f %6.1f %1.0e\n',dstr,inp.track.y(j),inp.track.x(j),met,inp.track.vmax(j,iq),e,e,e,e,e,inp.track.b(j,iq),inp.track.a(j,iq),e);
            case 2
                
                if inp.track.r35(j,iq)<0 || inp.track.r50(j,iq)<0
                    % Not enough input.
                    if inp.track.pc(j,iq)<0
                        % switch to method 6
                        fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,inp.track.y(j),inp.track.x(j),6,inp.track.vmax(j,iq),e,e,e,e,e,e,e,e);
                    else
                        if inp.track.rmax(j,iq)>=0
                            % RMax available. Switch to method 3.
                            fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.track.y(j),inp.track.x(j),3,inp.track.vmax(j,iq),inp.track.rmax(j,iq),e,e,e,e,e,e,inp.track.pc(j,iq));
                        else
                            % Switch to method 4.
                            fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.track.y(j),inp.track.x(j),4,inp.track.vmax(j,iq),e,e,e,e,e,e,e,inp.track.pc(j,iq));
                        end
                    end
                else
                    fmt='  %s  %6.2f  %6.2f      %i  %6.1f ';
                    if inp.track.rmax(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.track.rmax(j,iq)=e;
                    end
                    if inp.track.r100(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.track.r100(j,iq)=e;
                    end
                    if inp.track.r65(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.track.r65(j,iq)=e;
                    end
                    if inp.track.r50(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.track.r50(j,iq)=e;
                    end
                    if inp.track.r35(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.track.r35(j,iq)=e;
                    end
                    fmt=[fmt ' %1.0e %1.0e %1.0e\n'];
                    fprintf(fid,fmt,dstr,inp.track.y(j),inp.track.x(j),met,inp.track.vmax(j,iq),inp.track.rmax(j,iq),inp.track.r100(j,iq),inp.track.r65(j,iq),inp.track.r50(j,iq),inp.track.r35(j,iq),e,e,e);
                end
                
                
            case 3
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.track.y(j),inp.track.x(j),met,inp.track.vmax(j,iq),inp.track.rmax(j,iq),e,e,e,e,e,e,inp.track.pc(j,iq));
            case 4
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.track.y(j),inp.track.x(j),met,inp.track.vmax(j,iq),e,e,e,e,e,e,e,inp.track.pc(j,iq));
            case 5
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,inp.track.y(j),inp.track.x(j),met,inp.track.vmax(j,iq),inp.track.rmax(j,iq),e,e,e,e,e,e,e);
            case 6
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,inp.track.y(j),inp.track.x(j),met,inp.track.vmax(j,iq),e,e,e,e,e,e,e,e);
        end
    end
    
    fclose(fid);
    
    if (exist(fullfile(handles.toolbox.tropicalcyclone.dataDir,'wes.exe'),'file'))
        system(['"' handles.toolbox.tropicalcyclone.dataDir 'wes.exe" ' name iqstr '.inp']);
    else
        fname = which('wes.exe');
        if (exist(fname,'file'))
            system([fname ' ' name iqstr '.inp']);
        else
            GiveWarning('text','ERROR: The wes.exe program could not be found; cyclone winds cannot be created.');
            return;
        end
    end
    
    if inp.deleteTemporaryFiles
        delete(['trackfile' iqstr '.trk']);
        delete([name iqstr '.inp']);
        delete([name iqstr '_wes.dia']);
    end
    
end

if strcmpi(inp.quadrantOption,'perquadrant')
    
    % Merge files
    fid=fopen([name '.inp'],'wt');
    fprintf(fid,'%s\n','COMMENT             = WES run');
    fprintf(fid,'%s\n',['NE QUADRANT         = ' name '_1.spw']);
    fprintf(fid,'%s\n',['SE QUADRANT         = ' name '_2.spw']);
    fprintf(fid,'%s\n',['SW QUADRANT         = ' name '_3.spw']);
    fprintf(fid,'%s\n',['NW QUADRANT         = ' name '_4.spw']);
    fclose(fid);
    system(['"' handles.toolbox.tropicalcyclone.dataDir 'merge_spw.exe" ' name '.inp']);
    movefile([name '_merge.spw'],[name '.spw']);
    
    if inp.deleteTemporaryFiles
        delete([name '_1.spw']);
        delete([name '_2.spw']);
        delete([name '_3.spw']);
        delete([name '_4.spw']);
        delete([name '.inp']);
        delete([name '_wes.dia']);
    end
    
    
end

model=handles.activeModel.name;
handles.model.(model).domain(ad).spwFile=[name '.spw'];
handles.model.(model).domain(ad).wind=1;
handles.model.(model).domain(ad).windType='spiderweb';
handles.model.(model).domain(ad).airOut=1;

