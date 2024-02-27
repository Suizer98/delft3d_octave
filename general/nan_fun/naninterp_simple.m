function X2 = naninterp_simple(X1, option, method)

% Check all nans, do nothing
if sum(isnan(X1)) == length(X1);
    X2 = X1;
else
% Interpolate over NaNs
X2                  = X1;
id                  = find(~isnan(X1));
X2(isnan(X1))       = interp1(find(~isnan(X1)), X1(~isnan(X1)), find(isnan(X1)),method);

% Make more robuust
if isempty(option)
    option = 1;
end
if isempty(method)
    method = 'cubic';
end

% Linear at the ends
if option == 2;
    X2(1:id(1))         = X1(id(1));
    X2(id(end):end)     = X1(id(end));
elseif option == 3;
    X2(1: (id(1)-1))         = NaN;
    X2( (id(end)+1):end)     = NaN;
end
end

return