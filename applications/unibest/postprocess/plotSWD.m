function plotSWD(varargin)
% function plots the contents of an SWD file, which contains longshore sediment
% distribution over the cross-shore.
%
%   Syntax:
%     plotSWD(SWDfiles,NETTorGROSS)
% 
%   Input:
%    SWDfiles      cell array with SWD data structures OR seperate SWD data structures
%                  .sQs    
%                  .dx     
%    NETTorGROSS   switch to plot Nett or Gross transport (0 = nett /1 = gross)
%  
%   Output:
%     plot of SWD data
%
%   Example:
%     SWDfiles    = {'file1.swd','file2.swd'};
%     NETTorGROSS = 1;
%     plotSWD(SWDfiles,NETTorGROSS)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: plotSWD.m 3257 2012-01-24 14:43:32Z huism_b $
% $Date: 2012-01-24 15:43:32 +0100 (Tue, 24 Jan 2012) $
% $Author: huism_b $
% $Revision: 3257 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/plotSWD.m $
% $Keywords: $

seperateSWDdatastructures=1;
if iscell(varargin{1})
    SWDfiles = varargin{1};
    seperateSWDdatastructures=0;
end
NETTorGROSS=0;
teller=0;
for ii=1:nargin
    if isnumeric(varargin{ii})
        NETTorGROSS=varargin{ii};
    elseif isstruct(varargin{ii}) && seperateSWDdatastructures==1
        teller=teller+1;
        SWDfiles{teller}=varargin{ii};
    end
end

colours={'b','r','g','m','c','y','k'};
legendtxt={};
figure;
if NETTorGROSS~=1
    for ii=1:length(SWDfiles)
        plot(SWDfiles{ii}.x{1,end},SWDfiles{ii}.sQs{1,end},colours{mod(ii-1,7)+1});hold on;
        sQs1 = sum(SWDfiles{ii}.sQs{1,end}.*SWDfiles{ii}.dx);
        legendtxt{ii}=[SWDfiles{ii}.filename,' (',num2str(size(SWDfiles{ii}.sQs,2)),' cond, Qs=',num2str(sQs1,'%5.0f'),' m3/yr)'];
    end
    xlabel('Cross-shore distance [m] (coastline on the right side)');
    ylabel('Nett lonsghore sediment transport [m3/m/yr]');
elseif NETTorGROSS==1
    for ii=1:length(SWDfiles)
        plot(SWDfiles{ii}.x{1,end},SWDfiles{ii}.sQs_gross1,colours{mod(ii-1,7)+1});hold on;
        gQs1 = sort([sum(SWDfiles{ii}.sQs_gross1.*SWDfiles{ii}.dx),sum(SWDfiles{ii}.sQs_gross2.*SWDfiles{ii}.dx)]);
        legendtxt{ii}=[SWDfiles{ii}.filename,' (',num2str(size(SWDfiles{ii}.sQs,2)),' cond, gQs1=',num2str(gQs1(1),'%5.0f'),', gQs2=',num2str(gQs1(2),'%5.0f'),' m3/yr)'];
    end
    for ii=1:length(SWDfiles)
        plot(SWDfiles{ii}.x{1,end},SWDfiles{ii}.sQs_gross2,colours{mod(ii-1,7)+1});hold on;
    end
    xlabel('Cross-shore distance [m] (coastline on the right side)');
    ylabel('Gross lonsghore sediment transport [m3/m/yr]');
end
legend(legendtxt,'Location','NorthOutside','Interpreter','none','FontSize',8);
%md_paper('landscape');B=findobj(gcf,'Tag','border');set(get(B,'Children'),'String',['Deltares (',datestr(now,'DD-mm-YYYY'),')']);
%print('-dpdf','-r150','Nett sediment transports (flattened profile).pdf');