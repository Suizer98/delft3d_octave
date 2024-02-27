function y = logpositive(x,varargin)
%LOGPOSITIVE   log returning NaN for <=0
%
%  y = logpositive(x) returns NaN for negative and 0 values.
%  Handy for troublesome log analyses of concentration 
%  fields (that are by definition not-negative.
%
% Example: 
%
%  logpositive([-Inf -1 -realmin 0 realmin NaN Inf])
%
%  yields [NaN NaN NaN NaN -708.3964 NaN Inf]
%
%See also: LOG, LOG10, LOG10POSITIVE, REALMIN

x(x<=0)=nan;

y = log(x);