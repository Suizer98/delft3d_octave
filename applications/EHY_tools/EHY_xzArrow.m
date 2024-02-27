function EHY_xzArrow(x,z,u,w,varargin)

OPT.scale     = 1.0   ; % 1 cm (matlab lenx etc) corresponds with scale m/s
OPT.thinX     = 1.0   ; % Thinning in x direction
OPT.thinZ     = 1.0   ; % Thinning in y(z) direction
OPT.XScale    = 1     ; % Used to account for scaling of x axis (from m to km)
OPT.ucz       = true  ; % By defaut vertical velocities are taken into account. Not always desirable. Sometimes w = 0 (OPT.w0 = false) is better.
OPT           = setproperty(OPT,varargin);
x             = x/OPT.XScale;

xStart        = [];
zStart        = [];
xEnd          = [];
zEnd          = [];

%% Get the dimensions of the data
mmax = size(z,1);
nmax = size(z,2);

%% Get figure dimensions
orgUnit = get(gca,'Units');
set(gca,'Units','centimeters');
pos     = get(gca,'Position');
XLim    = get(gca,'XLim'    );
YLim    = get(gca,'YLim'    );
set(gca,'Units',orgUnit);
lenX    = pos(3);
lenY    = pos(4);
daspect([(XLim(2) - XLim(1))/lenX (YLim(2) - YLim(1))/lenY 1]);

%% Thinning (firts x,s direction)
if nmax > 1 % nmax is misused to determine wheteher it is a top- or crosssectiobal view
    indexX       = EHY_thinning(x,ones(1,mmax),'thinDistance',OPT.thinX,'Units','centimeters');
else
    indexX       = EHY_thinning(x,z,'thinDistance',OPT.thinX,'Units','centimeters');
    indexZ       = indexX;
end

for mThin = indexX
    zPlot  = z   (mThin,:);
    valu   = u(mThin,:);
    valw   = w(mThin,:);
    if ~OPT.ucz valw(1:length(valw)) = 0.; end

    indexZ = ~isnan(zPlot);

    %  Flip the z direction. Surface as start will normally give nicer figures
    zPlot  = flip(zPlot(indexZ));
    valu   = flip(valu(indexZ));
    valw   = flip(valw(indexZ));

    %  Thinning in the z direction
    if nmax > 1
        indexZ     = EHY_thinning(ones(1,length(zPlot)),zPlot,'thinDistance',OPT.thinZ,'Units','centimeters');
    end
    zPlot      = zPlot(indexZ);
    valu       = valu(indexZ);
    valw       = valw(indexZ);

    % Scale v velocities with aspect ratio of figure
    valw       = ((OPT.XScale*(XLim(2) - XLim(1))/lenX)/((YLim(2) - YLim(1))/lenY))*valw;

    for iZ = 1: length(zPlot)
        %  Determine start and end point of a single vector
        xStart(end + 1) = x    (mThin);
        zStart(end + 1) = zPlot(iZ);
        xEnd  (end + 1) = xStart(end) + ((valu(iZ)/OPT.scale)/lenX)*(XLim(2) - XLim(1));
        zEnd  (end + 1) = zStart(end) + ((valw(iZ)/OPT.scale)/lenY)*(YLim(2) - YLim(1));
    end
end

 % (avoid identical start and end point in case u = 0)
for i_pnt = 1: length(xStart)
    if xStart(i_pnt) == xEnd(i_pnt)  xEnd(i_pnt) = 1.0001*xEnd(i_pnt); end
end

%% Scale the arrrowheads, first compute the actual length, in cm,  of the vecors
for iVec = 1: length(xStart)
    lenVecX      = ((xEnd(iVec) - xStart(iVec))/(XLim(2) - XLim(1)))*lenX;
    lenVecZ      = ((zEnd(iVec) - zStart(iVec))/(YLim(2) - YLim(1)))*lenY;
    lenVec(iVec) = sqrt(lenVecX.^2 + lenVecZ.^2);
end

%  Now scale the arrowheads (length of arrowheads proportional to vector length)
unit = sqrt(lenX^2 + lenY^2)/72;
H    = 0.3*min(lenVec,1)/unit;
W    = 0.2*min(lenVec,1)/unit;

%% Finally, plot the arrows
hold on
arrow3([xStart; zStart]', [xEnd; zEnd]',[],W,H);

%% Still to do, vector legend 0.5 cm below X axis (had to be above the xaxis otherwise it is simply not plotted; Shame)
xLegStart = XLim(1) + ((lenX - 1.5)/lenX)*(XLim(2) - XLim(1));
xLegEnd   = XLim(1) + ((lenX - 0.5)/lenX)*(XLim(2) - XLim(1));
yLegStart = YLim(1) + (0.1         /lenY)*(YLim(2) - YLim(1));
arrow3([xLegStart; yLegStart]', [xLegEnd; yLegStart]',[],0.2/unit,0.3/unit);
xTxt      =  XLim(1) + ((lenX - 2.25)/lenX)*(XLim(2) - XLim(1));
yTxt      = YLim(1) + (0.15          /lenY)*(YLim(2) - YLim(1));
hText     = text(xTxt,yTxt,[num2str(OPT.scale) ' m/s']);
set (hText,'FontSize'         ,6       );
set (hText,'VerticalAlignment','middle');


