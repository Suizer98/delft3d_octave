%function results = run_all_grooteman_tests_1(varargin)
%RUN_ALL_GROOTEMAN_TESTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = run_all_grooteman_tests(varargin)
%
%   Input: For <keyword,value> pairs call run_all_grooteman_tests() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   run_all_grooteman_tests
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
%       <ADDRESS>
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
% Created: 02 Jul 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: run_groteman_linesearch_illustrate.m 9673 2013-11-13 09:22:27Z stuparu $
% $Date: 2013-11-13 17:22:27 +0800 (Wed, 13 Nov 2013) $
% $Author: stuparu $
% $Revision: 9673 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/plotting_tools_ADIS/run_groteman_linesearch_illustrate.m $
% $Keywords: $

%% Read Settings

OPT = struct(...
    'saveDir' , 'd:\Repos\OpenEarthTools\test\matlab\applications\probabilistic\grooteman_test_problems\resultsDS\', ...
    'Method', 'ADIS', ...
    'Weightening', 'none', ...
    'NoCrossTerms', false, ...
    'StartUp','', ...
    'MinAppr', 0, ...
    'seed', 20);                                                   % number of samples used for crude Monte Carlo

varargin={};
OPT = setproperty(OPT, varargin{:});

addpath(genpath(pwd),'-end')

% tests = {@test_grooteman_01_noise,...
%     @test_grooteman_02_multiple_DP,...
%     @test_grooteman_03_10term,...
%     @test_grooteman_04_convex,...
%     @test_grooteman_05_concave,...
%     @test_grooteman_06_saddle_surface,...
%     @test_grooteman_07_highly_nonlinear,...
%     @test_grooteman_08_highly_nonlinear,...
%     @test_grooteman_09_parallel,...
%     @test_grooteman_10_series,...
%     @test_grooteman_11_parallel2,...
%     @test_grooteman_12_series2,...
%     @test_grooteman_13_parallel3,...
%     @test_grooteman_14_series_multiple_DP...
%     };

 tests = {@test_grooteman_04_convex};


results = struct([]);

for i = 1:length(tests)
    for j = 1:length(OPT.seed)
        results{j} = feval(tests{i},'seed',OPT.seed(j),'Method', OPT.Method, 'StartUp', OPT.StartUp, 'Weightening', OPT.Weightening, 'NoCrossTerms', OPT.NoCrossTerms,'MinAppr', OPT.MinAppr);
    end
    
    nr      = num2str(i);
    fname   = [OPT.saveDir OPT.Method '_results_' OPT.Weightening nr '.mat'];
    
    save(fname,'results');
end