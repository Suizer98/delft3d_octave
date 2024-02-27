function wbmf2
% window motion callback function
% - this function will be called each time the mouse moves

% Created by Sandra Martinka March 2002
% Modified by Dano Roelvink Feb 2009
% Commented by Mark van Koningsveld April 2009

% $Id: wbmf2.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/xb_grid/wbmf2.m $
% $Keywords: $

global udata

%% get x1, y1 and x2, y2
x1       = udata.p1(1);
y1       = udata.p1(2);
x2       = udata.p2(1);
y2       = udata.p2(2);

%% determine angle
alfa     = atan2(y2-y1,x2-x1);
sina     = sin(alfa);
cosa     = cos(alfa);

%%
p3       = get(udata.h,'CurrentPoint');
x        = p3(1,1);
y        = p3(1,2);
yn       = -sina*(x-x1)+cosa*(y-y1);

%% get x3, y3 and x4, y4
x3       = x2-yn*sina;
y3       = y2+yn*cosa;
x4       = x1-yn*sina;
y4       = y1+yn*cosa;

%% collect information in xi and yi
xi       = [x1,x2,x3,x,x4,x1];
yi       = [y1,y2,y3,y,y4,y1];

%% set XData and YData on linehandle lh
set(udata.lh,'XData',xi, ...
             'YData',yi);

%% store lineinfo in userdata of current figure
udata.xi = xi;
udata.yi = yi;