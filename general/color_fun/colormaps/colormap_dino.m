function varargout = colormap_dino(varargin)
%COLORMAP_DINO  colors coding of sediments according to dinoloket.nl
%
%    [map,label_list] = colormap_dino
%
%  labels   = colormap_dino(mapindex)
%  mapindex = colormap_dino(labels)
%
% where mapindex are indixes in the range 1:length(labels),
% NaN when supplied labels do not exist in label_list.
% where labels is a (nsted) cellstr
%
% Example:
%
%   nam = colormap_dino(2)
%   ind = colormap_dino(nam)
%   
%   nam = colormap_dino(2:4)
%   ind = colormap_dino(nam)
%
%   ind = colormap_dino({'gyttja','gravel','detritus','clay'})
%   ind = colormap_dino({{'gyttja','gravel'},{'detritus','clay'}})
%
% See also: JET, http://www.dinoloket.nl/, colormapeditor

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for NMDC.eu
%       Gerben de Boer
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: colormap_dino.m 7280 2012-09-25 14:56:18Z tda.x $
% $Date: 2012-09-25 22:56:18 +0800 (Tue, 25 Sep 2012) $
% $Author: tda.x $
% $Revision: 7280 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/colormap_dino.m $
% $Keywords: $

labels = {'clay',...
         'detritus',...
         'gravel',...
         'gyttja',... % = a mud rich in organic matter,
         'loam',...
         'no sample available',...
         'not named',...
         'peat',...
         'sand',...
         'shells'};
         
% colors grabbed from rgb screenshots cuts of color from 
% e.g. http://www.dinoloket.nl/dinoLks/minisite/Entry?datatype=bor&id=BF020264&queryProperty=NitgNumber
%
% for i=1:length(labels)
%    im = imread(['dino_',labels{i},'.png']);
%    disp(num2str(permute(im(1,1,:),[3 1 2])'))
% end

map = [148    0  211
       157  116   98 % same as gyttja
       255  204  102
       157  116   98 % same as detritus
       238  130  238
       255  255  255 % white
       255  255  255 % white
       244  164   96
       255  255    0
       255  153   0]./256;

if nargin==0
   varargout = {map, labels};
elseif isnumeric(varargin{1}) && ~isnan(varargin{1})
   indices   = varargin{1};
   varargout = {{labels{indices}}};
else % allow any nesting of labels, and return same structure
   label_values = varargin{1};
   if ischar(label_values)
      label_values = cellstr(label_values);
   end
   n = length(label_values);
   if iscellstr(label_values)
      indices = 1:n;
      for i=1:n
         ii = strmatch(lower(label_values{i}), labels, 'exact');
         if ~isempty(ii)
            indices(i) = ii;
         else
            indices(i) = nan;
         end
      end
   elseif iscell(label_values)
      for i=1:n
      disp(num2str(i))
      indices{i} = colormap_dino(label_values{i});
      end
   else
      indices = nan;
   end
   varargout = {indices};
end

