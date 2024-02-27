function tabledisp(varargin)
%TABLEDISP   draw table of all 1D input vector arrays
%
%   TABLEDISP(fmt, vectorarray1, vectoraray2 ,....)
%
%  draws a table of all input vectors using format fmt, 
%  with first column being element number of vector.
%
%  All arrays need to have the same size.
%
%See also: DISP, SPRINTF

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: tabledisp.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/tabledisp.m $
% $Keywords$

%% extract format from first argument and ...
%-----------------------------------------------
fmt = varargin{1};

%% ... overwrite first argument with array 1 to length of vectors to become 1st column
%-----------------------------------------------
varargin{1} = 1:length(varargin{2});

%% draw table
%-----------------------------------------------
for ip=1:length(varargin{2})

   record = sprintf(fmt,cellfun(@(x) select_index(x,ip),varargin)); %['%',num2str(width),'g ']
   
   disp(record)
   
end

%-----------------------------------------------

function element = select_index(matrix,index)

element = matrix(index);

%% EOF
