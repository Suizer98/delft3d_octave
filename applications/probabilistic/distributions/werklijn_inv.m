function X = werklijn_inv(P, A)
% inverse probability distribution function 
% probability is translated to frequency.
% X is a piece-wise linear function of log(frequency)

% input
%   P:    probability of non-exceedance
%   A:  parameters of the werklijn
%
% output
%   X:    x-value, asociated with P


% read input parameters
nL = size(A,1);    % number of connecting points of piece-wise relation
a = A(:,3);        
b = A(:,4);        
RPL = [A(:,2); inf];   % limits of piece-wise relation

% transform probability of non-exceedance frequency of exceedance
Fe = -log(P);
RP = 1./Fe;    % return period

% derive X-values
X = NaN(size(P));
for j=1:nL
    index = RP>=RPL(j) & RP<RPL(j+1);
    X(index) = a(j)*log(RP(index))+b(j);
end


