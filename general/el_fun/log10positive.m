function y = log10positive(x,varargin)
%LOG10POSITIVE   log10 returning NaN for <=0
%
%  y = log10positive(x) returns NaN for negative and 0 values.
%  Handy for troublesome log analyses of concentration 
%  fields (that are by definition not-negative.
%
% Example: 
%
%  log10positive([-Inf -1 -realmin 0 realmin NaN Inf])
%
%  yields [NaN NaN NaN NaN -307.6527 NaN Inf]
%
%See also: LOG, LOG10, LOGPOSITIVE, REALMIN

x(x<=0)=nan;

y = log10(x);