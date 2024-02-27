function varargout = plotbox(xy,varargin)
%PLOTBOX   plots a bounding box
%
% plotbox(axisbox,<c>,...)
%
% where axisbox is an array of 4 as returned by axis.
% plotbox has the same syntax as PLOT. The optional c 
% argument is the color of the area. If c is specified
% the box will be a patch(), otherwise a line().
%
% Example: 
%  pcolor(peaks);hold on
%  plotbox([35 45 5 10],'k')
%
% See also: BOX, AXIS, PLOT

if odd(nargin)
h = plot([xy(1) xy(2) xy(2) xy(1) xy(1)],...
         [xy(3) xy(3) xy(4) xy(4) xy(3)],varargin{:});
else
h = patch([xy(1) xy(2) xy(2) xy(1) xy(1)],...
          [xy(3) xy(3) xy(4) xy(4) xy(3)],varargin{:});
end
         
if nargout==1
   varargout = {h};
end
