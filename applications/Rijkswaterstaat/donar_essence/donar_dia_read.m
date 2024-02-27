function D = donar_dia_read(fname, varargin)
%DONAR_DIA_READ  Read DONAR DIA file into a struct
%
%   Read DONAR DIA file into a struct without interpretation of the result.
%   This function is based on reversed engineering of several DONAR DIA
%   files. It intends to split all data available in the ASCII file into a
%   struct, without interpretating these results. It just reads meta data,
%   if it sees some text and it reads true data if it only sees numbers.
%   The file structure is based on headers and fieldnames and as much as
%   possible preserved.
%
%   Syntax:
%   D = donar_dia_read(fname, varargin)
%
%   Input:
%   fname =     Filename of DONAR DIA file
%   varargin =  from:       First block to read
%               to:         Last block to read
%               stride:     Blocks to skip after each read
%               index:      Blocks to read (overwrites from, to and stride)
%               nodata:     Read meta data only
%               parse:      Parse structure afterwards
%               verbose:    Show progress bar
%
%   Output:
%   D     =     Resuting data structure
%
%   Example
%   D = donar_dia_read('example.dia')
%   D = donar_dia_read('example.dia','to',10)       % read first 10 blocks
%   D = donar_dia_read('example.dia','stride',20)   % read every twentieth block
%
%   See also donar, donar_dia_parse, donar_dia_view

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Apr 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: donar_dia_read.m 9922 2013-12-30 15:55:16Z boer_g $
% $Date: 2013-12-30 23:55:16 +0800 (Mon, 30 Dec 2013) $
% $Author: boer_g $
% $Revision: 9922 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/donar_essence/donar_dia_read.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'from',     0,      ...
    'stride',   1,      ...
    'to',       Inf,    ...
    'index',    [],     ...
    'nodata',   false,  ...
    'parse',    true,   ...
    'verbose',  true        );

OPT = setproperty(OPT, varargin{:});

if OPT.verbose
    wb = waitbar(0,'Please wait...');
end

%% read file

fid = fopen(fname,'r');
contents = fread(fid,'*char')';
fclose(fid);

%% read sections
% [W3H]
% [RKS]
% [WRD]
%
% read all section headers
ihdr = regexpi(contents,'\[(\w{3})\]\s*\n','start');
shdr = regexpi(contents,'\[(\w{3})\]\s*\n','tokens');
shdr = cellfun(@(x)x{1},shdr,'UniformOutput',false);

% determine unique headers
[uhdr i] = unique(shdr);
[~,   i] = sort(i);
uhdr     = uhdr(i);

%% read fields

% determine number of parts
npart = max(cellfun(@(x) sum(strcmpi(shdr,x)), uhdr));

i1 = max(OPT.from,1);
i2 = min(OPT.to,npart);

if isempty(OPT.index)
    OPT.index = i1:OPT.stride:i2;
else
    OPT.index = sort(OPT.index);
    i1 = min(OPT.index);
    i2 = max(OPT.index);
end

D  = xs_empty();
Ds = xs_empty();

% save header
D.header = regexprep(contents(1:ihdr(1)-1),'\s','');

mhdr   = cell2struct(num2cell(false(size(uhdr))),uhdr,2);
ipart  = 1;
iblock = 1;
for i = 1:length(ihdr)
    
    % register current header
	mhdr.(shdr{i}) = true;
    
    if OPT.verbose
        waitbar((ipart-i1+1)/(i2-i1+1),wb,sprintf('Reading %d/%d...',ipart,npart));
    end
    
    j1 = ihdr(i)+length(shdr{i})+3;
    
    if i == length(ihdr)
        j2 = length(contents);
    else
        j2 = ihdr(i+1)-1;
    end
        
    str = contents(j1:j2);

    Dss = xs_empty();

    % check if this is a meta or data block
    if ~isempty(regexpi(str,'[a-zA-Z]{3}','start'))
        % meta

        % split all lines
        re = regexpi(str,'(\w{3});(.*?)\s*\n','tokens');
        re = reshape([re{:}],2,length(re))';

        val = cellfun(@(x)regexpi(x,';','split'),re(:,2),'UniformOutput',false);

        % uniquefy names
        while length(unique(re(:,1)))<length(re(:,1))
            re(:,1) = cellfun(@(x1,x2)[x1 '_' x2{1}],re(:,1),val,'UniformOutput',false);
            val     = cellfun(@(x)x(2:end),val,'UniformOutput',false);
        end

        % unpack single valued cell arrays
        idx = cellfun(@length,val)==1;
        val(idx) = cellfun(@(x)x{1},val(idx),'UniformOutput',false);

        Dss.data = struct('name',re(:,1),'value',val);
    else
        % data

        if ~OPT.nodata

            % remove all line breaks
            str = regexprep(str,'[\r\n]','');

            % split primary axes steps (two intertwined, weirdo!)
            re = regexpi(str,'/|:','split');

            % split primary axes in secondary axes steps, if present (again
            % two intertwined!)
            s = {};
            for k = 1:2
                s1 = cellfun(@(x)regexpi(x,'[;\\]+','split'),re(k:2:end),'UniformOutput',false)';
                s2 = cellfun(@str2double,s1,'UniformOutput',false);

                s{k} = cell2mat(s2);
                s{k}(abs(s{k})>1e6) = nan;
            end

            % store two primary axes separately
            n = min(cellfun(@(x)size(x,1),s));

            Dss.data = struct('name',{'data1' 'data2'},'value',{s{1}(1:n,:) s{2}(1:n,:)});
        end
    end

    Dss = xs_meta(Dss, mfilename, 'donar_block_item');
    Ds  = xs_set(Ds,shdr{i},Dss);
    
    % check if this is the end of the last part or a new part will start in
    % the next iteration, if any of the two is true then store result
    if i == length(ihdr) || mhdr.(shdr{i+1})
        
        if ismember(ipart, OPT.index)
            Ds = xs_meta(Ds, mfilename, 'donar_block');
            D = xs_set(D,sprintf('block%03d',iblock),Ds);
            iblock = iblock + 1;
            
            Ds = xs_empty();
        end
        
        ipart = ipart + 1;
        mhdr  = cell2struct(cellfun(@(x) false, struct2cell(mhdr), 'UniformOutput', false), fieldnames(mhdr));
    end
end

D = xs_meta(D, mfilename, 'donar', abspath(fname));

%% parse fields

if OPT.parse
    if OPT.verbose
        waitbar(1,wb,'Parsing data...');
    end
    
    D = donar_dia_parse(D);
end

if OPT.verbose
    close(wb);
end