function selUser = UCIT_selectUser
%UCIT_SELECTUSER   this routine presents a selection box when UCIT is started without input arguments
%
% input:       
%    function has no input
%

% output:       
%    selUser = result from the selection process  
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, February 2004)
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

% $Id: UCIT_selectUser.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

selUser=[];

fig=openfig('UCIT_selectUser','reuse');

dirnames=dir(fullfile(cd, 'UCIT_users',  'users'));
dirnames=dirnames([dirnames.isdir]);

%Exclude the dirs '.' and '..' by excluding dirs starting with a .
dirnames=dirnames(~strncmp({dirnames.name},'.',1));

set(findobj(fig,'tag','UCIT_selectUserBox'),'string',{dirnames.name});

%Alternative wait statement for that #@($*#$&-UIWAIT
while ~strcmp(get(findobj(fig,'tag','UCIT_selectUserOk'),'userdata'),'done')
    drawnow;
    pause(0.1);
end

users=get(findobj(fig,'tag','UCIT_selectUserBox'),'string');
selUser=users{get(findobj(fig,'tag','UCIT_selectUserBox'),'value')};
delete(fig);








