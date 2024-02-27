function ITHK_io_writeCLR(filename, time, phaseunit, timesteps, output_step, CL_filenames, varargin)
%write CLR : Writes a unibest cl-run specification file
%
%   Syntax:
%     function ITHK_io_writeCLR(filename, time, phases, timesteps, output_step, CL_filenames)
% 
%   Input:
%     time                 time in number of phases ([Nx1] matrix)
%     phases               number of phases in 1 year (for months = 12, for years = 1)
%     timesteps            computational timesteps (number / phase) (single value)
%     output_step          output per number of computational timesteps (single value, every n-th timestep)
%     CL_filenames         cellstringarray {e.g. 'abc','def','NULL','NULL','NULL','NULL','NULL'}
%  
%   Output:
%     .clr file
%
%   Example:
%     ITHK_io_writeCLR('test.clr', [0:2:4], 'year', 52, 26, {'abc','def','NULL','NULL','NULL','NULL','NULL'})
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

% $Id: ITHK_io_writeCLR.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/ITHK_io_writeCLR.m $
% $Keywords: $

if strcmp(phaseunit,'year')
    phaseunit2=1;
elseif strcmp(phaseunit,'month')
    phaseunit2=12;
elseif strcmp(phaseunit,'week')
    phaseunit2=52;
elseif strcmp(phaseunit,'day')
    phaseunit2=365;
elseif strcmp(phaseunit,'hour')
    phaseunit2=8760;
else
    fprintf('\n warning: phaseunit not recognised!\n          (phaseunit set at year)');
    phaseunit2=1;
end

no_phases      = length(time)-1;
no_cycli       = 1;
t0             = 0;
mda_file       = ['''',CL_filenames{1},''''];
%mda_file       = ['BASIS'];

%analysis
t1             = time(1:end-1);
t2             = time(2:end);
ifirst         = 0;
iaant          = ceil(((time(end)-time(1))*timesteps/output_step)*(no_cycli+1))+1;

%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');
fprintf(fid,'%s\n','Phase unit');
fprintf(fid,'%7.0f\n',phaseunit2);
fprintf(fid,'%s\n','Delta t');
fprintf(fid,'%7.0f\n',timesteps);
fprintf(fid,'%s\n','Number of Phases');
fprintf(fid,'%7.0f\n',no_phases);
fprintf(fid,'%s\n','Number of Cycli');
fprintf(fid,'%3.0f\n',no_cycli);
fprintf(fid,'%s\n','Begin time (t0)');
fprintf(fid,'%3.0f\n',t0);
fprintf(fid,'%s    %s\n',mda_file,'(MDA-file)');
fprintf(fid,'%s\n','    Fase      From      To        .GKL       .BCO       .GRO       .SOS       .REV       .OBW       .BCI');
for ii=1:no_phases
    fprintf(fid,'  %4.0f  %8.0f  %8.0f    ''%s''   ''%s''   ''%s''   ''%s''   ''%s''   ''%s''   ''%s''\n',ii,t1(ii),t2(ii),CL_filenames{2}{ii},CL_filenames{3}{ii},CL_filenames{4}{ii},CL_filenames{5}{ii},CL_filenames{6}{ii},CL_filenames{7}{ii},CL_filenames{8}{ii});
end
fprintf(fid,'%s\n','iaant    ifirst    ival');
fprintf(fid,'%8.0f  %8.0f  %8.0f\n',iaant,ifirst,output_step);
fclose(fid);