function varargout = plotc(x,y,c,marker,varargin)
%PLOTC   fast scatter/bubble plot (without auto color rescaling afterwards)
%
%    handle = plotc(X,Y,C,'MARKER') 
%
% plots the values of c colour coded at the 
% positions specified by x and y, and c (z-axis) in a 3-D axis
% system. A colorbar is added on the right side of the figure.
%
% The colorbar ticks stretch from the minimum value of c to its
% maximum in 9 steps (10 values).
%
% The last argument is optional to define the marker being used. The
% default is a point. To use a different marker (such as circles, ...) send
% its symbol to the function (which must be enclosed in '; see example).
%
% The plot is actually a 3D plot but the orientation of the axis is set
% such that it appears to be a plane 2D plot. However, you can toggle
% between 2D and 3D view either by using the command 'view(3)' (for 3D
% view) or 'view(2)' (for 2D), or by interactively rotating the axis
% system.
%
% NOTE:
% Unlike SCATTER, PLOTC marker colors are not linked to the caxis 
% and colorbar, but have fixed RGB colors assigned to them. 
% Changing the caxis after calling plotc will not affect the
% PLOTC marker colors.
%
% plotc comes from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/5718">Mathworks download central</a>, for copyright: edit plotc
%
% If 'CLimMode' is 'auto', PLOTC sets CAXIS equal to [min(V), max(V)],
% otherwise CAXIS limits are used to define the  RGB values of PLOTC markers.
%
%    handle = plotc(..) % returns handles 
%
% Example:
% Define three vectors
%    x=1:10;y=1:10;p=randn(10,1);
%    plotc(x,y,p)
%
%    x=randn(100,1);
%    y=2*x+randn(100,1);
%    p=randn(100,1);
%    plotc(x,y,p,'d')
%    view(3)
%
% See also: SCATTER

%% Version
% 2009 apr 02: 11:27:13 downloaded from: http://www.mathworks.com/matlabcentral/fileexchange/5718
% 2009 apr 02: improved documentation to OpenEarth standard
% 2009 apr 02: allow for user-defined caxis OR
% 2009 apr 02: set caxis to conform with automatic plotc range

%% Copyright:
%  Copyright: Uli Theune, University of Alberta, 2004

%% Input

   if nargin <4
       marker='.';
   end

%% make 1D and remove NaNs

   x = x(~isnan(c(:)));
   y = y(~isnan(c(:)));
   c = c(~isnan(c(:)));
   
   map = colormap;

%% Define RGB color scaling limits

   miv = min(c);
   mav = max(c);
   
   if isempty(miv)
      return
   end
   
   if strcmpi(get(gca,'CLimMode'),'auto')
      if miv==mav
         if miv > 0
            miv = 0;
         elseif miv==0
            miv = -1;
            mav =  1;
         else
            mav = 0;
         end
      end
      caxis([miv mav])
   else
      miv = clim1(1);
      mav = clim1(2);
   end

%% Plot the points

   hold on
   for i=1:length(x)
       in=round((c(i)-miv)*(length(map)-1)/(mav-miv));
       %--- Catch the out-of-range numbers
       if in<=0;in=1;end % changed to allow for values outside caxis range
       if in > length(map);in=length(map);end
       %--- Deal with in-range number
       handles(i) = plot3(x(i),y(i),c(i),marker,'color',map(in,:),'markerfacecolor',map(in,:));
   end
   hold off

if 0 % does not work

%% Re-format the colorbar

   h=colorbar;
   
   set(h,'ylim', [1 length(map)]); % this screws up the colorbar in 7.7.0.471 (R2008b)
   yal = linspace(1,length(map),10);
   set(h,'ytick',yal);

%% Create the yticklabels

   ytl = linspace(miv,mav,10);
   s   = char(10,4);
   for i=1:10
       if min(abs(ytl)) >= 0.001;B=sprintf('%-4.3f',ytl(i));
       else;                     B=sprintf('%-3.1E',ytl(i));
       end
       s(i,1:length(B))=B;
   end
   set  (h,'yticklabel',s);
   grid on
   view (2)
   
end % reformatcolorbar   

%% Output

   if nargout==1
      varargout = {handles};
   end

%% EOF

