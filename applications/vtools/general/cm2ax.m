%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: cm2ax.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/cm2ax.m $
%
%transforms a position in an axes in centimeters to its value in axes units
%
%INPUT:
%   -pos_cm = desired position in cm (x,y); double [2,1]
%   -han_fig = handle to the figure; handle
%   -han_ax = handle to the axes; handle
%
%OUTPUT:
%   -pos_ax = position in the units of the axes (x,y); double [2,1]
%
%OPTIONAL:
%   -'reference' = reference point where the measure is given
%       -'ll' = lower left corner of the axes (Position)
%       -'lr' = lower right corner of the axes (Position)
%       -'ul' = upper left corner of the axes (Position)
%       -'ur' = upper right corner of the axes (Position)
%   -'duration' = units of a duration axis
%       -'seconds'
%       -'hours'
%       -'days'
%
%160106
%   -V. v1
%
%160808
%   -V. adaptation to logarithmic scale
%
%170714
%   -V. adaptation to duration scale
%
%180727
%   -V. modification to duration and add as input. Would be nice to read this from the axis but I do not see how.
%
%181031
%   -V. add datetime to possible axis type

function pos_ax=cm2ax(pos_cm,han_fig,han_ax,varargin)
%% parse
parin=inputParser;

input.reference.default='ll'; %lowerleft
addOptional(parin,'reference',input.reference.default);

input.duration.default='days'; 
addOptional(parin,'duration',input.duration.default);

parse(parin,varargin{:});

reference=parin.Results.reference;
duration_unit=parin.Results.duration;

%% axes dimensions

han_fig.Units='centimeters';
ax_width_cm=han_ax.Position(3)*han_fig.PaperPosition(3);
ax_height_cm=han_ax.Position(4)*han_fig.PaperPosition(4);
% ax_width_cm=(han_ax.Position(3)+han_ax.TightInset(3))*han_fig.PaperPosition(3);
% ax_height_cm=(han_ax.Position(4)+han_ax.TightInset(4))*han_fig.PaperPosition(4);

%% reference
switch reference
    case 'll'
        x_cm=pos_cm(1)/ax_width_cm;
        y_cm=pos_cm(2)/ax_height_cm;
    case 'lr'
        x_cm=(ax_width_cm-pos_cm(1))/ax_width_cm;
        y_cm=pos_cm(2)/ax_height_cm;
    case 'ul'
        x_cm=pos_cm(1)/ax_width_cm;
        y_cm=(ax_height_cm-pos_cm(2))/ax_height_cm;
    case 'ur'
        x_cm=(ax_width_cm-pos_cm(1))/ax_width_cm;
        y_cm=(ax_height_cm-pos_cm(2))/ax_height_cm;
    otherwise
        error('the reference can be: ll (lower left) | lr (lower right) | ul (upper left) | ur (upper right)')
end

%coordinates in axes dimensions
switch han_ax.XScale
    case 'linear'
        x_ax=x_cm*(han_ax.XLim(2)-han_ax.XLim(1))+han_ax.XLim(1);
    case 'log'
        x_ax=10^(x_cm*(log10(han_ax.XLim(2))-log10(han_ax.XLim(1)))+log10(han_ax.XLim(1)));
    otherwise
        error('The XScale can be: linear | log')
end
if isduration(han_ax.XAxis.Limits)
    %this needs to be in the same units than the duration plot, but I do not know how to pass this info
    switch duration_unit
        case 'seconds'
            x_ax=seconds(x_ax);
        case 'hours'
            x_ax=hours(x_ax);
        case 'days'
            x_ax=days(x_ax); 
    end
end
if isdatetime(han_ax.XAxis.Limits)
    x_ax=datenum(x_ax)-datenum(han_ax.XLim(1));
end

switch han_ax.YScale
    case 'linear'
        y_ax=y_cm*(han_ax.YLim(2)-han_ax.YLim(1))+han_ax.YLim(1);
    case 'log'
        y_ax=10^(y_cm*(log10(han_ax.YLim(2))-log10(han_ax.YLim(1)))+log10(han_ax.YLim(1)));
    otherwise
        error('The YScale can be: linear | log')
end
if isduration(han_ax.YAxis.Limits)
    %this needs to be in the same units than the duration plot, but I do not know how to pass this info
    switch duration_unit
        case 'seconds'
            y_ax=seconds(y_ax);
        case 'hours'
            y_ax=hours(y_ax);
        case 'days'
            y_ax=days(y_ax); 
    end
end
if isdatetime(han_ax.YAxis.Limits)
    y_ax=datenum(y_ax)-datenum(han_ax.YLim(1));
end

pos_ax=[x_ax,y_ax];
    
end