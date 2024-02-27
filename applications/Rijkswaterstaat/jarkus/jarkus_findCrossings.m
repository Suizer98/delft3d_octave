function [xcr zcr x1_new_out z1_new_out x2_new_out z2_new_out crossdir] = jarkus_findCrossings(x1, z1, x2, z2, flag)
% JARKUS_FINDCROSSINGS  routine to find crossings of 2 profiles
%
% routine to find crossings of 2 profiles
%
% Syntax:       [xcr zcr x1_new_out z1_new_out x2_new_out z2_new_out crossdir] =
% findCrossings(x1, z1, x2, z2, flag)
%
% Input:
%               x1   = array of x-values profile 1
%               z1	 = array of corresponding z-values (same size as x1)
%               x2	 = array of x-values profile 2
%               z2	 = array of corresponding z-values (same size as x2)
%               flag :
%                 'synchronizegrids' add crossings and synchronize grids
%                 'keeporiginalgrid' add crossings only
%
% Output:
%
%   See also addXvaluesExactCrossings
%

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
%     Pieter van Geer and Kees den Heijer
%
%     pieter.vangeer@deltares.nl / c.denheijer@tudelft.nl
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id: jarkus_findCrossings.m 8802 2013-06-11 13:44:30Z heijer $ 
% $Date: 2013-06-11 21:44:30 +0800 (Tue, 11 Jun 2013) $
% $Author: heijer $
% $Revision: 8802 $
% $Keywords: Crossing Crossings line polygon intersect intersection

%% input check
if ~all([isvector(x1)...
        ~isscalar(x1)...
        size(x1) == size(z1)])
    error('FINDCROSSINGS:wronginput', 'x1 and z1 should be vectors with the same size.')
end
if ~all([isvector(x2)...
        ~isscalar(x2)...
        size(x2) == size(z2)])
    error('FINDCROSSINGS:wronginput', 'x2 and z2 should be vectors with the same size.')
end

%%
getdefaults('flag', 'keeporiginalgrid', 0);
MatchGrid = strcmp(flag, 'synchronizegrids');

%% check dimensions of input; transpose in case of row-vectors
% size sorted ascending means that # columns > # rows; knowing that x is a
% vector makes the logical "issorted(size(x))" showing whether x is a row
isrow1 = issorted(size(x1));
isrow2 = issorted(size(x2));
if isrow1 % in case of rows, transpose
    x1 = x1';
    z1 = z1';
end;
if isrow2 % in case of rows, transpose
    x2 = x2';
    z2 = z2';
end;

%% combine x-grids and derive corresponding z-values
x_new = [x1; x2];                                           % combine x-grids
x_new = unique(sort(x_new));                                % make unique and sort accending
if ~isequal(x1, x_new)
    z1_new = interp1(x1, z1, x_new);                % get corresponding z1-values
else
    z1_new = z1;
end
z1_new = roundoff(z1_new,8);
if ~isequal(x2, x_new)
    z2_new = interp1(x2, z2, x_new);                % get corresponding z1-values
else
    z2_new = z2;
end
z2_new = roundoff(z2_new,8);

%% add crossings and filter based on diff(x)
x2add = addXvaluesExactCrossings(x_new, z1_new, z2_new);    % get exact x-values of crossings

id_x2add = [false(size(x_new)); true(size(x2add))];         % create logical identifier which is true at x2add locations
x_new = [x_new; x2add];                                     % combine all x-values

[x_new, IX] = sort(x_new);                                  % sort x accending and including index (IX)
id_x2add = id_x2add(IX);                                    % sort identifier in the same way, using IX

threshold = 1e-4;                                           % new points (x2add) which are closer to an existing point than this threshold will be merged with that neighbouring existing point

xrecalculate = false(size(x_new));                          % basically, all exact points are used

% do not add points that are closer than threshold to and on the right of allready existing points
id_diffxbelowthreshold = [false; diff(x_new)<threshold];    % select x-differences below threshold (starting with a dummy (false))
id_xtoignoreright = id_x2add & id_diffxbelowthreshold;      % corresponding identifier right of this cell
xrecalculate([id_xtoignoreright(2:end); false]) = true;     % identifier to recalculate the (left) neighbouring z-values to still keep the crossing

% do not add points that are closer than threshold to and on the left of allready existing points
id_diffxbelowthreshold = [diff(x_new)<threshold; false];    % select x-differences below threshold (ending with a dummy (false))
id_xtoignoreleft = id_x2add & id_diffxbelowthreshold;       % corresponding identifier left of this cell
xrecalculate([false; id_xtoignoreleft(1:end-1)]) = true;    % identifier to recalculate the (right) neighbouring z-values to still keep the crossing

id_xtokeep = ~(id_xtoignoreleft | id_xtoignoreright);       % identifier of x-values to keep

id_x2add = id_x2add(id_xtokeep);

x_new = x_new(id_xtokeep);                                  % filter x-values
z1_new = roundoff(interp1(x1, z1, x_new),8);                % get corresponding z1-values
z2_new = roundoff(interp1(x2, z2, x_new),8);                % get corresponding z2-values
xrecalculate = xrecalculate(id_xtokeep);                    % filter x-values where z will be recalculated (will be the crossings)

meanz = mean([z1_new, z2_new],2);                           % mean z of 2 profiles
z1_new(xrecalculate | id_x2add) = meanz(xrecalculate | id_x2add);  % designate the mean z as crossings values in x-recalculate
z2_new(xrecalculate | id_x2add) = z1_new(xrecalculate | id_x2add); % designate the mean z as crossings values in x-recalculate

%% prepare output
id = z1_new == z2_new;                                      % identifier of crossings
xcr = x_new(id);                                            % x-values of crossings
zcr = z1_new(id);                                           % z-values of crossings

% distinguish between upcrossings and downcrossings
[crossdirpos crossdirneg] = deal(zeros(size(id)));
idpos = [false; id(1:end-1)]; % identifier of points neighbouring to the crossings at the positive side
crossdirpos([idpos(2:end); false]) = sign(z2_new(idpos) - z1_new(idpos));
crossdirpos(isnan(crossdirpos)) = 0;
idneg = [id(2:end); false]; % identifier of points neighbouring to the crossings at the negative side
crossdirneg([false; idneg(1:end-1)]) = - sign(z2_new(idneg) - z1_new(idneg));
crossdirneg(isnan(crossdirneg)) = 0;
% crossdir has the same size as xcr and zcr
% crossdir = -2 : line 2 is above line 1 at the negative x-side of the
%                 crossing AND below line 1 at the positive x-side
% crossdir = -1 : line 2 is above line 1 at the negative x-side of the
%                 crossing OR below line 1 at the positive x-side
% crossdir =  0 : line 2 has a point of contact (raakpunt) with line 1
% crossdir =  1 : line 2 is below line 1 at the negative x-side of the
%                 crossing OR above line 1 at the positive x-side
% crossdir =  2 : line 2 is below line 1 at the negative x-side of the
%                 crossing AND above line 1 at the positive x-side
crossdir = crossdirpos(id) + crossdirneg(id);

% MvK 06-04-2008: here the added points are not included anymore because not the new variables are used 
if MatchGrid
    % MvK 06-04-2008: new suggested solution
    x1_new_out = x_new;
    z1_new_out = z1_new;

    x2_new_out = x_new;
    z2_new_out = z2_new;

    % MvK 06-04-2008: old code was:
    % x1_new_out = [x1;x2(2:end-1)];
    % z1_new_out = [z1;interp1(x1,z1,x2(2:end-1))];
    %
    % x2_new_out = [x2;x1(2:end-1)];
    % z2_new_out = [z2;interp1(x2,z2,x1(2:end-1))];
else
    % MvK 06-04-2008: old code was:
    % x1_new_out = x1;
    % z1_new_out = z1;
    % 
    % x2_new_out = x2;
    % z2_new_out = z2;
    
    % MvK 06-04-2008: new suggested solution
    x1_new_out = [x1;xcr];
    z1_new_out = [z1;zcr];

    [x1_new_out unid]=unique(x1_new_out); z1_new_out=z1_new_out(unid); %Not necessary given lines 77-80
    [x1_new_out sortid]=sort(x1_new_out); z1_new_out=z1_new_out(sortid);
    
    x2_new_out = [x2;xcr];
    z2_new_out = [z2;zcr];

    [x2_new_out unid]=unique(x2_new_out); z2_new_out=z2_new_out(unid);
    [x2_new_out sortid]=sort(x2_new_out); z2_new_out=z2_new_out(sortid);
end

%% make sure that the dimensions of the output is similar to x1 and z1
if isrow1
    xcr = xcr';
    zcr = zcr';
end

