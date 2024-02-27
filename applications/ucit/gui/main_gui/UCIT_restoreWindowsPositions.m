function UCIT_restoreWindowsPositions
%UCIT_RESTOREWINDOWSPOSITIONS   This routine restores the positions of all UCIT windows
%
% This routine restores the positions of all UCIT windows
%
% syntax:    
%    UCIT_restoreWindowsPositions
%
% input: 
%    function has no input
%
% output:       
%    function has no output  
%
% example:      
% 	UCIT_restoreWindowsPositions
% 
% see also ucit

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, January 2006)
%     M.van Koningsveld
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

% $Id: UCIT_restoreWindowsPositions.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

batchvar = {...
    'UCIT_mainWin','LR';
    'plotWindow','UL';
    'plotWindow_US','UL';
    'mapWindow','LL';
    'USGSGUI','UR'};
    
for i = 1:size(batchvar,1)
    try %#ok<TRYNC>
        if ~isempty(findobj('tag',batchvar{i,1}))
            figure(findobj('tag',batchvar{i,1}));
            set(findobj('tag',batchvar{i,1}),'Position', UCIT_getPlotPosition(batchvar{i,2}));
        end
    end
end