function disclaimer = ITHK_KMLdisclaimer(sens)
% ITHK_KMLdisclaimer(sens)
%
% creates kml-txt for a disclaimer
% 
% The kml code (without header/footer) is written to the S structure 

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares for Building with Nature
%       Bas Huisman
%
%       Bas.Huisman@deltares.nl	
%
%       Deltares
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

% $Id: ITHK_KMLdisclaimer.m 6660 2012-06-27 16:11:10Z huism_b $
% $Date: 2012-06-28 00:11:10 +0800 (Thu, 28 Jun 2012) $
% $Author: huism_b $
% $Revision: 6660 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/operations/ITHK_KMLdisclaimer.m $
% $Keywords: $

global S

if nargin<1
sens=1;
end

disclaimer1 = S.settings.postprocessing.disclaimer.string1;
disclaimer2 = S.settings.postprocessing.disclaimer.string2;
scaleFAC=1;
figure('visible','off');
set(gcf,'MenuBar','None');
set(gcf,'Position',[50 50 100 30]);
set(gcf,'PaperSize',[10,30]);
set(gcf,'PaperPosition',[0 0 10*scaleFAC 0.6*scaleFAC]);
h1=text(0,0.65,disclaimer1,'FontSize',20,'Color','y');axis off;
h2=text(0,0.25,disclaimer2,'FontSize',20,'Color','y');axis off;
set(gca,'Position',[0,0,1,1]);
print('-dpng',['plot1.png']);
I = imread('plot1.png');
axc = get(gca,'Color');
axc = ceil(axc*255);
alphaMap = ~(I(:,:,1)==axc(1) & I(:,:,2)==axc(2) & I(:,:,3)==axc(3)).*255;
imwrite(I,[S.settings.basedir '\ITviewer\openearthtest\openearthtest\public\images\disclaimer.png'],'Alpha',uint8(alphaMap));
close all
delete('plot1.png')

figtexturl{1} = ['http://127.0.0.1:5000/images/disclaimer.png'];
disclaimer = '';
timeIn    = datenum((S.PP(sens).settings.tvec(1)+S.PP(sens).settings.t0),1,1);
timeOut   = datenum((S.PP(sens).settings.tvec(end)+S.PP(sens).settings.t0),1,1)+364;
timeSpan = KML_timespan('timeIn',timeIn,'timeOut',timeOut);

disclaimer = [disclaimer sprintf([...
    '  <ScreenOverlay>\n'...
    '  <name>budgetbar</name>\n'...
    '  <visibility>1</visibility>\n'...
    '  %s\n'...
    '  <Icon><href>%s</href></Icon>\n'...
    '   <overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>\n'...
    '   <screenXY  x="0.05" y="0.8" xunits="fraction" yunits="fraction"/>\n'...
    '   <size x="0" y="0.1" xunits="fraction" yunits="fraction"/>\n'... 
    '  </ScreenOverlay>\n'],...
    timeSpan,...
    figtexturl{1})];