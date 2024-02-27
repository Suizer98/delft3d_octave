function [IND, D] = nearestpoint(x,y,m) ;
% NEARESTPOINT - find the nearest value in another vector
%
%   IND = NEARESTPOINT(X,Y) finds the value in Y which is the closest to 
%   each value in X, so that abs(Xi-Yk) => abs(Xi-Yj) when k is not equal to j.
%   IND contains the indices of each of these points.
%   Example: 
%      NEARESTPOINT([1 4 12],[0 3]) -> [1 2 2]
%
%   [IND,D] = ... also returns the absolute distances in D,
%   that is D == abs(X - Y(IND))
%
%   NEARESTPOINT(X, Y, M) specifies the operation mode M:
%   'nearest' : default, same as above
%   'previous': find the points in Y that just precedes a point in X
%               NEARESTPOINT([1 4 12],[0 3],'previous') -> [1 1 1]
%   'next'    : find the points in Y that directly follow a point in X
%               NEARESTPOINT([1 4 12],[0 3],'next') -> [2 NaN NaN]
%
%   If there is no previous or next point in Y for a point X(i), IND(i)
%   will be NaN.
%
%   X and Y may be unsorted.
%
%   This function is quite fast, and especially suited for large arrays with
%   time data. For instance, X and Y may be the times of two separate events,
%   like simple and complex spike data of a neurophysiological study.
%
%   

%   Nearestpoint('test') will run a test to show it's effective ness for
%   large data sets

% Created       : august 2004
% Author        : Jos van der Geest
% Email         : matlab@jasen.nl
% Modifications : 
%  aug 25, 2004 - corrected to work with unsorted input values
%  nov 02, 2005 - 

if nargin==1 & strcmp(x,'test'),
    
    testnearestpoint ;
    return
end

error(nargchk(2,3,nargin)) ;

if nargin==2,
    m = 'nearest' ;
else
    if ~ischar(m),
        error('Mode argument should be a string (either ''nearest'', ''previous'', or ''next'')') ;
    end
end

if ~isa(x,'double') | ~isa(y,'double'),
    error('X and Y should be double matrices') ;
end

% sort the input vectors
sz = size(x) ;
[x, xi] = sort(x(:)) ; 
[dum, xi] = sort(xi) ; % for rearranging the output back to X
nx = numel(x) ; 
cx = zeros(nx,1) ;
qx = isnan(x) ; % for replacing NaNs with NaNs later on

[y,yi] = sort(y(:)) ; 
ny = length(y) ; 
cy = ones(ny,1) ;

xy = [x ; y] ;

[xy, xyi] = sort(xy) ;
cxy = [cx ; cy] ;
cxy = cxy(xyi) ; % cxy(i) = 0 -> xy(i) belongs to X, = 1 -> xy(i) belongs to Y
ii = cumsum(cxy) ;  
ii = ii(cxy==0).' ; % ii should be a row vector

% reduce overhead
clear cxy xy xyi ;

switch lower(m),
    case {'nearest','near','absolute'}
        % the indeces of the nearest point
        ii = [ii ; ii+1] ;
        ii(ii==0) = 1 ;
        ii(ii>ny) = ny ;         
        yy = y(ii) ;
        dy = abs(repmat(x.',2,1) - yy) ;
        [dum, ai] = min(dy) ;
        IND = ii(sub2ind(size(ii),ai,1:nx)) ;
    case {'previous','prev','before'}
        % the indices of the previous points
        ii = [ii(2:end) ii(end)] ;
        ii(ii < 1) = NaN ;
        IND = ii ;
    case {'next','after'}
        % the indices of the next points
        ii = ii + 1 ;
        ii(ii>ny) = NaN ;
        IND = ii ;
    otherwise
        error(sprintf('Unknown method "%s"',m)) ;
end

IND(qx) = NaN ; % put NaNs back in

if nargout==2,
    % also return distance if requested;
    D = repmat(NaN,1,nx) ;
    q = ~isnan(IND) ;    
    D(q) = abs(x(q) - y(IND(q))) ;
    D = reshape(D(xi),sz) ;
end
    
% reshape and sort to match input X
IND = reshape(IND(xi),sz) ;

% because Y was sorted, we have to unsort the indices
q = ~isnan(IND) ;
IND(q) = yi(IND(q)) ;

% END OF FUNCTION

function testnearestpoint
disp('TEST for nearestpoint, please wait ... ') ;
M = 13 ;
tim = repmat(NaN,M,3) ;
tim(8:M,1) = 2.^[8:M].' ;
figure('Name','NearestPointTest','doublebuffer','on') ;
h = plot(tim(:,1),tim(:,2),'bo-',tim(:,1),tim(:,3),'rs-') ;
xlabel('N') ;
ylabel('Time (seconds)') ;
title('Test for Nearestpoint function ... please wait ...') ;
set(gca,'xlim',[0 max(tim(:,1))+10]) ;
for j=8:M,
    N = 2.^j ;
    A = rand(N,1) ; B = rand(N,1) ;
    tic ;
    D1 = zeros(N,1) ;
    I1 = zeros(N,1) ;
    for i=1:N,
        [D1(i), I1(i)] = min(abs(A(i)-B)) ;
    end
    tim(j,2) = toc ;
    pause(0.1) ;
    tic ;
    [I2,D2] = nearestpoint(A,B) ;
    tim(j,3) = toc ;
    % isequal(I1,I2)
    set(h(1),'Ydata',tim(:,2)) ;
    set(h(2),'Ydata',tim(:,3)) ;
    drawnow ;
end
title('Test for Nearestpoint function') ;
legend('Traditional for-loop','Nearestpoint',2) ;


