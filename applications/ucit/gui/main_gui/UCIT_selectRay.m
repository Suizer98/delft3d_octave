function UCIT_selectRay(varargin)
%UCIT_SELECTRAY   this routine selects transects by mouse click
%              
% input:       
%    routine has no input
%
% output:       
%    routine has no output
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, January 2006)
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% -------------------------------------------------------------------- 

% $Id: UCIT_selectRay.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

UCIT_resetUCITDir

%Interactively select ray from Jarkus overzicht (figure mapWindow)

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make a JARKUS Overview!','No map found');
    return
end

figure(mapW);
% Reset current object (set the current object to be the figure itself)
set(mapW,'CurrentObject',mapW);

%Find all rays
rayH=findobj(gca,'type','line','LineStyle','-');
dpTs=strvcat(get(rayH,'tag'));
for ii=1:size(dpTs,1);
    if strfind(dpTs(ii,:),':')
        res(ii)=1;
    end
end
rayH=rayH(find(res==1));

if isempty(rayH)
    errordlg('No rays found!','');
    return
end

plotedit on;

while ~ismember(rayH,gco)
    pause(0.1);
end

set(rayH,'color',[1 0 0],'linewidth',0.15);
set(gco,'color',[0 1 0],'linewidth',1.5);
refresh;

plotedit off;

% Put the raynumber and coastvak in the GUI
[raaiNummer,kustVak]=strtok(get(gco,'tag'),':');
kustVak=kustVak(2:end);

if nargin==0 %From the UCIT GUI
    guiH=findobj('tag','UCIT_mainWin');
    set(findobj(guiH,'tag','h0'),'string',kustVak);
    set(findobj(guiH,'tag','h1'),'string',raaiNummer);
else
    switch varargin{1} %From batch windows, more cases possible
        case 'startDuinafslag'
            guiH=findobj('tag','UCIT_batchDuinafslagInput');
            set(findobj(guiH,'tag','UCIT_batchInputStartArea'),'string',kustVak);
            set(findobj(guiH,'tag','UCIT_batchInputStartRay'),'string',raaiNummer);
        case 'endDuinafslag'
            guiH=findobj('tag','UCIT_batchDuinafslagInput');
            set(findobj(guiH,'tag','UCIT_batchInputEndArea'),'string',kustVak);
            set(findobj(guiH,'tag','UCIT_batchInputEndRay'),'string',raaiNummer);
    end
    
end