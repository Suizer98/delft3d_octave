function block_data = read_block(fid,ncolumn,nval,varargin)
%READ_BLOCK reads one block of donar data
%
%    block_data = donar.read_block(fid,ncolumn,nval) 
%
% reads the datablock into a call matrixs. NOTE the file
% pointer should be where it was after donar.read_header()
% or be put at ftell position returned by donar.scan_block().
% read_block leaves the pointer at the end of the block,
% at the start of the next header or eof. This way, an 
% entire file can be read by alternatingly calling
% donar.read_header() and donar.scan_block(). 
%
% ncolumn is the number of ;-separated columns inside one
% DONAR tuple (that are :-separated). Note that the donar
% value x/y is here parsed into 2 seperate columns x and y,
% so block_data will be size [:, ncolumn+1].
%
% Use donar.squeeze_block to remove nodatavalue data.
%
% See also: scan_block, squeeze_block

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: read_block.m 10137 2014-02-05 09:50:57Z boer_g $
% $Date: 2014-02-05 17:50:57 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10137 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/read_block.m $
% $Keywords: $

OPT.format   = '%s';

OPT = setproperty(OPT,varargin);

    fmt  = repmat(OPT.format,[1 ncolumn+1]); % variable column has sub-column
    temp = textscan(fid,fmt,nval,'delimiter',';:/');
    
    %% make number from text
    for i=1:ncolumn+1
        temp{i} = str2num(char(temp{i}));
    end

if isempty(temp{ncolumn})

   block_data = [];

else

   block_data = cell2mat(temp);

end
