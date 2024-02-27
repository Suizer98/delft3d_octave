%PLOT_GRID Plot Values corresponding to X and Y
%   PLOT_GRID(X, Y, Z) 
%   Plots values according with the longitud and latitude.
%   Arguments:
%   <X> longitud
%   <Y> latitud
%   NOTE : If <Z> is a matrix of dim (n,m) 
%          <X> and <Y> could be matrices of dimension (n,m) 
%          or could be vectors of length (n) and length (m)
%   See also: PCOLORCORCEN, PCOLOR, CONTOUR

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 05.06.2009
%      Author: S. Gaytan Aguilar
%--------------------------------------------------------------------------
function plot_grid(varargin)

% Check arguments
[X, Y, extraSpec] = checkargin(varargin{:});
    
% Some settings for the figure
set(gcf,'Color','w');
hold on

% Ploting after having the correct arguments   
plot(X,Y,extraSpec{:})
plot(X',Y',extraSpec{:})

% Titles
% set(gca,'xticklabel',{})
% set(gca,'yticklabel',{})
% box on
axis image

%--------------------------------------------------------------------------
%CHECKARGIN This fuction check the arguments to be used in the plottig%
function [X Y extraSpec] = checkargin(varargin)

if isstruct(varargin{1})
    if all(isfield(varargin{1},{'X', 'Y'}))
       [X, Y] = deal(varargin{1}.X,varargin{1}.Y);   
    elseif all(isfield(varargin{1},{'x', 'y'}))        
       [X, Y] = deal(varargin{1}.x,varargin{1}.y);   
    end
   if nargin>1
      extraSpec = {varargin{2:end}}; %#ok<*CCAT1>
   else
      extraSpec = {'-k'};
   end
elseif ischar(varargin{1}) && exist(varargin{1},'file')
   structGrid = delwaq('open',varargin{1});
   X = structGrid.X;
   Y = structGrid.Y;
   if nargin>1
      extraSpec = {varargin{2:end}};
   else
      extraSpec = {'-k'};
   end
else
   [X, Y] = deal(varargin{1:2});
   if nargin>2
      extraSpec = {varargin{3:end}};
   else
      extraSpec = {'-k'};
   end
end
