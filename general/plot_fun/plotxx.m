function [ax,hl1,hl2] = plotxx(x1,y1,x2,y2,xlabels,ylabels,varargin);
%PLOTXX - Create graphs with x axes on both top and bottom 
%
%Similar to PLOTYY, but ...
%the independent variable is on the y-axis, 
%and both dependent variables are on the x-axis.
%
%Syntax: [ax,hl1,hl2] = plotxx(x1,y1,x2,y2,xlabels,ylabels);
%
%Inputs:  X1,Y1 are the data for the first line (black)
%         X2,Y2 are the data for the second line (red)
%         XLABELS is a cell array containing the two x-labels
%         YLABELS is a cell array containing the two y-labels
%
%The optional output handle graphics objects AX,HL1,HL2
%allow the user to easily change the properties of the plot.
%
%Example: Plot temperature T and salinity S 
%         as a function of depth D in the ocean
%
%D = linspace(-100,0,50);
%S = linspace(34,32,50);
%T = 10*exp(D/40);
%xlabels{1} = 'Temperature (C)';
%xlabels{2} = 'Salinity';
%ylabels{1} = 'Depth(m)';
%ylabels{2} = 'Depth(m)';
%[ax,hlT,hlS] = plotxx(T,D,S,D,xlabels,ylabels);


%The code is inspired from page 10-26 (Multiaxis axes)
%of the manual USING MATLAB GRAPHICS, version 5.
%
%Tested with Matlab 5.3.1 and above on PCWIN

%Author: Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%November 1997; Last revision: 01-Nov-2001

% Copyright (c) 1999, Denis Gilbert
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE. 

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Feb 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: plotxx.m 4065 2011-02-18 07:51:45Z b.t.grasmeijer@arcadis.nl $
% $Date: 2011-02-18 15:51:45 +0800 (Fri, 18 Feb 2011) $
% $Author: b.t.grasmeijer@arcadis.nl $
% $Revision: 4065 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/plotxx.m $
% $Keywords: $

OPT = struct('fontsize', 7);

OPT = setproperty(OPT, varargin{:});


if nargin < 4
   error('Not enough input arguments')
elseif nargin==4
   %Use empty strings for the xlabels
   xlabels{1}=' '; xlabels{2}=' '; ylabels{1}=' '; ylabels{2}=' ';
elseif nargin==5
   %Use empty strings for the ylabel
   ylabels{1}=' '; ylabels{2}=' ';
elseif nargin > 8
   error('Too many input arguments')
end

if length(ylabels) == 1
   ylabels{2} = ' ';
end

if ~iscellstr(xlabels) 
   error('Input xlabels must be a cell array')
elseif ~iscellstr(ylabels) 
   error('Input ylabels must be a cell array')
end

hl1=line(x1,y1,'Color','k');
ax(1)=gca;
set(ax(1),'Position',[0.12 0.12 0.75 0.70],'fontsize',OPT.fontsize)
set(ax(1),'XColor','k','YColor','k');

ax(2)=axes('Position',get(ax(1),'Position'),...
   'XAxisLocation','top',...
   'YAxisLocation','right',...
   'Color','none',...
   'XColor','r','YColor','k',...
   'fontsize',OPT.fontsize);

set(ax,'box','off')

hl2=line(x2,y2,'Color','r','Parent',ax(2));

%label the two x-axes
set(get(ax(1),'xlabel'),'string',xlabels{1},'fontsize',OPT.fontsize);
set(get(ax(2),'xlabel'),'string',xlabels{2},'fontsize',OPT.fontsize);
set(get(ax(1),'ylabel'),'string',ylabels{1},'fontsize',OPT.fontsize);
set(get(ax(2),'ylabel'),'string',ylabels{2},'fontsize',OPT.fontsize);
