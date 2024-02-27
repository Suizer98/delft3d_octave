function qdb2trirst(sourcedir,targetdir)
%QDB2TRIRST - converts qdb local database to tri-rst files
%
% example: qdb2trirst('local_database\','trirst_files\');
%
% Useful script for use in combination with the Simulation Management Tool 
% (see https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/SMT/trunk)
%
%   2014-08-08: Created by W. Ottevanger, Deltares
%
%   Copyright (C) 2016 Deltares
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.


nfsfiles = ls([sourcedir,'\*.dat']);
for f = 1:size(nfsfiles,1)
    nfsfile = deblank(nfsfiles(f,:));
    dom = nfsfile(5:end-4);
    NFStruct=vs_use([sourcedir,'\',nfsfile],'quiet');
    Qlevels = cell2mat(vs_get(NFStruct,'CURDIS','Q','quiet'));
    lenQlev = length(Qlevels);
    for q = 1:lenQlev;
        rst = sprintf('%s%s%s%s%s%i',targetdir,'\','tri-rst.',dom,'_Q',Qlevels(q));
        trim2rst(NFStruct,q,rst);
        disp(sprintf('%s - %i%s%i  %s',dom,q,'/',lenQlev, 'complete'));
    end
end
