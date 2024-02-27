function varargout = delft3D_trim2com(oricom, newcom, t0, t1, reftime, varargin)
%DELF3D_TRIM2COM  Makes Delft3D-WAVE communication file from Delft3D-FLOW trim file.
%
% This script converts a Delft3D FLOW trim file to a communication file that can be
% used for Delft3D-WAVE, including wind, water levels and current fields
% and all the necessary grid parameters (dry points etc.) necessary for
% WAVE.
%
% Besides the varargin needed the nefis file and datafolder below also need
% to be specified (lines 43, 44).
%
% This example is for a multi-domain model. In line 456 certain parameters
% are read from a mat file that has the combined parameters from multiple
% com files - this part still needs to be integrated into the script so
% for now this mat file has to be made manually and the path changed in
% Line 460 - ask Katherine Cronin if questions.
%
% Example inputs:
%
% oricom = original com file to be read as a template
% oricom=['p:\1000229-pace\hydrodynamica\dws_200m_v6\dws_200m_v6_2009_02\com\com-dws_200m_v6_2009_02-001.dat'];
% newcom = the name and path of the new com file to be written
% newcom=['p:\1000229-pace\hydrodynamica\dws_200m_v6\dws_200m_v6_2009_02\com-dws_200m_v6_2009_02.dat']; 
% t0=[datenum(2009,02,1,00,00,00)];
% t1=[datenum(2009,03,1,00,00,00)];
% reftime=[datenum(2009,02,1,00,00,00)];
%
%
% TO DO
%
% 1. Integrate a function for reading combining the necessary grid
% parameters from multiple com files
% 
%
%   Syntax:
%   varargout = delf3d_trim2com(varargin)
%
%   Input: For <keyword,value> pairs call delf3d_trim2com() without arguments.
%   varargin  = oricom, newcom, t0, t1, reftime
%
%   Output:
%   varargout =
%
%   Example
%   delf3d_trim2com
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <Deltares>
%
%        Katherine Cronin
%
%       <katherine.cronin@deltares.nl>
%
%       Deltares
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
% Created: 25 Apr 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: delft3d_trim2com.m 10601 2014-04-25 08:51:15Z cronin $
% $Date: 2014-04-25 16:51:15 +0800 (Fri, 25 Apr 2014) $
% $Author: cronin $
% $Revision: 10601 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/delft3d_trim2com.m $
% $Keywords: $

OPT.trimdat    = '';
OPT.trimdef    = '';
OPT.datafolder = '';

if nargin==0
  varargout  = {OPT};
  return
end

OPT = setproperty(OPT,varargin)

%% Get input arguments

nefis      = vs_use(OPT.trimdat,OPT.trimdef); 
datafolder = '';
dataname   = '';
mdffile    = '';

% time definition

tms=t0:1/24:t1;
nt=length(tms);

tms=tms-reftime;
tms=tms*1440;
timcur=tms;


cs.Name='WGS 84';
cs.Type='geographic';


%% Original com file
[dr,nm,ext]=fileparts(oricom);
% Read file
if isempty(dr)
    dr='.';
end
f0 = vs_use([dr filesep nm '.dat'],[dr filesep nm '.def']); %

% Determine grid size using the trim file (not original com file)

t=vs_time(nefis); t=t.datenum;

elements_trim={nefis.ElmDef(:).Name}; 
elements_oricom={f0.ElmDef(:).Name};

mmax=vs_let(nefis,'map-const',{1},'MMAX');
nmax=vs_let(nefis,'map-const',{1},'NMAX');
kmax=vs_let(nefis,'map-const',{1},'KMAX');

% Corner points
xcor=squeeze(vs_let(nefis,'map-const',{1},'XCOR'));
ycor=squeeze(vs_let(nefis,'map-const',{1},'YCOR'));
ycor(ycor==0)=NaN;
xcor(isnan(ycor))=NaN;
if ~strcmpi(cs.Name,'WGS 84') || ~strcmpi(cs.Type,'geographic')
    xcorproj=xcor;
    ycorproj=ycor;
    [xcor,ycor]=convertCoordinates(xcor,ycor,'persistent','CS1.name',cs.Name,'CS1.type',cs.Type,'CS2.name','WGS 84','CS2.type','geographic');
end
xcor=mod(xcor,360);

% Z points
[xz,yz]=getXZYZ(xcor,ycor);

thck=vs_let(nefis,'map-const',{1},'THICK');
dps=squeeze(vs_let(nefis,'map-const',{1},'DPS0')); % NB need to check this is the right parameter!

dplayer=getLayerDepths(dps,thck*100);

% U points
xu=zeros(nmax,mmax);
yu=xu;
dx=xu;
dy=xu;
dxu=xu;
dpu=xu;
xu(2:end-1,1:end-1)=0.5*(xcor(1:end-2,1:end-1)+xcor(2:end-1,1:end-1));
yu(2:end-1,1:end-1)=0.5*(ycor(1:end-2,1:end-1)+ycor(2:end-1,1:end-1));
dx(2:end-1,1:end-1)=xcor(2:end-1,1:end-1)-xcor(1:end-2,1:end-1);
dy(2:end-1,1:end-1)=ycor(2:end-1,1:end-1)-ycor(1:end-2,1:end-1);
dx(2:end-1,1:end-1)=dx(2:end-1,1:end-1).*cos(180*pi*yu(2:end-1,1:end-1));
alphau=atan2(dy,dx)-0.5*pi; % grid angle  
dxu(2:end-1,1:end-1)=sqrt(dx(2:end-1,1:end-1).^2+dy(2:end-1,1:end-1).^2); % what does dxu represent?
dxu=dxu*111111; %%??
dpu(2:end-1,1)=dps(2:end-1,2); % bed level at the u points 
dpu(2:end-1,end-1)=dps(2:end-1,end-1);
dpu(2:end-1,2:end-2)=0.5*(dps(2:end-1,2:end-2)+dps(2:end-1,3:end-1));
% V points
xv=zeros(nmax,mmax);
yv=xv;
dx=xv;
dy=xv;
dxv=xu;
dpv=xu;
xv(1:end-1,2:end-1)=0.5*(xcor(1:end-1,1:end-2)+xcor(1:end-1,2:end-1));
yv(1:end-1,2:end-1)=0.5*(ycor(1:end-1,1:end-2)+ycor(1:end-1,2:end-1));
dx(1:end-1,2:end-1)=xcor(1:end-1,2:end-1)-xcor(1:end-1,1:end-2);
dy(1:end-1,2:end-1)=ycor(1:end-1,2:end-1)-ycor(1:end-1,1:end-2);
dx(1:end-1,2:end-1)=dx(1:end-1,2:end-1).*cos(180*pi*yv(1:end-1,2:end-1));
alphav=atan2(dy,dx)+0.5*pi;
dxv(1:end-1,2:end-1)=sqrt(dx(1:end-1,2:end-1).^2+dy(1:end-1,2:end-1).^2);
dxv=dxv*111111;
dpv(1,2:end-1)=dps(2,2:end-1);
dpv(end-1,2:end-1)=dps(end-1,2:end-1);
dpv(2:end-2,2:end-1)=0.5*(dps(2:end-2,2:end-1)+dps(3:end-1,2:end-1));

% switching nans to -999;
xcor(isnan(xcor))=-999;
ycor(isnan(ycor))=-999;
xu(isnan(xu))=-999;
yu(isnan(yu))=-999;
xv(isnan(xv))=-999;
yv(isnan(yv))=-999;
xz(isnan(xz))=-999;
yz(isnan(yz))=-999;


%% Make new com file
[dr nm ext]=fileparts(newcom);
if isempty(dr)
    dr='.';
end
vs_ini([dr filesep nm '.dat'],[dr filesep nm '.def'], 'version', 5);
f=vs_use([dr filesep nm '.dat'],[dr filesep nm '.def']);
f.SubType = 'Delft3D-com';

% loop over the number of groups
wavegroups = {'INITBOT','KENMNT','CURTIM','CURNT','KENMTIM','GRID','PARAMS','WIND', 'KENMCNST', 'TEMPOUT'};
  
for w = 1:length(wavegroups)

    % find index in CelDef
    for k = 1:length(f0.CelDef);  
      
    IndexCelDef = find(strmatch(wavegroups{w}, f0.CelDef(1,k).Name, 'exact'));
   
    if ~isempty(IndexCelDef),  IndexCelDef = k;  IndexElmDef = f0.CelDef(1,k).Elm; break, end
   
    end
   
    % find index in GrpDef
    for k = 1:length(f0.GrpDef);  
      
    IndexGrpDef = find(strmatch(wavegroups{w}, f0.GrpDef(1,k).Name, 'exact'));
   
    if ~isempty(IndexGrpDef),  IndexGrpDef = k; break, end
  
    end
  
   % find index in GrpDat
   for k = 1:length(f0.GrpDat);  
     
   IndexGrpDat = find(strmatch(wavegroups{w}, f0.GrpDat(1,k).Name, 'exact'));
   
   if ~isempty(IndexGrpDat),  IndexGrpDat = k; break, end
  
   end
 
   % needs a dimension to read in quickplot
   
   for d = 1:length(f.GrpDef)
           f.GrpDef(1,d).SizeDim = 1;
   end

%% Define Elements for com file

for i=1:length(IndexElmDef)
   % sz=f0.ElmDef(IndexElmDef(i)).Size;
     
    sz=length(f0.ElmDef(IndexElmDef(i)).Size);
            switch sz
                case 1
                    szcell={1:f0.ElmDef(IndexElmDef(i)).Size(1)};
                    szcells = [length(szcell{1,1})];
                case 2
                    szcell={1:f0.ElmDef(IndexElmDef(i)).Size(1) 1:mmax};
                    szcells = [length(szcell{1,1}), length(szcell{1,2})];
                case 3
                    szcell={1:f0.ElmDef(IndexElmDef(i)).Size(1) 1:mmax 1:f0.ElmDef(IndexElmDef(i)).Size(3)};
                    szcells = [length(szcell{1,1}), length(szcell{1,2}), length(szcell{1,3})];
                case 4
                    szcell={1:f0.ElmDef(IndexElmDef(i)).Size(1) 1:mmax  1:f0.ElmDef(IndexElmDef(i)).Size(3)  1:f0.ElmDef(IndexElmDef(i)).Size(4)};
                    szcells = [length(szcell{1,1}), length(szcell{1,2}), length(szcell{1,3}), length(szcell{1,4})];
            end
   
        
     
    f = vs_def(f,'elm',f0.ElmDef(IndexElmDef(i)).Name,f0.ElmDef(IndexElmDef(i)).Type,f0.ElmDef(IndexElmDef(i)).SizeVal, ...
        szcells,f0.ElmDef(IndexElmDef(i)).Quantity,f0.ElmDef(IndexElmDef(i)).Units,f0.ElmDef(IndexElmDef(i)).Description);
end

for i=1:length(IndexCelDef)
    elements=[];
    for j=1:length(f0.CelDef(IndexCelDef(i)).Elm)
        iel=f0.CelDef(IndexCelDef(i)).Elm(j);
        elements{j}=f0.ElmDef(iel).Name;
       % f = vs_def(f,'cell',f0.CelDef(i).Name,elements{j});
    end
%     if length(elements)==1
%         elements=elements{1};
%     end
     f = vs_def(f,'cell',f0.CelDef(IndexCelDef(i)).Name,elements{1:j});
end

for i=1:length(IndexGrpDef)
    f = vs_def(f,'grp',f0.GrpDef(IndexGrpDef(i)).Name,f0.CelDef(IndexCelDef(i)).Name,0);
end

for i=1:length(IndexGrpDat)
    f = vs_def(f,'data',f0.GrpDat(IndexGrpDat(i)).Name,f0.GrpDat(IndexGrpDat(i)).DefName);
end

for k=1:length(f0.GrpDat)
    groups{k}=f0.GrpDat(k).Name;
end   
  
   
end  
                 
%% ADD DATA TO NEW COM FILE. NOTE! This example is for a multi-domain simulation

%% Read relevant data from nefis file
% trim file is for the whole domain - whereas com files are per domain...

for i = 1:length(tms) %;

    %Water level
    if ismember('S1',elements_trim)
        trim.S1.data=vs_let(nefis,'map-series',{i},'S1','quiet');
        %permute necessary for delft3d_io_ini
        trim.S1.data=permute( squeeze(trim.S1.data),[2 1]); 
        trim.S1.data = (trim.S1.data)';
        trim.S1.Id = 'S1';
        trim.S1.size = size(trim.S1.data);
    else
        error('No water level in trim file'); 
    end

    %u-velocity
    if ismember('U1',elements_trim)
        trim.U1.data=vs_let(nefis,'map-series',{i},'U1','quiet'); 
        %permute necessary for delft3d_io_ini
        trim.U1.data=permute( squeeze(trim.U1.data), [1 2 3]); 
        trim.U1.Id = 'U1';
    else
        error('No u-velocity in trim file');
    end

    %v-velocity
    if ismember('V1',elements_trim)
        trim.V1.data=vs_let(nefis,'map-series',{i},'V1','quiet');
        %permute necessary for delft3d_io_ini
        trim.V1.data=permute( squeeze(trim.V1.data), [1 2 3]);
        trim.V1.Id = 'V1';
    else
        error('No v-velocity in trim file');
    end

    % non active/active u points
    if ismember('KFU', elements_trim)
        trim.KFU.data=vs_let(nefis, 'map-series',{i}, 'KFU', 'quiet');
        trim.KFU.data=permute( squeeze(trim.KFU.data),[2 1]);
        trim.KFU.data = (trim.KFU.data)';
        trim.KFU.Id = 'KFU';
    else
        error('No kfu in trim file');
    end 

    % non-active/active v points
    if ismember('KFV', elements_trim)
        trim.KFV.data=vs_let(nefis, 'map-series',{i}, 'KFV', 'quiet');
        trim.KFV.data=permute( squeeze(trim.KFV.data),[2 1]);
        trim.KFV.data = (trim.KFV.data)';
        trim.KFV.Id = 'KFV';
    else
        error('No kfv in trim file');
    end

   %  WIND U  
    if ismember('WINDU', elements_trim)
        trim.WINDU.data=vs_let(nefis, 'map-series',{i}, 'WINDU', 'quiet');
        trim.WINDU.data=permute( squeeze(trim.WINDU.data),[2 1]);
        trim.WINDU.data= (trim.WINDU.data)';
        trim.WINDU.Id = 'WINDU';
    else
        error('No WINDU in trim file');
    end  
    
    % WIND V
    if ismember('WINDV', elements_trim)
        trim.WINDV.data=vs_let(nefis, 'map-series',{i}, 'WINDV', 'quiet');
        trim.WINDV.data=permute( squeeze(trim.WINDV.data),[2 1]);
        trim.WINDV.data= (trim.WINDV.data)';
        trim.WINDV.Id = 'WINDV';
    else
        error('No WINDV in trim file');
    end   
      
    time = timcur(i);
    
    % Putting the data into the NEFIS file
    
   
    vs_put(f,'CURTIM',{i},'U1',{1:nmax 1:mmax 1:kmax},trim.U1.data); 
    vs_put(f,'CURTIM',{i},'V1',{1:nmax 1:mmax 1:kmax},trim.V1.data);
    vs_put(f,'CURTIM',{i},'S1',{1:nmax 1:mmax},trim.S1.data);
    vs_put(f,'KENMTIM',{i},'KFU',{1:nmax 1:mmax},trim.KFU.data);
    vs_put(f,'KENMTIM',{i},'KFV',{1:nmax 1:mmax},trim.KFV.data);
    vs_put(f,'WIND',{i},'WINDU', {1:nmax 1:mmax},trim.WINDU.data);
    vs_put(f,'WIND',{i},'WINDV', {1:nmax 1:mmax},trim.WINDV.data);
    vs_put(f,'WIND',{i},'TIMCUR', {1},time);
    vs_put(f,'CURTIM',{i},'TIMCUR',{1},time);
    vs_put(f,'KENMTIM',{i},'TIMCUR',{1},time);
   

    
end % end of time loop

    % non active/active u points


    if ismember('DP0', elements_trim) %1
        trim.DP0.data=vs_let(nefis, 'map-const',{1}, 'DP0', 'quiet');
        trim.DP0.data=permute( squeeze(trim.DP0.data),[2 1]);
        trim.DP0.data = (trim.DP0.data)';
        trim.DP0.Id = 'DP0';
    else
        error('No DP0 in trim file');
    end
    
    if ismember('DPS0', elements_trim) %2
        trim.DPS0.data=vs_let(nefis, 'map-const',{1}, 'DPS0', 'quiet');
        trim.DPS0.data=permute( squeeze(trim.DPS0.data),[2 1]);
        trim.DPS0.data = (trim.DPS0.data)';
        trim.DPS0.Id = 'DPS0';
    else
        error('No DPS0 in trim file');
    end
    
    if ismember('XCOR', elements_trim) %3
        trim.XCOR.data=vs_let(nefis, 'map-const',{1}, 'XCOR', 'quiet');
        trim.XCOR.data=permute( squeeze(trim.XCOR.data),[2 1]);
        trim.XCOR.data = (trim.XCOR.data)';
        trim.XCOR.Id = 'XCOR';
    else
        error('No XCOR in trim file');
    end     
    
        if ismember('YCOR', elements_trim) %4
        trim.YCOR.data=vs_let(nefis, 'map-const',{1}, 'YCOR', 'quiet');
        trim.YCOR.data=permute( squeeze(trim.YCOR.data),[2 1]);
        trim.YCOR.data = (trim.YCOR.data)';
        trim.YCOR.Id = 'YCOR';
    else
        error('No YCOR in trim file');
        end  
   
    if ismember('MMAX', elements_trim) %5
        trim.MMAX.data=vs_let(nefis, 'map-const',{1}, 'MMAX', 'quiet');
        trim.MMAX.data=permute( squeeze(trim.MMAX.data),[2 1]);
        trim.MMAX.data = (trim.MMAX.data)';
        trim.MMAX.Id = 'MMAX';
    else
        error('No MMAX in trim file');
    end
        
    if ismember('NMAX', elements_trim)%6
        trim.NMAX.data=vs_let(nefis, 'map-const',{1}, 'NMAX', 'quiet');
        trim.NMAX.data=permute( squeeze(trim.NMAX.data),[2 1]);
        trim.NMAX.data = (trim.NMAX.data)';
        trim.NMAX.Id = 'NMAX';
    else
        error('No NMAX in trim file');
    end
        
    if ismember('KMAX', elements_trim)%7
        trim.KMAX.data=vs_let(nefis, 'map-const',{1}, 'KMAX', 'quiet');
        trim.KMAX.data=permute( squeeze(trim.KMAX.data),[2 1]);
        trim.KMAX.data = (trim.KMAX.data)';
        trim.KMAX.Id = 'KMAX';
    else
        error('No KMAX in trim file');
    end
        
        if ismember('COORDINATES', elements_trim)%8
        trim.COORDINATES.data=vs_let(nefis, 'map-const',{1}, 'COORDINATES', 'quiet');
        trim.COORDINATES.data=permute( squeeze(trim.COORDINATES.data),[2 1]);
        trim.COORDINATES.data = (trim.COORDINATES.data)';
        trim.COORDINATES.Id = 'COORDINATES';
    else
        error('No COORDINATES in trim file');
        end         
        
        if ismember('THICK', elements_trim)%9
        trim.THICK.data=vs_let(nefis, 'map-const',{1}, 'THICK', 'quiet');
        trim.THICK.data=permute( squeeze(trim.THICK.data),[2 1]);
        trim.THICK.data = (trim.THICK.data)';
        trim.THICK.Id = 'THICK';
    else
        error('No THICK in trim file');
        end         
% 
        if ismember('ALFAS', elements_trim)%9
        trim.ALFAS.data=vs_let(nefis, 'map-const',{1}, 'ALFAS', 'quiet');
        trim.ALFAS.data=permute( squeeze(trim.ALFAS.data),[2 1]);
        trim.ALFAS.data = (trim.ALFAS.data)';
        trim.ALFAS.Id = 'ALFAS';
    else
        error('No ALFAS in trim file');
        end       
 
        if ismember('KCS', elements_trim)%9
        trim.KCS.data=vs_let(nefis, 'map-const',{1}, 'KCS', 'quiet');
        trim.KCS.data=permute( squeeze(trim.KCS.data),[2 1]);
        trim.KCS.data = (trim.KCS.data)';
        trim.KCS.Id = 'KCS';
    else
        error('No KCS in trim file');
        end 

        if ismember('KCU', elements_trim)%9
        trim.KCU.data=vs_let(nefis, 'map-const',{1}, 'KCU', 'quiet');
        trim.KCU.data=permute( squeeze(trim.KCU.data),[2 1]);
        trim.KCU.data = (trim.KCU.data)';
        trim.KCU.Id = 'KCU';
    else
        error('No KCU in trim file');
        end 

        
        if ismember('KCV', elements_trim)%9
        trim.KCV.data=vs_let(nefis, 'map-const',{1}, 'KCV', 'quiet');
        trim.KCV.data=permute( squeeze(trim.KCV.data),[2 1]);
        trim.KCV.data = (trim.KCV.data)';
        trim.KCV.Id = 'KCV';
    else
        error('No KCV in trim file');
        end 
        
        
 % from concatenated file as from a multi-domain model
 % a mat file is needed with the parameters below combined from each com
 % file produced from the multi-domain run.
        
 
 comparameters = load('concatenated_com_parameters.mat');        

     if ismember('XWAT', elements_oricom)%10
        trim.XWAT.data = comparameters.trim.XWAT.data.total;
        trim.XWAT.Id = 'XWAT';
    else
        error('No XWAT in trim file');
     end 
%     
     if ismember('YWAT', elements_oricom)%11
        trim.YWAT.data = comparameters.trim.YWAT.data.total;
        trim.YWAT.Id = 'YWAT';
    else
        error('No YWAT in trim file');
     end 
     
     if ismember('CODB', elements_oricom)%11
        trim.CODB.data = comparameters.trim.CODB.data.total;
        trim.CODB.Id = 'CODB';
    else
        error('No CODB in trim file');
     end 
     
          
     if ismember('CODW', elements_oricom)%11
        trim.CODW.data = comparameters.trim.CODW.data.total;
        trim.CODW.Id = 'CODW';
    else
        error('No CODW in trim file');
     end 
     
     
    if ismember('GUU', elements_oricom)%12
        trim.GUU.data = comparameters.trim.GUU.data.total;
        trim.GUU.Id = 'GUU';
    else
        error('No GUU in trim file');
    end 
     
    if ismember('GVV', elements_oricom)%13
        trim.GVV.data = comparameters.trim.GVV.data.total;
        trim.GVV.Id = 'GVV';
    else
        error('No GVV in trim file');
    end 

    %% write out
    
    vs_put(f,'INITBOT',{1},'DP0',{1:nmax 1:mmax},trim.DP0.data);%1
    vs_put(f,'INITBOT',{1},'DPS',{1:nmax 1:mmax},trim.DPS0.data);%2
    vs_put(f,'GRID',{1},'XCOR',{1:nmax 1:mmax},trim.XCOR.data);%3
    vs_put(f,'GRID',{1},'YCOR',{1:nmax 1:mmax},trim.YCOR.data);%4
    vs_put(f,'GRID',{1},'COORDINATES',{1},trim.COORDINATES.data);%5
    vs_put(f,'GRID',{1},'THICK',{1:kmax},trim.THICK.data);%6
    vs_put(f,'GRID',{1},'MMAX',{1},trim.MMAX.data);%7
    vs_put(f,'GRID',{1},'NMAX',{1},trim.NMAX.data);
    vs_put(f,'GRID',{1},'KMAX',{1},trim.KMAX.data);
    vs_put(f,'GRID',{1},'ALFAS',{1:nmax 1:mmax},trim.ALFAS.data);
    vs_put(f,'GRID',{1},'GUU',{1:nmax 1:mmax},trim.GUU.data);
    vs_put(f,'GRID',{1},'GVV',{1:nmax 1:mmax},trim.GVV.data);
    vs_put(f,'TEMPOUT',{1},'XWAT',{1:nmax 1:mmax},trim.XWAT.data);
    vs_put(f,'TEMPOUT',{1},'YWAT',{1:nmax 1:mmax},trim.YWAT.data);
    vs_put(f,'TEMPOUT',{1},'CODB',{1:nmax 1:mmax},trim.CODB.data);
    vs_put(f,'TEMPOUT',{1},'CODW',{1:nmax 1:mmax},trim.CODW.data);
    vs_put(f,'KENMCNST',{1},'KCS',{1:nmax 1:mmax},trim.KCS.data);
    vs_put(f,'KENMCNST',{1},'KCU',{1:nmax 1:mmax},trim.KCU.data);
    vs_put(f,'KENMCNST',{1},'KCV',{1:nmax 1:mmax},trim.KCV.data);
   
% Set reference time
    vs_put(f,'PARAMS',{1},'DT',{1},1);
    vs_put(f,'PARAMS',{1},'TSCALE',{1},60);
    vs_put(f,'PARAMS',{1},'IT01',{1},str2double(datestr(reftime,'yyyymmdd')));
    vs_put(f,'PARAMS',{1},'IT02',{1},0);
    vs_put(f,'KENMNT',{1},'NTCUR',{1},nt);
    vs_put(f,'CURNT',{1},'NTCUR',{1},nt);


for i = 1:length(f.GrpDat)
        f.GrpDat(1,i).SizeDim = 1;
end

end
 

