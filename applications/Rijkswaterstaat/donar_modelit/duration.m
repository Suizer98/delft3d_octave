function d = duration(timeunit)
% Calculate duration of a timeunit in Matlab datenum units.
% 
% CALL:
%  d = duration(timeunit)
% 
% INPUT:
%  timeunit: String with possible values:
%            - 'mnd' months
%            - 'd'   days
%            - 'min' minutes
%            - 'uur' hours
%            - 'cs'  centiseconds
% 
% OUTPUT:
%  d: Duration of the given timeunit in Matlab datenum units.
% 
% EXAMPLE:
%  d = duration('d')
%  d = duration('uur')
%  d = duration('min')
% 
% See also: cmp_taxis

%Let op! bij coderen was complete lijst met mogelijkheden niet voorhanden!
%alleen de eenheid 'min' is geverifieerd.
switch lower(timeunit)
    case 'mnd'
        d=365/12;
        %Datatype maand slechts gedeeltelijk ondersteund
    case 'd'
        d=1;
    case 'min'
        d=1/1440;
    case 'uur'
        d=1/24;
    case 's'
        d=1/(24*60*60);
    case 'cs'
        d=1/(24*60*60*100);
    otherwise
        d=1;
end