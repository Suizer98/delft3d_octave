function stat_freqexc_plot(res, varargin)
%STAT_FREQEXC_PLOT  Plots a result structure from any of the stat_freqexc_* functions interactively
%
%   Plots the time series, determined and filtered maxima, fitted data and
%   probabilities of exceedance from any of the stat_freqexc_* functions
%   that return a result structure alike the structure from
%   stat_freqexc_get.
%
%   Syntax:
%   stat_freqexc_plot(res, varargin)
%
%   Input:
%   res       = Result structure from a stat_freqexc_* function
%   varargin  = interactive:    Enable/disable interactive plot
%
%   Output:
%   none
%
%   Example
%   stat_freqexc_plot(res)
%   stat_freqexc_plot(res, 'interactive', false)
%
%   See also stat_freqexc_get, stat_freqexc_filter, stat_freqexc_fit,
%            stat_freqexc_combine, stat_freqexc_logplot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_plot.m 7687 2012-11-14 15:16:12Z hoonhout $
% $Date: 2012-11-14 23:16:12 +0800 (Wed, 14 Nov 2012) $
% $Author: hoonhout $
% $Revision: 7687 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_plot.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'interactive', true ...
);

OPT = setproperty(OPT, varargin{:});

figure;
isf  = isfinite(res.data);
xlim = [min(res.time) max(res.time)];
ylim = [min(res.data(isf)) max(res.data(isf))].*[.9 1.1];

%% plot data

s1 = subplot(3,1,1); hold on;

plot(res.time,res.data,'-b');

if isfield(res,'filter')
    plot(xlim,res.filter.threshold*ones(1,2),'-g');
    plot([res.filter.maxima.time],[res.filter.maxima.value],'og');
end

p1 = plot(xlim,zeros(1,2),'-r');
p2 = plot(0,0,'or');

set(p1,'Tag','threshold');
set(p2,'Tag','maxima');

box on;
grid on;
xlabel('time');
ylabel('value');
title('');

ticktext(gca, '-datetime2');

%% plot number of exceedances

s2 = subplot(3,1,2); hold on;

plot([res.peaks.threshold],[res.peaks.nmax],'-b');

if isfield(res,'filter')
    plot(res.filter.threshold*ones(1,2),get(gca,'YLim'),'-g');
    
    [y i]   = sort([res.filter.maxima.value],2,'descend');
    
    plot(y,1:res.filter.nmax,'-g');
end

p3 = plot(zeros(1,2),get(gca,'YLim'),'-r');

set(p3,'Tag','numexc');

box on;
grid on;
xlabel('value');
ylabel('number of exceedances');

%% plot probability of exceedance

s3 = subplot(3,1,3); hold on;

plot([res.peaks.threshold],[res.peaks.probability],'-b');

if isfield(res,'filter')
    plot(res.filter.threshold*ones(1,2),get(gca,'YLim'),'-g');
    plot(y,[1:res.filter.nmax]./res.filter.nmax,'-g');
end

if isfield(res,'fit')
    plot([res.fit.fits.y],[res.fit.fits.f],'Color',[.8 .8 .8]);
    plot(res.fit.y,res.fit.f,'-r');
    
    if isfield(res.fit,'f_GEV')
        plot(res.fit.y,res.fit.f_GEV,':r');
    end
end

if isfield(res,'combined')
    plot(res.combined.y,res.combined.f,'-xk','LineWidth',2);
    
    ysplit = interp1(res.combined.f,res.combined.y,res.combined.split);
    plot(ysplit,res.combined.split,'ok','LineWidth',2);
end

p4 = plot(zeros(1,2),get(gca,'YLim'),'-r');

set(p4,'Tag','freqexc');

box on;
grid on;
xlabel('value');
ylabel('probability of exceedance');

set(s1,'XLim',xlim,'YLim',ylim);
set(s2,'XLim',ylim);
set(s3,'XLim',ylim,'YLim',[0 1]);

%% make it all dynamic

if OPT.interactive
    set(gcf,'windowbuttonmotionfcn',{@setpointer, [s1 s2 s3], res});
end

function setpointer(obj, event, objs, res)
    if ~isempty(objs)
        cobj = [];
        for i = 1:length(objs)
            cp = get(objs(i), 'currentpoint');
            x = cp(1,1);
            y = cp(1,2);

            xlim = get(objs(i), 'xlim');
            ylim = get(objs(i), 'ylim');
            xv = xlim([1 1 2 2]);
            yv = ylim([1 2 2 1]);

            if inpolygon(x, y, xv, yv)
                cobj = objs(i);
                
                if i == 1
                    v = y;
                else
                    v = x;
                end
                
                break;
            end
        end
        
        if ~isempty(cobj)
            set(obj, 'pointer', 'crosshair');

            p1 = findobj(objs(1),'Tag','threshold');
            p2 = findobj(objs(1),'Tag','maxima');
            p3 = findobj(objs(2),'Tag','numexc');
            p4 = findobj(objs(3),'Tag','freqexc');

            [th i] = closest(v,[res.peaks.threshold]);
            
            set(p1,'YData',v*[1 1]);
            set(p2,'XData',[res.peaks(i).maxima.time],'YData',[res.peaks(i).maxima.value]);
            set(p3,'XData',v*[1 1]);
            set(p4,'XData',v*[1 1]);
            
            title(objs(1),sprintf('value = %3.2f', v));
        else
            set(obj, 'pointer', 'arrow');
        end
    end