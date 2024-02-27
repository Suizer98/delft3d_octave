function [xi,yi,w,h]=select_oblique_rectangle(varargin)
%function to draw a rubberband line and return the start and end points
%Usage: [xi,yi] = select_oblique_rectangle;     uses current axes
% or    [xi,yi] = select_oblique_rectangle(h);  uses axes refered to by handle, h

% Created by Sandra Martinka March 2002
% Modified by Dano Roelvink Feb 2009
% Commented by Mark van Koningsveld April 2009

global udata

%% check number of arguments in
switch nargin
    case 0
        h = gca;
    case 1
        h = varargin{1};
        axes(h);
    otherwise
        disp('Too many input arguments.');
end

%% set axis properties
axis manual; hold on;

%% extract user data from figure (to be reattached to figure at the end of this routine) 
cudata   = get(gcf,'UserData');         % current UserData

%% start selection of oblique rectangle
% ----

%% get first location
% initiate waitforbuttonpress for first location
waitforbuttonpress;

% extract information from next button click, plot location and store click location in udata 
p1       = get(h,'CurrentPoint');       % get starting point
p1       = p1(1,1:2);                   % extract x and y
lh       = plot(p1(1),p1(2),'+:');      % plot starting point

drawnow

udata.p1 = p1;                          % add info to udata (first click location)
udata.h  = h;                           % add info to udata (axes handle)
udata.lh = lh;                          % add info to udata (line handle)
% set(gcf,'UserData',udata);              % store udata in userdata

%% get second location
% set WindowButtonMotionFcn and initiate waitforbuttonpress for second location
set(gcf,'WindowButtonMotionFcn','wbmf','DoubleBuffer','on');
waitforbuttonpress;

% extract information from next button click, plot location and store click location in udata 
p2       = get(h,'Currentpoint');       % get end point
p2       = p2(1,1:2);                   % extract x and y
udata.p2 = p2;                          % add info to udata
% set(gcf,'UserData',udata);              % store udata in userdata

%% get third location
% set WindowButtonMotionFcn and initiate waitforbuttonpress for third location
set(gcf,'WindowButtonMotionFcn','wbmf2','DoubleBuffer','on');
waitforbuttonpress;

% extract information from first button click, plot location and store click location in udata 
p3       = get(h,'Currentpoint');       %get end point
p3       = p3(1,1:2);                   %extract x and y
udata.p3 = p3;                          % add info to udata

%% compute fourth location
p4       = (p3-p2)+p1;
udata.p4 = p4;  

%% take care of function output
% udata    = get(gcf,'Userdata');
xi(1)       = [udata.p1(1)];
yi(1)       = [udata.p1(2)];
xi(2)       = [udata.p2(1)];
yi(2)       = [udata.p2(2)];
xi(3)       = [udata.p3(1)];
yi(3)       = [udata.p3(2)];
xi(4)       = [udata.p4(1)];
yi(4)       = [udata.p4(2)];
w        = sqrt(sum((p3-p2).^2));
h        = sqrt(sum((p2-p1).^2));

%% reset UserData and delete linehandle lh
set(gcf,'UserData',cudata,'WindowButtonMotionFcn','','DoubleBuffer','off'); 
delete(lh);

clear udata