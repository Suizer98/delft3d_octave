%% Coordinate conversion from RSP to RD

%% Introduction
% Sometimes one has data in the RSP grid, and this needs to be converted to
% RD coordinates. You can use the function jarkus_rsp2xy for this. Almost
% everything is already in the help. 

help jarkus_rsp2xy

%% example
% Example of the function:

x          = -100:50:200;  % some coordinates
areacode   = 7;            % Noord-Holland
alongshore = 3800;         % near Egmond

[xRD,yRD] = jarkus_rsp2xy(x,areacode,alongshore)


