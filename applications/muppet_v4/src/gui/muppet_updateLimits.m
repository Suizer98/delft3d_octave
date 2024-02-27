function plt=muppet_updateLimits(plt,opt)

% 9 options :

% 1) change width of plot  -> change xmax (keep scale)
% 2) change height of plot -> change ymax (keep scale)
% 3) change xmin           -> change xmax (keep scale)
% 4) change xmax           -> change ymax (update scale)
% 5) change ymin           -> change ymax (keep scale)
% 6) change ymax           -> change xmax (update scale)
% 7) change scale          -> change xmax, ymax
% 8) zoom in/out/pan       -> change xmin, xmax, ymin, ymax, scale
% 9) add new dataset       -> change xmin, xmax, ymin, ymax, scale 

unit=0.01;

plt.position=plt.position*unit;

switch plt.coordinatesystem.type
    case{'geographic'}
        plt.fscale=111111;
    otherwise
        plt.fscale=1;
end

switch opt
    case{'editsubplotsize'}
        plt=editsubplotsize(plt);
    case{'editheight','editwidth'}
        % Change ymax
        plt=editsubplotsize(plt);
    case{'editxmin'}
        % Change xmax
        plt=editxmin(plt);
    case{'editxmax'}
        % Change ymax and scale
        plt=editxmax(plt);
    case{'editymin'}
        % Change ymax
        plt=editymin(plt);
    case{'editymax'}
        % Change xmax and scale
        plt=editymax(plt);
    case{'editscale'}
        % Change xmax, ymax
        plt=editscale(plt);
    case{'zoom'}
        % Change xmin, xmax, ymin, ymax, scale
        plt=changezoom(plt);
    case{'updateall'}
        % Change xmin, xmax, ymin, ymax, scale, WITH rounding of axes
        plt=changeall(plt);
    case{'setprojectionlimits'}
        % Change xmax, ymax
        plt=setprojectionlimits(plt);
    case{'computescale'}
        plt=computescale(plt);
end

plt.position=plt.position/unit;

%%
function plt=editsubplotsize(plt)

% Assume x axis and ymin remain the same

switch plt.projection
    case{'equirectangular'}
        plt.ymax=plt.ymin+(plt.xmax-plt.xmin)*plt.position(4)/plt.position(3);
    case{'mercator'}
        plt.ymax=invmerc((plt.xmax-plt.xmin)/(plt.position(3)/plt.position(4))+merc(plt.ymin));
    case{'albers'}
%         [plt.xmin,plt.ymin]=albers(plt.xminproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [plt.xmax,dummy]=albers(plt.xmaxproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [dummy,plt.ymax]=albers(plt.xminproj,plt.ymaxproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
end

plt=computescale(plt);

%%
function plt=editxmin(plt)
% Compute new xmax
switch plt.projection
    case{'equirectangular'}
        plt.xmax=plt.xmin+(plt.position(3)/plt.position(4))*(plt.ymax-plt.ymin);
    case{'mercator'}
        plt.xmax=plt.xmin+(plt.position(3)/plt.position(4))*(merc(plt.ymax)-merc(plt.ymin));
    case{'albers'}
%        plt.xmax=plt.xmin+plt.position(3)*plt.scale/plt.fscale;
end

%%
function plt=editxmax(plt)

switch plt.projection
    case{'equirectangular'}
        plt.ymax=plt.ymin+(plt.position(4)/plt.position(3))*(plt.xmax-plt.xmin);
    case{'mercator'}
        plt.ymax=invmerc((plt.xmax-plt.xmin)/(plt.position(3)/plt.position(4))+merc(plt.ymin));
    case{'albers'}
%         [plt.xmin,plt.ymin]=albers(plt.xminproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [plt.xmax,dummy]=albers(plt.xmaxproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [dummy,plt.ymax]=albers(plt.xminproj,plt.ymaxproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
end

plt=computescale(plt);

%%
function plt=editymin(plt)

switch plt.projection
    case{'equirectangular'}
        plt.ymax=plt.ymin+(plt.xmax-plt.xmin)*plt.position(4)/plt.position(3);
    case{'mercator'}
%        plt.xmax=plt.xmin+(plt.position(3)/plt.position(4))*(merc(plt.ymax)-merc(plt.ymin));
        plt.ymax=invmerc((plt.xmax-plt.xmin)/(plt.position(3)/plt.position(4))+merc(plt.ymin));
    case{'albers'}
%         [plt.xmin,plt.ymin]=albers(plt.xminproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [plt.xmax,dummy]=albers(plt.xmaxproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [dummy,plt.ymax]=albers(plt.xminproj,plt.ymaxproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
end

plt=computescale(plt);

%%
function plt=editymax(plt)

switch plt.projection
    case{'equirectangular'}
        plt.xmax=plt.xmin+(plt.ymax-plt.ymin)*plt.position(3)/plt.position(4);
    case{'mercator'}
        plt.xmax=plt.xmin+(plt.position(3)/plt.position(4))*(merc(plt.ymax)-merc(plt.ymin));
    case{'albers'}
%         [plt.xmin,plt.ymin]=albers(plt.xminproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [plt.xmax,dummy]=albers(plt.xmaxproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [dummy,plt.ymax]=albers(plt.xminproj,plt.ymaxproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
end

plt=computescale(plt);

%%
function plt=editscale(plt)

% First compute new ymax, then new xmax

switch plt.projection
    case{'equirectangular'}
        plt.ymax=plt.ymin+plt.position(4)*plt.scale/plt.fscale;
    case{'mercator'}
        plt.ymax=invmerc(plt.scale*plt.position(4)/plt.fscale+merc(plt.ymin));
    case{'albers'}
%         plt.ymax=invmerc(plt.scale*plt.position(4)/plt.fscale+merc(plt.ymin));
end

switch plt.projection
    case{'equirectangular'}
        plt.xmax=plt.xmin+(plt.ymax-plt.ymin)*plt.position(3)/plt.position(4);
    case{'mercator'}
        plt.xmax=plt.xmin+(plt.position(3)/plt.position(4))*(merc(plt.ymax)-merc(plt.ymin));
    case{'albers'}
%         plt.xmax=plt.xmin+plt.position(3)*plt.scale/plt.fscale;        
%         plt.ymax=invmerc(plt.scale*plt.position(4)/plt.fscale+merc(plt.ymin));
end

%%
function plt=changezoom(plt)

plt=adjustprojectionlimits(plt);
switch plt.projection
    case{'equirectangular'}
        plt.xmin=plt.xminproj;
        plt.xmax=plt.xmaxproj;
        plt.ymin=plt.yminproj;
        plt.ymax=plt.ymaxproj;
%         [plt.xmin,plt.xmax,plt.xtick]=roundlimits(plt.xmin,plt.xmax);
%         [plt.ymin,plt.ymax,plt.ytick]=roundlimits(plt.ymin,plt.ymax);
    case{'mercator'}
        plt.xmin=plt.xminproj;
        plt.xmax=plt.xmaxproj;
        plt.ymin=invmerc(plt.yminproj);
        plt.ymax=invmerc(plt.ymaxproj);
%         [plt.xmin,plt.xmax,plt.xtick]=roundlimits(plt.xmin,plt.xmax);
%         [plt.ymin,plt.ymax,plt.ytick]=roundlimits(plt.ymin,plt.ymax);
    case{'albers'}
        plt.projection='albers';
        [plt.xmin,plt.ymin]=albers(plt.xminproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        [plt.xmax,dummy]=albers(plt.xmaxproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        [dummy,plt.ymax]=albers(plt.xminproj,plt.ymaxproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
%         [x1dummy,x2dummy,plt.xtick]=roundlimits(plt.xmin,plt.xmax);
%         [y1dummy,y2dummy,plt.ytick]=roundlimits(plt.ymin,plt.ymax);
end

plt=computescale(plt);

%%
function plt=changeall(plt)

switch plt.projection
    case{'equirectangular'}
        [plt.xmin,plt.xmax,plt.xtick]=roundlimits(plt.xmin,plt.xmax);
        [plt.ymin,plt.ymax,plt.ytick]=roundlimits(plt.ymin,plt.ymax);
        plt=setprojectionlimits(plt);
        plt=adjustprojectionlimits(plt);
        plt.xmin=plt.xminproj;
        plt.xmax=plt.xmaxproj;
        plt.ymin=plt.yminproj;
        plt.ymax=plt.ymaxproj;
    case{'mercator'}
        [plt.xmin,plt.xmax,plt.xtick]=roundlimits(plt.xmin,plt.xmax);
        [plt.ymin,plt.ymax,plt.ytick]=roundlimits(plt.ymin,plt.ymax);
        plt=setprojectionlimits(plt);
        plt=adjustprojectionlimits(plt);
        plt.xmin=plt.xminproj;
        plt.xmax=plt.xmaxproj;
        plt.ymin=invmerc(plt.yminproj);
        plt.ymax=invmerc(plt.ymaxproj);
    case{'albers'}
        [plt.xmin,plt.xmax,plt.xtick]=roundlimits(plt.xmin,plt.xmax);
        [plt.ymin,plt.ymax,plt.ytick]=roundlimits(plt.ymin,plt.ymax);
        plt=setprojectionlimits(plt);
        plt=adjustprojectionlimits(plt);
        plt.projection='albers';
        plt.labda0=0.5*(plt.xmin+plt.xmax);
        plt.phi0=0.5*(plt.ymin+plt.ymax);
        plt.phi1=plt.ymin;
        plt.phi2=plt.ymax;
        plt=setprojectionlimits(plt);
        [plt.xmin,plt.ymin]=albers(plt.xminproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        [plt.xmax,dummy]=albers(plt.xmaxproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        [dummy,plt.ymax]=albers(plt.xminproj,plt.ymaxproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
end

plt=computescale(plt);

%%
function plt=setprojectionlimits(plt)

switch plt.projection
    case{'equirectangular'}
        plt.xminproj=plt.xmin;
        plt.xmaxproj=plt.xmax;
        plt.yminproj=plt.ymin;
        plt.ymaxproj=plt.ymax;
    case{'mercator'}
        plt.xminproj=plt.xmin;
        plt.xmaxproj=plt.xmax;
        plt.yminproj=merc(plt.ymin);
        plt.ymaxproj=merc(plt.ymax);
    case{'albers'}
        [xlm(1),ylm(1)]=albers(plt.xmin,plt.ymin,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
        [xlm(2),ylm(2)]=albers(plt.xmax,plt.ymin,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
        [xlm(3),ylm(3)]=albers(plt.xmin,plt.ymax,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
        plt.xminproj=xlm(1);
        plt.yminproj=ylm(1);
        plt.xmaxproj=xlm(2);
        plt.ymaxproj=ylm(3);
end
%plt=adjustprojectionlimits(plt);

%%
function plt=adjustprojectionlimits(plt)

if (plt.xmaxproj-plt.xminproj)/plt.position(3)>(plt.ymaxproj-plt.yminproj)/plt.position(4)
    ymean=0.5*(plt.yminproj+plt.ymaxproj);
    plt.yminproj=ymean-0.5*(plt.xmaxproj-plt.xminproj)*plt.position(4)/plt.position(3);
    plt.ymaxproj=ymean+0.5*(plt.xmaxproj-plt.xminproj)*plt.position(4)/plt.position(3);    

    %plt.ymaxproj=plt.yminproj+(plt.xmaxproj-plt.xminproj)*plt.position(4)/plt.position(3);
else
    xmean=0.5*(plt.xminproj+plt.xmaxproj);
    plt.xminproj=xmean-0.5*(plt.ymaxproj-plt.yminproj)*plt.position(3)/plt.position(4);
    plt.xmaxproj=xmean+0.5*(plt.ymaxproj-plt.yminproj)*plt.position(3)/plt.position(4);
%    plt.xmaxproj=plt.xminproj+(plt.ymaxproj-plt.yminproj)*plt.position(3)/plt.position(4);
end

%%
function plt=computescale(plt)

switch plt.projection
    case{'equirectangular'}
        plt.scale=round(plt.fscale*(plt.ymax-plt.ymin)/plt.position(4));
    case{'mercator'}
%        plt.scale=round(plt.fscale*(merc(plt.ymax)-merc(plt.ymin))/plt.position(4));
        plt.scale=round(plt.fscale*(plt.ymax-plt.ymin)/plt.position(4));
    case{'albers'}
        [xx1,yy1]=albers(plt.xminproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        [xx2,yy2]=albers(plt.xmaxproj,plt.yminproj,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        dst=sqrt((cos(pi*0.5*(yy1+yy2)/180)*(xx2-xx1))^2+(yy2-yy1)^2);
        plt.scale=dst*plt.fscale/plt.position(3);
end
