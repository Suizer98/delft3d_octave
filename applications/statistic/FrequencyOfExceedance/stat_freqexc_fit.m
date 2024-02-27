function res = stat_freqexc_fit(res, varargin)
%STAT_FREQEXC_FIT  Fits one or more distributions through filtered maxima
%
%   Fits user-defined distributions through the maxima filtered by the
%   stat_freqexc_filter function. A given computational grid describes the
%   range and resolution of the levels to be returned. The frequencies are
%   computed for these levels only.
%
%   The original result structure is returned containing an extra field
%   with individual fits and the overall average fit.
%
%   Syntax:
%   varargout = stat_freqexc_fit(res, varargin)
%
%   Input:
%   res       = Result structure from the stat_freqexc_filter function
%   varargin  = y:          computational grid for levels to be returned
%               fcnfit:  	cell array with handles of user-defined fit
%                           functions
%
%   Output:
%   res       = Modified result structure with extra field fit:
%
%               y:          computational grid for levels
%               f:          frequencies corresponding to computational grid
%                           obtained by averaging individual fits
%               fits:       structure array with individual fits:
%
%                           fcn:    handle to user-defined fit function
%                           y:      computational grid for levels
%                           f:      frequencies corresponding to
%                                   computational grid
%
%   Example
%   % change computational grid
%   res = stat_freqexc_fit(res, 'y', 0:10);
%   % only fit gumbel distribution
%   res = stat_freqexc_fit(res, 'fcnfit', {@stat_fit_gumbel});
%
%   See also stat_freqexc_filter, stat_freqexc_combine, stat_freqexc_plot

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
% Created: 06 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_fit.m 6190 2012-05-14 14:27:03Z hoonhout $
% $Date: 2012-05-14 22:27:03 +0800 (Mon, 14 May 2012) $
% $Author: hoonhout $
% $Revision: 6190 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_fit.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'y',      -10:.01:10, ...
    'fcnfit', {{@stat_fit_gev}} ...
);

OPT = setproperty(OPT, varargin{:});

if ~isfield(res, 'filter')
    error('No data selected, please use stat_freqexc_filter first');
end

if ~exist('gevfit') && ~ismember('fcnfit', varargin(1:2:end))
    OPT.fcnfit = {@stat_fit_gumbel};
end

%% fit data

res.fit = struct();

data    = [res.filter.maxima.value];

n = 1;
for i = 1:length(OPT.fcnfit)
    if isa(OPT.fcnfit{i}, 'function_handle')
        try
            p   = [];
            ci  = [];
            
            switch nargout(OPT.fcnfit{i})
                case 1
                    f        = feval(OPT.fcnfit{i},data,OPT.y(:));
                case 2
                    [f p]    = feval(OPT.fcnfit{i},data,OPT.y(:));
                case 3
                    [f p ci] = feval(OPT.fcnfit{i},data,OPT.y(:));
            end
            
            res.fit.fits(n) = struct(   ...
                'fcn',  OPT.fcnfit{i},  ...
                'y',    OPT.y(:),       ...
                'f',    f,              ...
                'pars', p,              ...
                'ci',   ci                  );

            n = n+1;
        catch
            e = lasterror;
            disp(e.message);
        end
    end
end

%% compute average

if ~isempty(res.fit) && ~isempty(fieldnames(res.fit))
    f = [res.fit.fits.f];
    f = f(:,~all(isnan(f),1));

    res.fit.y = OPT.y(:);
    res.fit.f = mean(f,2);
else
    res.fit.y = nan;
    res.fit.f = nan;
end

%% add GEV, if available

if exist('gevfit') && (length(OPT.fcnfit)>1 || isempty(OPT.fcnfit) || ...
        ~strcmpi(func2str(OPT.fcnfit{1}), 'stat_fit_gev'))
    
    res.fit.f_GEV = feval(@stat_fit_gev,data,OPT.y(:));
end

