function [P,L,u]=pointTOline(P1,P2,P3)
% Resolves the normal distance from a point to a line. 
% The line is defined by P1 and P2 (points with x and y coordinate), while
% the point is defined as P3. The distance is computed from P3 to the line 
% in-between P1 and P2 given that the line is normal to 'P2-P1 line'.
%
% Input:
%   P1   array with x,y coordinates of P1 (line point 1)
%   P2   array with x,y coordinates of P2 (line point 2)
%   P3   array with x,y coordinates of P3
%
% Output:
%   P    location of projected point on line P1 to P2
%   L    distance of line from P3 to point P (line is normal to P2-P1) 
%   u    fraction of distance of point P along line between P2 and P1
% 
% Example:
%   P1 = [0,1];
%   P2 = [2,3];
%   P3 = [1,1.5];
%   [P,L,u]=pointTOline(P1,P2,P3);
%   plot([P1(1);P2(1)],[P1(2);P2(2)],'r*-');hold on;plot(P3(1),P3(2),'ks');
%   axis equal;plot(P(1),P(2),'g+');plot([P(1),P3(1)],[P(2),P3(2)],'k:');

x1=P1(1);
y1=P1(2);
x2=P2(1);
y2=P2(2);
x3=P3(1);
y3=P3(2);

u = ((x3-x1)*(x2-x1)+(y3-y1)*(y2-y1)) / ((x2-x1).^2+(y2-y1).^2);
x = x1+u*(x2-x1);
y = y1+u*(y2-y1);
P = [x;y];
L = ((x-x3).^2+(y-y3).^2).^0.5;