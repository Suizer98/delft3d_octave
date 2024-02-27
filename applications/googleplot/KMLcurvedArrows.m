function varargout = KMLcurvedArrows(x,y,u0,v0,varargin)
% KMLCURVEDARROWS makes nice curved arrows that 'go with the flow'
%
%   KMLcurvedArrows(x,y,u0,v0,varargin)
%
% x, y, u0, v0: must be a cell array, each cell with demsions of x and y
%
% NOTE
% Unlike all other GooglePlot functions, this one needs
% an [x,y], and not [lat,lon] (note order). This is because the particle 
% tracking is perfomed in (x,y) space, the keyword coordConvFun 
% determines how to transform the particle tracking results to (lat,lon).
% on the fly. Note the order u,v.
%
% see the keyword/value pair defaults for additional options
%
% See also: googlePlot, curvec, mxcurvec, KMLquiver, KMLquiver3, KMlcurvedArrows

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
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

% $Id: KMLcurvedArrows.m 12175 2015-08-14 12:44:19Z gagliardimarcelo.x.1 $
% $Date: 2015-08-14 20:44:19 +0800 (Fri, 14 Aug 2015) $
% $Author: gagliardimarcelo.x.1 $
% $Revision: 12175 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcurvedArrows.m $
% $Keywords: $

   OPT                   = KML_header();

   OPT.coordConvFun      = @(x,y,EPSG) convertCoordinates(x,y,EPSG,'CS1.code',31984,'CS2.code',4326); % do include epsg as we do numerous transformations
   OPT.colorSteps        = 9;
   OPT.colorMap          = @(m) colormap_cpt('YlOrRd 09.cpt',(m));
%     OPT.colorMap          = colormap_cpt('YlOrRd 09.cpt',10);   
    OPT.fileName          = [];
   OPT.time              = [1 1000]; % containing begin and end times of animation
   
   %% arrow properties
   OPT.length           = 90;                   % lenght in seconds (determines length of arrows)
   OPT.nrvertices       = 10;
   OPT.headthickness    = 0.15;
   OPT.arrowthickness   = 0.05;
   OPT.nhead            = 2;                    % Number of vertices used for arrow head length (default 2, max nrvertices-1).

   OPT.lifespan         = 50;                   % number of timesteps an arrow is alive
   OPT.n_arrows         = 300;                  % number of arrows
   OPT.flow_steps       = 4;                    % (max is OPT.nrvertices)
   OPT.colorScale       = .015;
   OPT.lineScale        = .02;
   OPT.interp_steps     = 1;                    % interpolate in time between consecutive arrows

%OPT.relwdt	     = @(x)ones(numel(x),1); % relative width, leave at one
OPT.x0 		     = []; % initial x of seeds
OPT.y0 		     = []; % initial y of seeds

if nargin==0
   varargout = {OPT};
   return
end

OPT.relwdt	     = ones(numel(x),1); % relative width, leave at one

%% set properties
[OPT, Set, Default] = setproperty(OPT, varargin{:});

%% filename
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','movingArrows.kmz');
    OPT.fileName = fullfile(filePath,fileName);
end
% set kmlName if it is not set yet
if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

tempPath = tempname; 

mkdir(tempPath)
% set colormap
cmap = OPT.colorMap(OPT.colorSteps);

% load EPSG for convert coordinates
EPSG = load('EPSG');

%% make arrows

   if isempty(OPT.time)
      OPT.time = [nan nan];
   end    

%% get first data
%  u0    is nt data array
%  u1,v1 is one  timestep
%  u2,v2 is next timestep

   if isnumeric(u0)
     if length(size(u0))==2
       u2 = u0;u1 = u0; clear u0; u0{1} = u1;u0{2} = u1;
       v2 = v0;v1 = v0; clear v0; v0{1} = v1;v0{2} = v1;
     else
       warning('TO DO')
     end
   elseif iscell(u0)
       u2 = u0{1};u1 = u2;
       v2 = v0{1};v1 = v2;
   end

%% make initial seed of arrows

   x_nonan       = x(~isnan(x)); % needed for adding new new arrows
   y_nonan       = y(~isnan(y));
   if isempty(OPT.x0) & isempty(OPT.y0)
     seedPoints  = linspace(1,numel(x_nonan)-numel(x_nonan)/OPT.n_arrows,OPT.n_arrows);
     seedPoints  = round(seedPoints'+(numel(x_nonan)/OPT.n_arrows).*rand(OPT.n_arrows,1));
     OPT.x0      = x_nonan(seedPoints);
     OPT.y0      = y_nonan(seedPoints);
   end
   t             = round((OPT.lifespan-1)*rand(size(OPT.x0)))+1;

%% interpolate time

   time        = linspace(OPT.time(1),OPT.time(2),OPT.interp_steps*(length(u0)-1)+1);
   if numel(time)>1
       time(end+1) = time(end)+(time(end)-time(end-1));
   else
       time(end+1) = time(end);
   end
%%

for ii = 1:OPT.interp_steps*(length(u0)-1)+1;

    if OPT.interp_steps > 0
      if rem((ii-1),OPT.interp_steps)==0 %only update when needed
          u1 = u2;v1 = v2;
      end
      if rem((ii-2),OPT.interp_steps)==0 %only update when needed
          u2 = u0{(ii-2)/OPT.interp_steps+2}; 
          v2 = v0{(ii-2)/OPT.interp_steps+2};
      end
         a = rem((ii-1),OPT.interp_steps)/OPT.interp_steps;
         b = 1-a;
         u = a*u2+b*u1;
         v = a*v2+b*v1;
    else
         u = u1;
         v = v1;
    end

%% make arrows

    [xp,yp,xax,yax,len]=mxcurvec(OPT.x0,OPT.y0,x ,y ,u ,v ,u ,v ,OPT.length,OPT.nrvertices,OPT.headthickness,OPT.arrowthickness,OPT.nhead,OPT.relwdt,0);

    % pre-proces xp and yp
    xax(xax<1000.0 & xax>999.998)=NaN; yax(yax<1000.0 & yax>999.998)=NaN;
    xp ( xp<1000.0 &  xp>999.998)=NaN; yp ( yp<1000.0 &  yp>999.998)=NaN;
    ic=1;while ~isnan(xp(ic,1));ic=ic+1;end % NOT: ic =  (OPT.nrvertices - OPT.nhead)*2+5 due to nhead cut-off in mxcurvec
    xp = reshape(xp,ic,[]);            yp = reshape(yp,ic,[]);
    xp(end,:) = [];                    yp(end,:) = [];

    % convert coordinates
    [lon,lat]  = OPT.coordConvFun(xp,yp,EPSG); 
    
    arrowSizes = sqrt(polyarea(xp,yp));
    lineColors = round(arrowSizes*OPT.colorScale)+1;
    lineColors = min(OPT.colorSteps,lineColors);
    lineColors = cmap(lineColors,:);
    lineWidths = min(round(arrowSizes*OPT.lineScale)+2,10)/5;
    
    if any(isnan(time))
    KMLline(lat(:,arrowSizes ~= 0),lon(:,arrowSizes ~= 0),'relativeToGround',... % prevent flicker between seabed & MSL
           'fileName',fullfile(tempPath,sprintf('arrows%03d.kml',ii)),...
            'visible',OPT.visible,...
             'timeIn',OPT.timeIn,...
            'timeOut',OPT.timeOut,...
            'kmlName',sprintf('arrows%03d',ii),...
          'lineWidth',lineWidths(arrowSizes ~= 0),...
          'lineColor',lineColors(arrowSizes ~= 0,:));
    else
    lineAlphas = ones(size(OPT.x0));
    lineAlphas(t==9|t==OPT.lifespan-8) = 0.9;
    lineAlphas(t==8|t==OPT.lifespan-7) = 0.8;
    lineAlphas(t==7|t==OPT.lifespan-6) = 0.7;
    lineAlphas(t==6|t==OPT.lifespan-5) = 0.6;
    lineAlphas(t==5|t==OPT.lifespan-4) = 0.5;
    lineAlphas(t==4|t==OPT.lifespan-3) = 0.4;
    lineAlphas(t==3|t==OPT.lifespan-2) = 0.3;
    lineAlphas(t==2|t==OPT.lifespan-1) = 0.2;
    lineAlphas(t==1|t==OPT.lifespan-0) = 0.1;       
    KMLline(lat(:,arrowSizes ~= 0),lon(:,arrowSizes ~= 0),...
                'open',OPT.open,...
             'visible',OPT.visible,...
              'timeIn',time(ii),...
             'timeOut',time(ii+1),...
            'fileName',fullfile(tempPath,sprintf('arrows%03d.kml',ii)),...
             'kmlName',sprintf('arrows%03d',ii),...
           'lineWidth',lineWidths(arrowSizes ~= 0),...
           'lineColor',lineColors(arrowSizes ~= 0,:),...
        'dateStrStyle',OPT.dateStrStyle,...
           'lineAlpha',lineAlphas(arrowSizes ~= 0));
    end
    disp(sprintf('arrows%03d done',ii));
    
    pause(0.01) % allows for better 'ctrl+c'-ing
    
    %% update y0 and x0
    OPT.x0 = xax(OPT.flow_steps:OPT.nrvertices+1:end);
    OPT.y0 = yax(OPT.flow_steps:OPT.nrvertices+1:end);
    
%% replace dead arrows

    t = t-1;
    t(arrowSizes' == 0) = t(arrowSizes' == 0)-20;
    %t(arrowSizes' >  prctile(arrowSizes,99)) =  t(arrowSizes' >  prctile(arrowSizes,99))-4;
    % kill arrows
    OPT.x0(t<1) = [];
    OPT.y0(t<1) = [];
         t(t<1) = [];
     
%% add new ones if needed

    if length(OPT.x0)<OPT.n_arrows
        new_arrows = OPT.n_arrows-length(OPT.x0);
        
        % pick new arrows. Use a bias so that arrows with small velocities
        % are more likely to be chosen.
        x_nonan = x(~isnan(x));
        y_nonan = y(~isnan(y));
        s_nonan = sqrt(u(~isnan(u)).^2+v(~isnan(v)).^2);
        
        s_nonan = -s_nonan/2 +... 
        ...% this ^^^^^^^ is where the bias is;
        rand(size(s_nonan))*max(s_nonan) +...
        rand(size(s_nonan))*max(s_nonan) +...
        rand(size(s_nonan))*max(s_nonan) +...
        rand(size(s_nonan))*max(s_nonan) +...
        rand(size(s_nonan))*max(s_nonan);
    
        [ignore,ind] = sort(s_nonan);
        seedPoints   = ind(end-new_arrows+1:end);
        if seedPoints < length(x_nonan)
        OPT.x0 = [OPT.x0;x_nonan(seedPoints)];
        OPT.y0 = [OPT.y0;y_nonan(seedPoints)];
        t      = [t   ;50*ones(new_arrows,1)];
        end
    end 
end
filesCreated = dir([tempPath filesep '*.kml']);
for ii = 1:length(filesCreated)
    sourceFiles{ii} = fullfile(tempPath,filesCreated(ii).name); %#ok<AGROW>
end
KMLmerge_files('fileName',OPT.fileName,...
                'kmlName',OPT.kmlName,...
                'visible',OPT.visible,...
            'sourceFiles',sourceFiles,...
      'deleteSourceFiles',true);
rmdir(tempPath,'s')

if nargout > 0
   varargout = {OPT.x0,OPT.y0};
end