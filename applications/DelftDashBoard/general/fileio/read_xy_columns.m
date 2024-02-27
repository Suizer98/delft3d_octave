function [x,y]=read_xy_columns(filename)
% [X,Y]=READ_XY_COLUMNS(FILENAME)
%

% (c) Copyright IHE Delft, 2021.
%     Created by Dano Roelvink - IHE Delft / Deltares

xy=load(filename);
x=xy(:,1)';
y=xy(:,2)';