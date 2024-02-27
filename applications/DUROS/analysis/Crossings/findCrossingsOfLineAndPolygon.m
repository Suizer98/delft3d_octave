function [xcr, zcr] = findCrossingsOfLineAndPolygon(x1,z1,x2,z2)
% FINDCROSSINGSOFLINEANDPOLYGON  determines the crossings of a line with an arbitrary polygon!!
%
% Some typical things to know about this function are:
% 	- the first line (x1 and z1) should conform to the standard input for findCrossings (i.e. line should not change on x value sorting)
% 	- the second line can be an arbitrary polygon
% 	- the function uses findCrossings.m to see if there is a crossing between a line and each segment of the polygon
% 	- using matrix math helps to keep the process very speedy (line crossed with polygon of app. 90000 points takes 0.1 seconds)
% 	- by default the flag 'keeporiginalgrid' add crossings only is used
% 
% Syntax:       [xcr, zcr] = findCrossingsOfLineAndPolygon(x1,z1,x2,z2)
%
% Input:
%               x1   = array of x-values profile 1
%               z1	 = array of corresponding z-values (same size as x1)
%               x2	 = array of x-values profile 2
%               z2	 = array of corresponding z-values (same size as x2)
%               
% Output:
%               xcr  = array of x-values crossings found
%               zcr	 = array of corresponding z-values of crossings found (same size as x1)
%
%   See also addXvaluesExactCrossings, findCrossings, POLYINTERSECT
%

% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, June 2008 (Version 1.0, June 2008)
% By: <Mark van Koningsveld (email: mark.vankoningsveld@deltares.nl)>
% --------------------------------------------------------------------------

getdefaults(...
    'x1',[429071 427411]',0,...
    'z1',[5.09359e+006 5.09399e+006]',0,...
    'x2',[427037 427318 427948 428801 429595 429906 429586 428898 428025 427531 427337 427424 427987 428607 429208 429440 429150 428617 428074 427715 427754 428151 428578 428810 428675 428239 427880 427909 428132 428316 428423 428432 428297]',0,...
    'z2',[5.09383e+006 5.09322e+006 5.09292e+006 5.09274e+006 5.09309e+006 5.09403e+006 5.09473e+006 5.09525e+006 5.09527e+006 5.09485e+006 5.0943e+006 5.09376e+006 5.09333e+006 5.09331e+006 5.09348e+006 5.09412e+006 5.09474e+006 5.09496e+006 5.09477e+006 5.09426e+006 5.09382e+006 5.09358e+006 5.09356e+006 5.09401e+006 5.09444e+006 5.09451e+006 5.09418e+006 5.09388e+006 5.09373e+006 5.09371e+006 5.09382e+006 5.09403e+006 5.09413e+006]',0);

%% get dimensions of input; for colums, dim = 1; for rows, dim = 2;
dim1 = find(size(x1)~=1);
dim2 = find(size(x2)~=1);
if dim1 == 2 % in case of rows, transpose
    x1 = x1';
    z1 = z1';
end;
if dim2 == 2 % in case of rows, transpose
    x2 = x2';
    z2 = z2';
end;

%% locate relevant sections where you might find crossings potentially (use matrix math for speed)
data = [x2(1:end-1) x2(2:end) z2(1:end-1) z2(2:end)];
mask = ~((data(:,1)<=min(x1) & data(:,2)<=min(x1)) | ... % both x values of segment are smaller than first x of line
    (data(:,1)>=max(x1) & data(:,2)>=max(x1)) | ... % both x values of segment are greater than first x of line
    (data(:,3)<=min(z1) & data(:,4)<=min(z1)) | ... % both y values of segment are smaller than first y of line
    (data(:,3)>=max(z1) & data(:,4)>=max(z1))) & ... % both y values of segment are greater than second y of line
    ~(isnan(data(:,1)) | ...
    isnan(data(:,2)) | ...
    isnan(data(:,3)) | ...
    isnan(data(:,4)));      % both y values of segment are greater than second y of line

%% filter data for relevant sections where you might find crossings potentially
data = data(mask,:);

%% for each section of the polygon perform findCrossings
[xcr_store, zcr_store] = deal([]);
for i = 1 : size(data,1)
    try
        if ~isscalar(unique(data(i,1:2)))
            [xcr, zcr] = findCrossings(x1,z1,data(i,1:2)',data(i,3:4)','keeporiginalgrid');
        else
            % swap x and z values for vertical sections
            [zcr, xcr] = findCrossings(z1,x1,data(i,3:4)',data(i,1:2)', 'keeporiginalgrid');
        end
    catch ME
        if dbstate
            rethrow(ME)
        end
        [xcr, zcr] = deal([]);
    end
    if ~isempty(xcr)
        xcr_store = [xcr_store xcr];
        zcr_store = [zcr_store zcr];
    end
end

%% prepare output
xcr = xcr_store';
zcr = zcr_store';

%% if dbstate on generate a plot to see end result
if dbstate
    figure(1);clf;hold on;
    
    ph(1)     = plot(x1,z1,'-or','markerfacecolor','r',...
        'DisplayName', 'line');
    ph(2)     = plot(x2,z2,'-ob','markerfacecolor','b',...
        'DisplayName', 'polygon');
    if ~isempty(data)
        xs = reshape([data(:,1:2) NaN(size(data,1),1)]', size(data,1)*3, 1);
        zs = reshape([data(:,3:4) NaN(size(data,1),1)]', size(data,1)*3, 1);
        ph(3) = plot(xs,zs,'-ok','markerfacecolor','k',...
            'DisplayName', 'relevant poly-sections');
    end
    if ~isempty(xcr_store)
        ph(4) = plot(xcr_store,zcr_store,'oy','markerfacecolor','y',...
            'DisplayName', 'crossing(s)');
    end

    lh = legend('show');
    set(lh,'FontWeight','bold','FontSize',8);
    legend('boxoff')

    axis equal; box on
    title('Test case for findCrossingsOfLineAndPolygon')
    xlabel('x-values')
    ylabel('y-values', 'Rotation', 270, 'VerticalAlignment', 'top')
end