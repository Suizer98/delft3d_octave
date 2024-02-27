function [Data, M] = read(File,ivar,ncolumn,varargin)
%READ read one variable from DONAR dia file (aggregating blocks)
%
%   [D,M] = donar.read(Info, variable_index, ncolumn)
%
% reads one variable from a dia file info array D, merging the internal
% dia blocks, where Info is the result from donar.open_file(),
% variable_index is the index of the variables found
% in the donar file (varies per file), and ncolumn is
% the number of data columns (where ncolumn is the variable column),
% needed internally to reshape the ascii donar data. M 
% contains a copy of the relevant variable metadata from Info.
%
% The coordinate columns 1+2 are parsed (WGS84 ONLY yet),
% and the date columns 3 is converted to Matlab datenumbers.
% Two extra columns are added next t ncolumn: dia flags and dia block index
%
% Note that timezone information is NOT in de dia files !
%
% Example: 
%
%  File            = donar.open_file(diafile)
%                    donar.disp(File)
% [data, metadata] = donar.read(File,1,6) % 1st variable, residing in 6th column
%
%See also: open_file, open_files, read, disp

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
% $Id: read.m 10137 2014-02-05 09:50:57Z boer_g $
% $Date: 2014-02-05 17:50:57 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10137 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/read.m $
% $Keywords: $

% TODO determine percentage nodatavalue

    OPT.disp        = 100;
    OPT.nodatavalue = []; % default to squeeze them out
    
    if nargin==0
        Data = OPT;return
    end
    OPT = setproperty(OPT,varargin);
    
    if ischar(File.Filename)
        File.Filename = cellstr(File.Filename);
    end

    for ifile=1:length(File.Filename)
       fid(ifile) = fopen(File.Filename{ifile},'r');
    end

%% read data from multiple blocks across multiple files into one array

    i0  = 1;
    nbl = length(File.Variables(ivar).block_index);
    if OPT.disp > 0
       disp([mfilename,' loading: ',File.Variables(ivar).hdr.PAR{1},': ',File.Variables(ivar).long_name]) % in case one of first OPT.disp blocks is BIG
       disp([mfilename,' loaded block ',num2str(0),'/',num2str(nbl)])
    end
    
    Data = repmat(nan,[sum(File.Variables(ivar).nval),ncolumn+2]); % extra column for flags and for dia block_index

    for ibl=1:nbl
       i1 = sum(File.Variables(ivar).nval(1:ibl));
       if mod(ibl,OPT.disp)==0
       disp([mfilename,' loaded block ',num2str(ibl),'/',num2str(nbl),' (',num2str(ibl/nbl*100),'%)'])
       end
       fid1 = fid(File.Variables(ivar).file_index(ibl));
       fseek(fid1,File.Variables(ivar).ftell(2,ibl),'bof');% position file pointer
       Data(i0:i1,1:end-1) = donar.read_block(fid1,ncolumn,File.Variables(ivar).nval(ibl));
       Data(i0:i1,  end  ) = ibl;
       i0 = i1+1;
    end % ibl

    for ifile=1:length(File.Filename)
       fclose(fid(ifile));
    end
    
 %% Remove or NaNify nodatavalues

    Data = donar.squeeze_block(Data,ncolumn,'nodatavalue',OPT.nodatavalue);
    
 %% either do both inline D{i}, or do both explicit D{i}(:,column)

    Data(:,1) = donar.parse_coordinates(Data(:,1));
    Data(:,2) = donar.parse_coordinates(Data(:,2));
    Data      = donar.parse_time(Data, ncolumn - [2 1]); % has to be inline due to sorting by parse_time
     
 %% copy relevant meta-data fields (not dia-file specific)
 %  Should perhaps better be in seperate substruct of File

    OPT.metafields = setdiff(fieldnames(File.Variables(ivar)),{'ftell','nline','nval'});

    for ifld=1:length(OPT.metafields)
        try
        fld = OPT.metafields{ifld};
        M.(fld) = File.Variables(ivar).(fld);
        end
    end
