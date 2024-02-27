function [index] = EHY_thinning(x,y,varargin)

%  Returns the indixes of x,y points with where the indivividual points are located the "thinDisctance" away from each other
%  Applies to the current axis
%  thinDistance is in cm!
%
%  If you adjust your axis (XLim and YLim) after calling this function, the thinDistance you applied is no longer correct
%
%% Some general parameters
index = [];
dX               = max(x) - min(x);
dY               = max(y) - min(y);
OPT.thinDistance = 0.;
OPT.Units        = 'centimeters';
OPT              = setproperty(OPT,varargin);

%% thinDistance equal to 0.0. Do nothing. Just give back evrything in index
if OPT.thinDistance <= 0.; index = 1:1:length(x); return; end

%% Actual thinning. Start with determining the length of the axis in OPT.Units (I prefer cm); get Xlim and Ylim
orgUnit = get(gca,'Units');
set(gca,'Units',OPT.Units);
pos     = get(gca,'Position');
XLim    = get(gca,'XLim'    );
YLim    = get(gca,'YLim'    );
set(gca,'Units',orgUnit);

%% x and y scaled, in cm, relative to the origin
lenX = 1; lenY = 1;
if strcmpi(OPT.Units,'centimeters') lenX = pos(3); lenY = pos(4); end
dX       = diff(XLim);
dY       = diff(YLim);
x_scaled = (x - XLim(1))*lenX/dX;
y_scaled = (y - YLim(1))*lenY/dY;

%% Cycle over all points
for i_pnt = 1: length(x)
    if ~isnan(x(i_pnt)) && ~isnan(y(i_pnt))
        if isempty(index)
            %  first valid point
            index = i_pnt;
        else
            % determine distance from points already defined as valid
            distance = sqrt((x_scaled(i_pnt) - x_scaled(index)).^2 + (y_scaled(i_pnt) - y_scaled(index)).^2);

            % distance sufficient than add to the list of valid points
            if min(distance) >= OPT.thinDistance
                index = [index i_pnt];
            end
        end
    end
end
