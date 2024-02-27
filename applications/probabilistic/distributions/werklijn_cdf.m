function P = werklijn_cdf(X, A)
% cdf according to "werklijn"  
% probability is translated to frequency.
% X is a piece-wise linear function of log(frequency)

% input
%   X:  x-value
%   A:  parameters of the werklijn
%
% output
%   P:  probability of non-exceedance

% read input parameters
nL = size(A,1);    % number of connecting points of piece-wise relation
a = A(:,3);        
b = A(:,4);        
XL = [A(:,1); inf];   % limits of piece-wise relation

% derive P-values
P = NaN(size(X));
for j=1:nL
    index = X>=XL(j) & X<XL(j+1);
    P(index) = exp(-exp(-(X(index)-b(j))./a(j)));
end


