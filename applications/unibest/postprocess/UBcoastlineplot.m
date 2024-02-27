function [data]=UBcoastlineplot(PRNfiles,settings)
%UBbarplot : Plots barplots of UNIBEST-CL results
%   
%   Syntax:
%     function []=UBbarplot(PRNfiles,PRNreffile,settings)
%   
%   Input:
%     PRNfiles       Structure with file information of UNIBEST PRN-files (fields : .name)
%     PRNreffile     (optional) Structure with file information of UNIBEST PRN-file that is used as reference (fields : .name) (keep empty to use no reference)
%     settings       (optional) Structure with settings
%                      .Ni    : Number of bars (default=50)
%   
%   Output:
%     Bar plot
%   
%   Example:
%     []=UBbarplot(PRNfiles,PRNreffile,settings)
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Wiebe de Boer / Bas Huisman
%
%       wiebe.deboer@deltares.nl / bas.huisman@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: UBcoastlineplot.m 3496 2013-02-06 15:24:35Z huism_b $
% $Date: 2013-02-06 16:24:35 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3496 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/UBcoastlineplot.m $
% $Keywords: $

% addpath(genpath('D:\2010\SandEngine\Data\'))

%% LOAD data
for ii = 1:length(PRNfiles)
%    if exist([PRNfiles{ii}(1:end-4),'.mat'],'file')
%        load([PRNfiles{ii}(1:end-4),'.mat']);
%    else
        UB=readPRN(PRNfiles{ii});
%        save([PRNfiles{ii}(1:end-4),'.mat'],'UB');%strcat('UB(',num2str(ii),')')
%    end
    UB2(ii)=UB;
end

if nargin<2
    settings.year = UB2(1).year(end);
    settings.color = {'r'};
end

%% plot unibest coastlines
fileid=1; % order of files (1=initial)
for fileid=1:length(UB2)
    for tt = 1:length(settings.year)
        %lookup id of year to plot
        diffyears=abs(UB2(fileid).year-settings.year(tt));
        if min(diffyears)>1
            fprintf('Warning : Requested year %1.0f outside range!\n',settings.year(tt));
        else
            id=find(diffyears==min(diffyears));
            plot(UB2(fileid).x(:,id),UB2(fileid).y(:,id),'Color',settings.color{fileid},'LineWidth',1.5); hold on;
        end
    end
    hold on;
end

