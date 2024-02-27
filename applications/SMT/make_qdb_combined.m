function make_qdb_combined(sourcedirs,targetdir,discharges)
%
%MAKE_QDB_COMBINED Combine QDB files from different hydrograph simulations
%
%   MAKE_QDB_COMBINED(SOURCEDIRS, TARGETDIR, DISCHARGES)
%   Combines the data of QDB files in the directories of the SOURCEDIRS
%   into one QDB file in the directory TARGETDIR. Only discharge levels
%   defined in DISCHARGES are taken into account.
%   If the target files exist, they will be overwritten.
%
%   Examples:
%   make_qdb_combined({'../localdatabase1','../localdatabase2'})
%   make_qdb_combined({'D:\Projects\120485\local_database2', 'D:\Projects\1204855\local_database3'},'D:\Projects\1204855\database_combined',[1080, 1400, 2380, 5670])
%
%   Useful script for use in combination with the Simulation Management Tool 
%   (see https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/SMT/trunk)
%
%   2011-06-28: Created by A. Spruyt, Deltares
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
%
%

try 
    oetroot
catch 
    error('open earth tools not loaded');
end

fprintf('================================\n');
fprintf('combining qdb-files\n');
fprintf('================================\n\n');

if nargin<3
    discharges=[];
    if nargin<2
        targetdir = '.';
    end
end

% target directory
target = fullfile(targetdir);
disp(['target dir = ',target]);
fprintf('\n');

% groups to be appended
grps={'CURDIS','map-series','map-info-series'};

ndir = length(sourcedirs);

for i = 1:ndir
    source    = sourcedirs{i};
    disp(['(',num2str(i),'/',num2str(ndir),') ','source dir = ',source]);
    
    trimfiles = dir(fullfile(source,'qdb-*.dat'));    
    f1 = length(trimfiles);
    % Checking if number of domains is correct
    if i==1
        f0 = f1;
    else
        if f1 > f0
            disp(['*** ERROR: too many domains'])
            return
        elseif f1 < f0
            disp(['*** ERROR: not enough domains'])
            return
        end
    end
    % loop over domains
    for f = 1:f1
        disp(['   * ',trimfiles(f).name])
        domainname = trimfiles(f).name(1:end-4);
        % checking if domainnames are equal
        if i==1
            Q{f}=[];
        else
            if ~strcmpi(domainname,name{f})
                disp(['   *** WARNING: domainnames do not match (',domainname,'<>',name{f},')'])
            end
        end
        S          = vs_use(fullfile(source,trimfiles(f).name),'quiet');
        Qtemp      = vs_get(S,'CURDIS',{0},'Q',{0},'quiet');
        copyQ = [];
        
        %beginRobin
        if ~iscell(Qtemp) %when timestep=1 Qtemp is not a cell
              Qtemp={Qtemp}; %transform Qtemp into a cell
        end
        %endRobin
        
        % defining which discharges should be appended
        for j=1:length(Qtemp)
            if sum(find(Q{f}==Qtemp{j})>0)
                disp(['   *** WARNING: Discharge Q = ',num2str(Qtemp{j}),' already exists, so this one is ignored'])
            else
                if isempty(discharges) || sum(find(discharges==Qtemp{j})>0)
                    Q{f} = [Q{f},Qtemp{j}];
                    copyQ = [copyQ,j];
                else
                    disp(['   *** WARNING: Discharge Q = ',num2str(Qtemp{j}),' is not used'])
                end
            end
        end
        if i==1
            % creating new qdb-file (discharge independent part)
            name{f} = domainname;
            T{f}=vs_ini(fullfile(target,[domainname,'.dat']),fullfile(target,[domainname,'.def']));
            notgrps = grps;
            notgrps(2,:) = {[]};
            T{f}=vs_copy(S,T{f},notgrps{:},'quiet');
        end
        if ~isempty(copyQ)
            % appending to new qdb-file (discharge dependent part)
            dogrps = grps;
            dogrps(2,:) = {{copyQ}};
            T{f}=vs_copy(S,T{f},'-append','*',[],dogrps{:},'quiet');
        end
    end
end
fprintf('\n');
% Checking if all discharges are present
for i=1:length(discharges)
    for f=1:length(name)
        if isempty(find(Q{f}==discharges(i)))
            disp(['*** WARNING: Discharge Q = ',num2str(discharges(i)),' is not stored in ',name{f}])
        end
    end
end
fprintf('\n');
