%function analyze_grooteman_results(varargin)
%ANALYZE_GROOTEMAN_RESULTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = analyze_grooteman_results(varargin)
%
%   Input: For <keyword,value> pairs call analyze_grooteman_results() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   analyze_grooteman_results
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 17 Jul 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: analyze_groteman_1000samples.m 9673 2013-11-13 09:22:27Z stuparu $
% $Date: 2013-11-13 17:22:27 +0800 (Wed, 13 Nov 2013) $
% $Author: stuparu $
% $Revision: 9673 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/plotting_tools_ADIS/analyze_groteman_1000samples.m $
% $Keywords: $

%% Read Settings

varargin={};

OPT = struct(...
   'resultsDirADIS1000',      'd:\Repos\OpenEarthTools\test\matlab\applications\probabilistic\grooteman_test_problems\resultsADIS1000_startup_aproxpoints', ...
    'tests',        1:14, ...
    'name',         '', ...
    'Labels',       '', ...
    'Methods',      {{'ADIS'}}, ...
    'StartUp',      {{''}});

OPT = setproperty(OPT, varargin{:});


N=100; % number of seeds
%% Grooteman 2011 performance

RelativeErrorPfGrooteman    = ...
    [2.4 ...
    10.8 ...
    1.7 ...
    11.3 ...
    2.1 ...
    12.4 ...
    8.4 ...
    6.0 ...
    4.4 ...
    6.0 ...
    6.3 ...
    10.1 ...
    15.6 ...
    8.0];

NumberEvaluationsGrooteman  = ...
    [136 ... 
    57 ...
    116 ...
    65 ...
    32 ...
    81 ...
    71 ...
    148 ...
    91 ...
    51 ...
    63 ...
    32 ...
    65 ...
    28];

%% Read results & plot analysis
% plot the performance of different methods for the same problem



for iTest = 1:length(OPT.tests)
 
    testNr  = num2str(OPT.tests(iTest));
  
    
        fileName1   = [OPT.Methods{1},'_resultsADIS1000_AxialP_Aprox50none' testNr '.mat'];
        fileName2   = [OPT.Methods{1},'_resultsADIS1000_AxialP_Aprox50selection' testNr '.mat'];
        fileName3   = [OPT.Methods{1},'_resultsADIS1000_AxialP_Aprox50weighted' testNr '.mat'];
        
          r1=load([OPT.resultsDirADIS1000 '\' fileName1]);
          r1=r1.fresults; 
          
          r2=load([OPT.resultsDirADIS1000 '\' fileName2]);
          r2=r2.fresults;
          
          r3=load([OPT.resultsDirADIS1000 '\' fileName3]);
          r3=r3.fresults;
          
            
            for iSeed=1:length(r1)% for all the seeds
                
                result1.Pf(iTest,iSeed)        = r1(iTest,iSeed).P_f;
                result1.Beta(iTest,iSeed)      = r1(iTest,iSeed).Beta;
                result1.Calc(iTest,iSeed)      = r1(iTest,iSeed).Calc;
                
                result2.Pf(iTest,iSeed)        = r2(iTest,iSeed).P_f;
                result2.Beta(iTest,iSeed)      = r2(iTest,iSeed).Beta;
                result2.Calc(iTest,iSeed)      = r2(iTest,iSeed).Calc;
                
                result3.Pf(iTest,iSeed)        = r3(iTest,iSeed).P_f;
                result3.Beta(iTest,iSeed)      = r3(iTest,iSeed).Beta;
                result3.Calc(iTest,iSeed)      = r3(iTest,iSeed).Calc;
            end

 
          median1_calc(iTest) = median(result1.Calc(iTest,:)',1);       
          median1_beta(iTest) = median(result1.Beta(iTest,:)',1);
          median1_Pf(iTest)   = median(result1.Pf(iTest,:)',1);
          
          median2_calc(iTest) = median(result2.Calc(iTest,:)',1);
          median2_beta(iTest) = median(result2.Beta(iTest,:)',1);
          median2_Pf(iTest)   = median(result2.Pf(iTest,:)',1);
         
          median3_calc(iTest) = median(result3.Calc(iTest,:)',1);
          median3_beta(iTest) = median(result3.Beta(iTest,:)',1);
          median3_Pf(iTest)   = median(result3.Pf(iTest,:)',1);
          
          
          tmp = result1.Beta(iTest,:);
          tmp = tmp(~isnan(tmp) & ~isinf(tmp));
          std1_Beta(iTest) = std(tmp);
          
          tmp2 = result2.Beta(iTest,:);
          tmp2 = tmp2(~isnan(tmp2) & ~isinf(tmp2));
          std2_Beta(iTest) = std(tmp2);
          
          tmp3 = result3.Beta(iTest,:);
          tmp3 = tmp3(~isnan(tmp3) & ~isinf(tmp3));
          std3_Beta(iTest) = std(tmp3);
end

xlswrite('stdBeta_ADIS_1000_AxialP_Aprox50none.xls',std1_Beta );
xlswrite('stdBeta_ADIS_1000_AxialP_Aprox50selection.xls',std2_Beta );
xlswrite('stdBeta_ADIS_1000_AxialP_Aprox50weighted.xls',std3_Beta );

% p=1;
% k=1;
% tmp= result1.Calc';
% tmp2 =result2.Calc';
% tmp3 =result3.Calc';
% 
% mixed_matrix =[];
% for k=1:size(tmp,2)
%  
% mixed_matrix(:,p)= tmp(:,k);
% p=p+1;
% mixed_matrix(:,p)= tmp2(:,k);
% p=p+1;
% mixed_matrix(:,p)= tmp3(:,k);
% p=p+1;
% end
% 
%  xtck = 1:size(mixed_matrix,2);
%  xtckname ={'1','1','1','2','2','2','3','3','3','4','4','4','5','5'...
%             '5','6','6','6','7','7','7','8','8','8','9','9','9',...
%             '10','10','10','11','11','11','12','12','12','13','13','13','14','14','14'};
% figure(1)
%  p=1;
% for k=1:(size(mixed_matrix,2)/3)
%     
% bplot(mixed_matrix(:,p),p,p,'nodots', 'nomean', 'color','green')
% hold on;
% p=p+1;
% bplot(mixed_matrix(:,p),p,p,'nodots', 'nomean', 'color','black')
% p=p+1;
% hold on;
% bplot(mixed_matrix(:,p),p,p,'nodots', 'nomean', 'color','magenta')
% p=p+1;
% 
% end
% %ylim([1 700])
% 
% set(gca,'Xtick',xtck,'XtickLabel',xtckname )
% xlabel('Test function')
% ylabel('Number of evaluations')
% title('Nr. Evaluations for  ADIS 1000 samples (green), ADIS 1000 selection samples(black), ADIS 1000 weighted samples (magenta) ')
% print -dpng Comparison_number_of_evaluations_ADIS_1000_ADIS_1000_selection_ADIS_1000_weighted
% 
% 
% 
% p=1;
% k=1;
% tmp= result1.Beta';
% tmp2 =result2.Beta';
% tmp3 =result3.Beta';
% 
% 
% mixed_matrix =[];
% for k=1:size(tmp,2)
%  
% mixed_matrix(:,p)= tmp(:,k);
% p=p+1;
% mixed_matrix(:,p)= tmp2(:,k);
% p=p+1;
% mixed_matrix(:,p)= tmp3(:,k);
% p=p+1;
% end
% 
% figure(2)
%  p=1;
% for k=1:(size(mixed_matrix,2)/3)
%     
% bplot(mixed_matrix(:,p),p,p,'nodots', 'nomean', 'color','green')
% hold on;
% p=p+1;
% bplot(mixed_matrix(:,p),p,p,'nodots', 'nomean', 'color','black')
% p=p+1;
% hold on;
% bplot(mixed_matrix(:,p),p,p,'nodots', 'nomean', 'color','magenta')
% p=p+1;
% 
% end
% %ylim([1 900])
% %legend('ADIS','ADIS+Selection','ADIS+Weighted')
% set(gca,'Xtick',xtck,'XtickLabel',xtckname )
% xlabel('Test function')
% ylabel('Beta Values')
% title('Beta values for ADIS 1000 samples (green), ADIS 1000 selection samples(black), ADIS 1000 weighted samples (magenta) ')
% print -dpng Comparison_Beta_ADIS_1000_ADIS_1000_selection_ADIS_1000_weighted
% 
















