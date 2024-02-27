function OPT = delft3d_mdf2kml(mdf,varargin)
%DELFT3D_MDF2KML  plot complete spatial schematization (grd,dep,thd,dry,src,obs) as kml
%
%   Create a 2D kml-file (or kmz-file) of a Delft3D model setup
%
%   Syntax:
%   delft3d_mdf2kml(mdf,<keyword,value>)
%
%   Input:
%   mdf  = filename of the mdf file
%
%   Keyword-value pairs:
%   epsg      = epsg code of the grid
%   dep       = switch for bathymetry output (true/false)
%   dry       = switch for dry points output (true/false)
%   thd       = switch for thin dams output (true/false)
%   src       = switch for river sources output (true/false)
%   obs       = switch for obser vation points output (true/false)
%   kmz       = switch for saving to kmz (true/false)
%
%   Example
%   OPT = delft3d_mdf2kml();
%   The output structure OPT will give you all possible keyword-value pairs
%
%   DELFT3D_MDF2KML('F:\checkouts\OpenEarthModels\deltares\brazil_patos_lagoon_52S_32E\3d1.mdf',...
%    'epsg',4326,...
%     'dep',1,... 
%     'dry',1,... 
%     'thd',1,... 
%     'src',1,... 
%     'obs',1,... 
%     'kmz',1) 
%
%   See also DELFT3D_GRD2KML, googleplot, VS_TRIM_TO_KML_TILED_PNG

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 16 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: delft3d_mdf2kml.m 10035 2014-01-17 10:46:25Z bart.demaerschalck.x $
% $Date: 2014-01-17 18:46:25 +0800 (Fri, 17 Jan 2014) $
% $Author: bart.demaerschalck.x $
% $Revision: 10035 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/delft3d_mdf2kml.m $
% $Keywords: $

%% Handle input arguments

   OPT2            = delft3d_grd2kml;

   OPT = OPT2;
   OPT.epsg        = 4326;             % epsg-code: 28992; % 7415; % 28992; ['Amersfoort / RD New']
   OPT.ddep        = 10;               % height offset
   OPT.grdColor    = [0.7 0.7 0.7];    % color of grid lines
   OPT.dep         = false;            % switch for bathymetry
   OPT.cLim        = [-50 25];         % color limits for bathymetry
   OPT.dry         = false;            % switch for dry points
   OPT.dryColor    = [163 208 1]./256; % color of dry points
   OPT.thd         = false;            % switch for thin dams
   OPT.thdColor    = [216 215 1]./256; % color for thin dams
   OPT.thdWidth    = 2;                % width of thin dams
   OPT.src         = false;            % switch for source&sink
   OPT.srcColor    = [153 0 153]./256; % color for source&sink
   OPT.obs         = false;            % switch for observation points
   OPT.obsColor    = [0 0 0]./256;     % color for observation points
   OPT.kmz         = false;            % switch for output to kmz
   OPT.dep3D       = false;            % for 3D view of bathymetry. NB: by using this option, drypoints and thindams can get invisible because they are below the bathymetry.
   
   if nargin==0
      return
   end

   OPT  = setproperty(OPT ,varargin);
   OPT2 = setproperty(OPT2,varargin,'onExtraField','silentIgnore');

if ~exist(mdf,'file')
    error('mdf file does not exist')
    return
end

[pathstr,name,ext] = fileparts(mdf);
if isempty(pathstr)
    pathstr = pwd;
end

%% Read mdf-file

   MDF = delft3d_io_mdf('read',mdf);
   G = wlgrid('read',[pathstr,filesep,MDF.keywords.filcco]);
   xg = G.X;
   yg = G.Y;

%% Convert grid
disp('Converting the grid...')
   z = repmat(10,size(xg));
   if OPT.epsg ~= 4326
       [xg,yg]=convertCoordinates(xg,yg,'CS1.code',OPT.epsg,'CS2.code',4326);
   end
   
   kmlFiles{1} = 'grid.kml';
   KMLmesh(yg,xg,z,...
       'fileName',kmlFiles{1},...
       'kmlName','grid',...
       'lineColor',OPT.grdColor,...
       'lineAlpha',.6,...
       'lineWidth',1);
   
   %% Convert bathymetry
   disp('Converting bathymetry...')
   if isfield(MDF.keywords,'fildep')
       OPT2.dep = [pathstr,filesep,MDF.keywords.fildep];
       OPT2.mdf = mdf;
       OPT2 = delft3d_grd2kml([pathstr,filesep,MDF.keywords.filcco],OPT2);
   else
       OPT2.dep = '';
       OPT2 = delft3d_grd2kml([pathstr,filesep,MDF.keywords.filcco],OPT2);
   end
   
   if OPT.dep3D
       kmlFiles{end+1} = [filename(MDF.keywords.filcco),'_3D.kml'];
       delete([filename(MDF.keywords.filcco),'_2D.kml']);
   else
       kmlFiles{end+1} = [filename(MDF.keywords.filcco),'_2D.kml'];
       delete([filename(MDF.keywords.filcco),'_3D.kml']);
       delete([filename(MDF.keywords.filcco),'_3D_ver_lft.png']);
   end

%% Process dry points

   if OPT.dry
    nr=0;
    
    try
        D = delft3d_io_dry('read' ,[pathstr,filesep,MDF.keywords.fildry]);
        nr = length(D.m1);
    catch
        disp('No dry points found...')
    end
    
    if nr>0
        for i = 1:nr
            m1=min(D.m0(i),D.m1(i));
            n1=min(D.n0(i),D.n1(i));
            m2=max(D.m0(i),D.m1(i));
            n2=max(D.n0(i),D.n1(i));
            x1=xg(m1-1:m2,n1-1)';
            y1=yg(m1-1:m2,n1-1)';
            x1=[x1 xg(m2,n1-1:n2)];
            y1=[y1 yg(m2,n1-1:n2)];
            x1=[x1 xg(m2:-1:m1-1,n2)'];
            y1=[y1 yg(m2:-1:m1-1,n2)'];
            x1=[x1 xg(m1-1,n2:-1:n1-1)];
            y1=[y1 yg(m1-1,n2:-1:n1-1)];
            xDry{i} = x1';
            yDry{i} = y1';
        end
        
        %     [m,n]=size([xDry{:}]);
        %     z = mat2cell(repmat(OPT.ddep+1, size([xDry{:}])),m,repmat(1,n,1));
        z = cellfun(@(x) ones(size(x))+OPT.ddep,xDry,'UniformOutput',false);
        
        kmlFiles{end+1} = 'drypoints.kml';
        KMLpatch3(yDry,xDry,z,'fileName',kmlFiles{end},'fillColor',OPT.dryColor,'fillAlpha',0.8,'kmlName','drypoints');
    end
   end

%% Process src points

   if OPT.src
    nr=0;
    
    try
        D = delft3d_io_src('read' ,[pathstr,filesep,MDF.keywords.filsrc]);
        nr = length(D.m);
    catch
        disp('No src points found...')
    end
    
    if nr>0
    
        clear x1 y1
    
        for i = 1:nr
            m = D.m(i);
            n = D.n(i);
            x1(1)=(xg(m  ,n-1)+xg(m  ,n  ))./2;
            y1(1)=(yg(m  ,n-1)+yg(m  ,n  ))./2;
            x1(2)=(xg(m  ,n  )+xg(m-1,n  ))./2;
            y1(2)=(yg(m  ,n  )+yg(m-1,n  ))./2;
            x1(3)=(xg(m-1,n-1)+xg(m-1,n  ))./2;
            y1(3)=(yg(m-1,n-1)+yg(m-1,n  ))./2;
            x1(4)=(xg(m  ,n-1)+xg(m-1,n-1))./2;
            y1(4)=(yg(m  ,n-1)+yg(m-1,n-1))./2;
            xSrc{i} = x1';
            ySrc{i} = y1';
        end
        
        %     [m,n]=size([xDry{:}]);
        %     z = mat2cell(repmat(OPT.ddep+1, size([xDry{:}])),m,repmat(1,n,1));
        z = cellfun(@(x) ones(size(x))+OPT.ddep,xSrc,'UniformOutput',false);
        
        kmlFiles{end+1} = 'srcpoints.kml';
        KMLpatch3(ySrc,xSrc,z,'fileName',kmlFiles{end},'fillColor',OPT.srcColor,'fillAlpha',0.8,'kmlName','srcpoints');
    end
   end

%% Process obs points: black and as diamond also

   if OPT.obs
    nr=0;
    
    try
        D = delft3d_io_obs('read' ,[pathstr,filesep,MDF.keywords.filsta]);
        nr = length(D.m);
    catch
        disp('No obs points found...')
    end
    
    if nr>0
    
        clear x1 y1
    
        for i = 1:nr
            m = D.m(i);
            n = D.n(i);
            x1(1)=(xg(m  ,n-1)+xg(m  ,n  ))./2;
            y1(1)=(yg(m  ,n-1)+yg(m  ,n  ))./2;
            x1(2)=(xg(m  ,n  )+xg(m-1,n  ))./2;
            y1(2)=(yg(m  ,n  )+yg(m-1,n  ))./2;
            x1(3)=(xg(m-1,n-1)+xg(m-1,n  ))./2;
            y1(3)=(yg(m-1,n-1)+yg(m-1,n  ))./2;
            x1(4)=(xg(m  ,n-1)+xg(m-1,n-1))./2;
            y1(4)=(yg(m  ,n-1)+yg(m-1,n-1))./2;
            xObs{i} = x1';
            yObs{i} = y1';
        end
        
        %     [m,n]=size([xDry{:}]);
        %     z = mat2cell(repmat(OPT.ddep+1, size([xDry{:}])),m,repmat(1,n,1));
        z = cellfun(@(x) ones(size(x))+OPT.ddep,xObs,'UniformOutput',false);
        
        kmlFiles{end+1} = 'obspoints.kml';
        KMLpatch3(yObs,xObs,z,'fileName',kmlFiles{end},'fillColor',OPT.obsColor,'fillAlpha',0.8,'kmlName','obspoints');
    end
   end


%% Process thin dams

   if OPT.thd
    nr = 0;
    
    try
        T = delft3d_io_thd('read' ,[pathstr,filesep,MDF.keywords.filtd]);
        nr = length(T.m);
    catch
        disp('No thin dams found');
    end
    
    if nr>0
        xThd = [];
        yThd = [];
        
        for i = 1:nr
            m1=min(T.m(:,i));
            n1=min(T.n(:,i));
            m2=max(T.m(:,i));
            n2=max(T.n(:,i));
            k=0;
            for jj=m1:m2
                for kk=n1:n2
                    k=k+1;
                    m=jj;
                    n=kk;
                    if strcmpi(T.DATA(i).direction,'u')
                        xThd = [xThd nan xg(m,n-1) xg(m,n)];
                        yThd = [yThd nan yg(m,n-1) yg(m,n)];
                    else
                        xThd =[xThd nan xg(m-1,n) xg(m,n)];
                        yThd =[yThd nan yg(m-1,n) yg(m,n)];
                    end
                end
            end
        end
        
        z = repmat(OPT.ddep+2, size(xThd));
        
        kmlFiles{end+1} = 'thindams.kml';
        KMLline(yThd',xThd',z','lineWidth',OPT.thdWidth,'lineColor',OPT.thdColor,'fileName',kmlFiles{end},'kmlName','thindams');
    end
   end

%% Merge kml-files to one

   KMLmerge_files('sourceFiles',kmlFiles,'fileName',[name,'.kml']);

   try
      delete(kmlFiles{:});
   end

   if OPT.kmz
       if OPT.colorbar
           zip([name,'.kmz'],{[name,'.kml'],[filename(MDF.keywords.filcco),'_2D_ver_lft.png']});
       else
           zip([name,'.kmz'],{[name,'.kml']});
       end
       copyfile([name,'.kmz.zip'],[name,'.kmz']);
       delete  ([name,'.kmz.zip']);
       delete  ([name,'.kml']);
       delete  ([filename(MDF.keywords.filcco),'_2D_ver_lft.png']);
   end
