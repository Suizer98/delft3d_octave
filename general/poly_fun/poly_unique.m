function [xu,yu,varargout] = poly_unique(x,y,varargin)
%poly_unique  returns unique points in polygon
%
%  [xu,yu,<zu>,<ind>] = poly_unique(x,y,<z>)
%
% where (xu,yu) are the unique points from (x,y) and properties
% (i) without max. 1 NaN as last value in xu, as in nanunique
% (ii) with xu has same orientation as x (row or column) and 
% (iii) precision for uniqueness can be specified with keyword 'eps'.
% These make POLY_UNIQUE different than use of UNIQUE as in:
% M = unique([p.x(:),p.y(:)],'rows');xu = M(:,1);yu = M(:,2);
%
% Optionally ind is resulted, the index of xu (unique point index)
% associated with each input x such that x = xu(ind).
%
%See also: unique, nanunique, poly_fun, sortrows, eps, unique_rows_tolerance

% TO DO: make more generic: handle any number of input vectors
% just like sortrows does: make UNIQUEROWS

OPT.eps = eps('single');

if odd(nargin)
    z = varargin{1};
    varargin(1) = [];
end

if nargin==0
    xu = OPT;return
end

OPT = setproperty(OPT,varargin);

% create dummy-value for NaN which is larger than the maximum finite value in x,y
% and replace all NaN-values with this dummy-value (tric nanunique)
x4nan = max(x(isfinite(x(:))))+1;
y4nan = max(y(isfinite(y(:))))+1;

if exist('z','var')
   z4nan = max(z(isfinite(z(:))))+1;
   nanmask = isnan(x) | isnan(y) | isnan(z);
   x(nanmask) = x4nan;
   y(nanmask) = y4nan;   
   z(nanmask) = z4nan;
   A = [x(:),y(:),z(:)];
else
   nanmask = isnan(x) | isnan(y);
   x(nanmask) = x4nan;
   y(nanmask) = y4nan; 
   A = [x(:),y(:)];
end

% [A,Ix]  = sortrows(A);
% 
% % get inverse index (do not fully understand myself yet)
% [~,Iy] = sortrows(Ix);
% 
% % DOES SAME: unique(M,'rows') BUT does not allow to specify eps
% A0           = true([1 size(A,2)]);
% unique_index = any([A0;~(abs(diff(A,1,1))<OPT.eps)],2);
% mask         = unique_index;
% C            = A(mask,:);
% ind          = cumsum(mask);
% ind = ind(Iy);

[C,~,IC] = unique_rows_tolerance(A,OPT.eps);

xu = C(:,1);xu(xu==x4nan)=NaN;
yu = C(:,2);yu(yu==y4nan)=NaN;
if isrow(x)
    xu = xu';yu=yu';
end
 
if exist('z','var')
    zu = C(:,3);zu(zu==z4nan)=NaN;
    if isrow(x)
        zu=zu';
    end
end

%%
if     exist('z','var') &  nargout==3
       varargout = {zu};
elseif exist('z','var') &  nargout==4
       varargout = {zu,IC};        
else
       varargout = {IC};       
end
