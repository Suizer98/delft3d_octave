function [xi,yi]=rbline(varargin)
% RBLINE   function to draw a rubberband line and return the start and end points
%
% Usage: [p1,p2]=rbline;     uses current axes
%   or    [p1,p2]=rbline(h);  uses axes refered to by handle, h

% Created by Sandra Martinka March 2002

switch nargin
    case 0
        h=gca;
    case 1
        h=varargin{1};
        axes(h);
    otherwise
        disp('Too many input arguments.');
end

cudata=get(gcf,'UserData'); %current UserData
hold on;

%% get the first buttonpress and plot that location
k           = waitforbuttonpress;
p1          = get(h,'CurrentPoint');       % get starting point
p1          = p1(1,1:2);                   % extract x and y

% plot the starting point
lh          = plot(p1(1),p1(2),'+:');      % plot starting point
drawnow

% prepare the variable udata before placing it in the figures UserData
udata.p1    = p1;
udata.h     = h;
udata.lh    = lh;
set(gcf,'UserData',udata,'WindowButtonMotionFcn','wbmf','DoubleBuffer','on');

%% get the second buttonpress and plot that location
k           = waitforbuttonpress;
p2          = get(h,'Currentpoint');       %get end point
p2          = p2(1,1:2);                   %extract x and y

% add p2 to the variable udata and placing it in the figures UserData
udata.p2    = p2;
set(gcf,'UserData',udata,'WindowButtonMotionFcn','wbmf2','DoubleBuffer','on');

%% get the second buttonpress and plot that location
k       = waitforbuttonpress;
p3      = get(h,'Currentpoint');       %get end point

% add p2 to the variable udata and placing it in the figures UserData
p3      = p3(1,1:2);                   %extract x and y
udata   = get(gcf,'Userdata')

xi      = udata.xi;
yi      = udata.yi;

set(gcf,'UserData',cudata,'WindowButtonMotionFcn','','DoubleBuffer','off'); % reset UserData, etc..

delete(lh);
