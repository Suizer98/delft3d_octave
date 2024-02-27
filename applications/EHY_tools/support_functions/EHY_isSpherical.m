function TF = EHY_isSpherical(X,Y)
% This function makes an educated guess if the provided X or LON and Y or
% LAT values are spherical (TRUE) or not (FALSE). A logical is returned.

TF = false;

% only use no-nan values (and turn X and Y into 1D-arrays)
X = X(~isnan(X));
Y = Y(~isnan(Y));

if all(X>=-180) && all(X<=180) && all(Y>=-90) && all(Y<=90)
    TF = true;
end