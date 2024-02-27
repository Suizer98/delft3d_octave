function UCIT_print(WorkDir)
%UCIT_print   this routine prints the current fig to a graphics file
%
% input:       
%    WorkDir = directory to which the plot must be saved 
%
% output:       
%    function has no output 
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

% $Id: UCIT_print.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

UCIT_resetUCITDir;

pW=findobj('tag','plotWindow');
if isempty(pW)
    errordlg('No plots found!','Error printing');
    UCIT_resetUCITDir
    return
end

% Het is handig dat niet de hele tijd naar een bepaalde directory hoeft te worden gewandeld
if nargin==0
    WorkDir = getINIValue('UCIT.ini','WorkDir'); 
end

try 
    cd(WorkDir)
    
    batchPrint=getINIValue('UCIT.ini','printCommand');
    if isempty(batchPrint)
        printdlg(findobj('tag','plotWindow'));
    else
        eval(batchPrint);
    end
    
    %Back to old dir
    UCIT_resetUCITDir;
catch
    disp(lasterr);
    %Back to old dir
    UCIT_resetUCITDir;
end
