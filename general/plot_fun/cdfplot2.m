function hp = cdfplot2(X)
% cdfplot(X) 
% displays a plot of the Empirical Cumulative Distribution Function 
% (CDF) of the input array X in the current figure. The empirical 
% CDF y=F(x) is defined as the proportion of X values less than or equal to x.
% If input X is a matrix, then cdfplot(X) parses it to the vector and 
% displays CDF of all values.
%
% EXAMPLE:
% figure;
% cdfplot(randn(1,100));
% hold on;
% cdfplot(-log(1-rand(1,100)));
% cdfplot(sqrt(randn(1,100).^2 + randn(1,100).^2))
% legend('Normal(0,1) CDF', 'Exponential(1) CDF', 'Rayleigh(1) CDF', 4)

% Version 1.0
% Alex Podgaetsky, September 2003
% alex@wavion.co.il
%
% Revisions:
%       Version 1.0 -   initial version

tmp = sort(reshape(X,prod(size(X)),1));
Xplot = reshape([tmp tmp].',2*length(tmp),1);

tmp = [1:length(X)].'/length(X);
Yplot = reshape([tmp tmp].',2*length(tmp),1);
Yplot = [0; Yplot(1:(end-1))];

hp = plot(Xplot, Yplot,'linewidth', 2);

