function strout = mktex(strin);
%MKTEX   Make char string into valid LaTeX string.
%
% strout = mktex(strin)
%
% Replaces following in string strin:
%
% '\'  becomes '\\'
% '_'  becomes '\_'
% '^'  becomes '\^'
%
% such that strout can be used as a LaTeX name, as in 
% TITLE of XLABEL for instance, without having to 
% put the interpeter property to off to avoid interpretation
% into sub- and supertext.
%
% See also: ISLETTER, MKVAR, MKHTML

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

% $Id: mktex.m 2724 2010-06-24 14:25:22Z boer_g $
% $Date: 2010-06-24 22:25:22 +0800 (Thu, 24 Jun 2010) $
% $Author: boer_g $
% $Revision: 2724 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/mktex.m $
% $Keywords$

strout = strin;
strout = strrep(strout,'\','\\');
strout = strrep(strout,'_','\_');
strout = strrep(strout,'^','\^');

%% EOF