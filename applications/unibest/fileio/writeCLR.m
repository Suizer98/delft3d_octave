function writeCLR(filename,CLdata)
%write CLR : Writes a unibest cl-run specification file
%
%   Syntax:
%     function writeCLR(filename,CLdata)
% 
%   Input:
%     filename                String with CLR filename
%     CLdata                  Structure with CLR-data
%             .t0             Start year
%             .timesteps      Number of numerical timesteps per year
%             .no_phases      Number of phases [N]
%             .tstart         Start time of each phase (in year with respect to t0) [Nx1]
%             .tend           End time of each phase (in year with respect to t0) [Nx1]
%             .MDAfile        String with MDA-file
%             .LATfile        (optional) string with LAT-file (uses same name as MDAfile if not specified)
%             .GKLfile        Cell-string with GKL-file (with one filename per phase) {Nx1}
%             .BCOfile        Cell-string with BCO-file (with one filename per phase) {Nx1}
%             .GROfile        Cell-string with GRO-file (with one filename per phase) {Nx1}
%             .SOSfile        Cell-string with SOS-file (with one filename per phase) {Nx1}
%             .REVfile        Cell-string with REV-file (with one filename per phase) {Nx1}
%             .OBWfile        Cell-string with OBW-file (with one filename per phase) {Nx1}
%             .BCIfile        Cell-string with BCI-file (with one filename per phase) {Nx1}
%             .iaant          (optional) Maximum number of output steps in PRN-file (default = 1000)
%             .ifirst         (optional) Numerical timestep of first output written to PRN-file (default = 0)
%             .output_step    Number of numerical timesteps before output is written to PRN-file
%  
%   Output:
%     '.clr file'
%
%   Example:
%     CLdata.t0 = 2000;
%     CLdata.timesteps = 52;
%     CLdata.no_phases = 1;
%     CLdata.tstart = [0];
%     CLdata.tend = [2];
%     CLdata.MDAfile = 'abc';
%     CLdata.GKLfile = {'NULL'};
%     CLdata.BCOfile = {'NULL'};
%     CLdata.GROfile = {'NULL'};
%     CLdata.SOSfile = {'NULL'};
%     CLdata.REVfile = {'NULL'};
%     CLdata.OBWfile = {'NULL'};
%     CLdata.BCIfile = {'NULL'};
%     CLdata.output_step = 26;
%     writeCLR('test.clr', CLdata)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeCLR.m 13439 2017-07-04 19:37:19Z huism_b $
% $Date: 2017-07-05 03:37:19 +0800 (Wed, 05 Jul 2017) $
% $Author: huism_b $
% $Revision: 13439 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeCLR.m $
% $Keywords: $


CL = CLdata;

%% convert to cell if required
fldnms = {'GKLfile','BCOfile','GROfile','SOSfile','REVfile','OBWfile','BCIfile'};
for kk=1:length(fldnms)
    if isstr(CL.(fldnms{kk}));
        CL.(fldnms{kk}) = {CL.(fldnms{kk})};
    end
end
if ~isfield(CL,'phaseunit'); CL.phaseunit = 1; end
if ~isfield(CL,'timesteps'); CL.timesteps = 200; end
if ~isfield(CL,'no_phases'); CL.no_phases = length(CL.GKLfile); end
if ~isfield(CL,'no_cycli'); CL.no_cycli = 1; end
if ~isfield(CL,'t0'); CL.t0 = 0; end
if ~isfield(CL,'tstart'); CL.tstart = 0; end
if ~isfield(CL,'tend'); CL.tend = 5; end
if ~isfield(CL,'iaant'); CL.iaant = 100; end
if ~isfield(CL,'ifirst'); CL.ifirst = 0; end
if ~isfield(CL,'output_step'); CL.output_step = 50; end
if ~isfield(CL,'LATfile'); CL.LATfile = CL.MDAfile; end
[pthnm, CL.MDAfile, extnm] = fileparts(CL.MDAfile);
[pthnm, CL.LATfile, extnm] = fileparts(CL.LATfile);
for kk=1:CL.no_phases; 
    [pthnm, CL.GKLfile{kk}, extnm] = fileparts(CL.GKLfile{kk});
    [pthnm, CL.BCOfile{kk}, extnm] = fileparts(CL.BCOfile{kk});
    [pthnm, CL.GROfile{kk}, extnm] = fileparts(CL.GROfile{kk});
    [pthnm, CL.SOSfile{kk}, extnm] = fileparts(CL.SOSfile{kk});
    [pthnm, CL.REVfile{kk}, extnm] = fileparts(CL.REVfile{kk});
    [pthnm, CL.OBWfile{kk}, extnm] = fileparts(CL.OBWfile{kk});
    [pthnm, CL.BCIfile{kk}, extnm] = fileparts(CL.BCIfile{kk});
end

%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');
fprintf(fid,'%s\n','Phase unit');
fprintf(fid,'%7.0f\n',CL.phaseunit);
fprintf(fid,'%s\n','Delta t');
fprintf(fid,'%7.0f\n',CL.timesteps);
fprintf(fid,'%s\n','Number of Phases');
fprintf(fid,'%7.0f\n',CL.no_phases);
fprintf(fid,'%s\n','Number of Cycli');
fprintf(fid,'%3.0f\n',CL.no_cycli);
fprintf(fid,'%s\n','Begin time (t0)');
fprintf(fid,'%4.4f\n',CL.t0);
fprintf(fid,'''%s''      %s\n',CL.MDAfile,'(MDA-file)');
fprintf(fid,'''%s''      %s\n',CL.LATfile,'(LAT-file)');
fprintf(fid,'%s\n','    Phase     From      To        .GKL       .BCO       .GRO       .SOS       .REV       .OBW       .BCI');
for ii=1:CL.no_phases
    fprintf(fid,'  %4.0f  %8.3f  %8.3f    ''%s''   ''%s''   ''%s''   ''%s''   ''%s''   ''%s''   ''%s''\n',ii,CL.tstart(ii),CL.tend(ii),CL.GKLfile{ii},CL.BCOfile{ii},CL.GROfile{ii},CL.SOSfile{ii},CL.REVfile{ii},CL.OBWfile{ii},CL.BCIfile{ii});
end
fprintf(fid,'%s\n','iaant    ifirst    ival');
fprintf(fid,'  %8.0f  %8.0f  %8.0f\n',CL.iaant,CL.ifirst,CL.output_step);
fclose(fid);

