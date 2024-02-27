function swan_io_mergesp2(dr,fout,varargin)
%SWAN_IO_MERGESP2  Merge multiple sp2 files into 1 sp2 file
%
%   Create one sp2-file in which sp2-files at different moments in time are merged (for wave nesting).
%
%   For nested Delft3D Wave models it is possible to specify the wave output of the outer grid as input
%   for the nested grid (specified at the boundary), using 2D wave spectra (sp2-files). For non-stationary
%   2D wave spectra (for example in a coupled Flow-Wave simulation), the sp2-files of different moments in
%   time have to be merged into one sp2-file. This function merges thr sp2-files in the directory 'dr' in a
%   sp2-file with filename 'fout'. Default coordinate system is LONLAT.
%
%   Syntax:
%   swan_io_mergesp2(dr,fout,<keyword,value>)
%
%   Input:
%   dr                      = directory containing sp2-files to be merged
%   fout                    = filename for merged sp2-file
%   fexclude    (optional)  = string-array specifying sp2-files to be excluded in directory dr
%   prefix      (optional)  = prefix of files to be merged (only sp2 files starting with prefix will be merged)
%   firstpoint  (optional)  = first spectral output point to be merged
%   lastpoint   (optional)  = last spectral output point to be merged
%   CS1         (optional)  = structure with fields code and type of coordinates system 1
%   CS2         (optional)  = structure with fields code and type of coordinates system 2
%
%   Examples
%   swan_io_mergesp2('d:\test\','test.sp2')
%   swan_io_mergesp2('d:\test\','test.sp2','CS1',CS1,'CS2',CS2)
%       with CS1.code = 32631, CS1.type = 'xy', CS2.code = 4326, CS2.type = 'geo'
%   swan_io_mergesp2('d:\test\','test.sp2','fexclude',{'nest_t1.sp2','nest_t2.sp2'})
%   swan_io_mergesp2('d:\test\','test.sp2','prefix','csm'})
%   swan_io_mergesp2('d:\test\','test.sp2','firstpoint',5,'lastpoint',10})
%
%   See also SWAN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Wiebe de Boer (based on function of Maarten van Ormondt)
%
%       wiebe.deboer@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 07 Oct 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: swan_io_mergesp2.m 15133 2019-02-07 10:49:31Z nederhof $
% $Date: 2019-02-07 18:49:31 +0800 (Thu, 07 Feb 2019) $
% $Author: nederhof $
% $Revision: 15133 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_io_mergesp2.m $
% $Keywords: $

%% Set <keyword, value>
OPT.fexclude    = '';
OPT.CS1 = struct;
OPT.CS2 = struct;
OPT.prefix = [];
OPT.firstpoint = [];
OPT.lastpoint = [];
OPT = setproperty(OPT,varargin{:});

if nargin==0;
    disp('Please specify directory name of sp2 files and output file name')
    return;
end
%% code

% Set coordinate conversion
convc = 0;
if isfield(OPT.CS1,'code') && isfield(OPT.CS2,'code')
    convc =1;
end
if isfield(OPT.CS1,'name') && isfield(OPT.CS2,'name')
    convc =1;
end
if isfield(OPT.CS1,'type') && isfield(OPT.CS2,'type')
    convc =1;
end

% Add file separator to folder name
if ~isempty(dr)
    if ~strcmpi(dr(end),filesep)
        dr=[dr filesep];
    end
end

lst=dir([dr OPT.prefix '*.sp2']);
n=length(lst);

% Omit sp2-files (if set)
if ~isempty(OPT.fexclude)
    ids = 1:n;
    for ii=1:n
        names{ii} = lst(ii).name;
    end
    for jj=1:length(OPT.fexclude)
        [TF,id(jj)] = ismember(OPT.fexclude{jj},names);
    end
    lst = lst(~ismember(ids,id));
    n=length(lst);
end

fi2=fopen(fout,'wt');

% Read sp2-files
for i=1:n
    
    fname=lst(i).name;
    fid=fopen([dr fname],'r');
    
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    CS = strtrim(f(1:12));
    
    f=fgetl(fid);
    
    spec.nPoints=str2double(f(1:12));
    
    for j=1:spec.nPoints
        f=fgetl(fid);
        [spec.x(j) spec.y(j)]=strread(f);
    end
    
    if convc
        if isfield(OPT.CS1,'code') && isfield(OPT.CS2,'code')
            [spec.x,spec.y]=convertCoordinates(spec.x,spec.y,'persistent','CS1.code',OPT.CS1.code,'CS2.code',OPT.CS2.code);
        else
            [spec.x,spec.y]=convertCoordinates(spec.x,spec.y,'persistent','CS1.name',OPT.CS1.name,'CS1.type',OPT.CS1.type, ...
                'CS2.name',OPT.CS2.name,'CS2.type',OPT.CS2.type);
        end
    end
    
    f=fgetl(fid);
    
    f=fgetl(fid);
    spec.nFreq=str2double(f(1:12));
    
    for j=1:spec.nFreq
        f=fgetl(fid);
        spec.freqs(j)=strread(f);
    end
    
    f=fgetl(fid);
    
    f=fgetl(fid);
    spec.nDir=str2double(f(1:12));
    
    for j=1:spec.nDir
        f=fgetl(fid);
        spec.dirs(j)=strread(f);
    end
    
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    
    f=fgetl(fid);
    f=f(1:15);
    
    it=1;
    
    spec.time(it).time=datenum(f,'yyyymmdd.HHMMSS');
    
    nbin=spec.nDir*spec.nFreq;
    
    for j=1:spec.nPoints
        f=fgetl(fid);
        deblank(f);
        if strcmpi(deblank(f),'factor')
            try
                f=fgetl(fid);
                spec.time(it).points(j).factor=strread(f);
                data=textscan(fid,'%f',nbin);
                data=data{1};
                data=reshape(data,spec.nDir,spec.nFreq);
                data=data';
                spec.time(it).points(j).energy=data;
                f=fgetl(fid);
            catch
                spec.time(it).points(j).factor=0;
                spec.time(it).points(j).energy=0;
            end
        else
            spec.time(it).points(j).factor=0;
            spec.time(it).points(j).energy=0;
        end
    end
    
    % Write to merged sp2-file
    if i==1
        fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
        fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
        fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
        fprintf(fi2,'%s\n','TIME                                    time-dependent data');
        fprintf(fi2,'%s\n','     1                                  time coding option');
        if convc
            switch lower(OPT.CS2.type)
                case{'proj','projection','projected','cart','cartesian','xy'}
                    fprintf(fi2,'%s\n','LOCATIONS');
                otherwise
                    fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
            end
        elseif strcmp(CS,'LOCATIONS')
            fprintf(fi2,'%s\n','LOCATIONS');
        else
            fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
        end
        if isempty(OPT.firstpoint)
            i1=1;
        else
            i1=OPT.firstpoint;
        end
        if isempty(OPT.lastpoint)
            i2=spec.nPoints;
        else
            i2=OPT.lastpoint;
        end
        fprintf(fi2,'%i\n',i2-i1+1);
        for j=i1:i2
            fprintf(fi2,'%15.6f %15.6f\n',spec.x(j),spec.y(j));
        end
        fprintf(fi2,'%s\n','AFREQ                                   absolute frequencies in Hz');
        fprintf(fi2,'%6i\n',spec.nFreq);
        for j=1:spec.nFreq
            fprintf(fi2,'%15.4f\n',spec.freqs(j));
        end
        fprintf(fi2,'%s\n','NDIR                                   spectral nautical directions in degr');
        fprintf(fi2,'%i\n',spec.nDir);
        for j=1:spec.nDir
            fprintf(fi2,'%15.4f\n',spec.dirs(j));
        end
        fprintf(fi2,'%s\n','QUANT');
        fprintf(fi2,'%s\n','     1                                  number of quantities in table');
        fprintf(fi2,'%s\n','EnDens                                  energy densities in J/m2/Hz/degr');
        fprintf(fi2,'%s\n','J/m2/Hz/degr                            unit');
        fprintf(fi2,'%s\n','   -0.9900E+02                          exception value');
    end
    
    fprintf(fi2,'%s\n',datestr(spec.time(it).time,'yyyymmdd.HHMMSS'));
    for j=i1:i2
        if spec.time(it).points(j).factor>0
            fprintf(fi2,'%s\n','FACTOR');
            fprintf(fi2,'%18.8e\n',spec.time(it).points(j).factor);
            fmt=repmat([repmat('  %7i',1,spec.nDir) '\n'],1,spec.nFreq);
            fprintf(fi2,fmt,spec.time(it).points(j).energy');
        else
            fprintf(fi2,'%s\n','NODATA');
        end
    end
    fclose(fid);
end
fclose(fi2);
