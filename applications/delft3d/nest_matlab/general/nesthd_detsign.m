function sign = nesthd_detsign(ma,na,mb,nb,kcs)

% determines whether or not positive means inflow or outflow

%% iitialise
sign = 1.0;
mmax = size(kcs,1);
nmax = size(kcs,2);

%% right/left boundary
if ma == mb && na ~= nb
   if kcs(max(ma - 1,1),na) == 1
      sign = -1.0;
   end
%% upper/lower boundary
elseif ma ~= mb && na == nb
   if kcs(ma,max(na-1,1)) == 1
      sign = -1.0;
   end
%% ambigous boundary definition, unable to determine in or outflow
else
    if kcs(max(ma - 1,1),na) == 1 || kcs(ma,max(na-1,1)) == 1
        sign = -1.0;
    end
end

