function standarddev = sums2std(nx,sumx,sumx2,varargin)
%SUMS2STD   returns std from sum and sum of squares (Steiner's rule)
%
% sums2std(nx,sumx,sumx2) returns the standard deviation
% given the sum and the sum of all squares of a dataset (sum2).
%
% sums2std(nx,sumx,sumx2) normalizes by (nx-1)
% sums2std(nx,sumx,sumx2,1) normalizes by (nx)
% Note that this convention is in agreement with
% the one used by the matlab function std.
%
% It basically applies Steiners rule and is useful when 
% you want to calculate the std of images/arrays, that you
% cannot load into memory at once, so you have to go 
% through them one by one, keeping track of n, sum and sum2.
%
%See also: SUM, STD

% $Id: sums2std.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/sums2std.m $
% $Keywords$

if nargin==4 & varargin{1}==1
   nx(nx==0)=nan;
   standarddev = sqrt(1./(nx  ).*abs(sumx2-sumx.^2./nx));
else
   nx(nx<=1)=nan;
   standarddev = sqrt(1./(nx-1).*abs(sumx2-sumx.^2./nx));
end 

%%>> help std
%%
%% STD    Standard deviation.
%%    For vectors, STD(X) returns the standard deviation. For matrices,
%%    STD(X) is a row vector containing the standard deviation of each
%%    column.  For N-D arrays, STD(X) is the standard deviation of the
%%    elements along the first non-singleton dimension of X.
%% 
%%    STD(X) normalizes by (N-1) where N is the sequence length.  This
%%    makes STD(X).^2 the best unbiased estimate of the variance if X
%%    is a sample from a normal distribution.
%% 
%%    STD(X,1) normalizes by N and produces the square root of the
%%    second moment of the sample about its mean.  STD(X,0) is the
%%    same as STD(X).
%% 
%%    STD(X,FLAG,DIM) takes the standard deviation along the dimension
%%    DIM of X.  When FLAG=0 STD normalizes by (N-1), otherwise STD
%%    normalizes by N.
%% 
%%    Example: If X = [4 -2 1
%%                     9  5 7]
%%      then std(X,0,1) is [ 3.5355 4.9497 4.2426] and std(X,0,2) is [3.0
%%                                                                    2.0]
%%    See also COV, MEAN, VAR, MEDIAN, CORRCOEF.
