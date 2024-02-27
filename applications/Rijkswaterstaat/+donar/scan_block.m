function [iline, ival, bob]= scan_block(fid,varargin)
%scan_block    fast scan donar dia data block without reading data
%
% [iline, ival]= scan_block(fid,<keyword,value>)
%
% scans a data block to determine number of lines andf number
% of values (can be kore per line). The file pointer should be
% where it is after donar.read_header(). Optionally repositions 
% the file pointer after scanning with keyword 'rewind'=1.
%
% [iline, ival,position] = donar.scan_block(fid) returns the
% ftell position of the begin of the block.
%
% See also: scan_file = read_header + scan_block, read_block

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
% $Id: scan_block.m 10137 2014-02-05 09:50:57Z boer_g $
% $Date: 2014-02-05 17:50:57 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10137 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/scan_block.m $
% $Keywords: $

% warning('TO DO: return # ncolumns')

OPT.rewind = 0;

OPT = setproperty(OPT,varargin);

    bob = ftell(fid); % begin of block

    rec = fgetl(fid);
    if rec == -1, temp = -1; return; end %Is it the end of the file?
    
    iline = 0;
    ival  = 0;

    % STOP at each [wrd]    
    while ~(strcmpi(rec(1),'[') | rec==-1)
        p     = strfind(rec,':');
        ival  = ival + length(p);
        iline = iline+1;
        eob   = ftell(fid); % end of block
        rec   = fgetl(fid);
    end
    
    if OPT.rewind
       fseek(fid,bob,'bof'); % remedy against last rec, that belonhg to block and not header
    else
       fseek(fid,eob,'bof');        
    end
