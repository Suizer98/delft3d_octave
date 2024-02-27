function UCIT_batchCommand()
%UCIT_BATCHCOMMAND   the next command will be batched
%
% input:       
%    function has no input
%
% output:       
%    function has no output  
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, February 2004)
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

% $Id: UCIT_batchCommand.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

guiH     = findobj('tag','UCIT_mainWin');
guiHback = findobj('tag','UCIT_mainWin_background');

if strcmp(get(findobj(guiH,'tag','UCIT_batchCommand'),'checked'),'off')
    %check menuitem
    set(findobj(guiH,'tag','UCIT_batchCommand'),'checked','on');
    
    %change color of GUI
    guiColor=get(guiHback,'BackgroundColor');
    for ii=1:-0.05:0
        set(guiHback,'BackgroundColor',[guiColor(1) 1-ii*(1-guiColor(2)) 1-ii*(1-guiColor(3))]);
        drawnow;
    end
else
    %Uncheck and uncolor GUI
    set(findobj(guiH,'tag','UCIT_batchCommand'),'checked','off');
    
    %change color of GUI
    guiColor=get(guiHback,'BackgroundColor');
    set(guiHback,'BackgroundColor',[guiColor(1) guiColor(1) guiColor(1)]);
end
