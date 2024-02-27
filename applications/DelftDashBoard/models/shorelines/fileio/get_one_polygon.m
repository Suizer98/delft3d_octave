function [ x,y,n_mc,i1,i2 ] = get_one_polygon( x_mc,y_mc,i_mc )
% function [ x,y,n_mc,i1,i2 ] = get_one_polygon( x_mc,y_mc,i_mc )
%
% Copyright : IHE-delft & Deltares, 2020-feb
% Authors   : Dano Roelvink
% License   : GNU GPLv2.1

nans=find(isnan(x_mc));
n_mc=length(nans)+1;
%i_mc=min(i_mc,n_mc);
if isempty(nans)
    i1=1;
    i2=length(x_mc);
else
    if i_mc==1
        i1=1;
        i2=nans(i_mc)-1;
    elseif i_mc==n_mc
        i1=nans(i_mc-1)+1;
        i2=length(x_mc);
    else
        i1=nans(i_mc-1)+1;
        i2=nans(i_mc)-1;
    end
end
x=x_mc(i1:i2);
y=y_mc(i1:i2);


end

