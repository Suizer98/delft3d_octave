%ARROW2TEST   test for ARROW2
% This script shows why arrow2 performs better than quiver in distorted axes,
%
% For instance in crosssections through oceans and seas and rivers, where the
% width is generally in the order of (tens of) kilometeres, while the depth
% is only in the order of (tens) of meters: an ratio of order 1000.
% G.J. de Boer, Dec 2004
%
%See also: ARROW2

%% set options
OPT.arrowscale = 1;
OPT.dm         = 5;
OPT.dn         = 5;

%% test 1
    figure('name','arrow2test, case 1: distortion')
 
    [x,y,z] = peaks;
     y      = 100.*y;
    [u,v]   = gradient(z);
 
    pcolor(x,y,z)
    shading interp
    hold on
 
    H.quiver = quiver2(x,y,u,v,OPT.arrowscale,[OPT.dm OPT.dn],'w');
 
    I.scale = OPT.arrowscale;
    I.color = 'k';
    I.AspectRatioNormalisation = 1; %'min';
    
    H.arrow2 = arrow2    (x(1:OPT.dm:end,1:OPT.dn:end),...
                          y(1:OPT.dm:end,1:OPT.dn:end),...
                          u(1:OPT.dm:end,1:OPT.dn:end),...
                          v(1:OPT.dm:end,1:OPT.dn:end),I);
                     
    H.arrow = quiverarrow(x(1:OPT.dm:end,1:OPT.dn:end),...
                          y(1:OPT.dm:end,1:OPT.dn:end),...
                          u(1:OPT.dm:end,1:OPT.dn:end),...
                          v(1:OPT.dm:end,1:OPT.dn:end),OPT.arrowscale);

    set(H.arrow,'edgecolor',[.7 .7 .7]);
    set(H.arrow,'facecolor',[.7 .7 .7]);
                     
    H.arrow = quiverarrow(x(1:OPT.dm:end,1:OPT.dn:end),...
                          y(1:OPT.dm:end,1:OPT.dn:end),...
                          u(1:OPT.dm:end,1:OPT.dn:end),...
                          v(1:OPT.dm:end,1:OPT.dn:end),OPT.arrowscale,'distort');

    set(H.arrow,'edgecolor',[.3 .3 .3]);
    set(H.arrow,'facecolor',[.3 .3 .3]);

    title({'quiver: white // arrow2: black // (dark) gray: (distorted) quiverarrow > arrow'});
    
%% test 2
    figure('name','arrow2test, case 2: amplitude')

   [x,y] = meshgrid(-2:2:2,-2:2:2)
   u     = (x + y)./4;
   v     = (x - y)./4;
   
   plot(x,y,'o')
   hold on
   
   for i=1:length(x(:))
      txt{i} = strvcat([' u= ',num2str(u(i))],[' v= ',num2str(v(i))]);
      text(x(i),y(i),txt{i})
   end
   
   arrow2(x,y,u,v)
   
   grid