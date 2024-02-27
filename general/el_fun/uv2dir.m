function dir = uv2dir(u,v,convention)
% dir = uv2dir(u,v,convention)
% UV2DIR derives the direction (in cartesian or nautical convention) from the u and v data
% 
% u = u or x vector of parameter
% v = v or y vector of parameter
% convention = either 'cartesian' or 'nautical'
%
% where:
% 'cartesian', the direction to where the vector points
% 'nautical', the direction where the vector comes from
% if no convention is assigned, 'cartesian'  convention is applied
% note that both convention are considered clockwise from geographic North

% created by E.Moerman 24-11-2011
% adjusted by E.Moerman 06-03-2012 to allow for Matrix handling

if nargin == 2,
    convention='cartesian';
end;


% derive direction
if strcmpi(convention,'cartesian')
    dir = mod(atan2(u,v)*180/pi,360);
elseif strcmpi(convention,'nautical')
    dir = mod(atan2(-u,-v)*180/pi,360);
end

dir(u==0&v==0) = NaN;

end
