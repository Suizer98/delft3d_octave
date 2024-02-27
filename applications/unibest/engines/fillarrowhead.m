function [hf,XYarrow] = fillarrowhead(hq,varargin)

% function crossdist = fillarrowhead(qh,SizeHead,ColorSpec)
%
% Resizes and fills the arrowhead of a quiver
%
% input:
%   hq           handle of quiver
%   SizeHead     (optional) Size head relative to length of quiver (default = 0.2)
%   ColorSpec    (optional) colour specification of arrowhead fill (default = 'b')
%   SizeHeadY    (optional) Use different size for y scaling of arrow head
%   
% 
% Output:
%   hf           handle of filled quiver head
% 
% Example:
%   fillarrowhead(quiver_handle,0.3,'r')
%
% B.J.A. Huisman, 2008

if nargin==1
    SizeHead  = 0.2;
    ColorSpec = [];
elseif nargin==2
    SizeHead  = varargin{1};
    ColorSpec = [];
elseif nargin>=3
    SizeHead  = varargin{1};
    ColorSpec = varargin{2};
else
    fprintf('\n Wrong number of input parameters!\n');
end
SizeHeadY = SizeHead;
if nargin==4;SizeHeadY = varargin{3};end

children  = get(hq,'Children');
x_arrow   = get(children(1),'XData');
y_arrow   = get(children(1),'YData');
x_head    = get(children(2),'XData');
y_head    = get(children(2),'YData');

%reshape
x_arrow2   = reshape(x_arrow,[3,length(x_arrow)/3])';
y_arrow2   = reshape(y_arrow,[3,length(y_arrow)/3])';
x_head2    = reshape(x_head,[4,length(x_head)/4])';
y_head2    = reshape(y_head,[4,length(y_head)/4])';

%resize head
L_arrow   = mean(sqrt((x_arrow2(:,2)-x_arrow2(:,1)).^2 + (y_arrow2(:,2)-y_arrow2(:,1)).^2));
L_head    = mean(sqrt((mean(x_head2(:,[1,3]) - x_head2(:,[2,2]),2)).^2 + (mean(y_head2(:,[1,3]) - y_head2(:,[2,2]),2)).^2));

x_head3   = L_arrow * SizeHead / L_head * (x_head2 - x_head2(:,[2,2,2,2])) + x_head2(:,[2,2,2,2]);
y_head3   = L_arrow * SizeHeadY / L_head * (y_head2 - y_head2(:,[2,2,2,2])) + y_head2(:,[2,2,2,2]);

%reshape
x_head4    = reshape(rot90(x_head3),[1,size(x_head3,1)*size(x_head3,2)]);
y_head4   = reshape(rot90(y_head3),[1,size(y_head3,1)*size(y_head3,2)]);

%set handle
set(children(2),'XData',x_head4);
set(children(2),'YData',y_head4);

if ~isempty(ColorSpec)
    hf=zeros(size(x_head2,1),1);
    hold on;
    for ii=1:size(x_head2,1)
        hf(ii)=fill(x_head3(ii,1:3),y_head3(ii,1:3),ColorSpec);hold on;
        set(hf(ii),'EdgeColor',get(hf(ii),'FaceColor'));
    end
end
XYarrow = [x_arrow;y_arrow]';