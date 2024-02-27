function P = werklijn_pdf(X, A)
% pdf according to "werklijn"  
% probability is translated to frequency.
% X is a piece-wise linear function of log(frequency)

% input
%   X:    x-value
%   A:  parameters of the werklijn
%
% output
%   P:    probability density

% read input parameters
nL = size(A,1);    % number of connecting points of piece-wise relation
a = A(:,3);        
b = A(:,4);        
XL = [A(:,1); inf];   % limits of piece-wise relation

% derive P-values
P = NaN(size(X));
for j=1:nL
    index = X>=XL(j) & X<XL(j+1);
    P(index) = werklijn_cdf(X(index), A).*exp(-(X(index)-b(j))./a(j)).*(1./a(j));
end

% density
