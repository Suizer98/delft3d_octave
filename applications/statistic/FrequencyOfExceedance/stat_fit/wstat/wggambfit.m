function l=wggambfit(b,data,F,def)
%WGGAMBFIT Is an internal routine for wggamfit
%

% History
% revised pab 27.01.2001
if nargin<4|isempty(def),def=1;end

monitor = logical(0);
switch def
  case 1,
    %ld  = log(data); 
    ld  = F;
    mld = mean(ld);
    db  = data.^b;
    sdb = sum(db);
    a   = -(b*(mld-sum(db.*ld)/sdb))^(-1);
    h   = 1e-6;
    h1  = .5*1e+6;
    if a<h|isnan(a), % Avoid error with gammaln for a<0 pab 27.01.2001
      l = NaN;
    else
      l = -(gammaln(a+h)-gammaln(a-h))*h1+b*mld ....
	  -log(sdb)+log(length(data)*a);
    end
  case 2, % LS-fit to empirical CDF
    x   = data;
    tmp = sqrt(-log(1-F));
    tmp2 = sqrt(-log(1-wggamcdf(x,b(1),b(2),b(3))));
    if monitor
      plot(x,[ tmp tmp2]); drawnow
    end
    l = mean(abs(tmp-tmp2).^(2));
  case 3,% Moment fit: data = E(x^2)/E(x)^2,F= E(x^3)/E(x^2)^(3/2)
    l = ...
	sum([(gamma(b(1))*gamma(b(1)+2/b(2))/gamma(b(1)+1/b(2))^2-data)^2+...
	  (sqrt(gamma(b(1)))*gamma(b(1)+3/b(2))/gamma(b(1)+2/b(2))^1.5-F)^2]);
  case 4,% Moment fit: data = E(x^3)/E(x^2)^(3/2),F= E(x^4)/E(x^2)^(2)
    l = sum([(sqrt(gamma(b(1)))*gamma(b(1)+3/b(2))/gamma(b(1)+2/b(2))^1.5-data)^2+...
	  (gamma(b(1))*gamma(b(1)+4/b(2))/gamma(b(1)+2/b(2))^2-F)^2]);
end

if monitor
  disp(['err = ' num2str(l,10)   ' phat = ' num2str(b,4) ])
end
