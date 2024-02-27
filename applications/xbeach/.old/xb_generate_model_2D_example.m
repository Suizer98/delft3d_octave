function xb_generate_model_2D_example(varargin)
%XB_GENERATE_MODEL_2D_EXAMPLE  example of generating an XBeach 2D model
%
% This routine helps a user to setup a 2D XBeach model based on know X, Y,
% and Z input. The procedure contains the following steps:
%
%  * Get data (X, Y, Z)
%  * Generate input files with xb_generate_model_2D
%  * Run model
%
% See also XBeach, xb_generate_model_2D

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl	
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: 20 Apr 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: xb_generate_model_2D_example.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/xb_generate_model_2D_example.m $
% $Keywords: $

%% prepare input
% Retreive data (e.g. from OpenDAP server)
[X, Y, Z] = grid_orth_getDataInPolygon(...
    'dataset',          'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml', ...
    'starttime',        datenum([2008 12 31]), ...
    'searchinterval',   -2*365, ...
    'polygon',          [71966.6 70673.8 73869 75032.6 71966.6 ; 450142 451324 454704 453614 450142]', ...
    'datathinning',     1); %#ok<*UNRCH>

% reshape to a 3 column matrix, with x, y and z
xyz = [reshape(X,size(X,1)*size(X,2),1) reshape(Y,size(Y,1)*size(Y,2),1) reshape(Z,size(Z,1)*size(Z,2),1)];

[XB calcdir] = xb_generate_model_2D(xyz(:,1), xyz(:,2), xyz(:,3), varargin);

%% run model
[exefile exepath] = uigetfile('*.*', 'Select XBeach executable');
XB_run( ...
    'inpfile', fullfile(calcdir, 'params.txt'),...
    'exepath', exepath,...
    'exefile', exefile,...
    'np', 1,...
    'priority', '1:1',...
    'passphrase', '');

% % define stride to use
% datathinning = 10;
% stride       = [1 datathinning datathinning];
% 
% % identify a polygon within which to get the data
% poly = [68156.2 447856
% 	    68764.5 447415
% 	    69715.3 448519
% 	    69066.4 448960
% 	    68151.7 447861];
% 
% %% get base data
% % get data from ncfile
% [X_vect, Y_vect, Z] = getDataFromNetCDFGrid('ncfile', ncfile, 'starttime', now, 'searchwindow', -100, 'polygon', poly, 'stride', stride);
% 
% clear datathinning ncfile stride varargin 
% 
% % convert X_vect and Y_vect to X and Y matrices
% X = repmat(X_vect',size(Y_vect));
% Y = repmat(Y_vect,size(X_vect'));
% 
% clear X_vect Y_vect
% 
% % transform X, Y and Z matrices to x_vect, y_vect and z_vect
% x_vect = reshape(X,size(X,1)*size(X,2),1);
% y_vect = reshape(Y,size(Y,1)*size(Y,2),1);
% z_vect = reshape(Z,size(Z,1)*size(Z,2),1);
% 
% clear X Y Z 
% 
% %% run XBeach2D with the x, y and z vectors 
% XB = XBeach2D( ...
%     'XInitial', x_vect, ...
%     'YInitial', y_vect, ...
%     'ZInitial', z_vect, ...
%     'polygon',  poly, ...
%     'xori',     poly(1,1), ...
%     'yori',     poly(1,2), ...
%     'xend_y0',  [poly(2,1) poly(2,2)], ... % first along shore point
%     'x_yend',   [poly(3,1) poly(3,2)]);    % last along shore point moving along the shore keeping the beach to your right
% 
% figure(1);clf
% pcolor(XB.Input.xInitial, XB.Input.yInitial, XB.Input.zInitial)
% axis equal
