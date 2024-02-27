function delft3d_trim2ini(mdffile,time,fileOut,varargin)
%DELFT3D_TRIM2INI Convert field of trim file to .ini file and possibly also
%.sdb-files or .thk and .frc files
%
%If one wants to edit restarts it is convient to convert the timestep of
%the trim file from which one wants to restart into .ini file and .sdb 
%sediment masses or .thk and .frc files with respectively layer thicknesses
%and mass fractions. This function does so. At this moment only water levels,
%velocities, salinities, temperatures, constituents and secondary flow can 
%be written to .ini file. 
%The depths at the boundary in the .dep file are equal to the depths in the
%.dep file that is associated with mdffile. 
%
%Syntax:
%  delft3d_trim2ini(mdffile,time,fileOut,<keyword>,<value>)
%
%Input:
%   mdffile = [string] filepath of .mdf file of the simulation used to
%   generate the restart files.
%   time    = [datenum] time in the simulation which is used to generate
%   the restart files
%   fileOut = [string] filepath of the output .ini file. .sdb., .dep, .frc
%   and .thk files are generated using the same filename.
%   
%Keywords:
%   sedmode = if it is a morphological simulation indicate whether to write
%   .sdb files ('sdb') or .thk and .frc files ('thk' or 'frc') or no
%   sediment files ('none')
%   skip_constituent = [1xn double] do NOT copy the constituents in with these numbers. 
%
%Example
%     delft3d_trim2ini('c:\mysim1\mysim.mdf',datenum('2012-01-01'),...
%    'c:\mysim2\mysim.ini','sedmode','frc'); 
%     will generate in c:\mysim2 mysim.ini, mysim_ini.dep, mysim_L1F1.sdb,
%     mysim_L1F2.sdb,...,mysim_L2F1.sdb,...
%     Here L gives the sedimentlayer and F the sediment fraction
%
% BETA VERSION. The number of constituents that can be processed is limited to 3. 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl	
%
%       Arcadis Zwolle
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
% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id: delft3d_trim2ini.m 14490 2018-07-11 02:04:00Z r.measures.x $
% $Date: 2018-07-11 10:04:00 +0800 (Wed, 11 Jul 2018) $
% $Author: r.measures.x $
% $Revision: 14490 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/delft3d_trim2ini.m $
% $Keywords: $

%% Preprocessing


OPT.sedmode='sdb';
OPT.skip_constituent=[]; 

%set <keyword>,<values>
OPT=setproperty(OPT,varargin);

%% Open files

[fPath fName fExt]=fileparts(mdffile)

%open .mdf file
mdf=delft3d_io_mdf('read',mdffile); 
sub1=mdf.keywords.sub1;

%read trim file into matlab
nefis=fullfile(fPath,sprintf('trim-%s.def',fName));
nefis=vs_use(nefis,'quiet'); 
elements={nefis.ElmDef(:).Name}; 

%% Find time step

%load all timesteps
t=vs_time(nefis); t=t.datenum;

%find timestep closest to time
if ~isempty(time)
    if time<t(1) | time>t(end)
        warning('warning: time outside simulated interval. Using first/last time step.');
    end
    timestep=find( abs(t-time)==min(abs(t-time)) ,1); 
else
    timestep=length(t);
end %end if isempty(time)

%% Read data from nefis file

data=struct(); 

%Water level
if ismember('S1',elements)
    data.waterlevel=vs_let(nefis,'map-series',{timestep},'S1','quiet');
    %permute necessary for delft3d_io_ini
    data.waterlevel=permute( squeeze(data.waterlevel),[2 1]); 
else
    error('No water level in trim file'); 
end

%u-velocity
if ismember('U1',elements)
    data.u=vs_let(nefis,'map-series',{timestep},'U1','quiet'); 
    %permute necessary for delft3d_io_ini
    data.u=permute( squeeze(data.u), [2 1 3]); 
else
    error('No u-velocity in trim file');
end

%v-velocity
if ismember('V1',elements)
    data.v=vs_let(nefis,'map-series',{timestep},'V1','quiet');
    %permute necessary for delft3d_io_ini
    data.v=permute( squeeze(data.v), [2 1 3]); 
else
    error('No v-velocity in trim file');
end

%salinity, temperature, constituents
flag=0; 
if ismember('R1',elements)
    %read
    r1=vs_let(nefis,'map-series',{timestep},'R1','quiet');
    
    %reshape so that r1 is always 5D
    mnkmax=mdf.keywords.mnkmax;
    r1=reshape(r1,1,mnkmax(2),mnkmax(1),mnkmax(3),[]); 
    %permute necessary for delft3d_io_ini
    r1=permute(r1,[1 3 2 4 5]); 
    namcon=cellstr(vs_get(nefis,'map-const','NAMCON'));
end

%salinity
if sum(sub1=='S')>0
    flag=flag+1;
    data.salinity=squeeze(r1(:,:,:,:,flag));
end

%temperature
if sum(sub1=='T')>0
    flag=flag+1;
    data.temperature=squeeze( r1(:,:,:,:,flag) );
end

%constituents
for k=1:3
    if isfield(mdf.keywords,sprintf('namc%d',k)) & sum(k==OPT.skip_constituent)==0
        flag=flag+1; 
        data.(sprintf('%s%d','constituent',k))=squeeze(r1(:,:,:,:,flag)); 
    end
end

%secondary flow
if sum(sub1=='I')>0
    flag=flag+1;
    if ~strcmp(namcon{flag},'Secondary flow')
        warning('warning: Secondary flow missing from trim file.');
    end
    data.secondaryflow=squeeze( r1(:,:,:,:,flag) );
end

%morphology
if ismember('map-sed-series',{nefis.CelDef(:).Name})
   %Morphological simulation
   
   grd=delft3d_io_grd('read',mdf.keywords.filcco);
   dep=delft3d_io_dep('read',mdf.keywords.fildep,grd,'location','cor','dpsopt',lower(mdf.keywords.dpsopt));
   msed=vs_let_scalar(nefis,'map-sed-series',{timestep},'MSED','quiet'); 
   thk=vs_let_scalar(nefis,'map-sed-series',{timestep},'THLYR','quiet'); 
   dps=vs_let_scalar(nefis,'map-sed-series',{timestep},'DPS','quiet'); 
   
else

   OPT.sedmode='none';
   
end

%% Write ini file

delft3d_io_ini('write',fileOut,data); 

%% Write .sdb files


if strcmpi(OPT.sedmode,'sdb') 

    smsed=size(msed)
    msed=reshape(msed,1,max(mnkmax(2)-2,1),max(mnkmax(1)-2,1),[],smsed(end));
    smsed=size(msed);
    msed=max(msed,0); 
   
    %Write .sdb files
    for k=1:smsed(end-1)
        for l=1:smsed(end)
            delft3d_io_dep('write',sprintf('%s_L%dF%d.sdb',fName,k,l),squeeze(msed(1,:,:,k,l)),'location','cen'); 
        end %end for l
    end %end for k
    
elseif strcmpi(OPT.sedmode,'thk') || strcmpi(OPT.sedmode,'frc')
   
    smsed=size(msed);
	msed=reshape(msed,1,max(mnkmax(2)-2,1),max(mnkmax(1)-2,1),[],smsed(end));
	smsed=size(msed);
    thk=reshape(thk,1,max(mnkmax(2)-2,1),max(mnkmax(1)-2,1),[]);
    thk=max(thk,0); 
	
   
    %Write .thk and .frc files
    for k=1:smsed(end-1)
		%write .thk
        delft3d_io_dep('write',sprintf('%s_L%d.thk',fName,k),squeeze(thk(1,:,:,k)),'location','cen');
        
		%write .frc
		msedtot=sum(msed(1,:,:,k,:),5);
		frctot=ones(max(mnkmax(2)-2,1),max(mnkmax(1)-2,1));
		if smsed(end)>1
			for l=1:smsed(end)-1
				frc=round(squeeze(msed(1,:,:,k,l))./squeeze(msedtot)*1e3)*1e-3;
				frc=min(frc,frctot); 
				delft3d_io_dep('write',sprintf('%s_L%dF%d.frc',fName,k,l),frc,'location','cen'); 
				frctot=frctot-frc; 
			end %end for l
		else
			l=0;
		end %end if     
		delft3d_io_dep('write',sprintf('%s_L%dF%d.frc',fName,k,l+1),frctot,'location','cen'); 	
		
    end %end for k
    
elseif strcmpi(OPT.sedmode,'none')
    %no sediment files are written
    
else
    
    error('value of keyword sedmode is invalid.'); 
    
end %end if OPT.sedmode
   
%% Write .dep file

if ~strcmpi(OPT.sedmode,'none')
    
    dps=center2corner(dps); 
    dep.cor.dep(2:end-1,2:end-1)=dps(2:end-1,2:end-1); 
    delft3d_io_dep('write',[fName,'_ini.dep'],dep.cor.dep,'location','cor'); 
end %end if OPT.sedmode~='none'  


end %end function delft3d_trim2ini