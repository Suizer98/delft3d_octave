function [xi,yi]=select_area(varargin)
%function to draw a rubberband line and return the start and end points
%Usage: [xi,yi]=select_oblique_rectangle;     uses current axes
% or    [xi,yi]=select_oblique_rectangle(h);  uses axes refered to by handle, h

% Created by Sandra Martinka March 2002
% Modified by Dano Roelvink Feb 2009

switch nargin
case 0
  h=gca;
case 1
  h=varargin{1};
  axes(h);
otherwise
  disp('Too many input arguments.');
end
axis manual
cudata=get(gcf,'UserData'); %current UserData
hold on;
k=waitforbuttonpress;
p1=get(h,'CurrentPoint');       %get starting point
p1=p1(1,1:2);                   %extract x and y
lh=plot(p1(1),p1(2),'+:');      %plot starting point
udata.p1=p1;
udata.h=h;
udata.lh=lh;
set(gcf,'UserData',udata,'WindowButtonMotionFcn','wbmf','DoubleBuffer','on');
k=waitforbuttonpress;
p2=get(h,'Currentpoint');       %get end point
p2=p2(1,1:2);                   %extract x and y
udata.p2=p2;
set(gcf,'UserData',udata,'WindowButtonMotionFcn','wbmf2','DoubleBuffer','on');
k=waitforbuttonpress;
p3=get(h,'Currentpoint');       %get end point
p3=p3(1,1:2);                   %extract x and y
udata=get(gcf,'Userdata')
xi=udata.xi
yi=udata.yi
set(gcf,'UserData',cudata,'WindowButtonMotionFcn','','DoubleBuffer','off'); %reset UserData, etc..
delete(lh);
