function [LL,C]=loglike(phat,varargin)
%LOGLIKE Log-likelihood function.
% 
% CALL:  [L,cov] = loglike(phat,x1,x2,...,xN,dist);
%
%       L    = -log(f(phat|data)), i.e., the log-likelihood function
%              with parameters phat given the data.
%       cov  = Asymptotic covariance matrix of phat (if phat is estimated by
%              a maximum likelihood method).
%       phat = [A1,A2,...,Am], vector of distribution parameters.
% x1,x2,..xN = vectors of data points.
%       dist = string containing the name of the PDF.
%           
%  LOGLIKE is a utility function for maximum likelihood estimation. 
%  This works on any PDF having the following calling syntax:
%
%       f = testpdf(x1,x2,..,xN,A1,A2,..,Am)
%
% where x1,x2,...,xN contain the points to be evaluated and A1,A2... are
% the distribution parameters. 
%
% Example: MLE and asymptotic covariance of phat:
%   R = wweibrnd(1,3,100,1);                      
%   phat0 = [1.3 2.5];                             %initial guess
%   phat = fminsearch('loglike',phat0,[],R,'wweibpdf')
%   [L, cov] = loglike(phat,R,'wweibpdf')
%   [phat2 cov2] = wweibfit(R)                     % compare with wweibfit  


%Tested on: matlab 5.3
% History:
% by pab 31.10.2000


error(nargchk(3,inf,nargin))

params = num2cell(phat(:).',1);
data1  = varargin(1:end-1); % cell array of vectors with data points
dist   = varargin{end};
if ~ischar(dist),error('Distribution is unspecified'),end
for ix=1:length(data1),
  data1{ix}  = data1{ix}(:); %% make sure it is a vector.
end


x = feval(dist,data1{:},params{:})+eps; 
%x = x(:);  % make sure it is a vector.
LL = - sum(log(x)); % log likelihood function

if nargout == 2
  Nd     = length(x);
  np     = length(params);
  delta  = eps^.4;
  delta2 = delta^2;
  
  switch  2,
  case 1,  
    % Approximate 1/(nE( (d L(x|theta)/dtheta)^2)) with
    %             1/(d L(theta|x)/dtheta)^2  
    % This is a bad approximation especially for the off diagonal elements
    xp     = zeros(Nd,np);
    sparam = params;
    for ix = 1:np,
      sparam{ix}= params{ix}+delta;
      xp(:,ix) = feval(dist,data1{:},sparam{:})+eps;
      sparam{ix}= params{ix};
    end
    J = (log(xp) - repmat(log(x),1,np))./delta;
    [Q,R]= qr(J,0);
    Rinv = R\eye(np);
    C = Rinv'*Rinv;
  case 2,
    % Approximate 1/(nE( (d L(x|theta)/dtheta)^2)) with
    %             1/(d^2 L(theta|x)/dtheta^2) 
    %  using central differences
    % This is usually a much better estimate than case 1 and slightly
    % faster than case 3.
    H = zeros(np);             % Hessian matrix
    for ix=1:np,
      sparam = params;
      sparam{ix}= params{ix}+delta;
      x  = feval(dist,data1{:},sparam{:})+eps; 
      fp = sum(log(x));
      sparam{ix} = params{ix}-delta;
      x  = feval(dist,data1{:},sparam{:})+eps; 
      fm = sum(log(x));
      H(ix,ix) = (fp+2*LL+fm)/delta2;
      for iy=ix+1:np,
	sparam{ix} = params{ix}+delta;
	sparam{iy} = params{iy}+delta;
	x   = feval(dist,data1{:},sparam{:})+eps; 
	fpp = sum(log(x));
	sparam{iy} = params{iy}-delta;
	x   = feval(dist,data1{:},sparam{:})+eps; 
	fpm = sum(log(x));
	sparam{ix} = params{ix}-delta;
	x   = feval(dist,data1{:},sparam{:})+eps; 
	fmm = sum(log(x));
	sparam{iy} = params{iy}+delta;
	x   = feval(dist,data1{:},sparam{:})+eps; 
	fmp = sum(log(x));
	H(ix,iy) = (fpp-fmp-fpm+fmm)/(4*delta2);
	H(iy,ix) = H(ix,iy);
      end
    end
    % invert the Hessian matrix (i.e. invert the observed information number)
    C = -H\eye(np); 
  case 3,
    % Approximate 1/(nE( (d L(x|theta)/dtheta)^2)) with
    %             1/(d^2 L(theta|x)/dtheta^2) 
    % using differentiation matrices
    % This is the same as case 2 when N=3
   
    if 1, % 
      xn =[     1;     0;    -1];
      D(:,:,1) =[...
	    1.5000   -2.0000    0.5000;...
	    0.5000    0.0000   -0.5000;...
	    -0.5000    2.0000   -1.5000];
      D(:,:,2) =[...
	    1.0000   -2.0000    1.0000;...
	    1.0000   -2.0000    1.0000;...
	    1.0000   -2.0000    1.0000];
    else % If you have the differentiation matrix suite toolbox you may 
      %use this 
      % By increasing N better accuracy might be expected
      %N=3; % NB!: N must be odd
      %[xn D]=chebdif(N,2);  % construct differentiation matrix
    end
    N=length(xn);
    xn=xn.';
    % Construct differentiation matrices
    D11 = kron(D(:,:,1),D(:,:,1));  
    %D20 = kron(D(:,:,2),eye(N));
    %D02 = kron(eye(N),D(:,:,2));
    H   = zeros(np);           % Hessian matrix
    LL2 = zeros(N,N);          % Log likelihood evaluated at phat and in
                               % the vicinity of phat
			       
    N2 = (N+1)/2;              % The middle indices
    LL2(N2,N2) = -LL; % = sum(log(x))
    for ix=1:np,
      sparam = params;
      for iy = [1:N2-1 N2+1:N];
	sparam{ix}= params{ix}+xn(iy)*delta;
	x = feval(dist,data1{:},sparam{:})+eps;
	%sparam{ix} = params{ix}+xn(ones(Nd,1),iy)*delta;
	%x = feval(dist,repmat(data1,[1 length(iy)]),sparam{:})+eps; 
	LL2(iy,N2) = sum(log(x)).';
      end
      %sparam=params;
      H(ix,ix) = (D(N2,:,2)*LL2(:,N2))/delta2;
      for iy=ix+1:np,
	for iz=[1:N],
	  sparam{ix} = params{ix}+xn(iz)*delta;
	  for iw=[1:N2-1 N2+1:N];
	    sparam{iy}= params{iy}+xn(iw)*delta;
	    x = feval(dist,data1{:},sparam{:})+eps; 
	    %sparam{iy} = params{iy}+xn(ones(Nd,1),iw)*delta;
	    %x = feval(dist,repmat(data1,[1,length(iw)]),sparam{:})+eps; 
	    LL2(iz,iw) = sum(log(x));
	  end
	end
	H(ix,iy) = D11((N^2+1)/2,:)*LL2(:)/delta2;
	H(iy,ix) = H(ix,iy);
      end
    end
    % invert the Hessian matrix (i.e. invert the observed information number)
    C = -H\eye(np); 
  end
end

















