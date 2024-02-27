function varargout=curvec(x,y,u,v,varargin)
%CURVEC make curvy arrows from velocity vector fields
%
% This function computes streamlines along randomly distributed seed
% points and generates curvy arrows along these streamlines.Can be used
% for stills and animations.
%
% [polx,poly,xax,yax,len,pos] = curvec(x,y,u,v,'keyword','value')
%
% INPUT:
% x,y            : Values of the x and y coordinates of the velocity vector field.
% u,v            : Values of the velocity components (u and v can be a m*n
%                  or m*n*nt matrix, where nt is the number of time steps).
% 
% OUTPUT:        Output is provided in cell arrays in case of animated output.
% polx,poly      : n*2 matrix with polygons of curvy arrows.
% xax,yax        : n*2 matrix with axis coordinates of curvy arrows.
% len            : Vector with length of curvy arrows (in m).
% pos            : n*3 matrix with start coordinates for arrows in next
%                  time step, (first two columns) and age of arrow (third column).
%
% OPTIONAL INPUT ARGUMENTS:
% dx                   : Average horizontal spacing (in metres) between start points of arrows.
% times                : Vector with times in u and v fields. Length must equal to nt. 
% starttime            : Start time of animation, e.g. datenum(2011,7,2). 
% stoptime             : Stop time of animation, e.g. datenum(2011,7,3). 
% timestep             : Time step of animation (in seconds). Only for animations.
% length               : Length of the curvy arrows (in seconds).
% xlim                 : Horizontal limits in x-direction, e.g. [3000 8000].
% ylim                 : Horizontal limits in y-direction, e.g. [3000 8000].
% position             : n*3 matrix with start coordinates for arrows in next time step
%                        (first two columns) and age of arrow (third column).
%                        This option is only required for animations.
% nrvertices           : Number of vertices along axis of arrows (default 15).
% headthickness        : Relative width of arrow heads (default 0.15).
% arrowthickness       : Relative width of arrows (default 0.05).
% nhead                : Number of vertices used for arrow head length (default 3, max nrvertices-1).
% lifespan             : Life span of arrows in animation (default 50). Only for
%                        animations.
% relativespeed        : Factor for speed of curvy arrows (default 1.0). Only for
%                        animations.
% fade                 : Fade in arrows that were just seeded and fade out
%                        arrows that are about to die (1 or 0, default 1).
% polygon              : Matrix with coordinates of polygon within which curvy
%                        arrows will be computed (first column x, second column
%                        y). Overrides xlim and ylim.
% cs                   : Type of coordinate system. Must be 'geographic' or
%                        'projected' (default).
%
% Note: the maximum number of arrows is 15,000!
% 
% EXAMPLE 1 : Still
% 
% [x,y] = meshgrid(0:10:300,0:10:100);
% u = zeros(size(x))+1;
% v = 0.5*cos(x/30);
% [polx,poly]=curvec(x,y,u,v,'length',20,'dx',10,'headthickness',0.3,'arrowthickness',0.1);
% patch(polx,poly,'g');axis equal;
%
% EXAMPLE 2 : Animation
% 
% [x,y]= meshgrid(0:1:100,0:1:100);
% ang  = atan2(y-50,x-50);
% dist = sqrt((x-50).^2+(y-50).^2);
% amp  = cos(2*pi*dist/50);
% fig  = figure;
% set(fig,'Position',[20 20 600 600]);
% ptch=patch(0,0,'r');
% axis equal;
% set(gca,'xlim',[-10 110],'ylim',[-10 110]);
% %aviobj = avifile('example.avi','fps',20,'Compression','Cinepak','Quality',100);
% pos=[];
% for t=1:200
%     disp(['Processing ' num2str(t) ' of 200 ...']);
%     u=amp.*sin(ang-pi)+0.004*t*cos(ang-pi);
%     v=amp.*cos(ang   )+0.004*t*sin(ang-pi);
%     [polx,poly,xax,yax,len,pos]=curvec(x,y,u,v,'length',10,'dx',5,'position',pos,'timestep',2);
%     set(ptch,'XData',polx,'YData',poly);
%     F = getframe(fig);
%     %aviobj = addframe(aviobj,F);
% end
% %close(fig)
% %aviobj = close(aviobj);
%
%See also: KMLcurvedArrows, mxcurvec, quiver, arrow2, arrow, particle_tracker, MakeCurvedArrow
 
% --------------------------------------------------------------------
% Copyright (C) 2011 Deltares
%
%       Maarten.vanOrmondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
% This library is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this library.  If not, see <http://www.gnu.org/licenses/>.
% --------------------------------------------------------------------

%% initiate, handle and process heyword

OPT.length           = [];
OPT.nrvertices       = 15;
OPT.headthickness    = 0.15;
OPT.arrowthickness   = 0.05;
OPT.nhead            = 3;

OPT.position         = [];
OPT.geofac           = 111111;
OPT.lifespan         = 50;
OPT.relativespeed    = 1;
OPT.timestep         = 0;
OPT.polygon          = [];
OPT.dx               = [];
OPT.xlim             = [];
OPT.ylim             = [];
OPT.coordinatesystem = ''; % 'geographic','geo','spherical','latlon'
OPT.cs               = ''; % 'geographic','geo','spherical','latlon'
OPT.iopt             = 0;% 0: (x,y), 1: (lat,lon)
OPT.starttime        = [];
OPT.stoptime         = [];
OPT.times            = [];
OPT.fade             = 1;
OPT.minarrowlength   = 0.01;

if nargin==0
    varargout{1} = OPT;return
end

OPT = setproperty(OPT,varargin{:});

if (~isempty(OPT.starttime) && isempty(OPT.stoptime))
    OPT.stoptime=OPT.starttime;
end

%% Check for errors in input
% Missing stop time
if isempty(OPT.starttime) && ~isempty(OPT.stoptime)
    error('Error in curvec.m. Please provide start time for animation.');
end
% Missing start or stop time
if (~isempty(OPT.times) && (isempty(OPT.starttime) || isempty(OPT.stoptime)))
    error('Error in curvec.m. Please provide start time and stop time for animation.');
end
% Missing times
if (isempty(OPT.times) && (~isempty(OPT.starttime) || ~isempty(OPT.stoptime)))
    error('Error in curvec.m. Please provide times for vector fields.');
end
% Missing time step
if (OPT.timestep==0 && (~isempty(OPT.starttime) || ~isempty(OPT.stoptime)))
    error('Error in curvec.m. Please provide time step for animation.');
end

if ~isempty(OPT.xlim)
    xmin=OPT.xlim(1);
    xmax=OPT.xlim(2);
else
    xmin=min(x(:));
    xmax=max(x(:));
end

if ~isempty(OPT.ylim)
    ymin=OPT.ylim(1);
    ymax=OPT.ylim(2);
else
    ymin=min(y(:));
    ymax=max(y(:));
end

if any(strcmpi(OPT.coordinatesystem,{'geographic','geo','spherical','latlon'})) || ...
   any(strcmpi(OPT.cs              ,{'geographic','geo','spherical','latlon'}))
    OPT.iopt=1;
end

if isempty(OPT.length)
    error('Could not make arrows. Please specify the length of the vectors (in seconds) with the keyword LENGTH!');
end

if isempty(OPT.dx)
    % Estimate good arrow distance
    if OPT.iopt==1
        OPT.dx=OPT.geofac*(xmax-xmin)/20;
    else
        OPT.dx=(xmax-xmin)/20;
    end
end

if isempty(OPT.polygon)
    % Make polygon from xlim and ylim
    xp=[xmin xmax xmax xmin];
    yp=[ymin ymin ymax ymax];
else
    xp=squeeze(OPT.polygon(:,1));
    yp=squeeze(OPT.polygon(:,2));
end

if ~isempty(OPT.starttime) && ~isempty(OPT.stoptime) && ~isempty(OPT.timestep)
    nt=round((OPT.stoptime-OPT.starttime)/(OPT.timestep/86400))+1;
else
    nt=1;
end

% Check if data is structured or unstructured
if size(u,1)==1 || size(u,2)==1
    % Unstructured
    u=repmat(u,[1 4]);
    v=repmat(v,[1 4]);
end

for it=1:nt
    
    if nt>1
        disp(['Processing time ' num2str(it) ' of ' num2str(nt) ' ...']);
    end
    
    %% Interpolate in time

    % Check if u and v matrices are 3d (varying in time) or 2d (constant in time)
    if ndims(u)>2

        if isempty(OPT.times)
            u1=squeeze(u(:,:,1));
            v1=squeeze(v(:,:,1));
            u2=squeeze(u(:,:,2));
            v2=squeeze(v(:,:,2));
        else
            
            % Find indices of required time
            time1=OPT.starttime+(it-1)*OPT.timestep/86400;
            it1a=find(OPT.times<=time1,1,'last');
            if isempty(it1a)
                it1a=1;
            end
            it1b=it1a+1;
            if it1b>length(OPT.times)
                it1b=length(OPT.times);
            end
            if it1a==it1b
                tfac1a=1;
                tfac1b=0;
            else
                tfac1a=(OPT.times(it1b)-time1)/(OPT.times(it1b)-OPT.times(it1a));
                tfac1b=1-tfac1a;           
            end

            time2=time1+OPT.timestep/86400;
            it2a=find(OPT.times<=time2,1,'last');
            if isempty(it2a)
                it2a=1;
            end
            it2b=it2a+1;
            if it2b>length(OPT.times)
                it2b=length(OPT.times);
            end
            if it2a==it2b
                tfac2a=1;
                tfac2b=0;
            else
                tfac2a=(OPT.times(it2b)-time1)/(OPT.times(it2b)-OPT.times(it2a));
                tfac2b=1-tfac2a;
            end
            
            u1=tfac1a*squeeze(u(:,:,it1a))+tfac1b*squeeze(u(:,:,it2a));
            v1=tfac1a*squeeze(v(:,:,it1a))+tfac1b*squeeze(v(:,:,it2a));
            u2=tfac2a*squeeze(u(:,:,it1b))+tfac2b*squeeze(u(:,:,it2b));
            v2=tfac2a*squeeze(v(:,:,it1b))+tfac2b*squeeze(v(:,:,it2b));

        end
    else
        u1=u;
        v1=v;
        u2=u;
        v2=v;
    end

    %% Start points of curved vectors    
    if ~isempty(OPT.position)
        x2   = OPT.position(:,1);
        y2   = OPT.position(:,2);
        iage = OPT.position(:,3);
        n2   = length(x2);
    else
        % Total number of arrows
        if OPT.iopt==1
            % Geographic
            polarea=polyarea(xp*OPT.geofac,invmerc(yp)*OPT.geofac);
        else
            polarea=polyarea(xp,yp);
        end
        n2=round(polarea/OPT.dx^2);
        n2=max(n2,5);
        if OPT.iopt==1
            % Geographic
            [x2,y2]=randomdistributeinpolygon(xp,invmerc(yp),'nrpoints',n2);
            y2=merc(y2);
        else
            [x2,y2]=randomdistributeinpolygon(xp,yp,'nrpoints',n2);
        end
        iage=round(OPT.lifespan*rand(n2,1));
        if OPT.timestep==0
            iage=min(iage,OPT.lifespan-3);
            iage=max(iage,3);
        end
    end
    
    if n2>15000
        disp(['Number of curved arrows (' num2str(n2) ') exceeds 15000!']);
        return
    end
    
    %% Check for points past their lifespan
    
    idead=find(iage>=OPT.lifespan);
    for j=1:length(idead)
        ii=idead(j);
        if OPT.iopt==1
            % Geographic
            [xn,yn]=randomdistributeinpolygon(xp,invmerc(yp),'nrpoints',1);
            yn=merc(yn);
        else
            [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
        end
        x2(ii)=xn;
        y2(ii)=yn;
        iage(ii)=0;
    end
    
    %% Check for points outside polygon
    
    iout=find(inpolygon(x2,y2,xp,yp)==0);
    for j=1:length(iout)
        ii=iout(j);
        if OPT.iopt==1
            % Geographic
            [xn,yn]=randomdistributeinpolygon(xp,invmerc(yp),'nrpoints',1);
            yn=merc(yn);
        else
            [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
        end
        x2(ii)=xn;
        y2(ii)=yn;
        iage(ii)=0;
    end
    
    x1=x;
    y1=y;
    
    y1(isnan(x1))=-999.0;
    u (isnan(x1))=-999.0;
    v (isnan(x1))=-999.0;
    x1(isnan(x1))=-999.0; % last itself
    
    %% Make arrows narrower that were just seeded or which are about to die
    
    relwdt=ones(n2,1);
    if OPT.timestep>0 && OPT.fade
        for ii=1:n2
            if iage(ii)<4
                relwdt(ii)=iage(ii)/4;
            elseif iage(ii)>OPT.lifespan-4
                relwdt(ii)=(OPT.lifespan-iage(ii)+1)/4;
            else
                relwdt(ii)=1.0;
            end
        end
    end
    
    %% Compute arrows using mex file
    if size(x1,1)==1 || size(x1,2)==1
        [x1,y1]=meshgrid(x1,y1);
    end

    u1=double(u1);
    v1=double(v1);
    u2=double(u2);
    v2=double(v2);
    x1(isnan(u1))=-999;
    y1(isnan(u1))=-999;
    u1(isnan(u1))=-999;
    v1(isnan(v1))=-999;
    u2(isnan(u2))=-999;
    v2(isnan(v2))=-999;

    pause(0.1);
    
    [xar,yar,xax,yax,len]=mxcurvec(x2,y2,x1,y1,u1,v1,u2,v2,OPT.length,OPT.nrvertices,OPT.headthickness,OPT.arrowthickness,OPT.nhead,relwdt,OPT.iopt);
    
    %% Set nan values
    
    xar(xar<1000.0 & xar>999.998)=NaN;
    yar(yar<1000.0 & yar>999.998)=NaN;
    xax(xax<1000.0 & xax>999.998)=NaN;
    yax(yax<1000.0 & yax>999.998)=NaN;
    
    %% Count number of points per arrow
    
    ic=1;while ~isnan(xar(ic,1));ic=ic+1;end % NOT: ic =  (OPT.nrvertices - OPT.nhead)*2+5 due to nhead cut-off in mxcurvec
    
    %% Put all arrows in 2D matrix
    
    polx=reshape(xar,[ic               n2]);
    poly=reshape(yar,[ic               n2]);
    xax =reshape(xax,[OPT.nrvertices+1 n2]);
    yax =reshape(yax,[OPT.nrvertices+1 n2]);
    
    %% Get rid of very short arrows
    
    ishort=len<OPT.minarrowlength;
    polx(:,ishort)=NaN;
    poly(isnan(polx))=NaN;
    
    %% Get rid of NaN row
    
    polx = polx(1:end-1,:);
    poly = poly(1:end-1,:);
    xax  =  xax(1:end-1,:);
    yax  =  yax(1:end-1,:);
    
    %% Determine position of arrows in next time step
    
    if isempty(OPT.timestep)
        OPT.timestep=0;
    end
    OPT.timestep = min(OPT.timestep,OPT.length);
    nn    = (OPT.nrvertices-1)*(OPT.relativespeed*OPT.timestep/OPT.length);
    nfrac = nn-floor(nn);
    nn1   = floor(nn)+1;
    nn2   = floor(nn)+2;
    nn2   = min(nn2,OPT.nrvertices);
    OPT.position(:,1) = xax(nn1,:)+nfrac*(xax(nn2,:)-xax(nn1,:));
    OPT.position(:,2) = yax(nn1,:)+nfrac*(yax(nn2,:)-yax(nn1,:));
    OPT.position(:,3) = iage+1;
    
    % iout= xax(end,:)==xax(end-1,:);
    % OPT.position(iout,3)=OPT.lifespan;

    if nt>1
        % Multiple
        xarrow{it} = polx;
        yarrow{it} = poly;
        xaxis{it}  = xax;
        yaxis{it}  = yax;
        arrlen{it} = len;
    else
        xarrow = polx;
        yarrow = poly;
        xaxis  = xax;
        yaxis  = yax;
        arrlen = len;
    end    
    
end

varargout = {xarrow,yarrow,xaxis,yaxis,arrlen,OPT.position};

%%
function [x,y]=randomdistributeinpolygon(xp,yp,varargin)

np=[];
dxp=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'nrpoints'}
                np=varargin{i+1};
            case{'dx'}
                dxp=varargin{i+1};
        end
    end
end

if isempty(np)
    parea=polyarea(xp,yp);
    np=round(parea/dxp^2);
end

xmin=min(min(xp));
xmax=max(max(xp));
ymin=min(min(yp));
ymax=max(max(yp));

nrInPol=0;
x=zeros(np,1);
y=zeros(np,1);
while nrInPol<np
    nrnew  = np-nrInPol;
    xr     = xmin+rand(nrnew,1)*(xmax-xmin);
    yr     = ymin+rand(nrnew,1)*(ymax-ymin);
    inp    = inpolygon(xr,yr,xp,yp);
    iinp   = find(inp==1);
    sumInp = length(iinp);
    if sumInp>0
        x(nrInPol+1:nrInPol+sumInp)=xr(iinp);
        y(nrInPol+1:nrInPol+sumInp)=yr(iinp);
    end
    nrInPol=nrInPol+sumInp;
end

