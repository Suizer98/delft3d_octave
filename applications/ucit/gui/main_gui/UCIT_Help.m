function UCIT_Help(linktype)
%UCIT_HELP   This routine opens a webpage identified by <linktype>.
%
% syntax:
%  UCIT_Help(linktype)
%
% input:
%    linktype = variable identifying which weblink to open
%        1: transects
%        2: grids
%        3: lines
%        4: points
%
% output:
%    objTag1 = tag of first popup
%    objTag2 = tag of second popup
%    objTag3 = tag of third popup
%    objTag4 = tag of fourth popup
%
% output:       
%    function has no output  
%

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

% $Id: UCIT_Help.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

switch linktype
    case 1 % general mctools page
        web http://mctools.deltares.nl -browser -new;
    case 2 % Ucit page
        web http://public.deltares.nl//x/aoWC -browser -new;
    case 3 % tips and tricks page
        web http://public.deltares.nl//x/e4WC -browser -new;
end
