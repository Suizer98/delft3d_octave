function h=colquiver(hline,cdata);
%COLQUIVER Color quiver plot
%   Replaces the uncolored quiver plot generated by QUIVER or QUIVER3
%   by a colored quiver plot.
%
%   COLQUIVER(HL,C)
%   where HL is the vector of line handles returned by QUIVER or QUIVER3
%   and C is a matrix of the same size as used to generate the quiver plot.
%
%   HP = COLQUIVER(...) returns a vector of patch handles.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      colquiver(quiver(x,y,px,py),sqrt(px.^2+py.^2))
%      hold off, axis image
%
%   See also QUIVER, QUIVER3.

%   Copyright (c) H.R.A. Jagers, Feb. 11, 2000
%   WL | Delft Hydraulics, Delft, The Netherlands

ch=get(hline,'Children');

x{1}=get(ch(1),'xdata');
y{1}=get(ch(1),'ydata');
z{1}=get(ch(1),'zdata');
x{2}=get(ch(2),'xdata');
y{2}=get(ch(2),'ydata');
z{2}=get(ch(2),'zdata');

quiv3=~isempty(z{1});
c=zeros(4,prod(size(cdata)));
c(1:3,:)=repmat(cdata(:)',3,1);
c(4,:)=NaN;
if quiv3,
  hpatch(2)=patch(repmat(x{2}',1,2),repmat(y{2}',1,2),repmat(z{2}',1,2),repmat(c(:),1,2), ...
                  'parent',get(hline(1),'parent'), ...
                  'edgecolor','flat','facecolor','none');
  c=c(2:4,:);
  hpatch(1)=patch(repmat(x{1}',1,2),repmat(y{1}',1,2),repmat(z{1}',1,2),repmat(c(:),1,2), ...
                  'parent',get(hline(1),'parent'), ...
                  'edgecolor','flat','facecolor','none');
else,
  hpatch(2)=patch(repmat(x{2}',1,2),repmat(y{2}',1,2),repmat(c(:),1,2), ...
                  'parent',get(hline(1),'parent'), ...
                  'edgecolor','flat','facecolor','none');
  c=c(2:4,:);
  hpatch(1)=patch(repmat(x{1}',1,2),repmat(y{1}',1,2),repmat(c(:),1,2), ...
                  'parent',get(hline(1),'parent'), ...
                  'edgecolor','flat','facecolor','none');
end;
delete(hline);
if nargout>0,
  h=hpatch;
end;