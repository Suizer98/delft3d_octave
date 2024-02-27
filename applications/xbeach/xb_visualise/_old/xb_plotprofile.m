function xb_plotprofile(varargin)
%XB_PLOTPROFILE  Plot or animate cross shore profiles
%
%   Visualization toolbox for cross shore model results. The function
%   allows users to specify which XBeach output data to read and how to
%   plot them. This function reads XBeach output directly from the source
%   files. The function allows results to be saved as figures or as a
%   movie
%
%   Syntax:
%   xb_plotprofile(varargin)
%
%   Input:
%   Keyword,value pairs:
%     - dir    ::  directory from which to read variables. Default current
%                  directory
%     - vars   ::  cell of names of variable to be plotted 
%                  (default {'zb' 'zs' 'H'})
%     - starttime :: index of timestep to start animation (default 0)
%     - stoptime  :: index of timestep to stop animation (default xb.nt)
%     - colors ::  array of line colors for plotting each variable 
%                  (default ['k','r','g','b','m',...])                
%     - lineweights :: array of line weights for plotting each variable
%                      (default 1)
%     - factor ::  array of multiplication factors for plotting each
%                  variable (default 1)
%     - ylimit ::  ylim for animation (default none)
%     - rownumber :: number of the cross shore row to be plotted (default 2)
%     - stride :: number of time steps to stride during animation (default 1)
%     - pauselength :: period between subsequent frames (default 0.1s)
%     - output :: option to save as pictures ('png','.jpg',etc.) or movie ('avi') or
%                 neither ('none'). Default 'none'.
%     - outputfilename :: file name base for output (i.e.
%                         outputfilename.avi, outputfilename001.png). 
%                         Default 'plotprofile'
%     - avifileoptions :: cell of keyword, value options for avi output.
%                         Default {'fps',4,'quality',85}
%
%   Example
%   xb_plotprofile('vars',{'zs' 'u' 'ccg'},'factor',[1 1 2650])
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall
%
%       robert.mccall@deltares.nl	
%
%       Rotterdamseweg 185
%       Delft
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: xb_plotprofile.m 3497 2010-12-02 17:16:30Z hoonhout $
% $Date: 2010-12-03 01:16:30 +0800 (Fri, 03 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3497 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/_old/xb_plotprofile.m $
% $Keywords: $

%%

OPT = struct(...
    'dir',pwd,...
    'vars',{'zb' 'zs' 'H'},...
    'starttime',1,...
    'stoptime',Inf,...
    'colors',['k','r','g','b','m'],...
    'lineweights',1,...
    'factor',1,...
    'ylimit','none',...
    'rownumber',2,...
    'stride',1,...
    'pauselength',0.1,...
    'output','none',...
    'outputfilename','plotprofile',...
    'avifileoptions', {'fps',4,'quality',85});

setproperty(OPT,varargin{:});

XBdims=xb_read_dims(OPT.dir);
nt=XBdims.nt;
x=XBdims.x;
y=XBdims.y;

for i=1:length(OPT.vars)
    eval(['fid',num2str(i),'=fopen(''',fullfile(OPT.dir,OPT.vars{i}),'.dat'',''r'');']);
    eval(['if fid',num2str(i),'<0;error(''cannot find ',fullfile(OPT.dir,OPT.vars{i}),'.dat'');end']);
end

% original profile
try
    fidzb0=fopen('zb.dat','r');
    zb0=fread(fidzb0,size(x),'double');
    fclose(fidzb0);
catch
    warning ('No zb output file found to plot')
    zb0=NaN(size(x));
end

if strcmpi(OPT.output,'avi');
    mov = avifile([OPT.outputfilename '.avi'],OPT.avifileoptions);
end

f1=figure;

h0=plot(x(:,OPT.rownumber),zb0(:,OPT.rownumber),'color','k','linewidth',2,'linestyle','-.');

if ~strcmpi(OPT.ylimit,'none')
    ylim(ylimit);
end

if strcmpi(OPT.output,'avi');
    F=getframe(f1);
    mov = addframe(mov,F);
end

hold on;
for ii=1:length(OPT.vars)
    eval(['var',num2str(ii),'=OPT.fac(ii).*fread(fid',num2str(ii),',size(x),''double'');']);
    eval(['h',num2str(ii),'=plot(x(:,OPT.rownumber),var',num2str(ii),'(:,OPT.rownumber),''color'',''',OPT.colors(ii,:),''',''linewidth'',OPT.lineweights(ii));']);
end
legtext{1}='zb0';
for i=1:length(OPT.vars)
    if OPT.fac(i)==1
        legtext{i+1}=OPT.vars{i};
    else
        legtext{i+1}=[OPT.vars{i} ' (x ' num2str(OPT.fac(i)) ')'];
    end
end
l=legend(legtext,'location','eastoutside');
if start>2
    hwait = waitbar(0,'Loading files');
end
grid on
title('Start');
pause
times = [OPT.starttime:OPT.stride:min(OPT.stoptime,nt)];

for i=2:stop
    for ii=1:length(OPT.vars)
        eval(['var',num2str(ii),'=OPT.fac(ii).*fread(fid',num2str(ii),',size(x),''double'');']);
    end
    
    
    if any(times==i) %i>=start
        delete(hwait);
        if isempty(OPT.pauselength)
            show=true;
        else
            if or(OPT.pauselength>0,i==OPT.stoptime)
                show=true;
            else
                show=false;
            end
        end
        if show
            for ii=1:length(OPT.vars)
                eval(['set(h',num2str(ii),',''YData'',var',num2str(ii),'(:,OPT.rownumber));']);
            end
            title(num2str(i));
            if strcmpi(OPT.output,'avi');
                F=getframe(f1);
                mov = addframe(mov,F);
            elseif strcmpi(OPT.output,'none');
                % do nothing
            else
                try
                    saveas(gcf,[
            end
            if isempty(OPT.pauselength)
                pause
            else
                pause (OPT.pauselength);
            end
        end
    elseif i<OPT.starttime
        waitbar(i/(start-1),hwait);
    end
end

if strcmpi(OPT.output,'avi');
    mov=close(mov);
end

fclose all
