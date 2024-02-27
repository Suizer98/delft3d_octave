function [phat, cov,pci]=wggamfit(data1, plotflag);
%WGGAMFIT Parameter estimates for Generalized Gamma data.
%
% CALL:  [phat, cov] = wggamfit(data, plotflag)
%
%     phat = [a,b,c] = the maximum likelihood estimates of the  
%            parameters of the Generalized Gamma distribution
%            (see wggampdf) given the data.
%     cov  = estimated asymptotic covariance matrix of estimates
%     data = data vector
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
% 
% Example:
%   R = wggamrnd(2,2,2,1,100);
%   [phat, cov] = wggamfit(R,2)
%
% See also:  wggamcdf, empdistr

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 220 ff, Marcel Dekker.

% Tested on: Matlab 5.3
% History:
% revised pab 27.01.2001
%  - Improved the stability of estimation by adding a linear search to
%    find the largest sign change with positive derivative.
% revised pab 13.11.2000
%  - added check on estimated parameters -> return NaN when any is less
%    than zero
% revised pab 
%  -changed the order of a,b,c
%  -safer call to fzero 
% rewritten ms 10.08.2000


error(nargchk(1,2,nargin))
if nargin < 2 | isempty(plotflag), plotflag=1;end 
cov   = []; pci=[];
data  = sort(data1(:)); % make sure it is a vector

% Use Weibull start for c (assuming a=1)
ld   = log(data);
start = 1./(6^(1/2)/pi*std(ld)); % approx sqrt(a)*c

if 1, % Do linear search to find a sign change pab 28.01.2001
  % -> more stable estimation
  x  = [linspace(max(eps,start/100),start,25) linspace(start+1,10*start+20,15)]; 
  %x  = [linspace(eps,start,50) linspace(start+1,start+20,10)]; 
  ll = zeros(size(x));
  ll(1) = wggambfit(x(1),data,ld);
  for ix=2:length(x),
    ll(ix) = wggambfit(x(ix),data,ld);
    if ll(ix-1)<ll(ix)&ll(ix)>0 ,x(ix+1:end)=[];ll(ix+1:end)=[];break,end
  end
  
  ind = find(isnan(ll));
  ll(ind) = [];
  x(ind)  = [];
  dll=diff(ll)./diff(x);
  % figure(1),  plot(x,ll,(x(1:end-1)+x(2:end))/2 ,dll,'r');axis([0 inf -0.1 0.1]),figure(2)
  sl = sign(ll);
  %choose the largest sign change with positive derivative
  ind = max(find(sl(1:end-1)<sl(2:end) ) ); 
  if ~isempty(ind)
    start = x(ind:ind+1);
  elseif any(dll>0)
    start = x(min(find(dll>0)));
  end
end
%start
mvrs = version;
ix   = find(mvrs=='.');
mvrs = str2num(mvrs(1:ix(2)-1));
if (mvrs > 5.2),
   chat = fzero('wggambfit',start,optimset,data,ld);
else
   chat = fzero('wggambfit',start,sqrt(eps),[],data,ld);
end	

dc   = data.^chat;
ahat = -(chat*(mean(ld)-sum(dc.*ld)/sum(dc)))^(-1);
bhat = (mean(dc)/ahat).^(1/chat);
phat = [ahat, bhat, chat];

if any(phat<=0|isnan(phat)), 
  phat(1:3)=NaN;cov=phat;pci=cov;
  return,
  chat = start(end)+10; %1./(6^(1/2)/pi*std(log(data)));
  ahat =-(chat*(mean(ld)-sum(data.^chat.*ld)/sum(data.^chat)))^(-1);
  bhat = (mean(data.^chat)/ahat).^(1/chat);
  phat0 = max([ahat, bhat, chat],sqrt(eps))
  if 1, % Moments fit
    Ex = mean(data);
    Ex2 = mean(data.^2);
    Ex3 = mean(data.^3);
    Ex4 = mean(data.^4);
    phat1 = fmins('wggambfit',phat0(1:2:3),[],[],Ex2/Ex^2,Ex3/Ex2^1.5,3)
    phat1 = fmins('wggambfit',phat0(1:2:3),[],[],Ex3/Ex2^1.5,Ex4/Ex2^2,4)
    %phat0  = [mean(data.^start).^(1./start) start];
  end
  if mvrs>5.2
    phat = fminsearch('loglike',phat0,[],data,'wggampdf');
   % N =length(data);
   % phat = fminsearch('wggambfit',phat0,[],data,(.5:N)'/N,2)
  else
    phat = fmins('loglike',phat0,[],[],data,'wggampdf');
  end
  ahat = phat(1);
  bhat = phat(2);
  chat = phat(3);
  if any(phat<=0|isnan(phat)), 
    phat(1:3)=NaN;cov=phat;pci=cov;return,
  end
end

if nargout>1,
  h=10^(-5);

  c1=(gammaln(ahat+h)-gammaln(ahat))/h;
  c2=(gammaln(ahat+1+h)-gammaln(ahat+1))/h;
  c3=(gammaln(ahat+2*h)-2*gammaln(ahat+h)+gammaln(ahat))/h^2;
  c4=(gammaln(ahat+1+2*h)-2*gammaln(ahat+1+h)+gammaln(ahat+1))/h^2;

  cov=[c3, -c1/chat, chat/bhat;
    -c1/chat, (1+ahat*c4+ahat*c2^2)/chat^2, -(1+ahat*c1)/bhat;
    chat/bhat, -(1+ahat*c1)/bhat, ahat*chat^2/bhat^2]/length(data);
   
  %[LL, cov] = loglike(phat,data,'wggampdf');
end
if nargout>2
  alpha2 = ones(1,3)*0.05/2;
  var = diag(cov).';
  pci = wnorminv([alpha2;1-alpha2], [phat;phat],[var;var]);
end
if plotflag
%  sd=sort(data);
  sd = data;
  empdistr(sd,[sd, wggamcdf(sd,ahat,bhat,chat)],plotflag)
  title([deblank(['Empirical and Generalized Gamma estimated cdf'])])
end






