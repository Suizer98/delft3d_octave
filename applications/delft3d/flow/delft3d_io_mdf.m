function varargout=delft3d_io_mdf(cmd,varargin)
%DELFT3D_IO_MDF   x read/write Delft3D ASCII Master Definition File (*.mdf) <<beta version!>>
%
%   DATA         = delft3d_io_mdf('read' ,<filename>,<keyword,value>);
%  [DATA,iostat] = delft3d_io_mdf('read' ,<filename>,<keyword,value>);
%
%         iostat = delft3d_io_mdf('write',filename,DATA.keywords);
%
% where iostat= 1 when writing was succesful,
% and iostat=-1/-2/-3 when error finding/opening/reading file.
%
%  [DATA,iostat] = delft3d_io_mdf('new',<template_*.mdf>)
%
% loads an template, where template_extensions.mdf  and template_empty.mdf
% contain all known keywords (incl. % mutually exclusive ones) and
% template_gui.mdf only returns the default one from  the GUI (default).
%
% Note that the keywords in the mdf file are not case sensitive,
% whereas the field names in matlab are case sensitive. When reading file
% all keyword are therefore set to LOWER CASE by default. This can be
% changed by adding a <keyword,value> pair (for reading and writing):
% * 'case' = 'upper'/'auto'/'lower' (default).
%
% Note that when a keyword appears multiple times in the *.mdf file,
% Delft3D uses (by experience, not in the manual) the first
% instance of the keyword. One should be aware of this when using
% case='auto', in which case multiple instances of the same keyword with
% different cases can end up in the MDF file.
%
% Comment lines are read but cannot not be written to mdf file. The
% delft3d_io_mdf version is added as keyword, except when keyword 'stamp'=0
%
% To control the order of keywords in the mdf file, or to write only a subset,
% use keyword selection, e.g.: delft3d_io_mdf('write',filename,'selection',{'runtxt','mnkmax'});
%
% For keywords that use multiple lines use sprintf to make a formatted string, for example:
% DATA.tidfor = sprintf('%s\n%s\n%s','M2 S2 N2 K2#','         #K1 O1 P1 Q1#','         #MF MM SSA--');
%
% Storage flags for map data (trim only)
%     SMhydr(1:6)  - water level, U, V, magnitude, direction, w/omega velocities
%     SMproc(1:2)  - salinity, temperature
%     SMproc(3:7)  - constituent1, .., constituent5
%     SMproc(8)    - intensity spiral motion
%     SMproc(9:10) - turbulent energy k and dissipation eps
%     SMderv(1:2)  - U and V Bed shear stress
%     SMderv(3:4)  - vertical eddy viscosity and diffisuvity and Ri if either of both are selected
%     SMderv(5:6)  - density and HLES
%
% See also: delft3d, python module "openearthtools.io.delft3d.mdf"

% Mar 13 2006: added keyword for upper/lower case
% Dec 19 2005: changes a few special cases when writing
% Oct 27 2006: added iostat catchers
% Jul 11 2007: added reading of comments and employed strcmpi everwhere
% Aug 27 2007: added keywords whose numerical values need to written column wise (Thick,Rettis,Rettib,s0,c01,c02,c03,c04,c01)
% jul 29 2009: fixed error: now keep comment text & added cmd to read template ('new')

% TO DO: when writing use preferred order of mdf file (ident 1st, then a comment etc.

% Uses
% + odd
% + strtrim
% - strselect not any more, is enclosed now
% + delft3d_io_mdf
%   + time2datenum

%   --------------------------------------------------------------------
%   Copyright (C) 2005-6 Delft University of Technology
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
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delft3d_io_mdf.m 16363 2020-05-04 15:38:58Z kaaij $
% $Date: 2020-05-04 23:38:58 +0800 (Mon, 04 May 2020) $
% $Author: kaaij $
% $Revision: 16363 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_mdf.m $

%% Get filename from GUI

if (nargin ==1) & strcmpi(cmd,'read')
    
    [fname, pathname, filterindex] = uigetfile( ...
        {'*.mdf', 'Delft3D-FLOW input file (*.mdf)'; ...
        '*.*'  , 'All Files               (*.*)'}, ...
        'Delft3D-FLOW');
    
    if ~ischar(fname) % uigetfile cancelled
        fname = [];
        iostat         = 0;
    else
        fname = [pathname, fname];
        iostat         = 1;
    end
    nextarg = 1;
elseif (nargin ==1) & strcmpi(cmd,'write')
    error('for write 2 input parameters required: delft3d_io_mdf(''write'',filename,DATA)')
elseif nargin>1
    fname   = varargin{1};
    nextarg = 2;
end

%disp   ('This is a beta version for writing with delft3d_io_mdf.')
%disp   ('Reading and writing of comment lines not supported yet.')

%% Switch read/write

switch lower(cmd)
    
    case 'read'
        
        if     nargout ==1
            
            [DAT       ] = Local_read(fname,varargin{nextarg:end});
            varargout  = {DAT};
            
        elseif nargout  == 2
            
            [DAT,iostat] = Local_read(fname,varargin{nextarg:end});
            varargout  = {DAT,iostat};
            
        elseif nargout >2
            
            error('too much output parameters: 1 or 2')
            
        end
        
    case 'write'
        
        OS           = 'windows'; % or 'unix'
        iostat=Local_write(OS,fname,varargin{nextarg:end});
        
        if nargout ==1
            
            varargout = {iostat};
            
        elseif nargout >1
            
            error('too much output parameters: 0 or 1')
            
        end
        if iostat<0,
            error(['Error opening file: ',varargin{1}])
        end;
        
    case 'new'
        
        %
        % TK: mfilename does NOT work when making an executable:
        %     optional: If entire filename of the template is given use that one!
        %
        
        path_m = fileparts(mfilename('fullpath'));
        
        if nargin==2
            [path_file,dummy,dummy] = fileparts(varargin{1});
            if ~isempty(path_file)
                fname = varargin{1};
            else
                fname    = [path_m,filesep,varargin{1}];
            end
        else
            fname    = [path_m,filesep,'template_gui.mdf'];
        end
        
        if     nargout ==1
            
            [DAT       ] = Local_read(fname);
            varargout  = {DAT};
            
        elseif nargout  == 2
            
            [DAT,iostat] = Local_read(fname);
            varargout  = {DAT,iostat};
            
        elseif nargout >2
            
            error('too much output parameters: 1 or 2')
            
        end
        
    otherwise
        
        error(['option not implemented:',cmd])
        
end;

% ------------------------------------
% --READ------------------------------
% ------------------------------------

function varargout=Local_read(fname,varargin)

%% Input

OPT.case = 'lower';

OPT = setproperty(OPT,varargin);

STRUCT.filename     = fname;
STRUCT.case         = OPT.case;
STRUCT.iostat       = -3;


%% Locate

tmp = dir(fname);

% ones in matlab path
if length(tmp)==0 & exist(fname,'file')==2
    clear tmp
    tmp.name = filename(fname);
    tmp.date = '';
    tmp.bytes= '';
end

if length(tmp)==0
    
    STRUCT.iostat = -1;
    disp (['??? Error using ==> delft3d_io_mdf'])
    disp (['Error finding file: ',fname])
    
elseif length(tmp)>0
    
    STRUCT.filedate  = tmp.date;
    STRUCT.filebytes = tmp.bytes;
    
    fid              = fopen(STRUCT.filename,'r');
    
    %% Open
    
    if fid < 0
        
        STRUCT.iostat = -2;
        disp (['??? Error using ==> delft3d_io_mdf'])
        disp (['Error opening file: ',fname])
        
    elseif fid > 2
        
        %% Read
        
        %-% try
        
        count.line    = 0;
        count.comment = 0;
        while 1
            
            %% get line
            
            newline          = fgetl(fid);
            if ~ischar(newline);break, end % -1 when eof
            if length(deblank2(newline)) > 0;
                count.line=count.line+1;
                
                %% Keyword
                keyword  = deblank(newline(1:6));
                
                if     strcmpi(STRUCT.case,'lower')
                    keyword  = lower(keyword);
                elseif strcmpi(STRUCT.case,'upper')
                    keyword  = upper(keyword);
                elseif ~strcmpi(STRUCT.case,'auto')
                    error('case should be lower/upper/auto')
                end
                
                value    = newline(7:end);
                
                if ~isempty(keyword)
                    keyword_last     = keyword;
                    
                    % remove = sign and leading/trailing blanks
                    equalsignposition = findstr(value,'=');
                    value             = strtrim(value(equalsignposition+1:end));
                else
                    value=strtrim(value);
                end
                
                %% Look for strings
                
                if ~strcmpi(keyword,'commnt') && ~strncmp(keyword,'#',1)
                    [string,strstat] = strselect(value,'#');
                    if strstat ==1
                        value = string;
                    else
                        value =str2num(value); % vectorized !!
                    end
                end
                
                %% Assign value
                if isempty(keyword)
                    STRUCT.keywords.(keyword_last)=[STRUCT.keywords.(keyword_last),value];
                elseif strcmpi(keyword,'commnt') || strncmp(keyword,'#',1)
                    count.comment  = count.comment + 1;
                    STRUCT.comments{count.comment} = value;
                else
                    if ~isempty(keyword)
                        STRUCT.keywords.(keyword)  = value;
                    elseif ~strcmpi(keyword,'commnt')
                        STRUCT.keywords.(keyword_last) = [STRUCT.keywords.(keyword_last) value];
                    end
                end
            end
        end % while
        
        %% Extract sensible data
        try 
            STRUCT.data.datenum = time2datenum(STRUCT.keywords.itdate) + ...
                [STRUCT.keywords.tstart:...
                STRUCT.keywords.dt:...
                STRUCT.keywords.tstop]./60./24;
        end
        
        %% Finished succesfully
        
        STRUCT.linecount = count.line;
        fclose(fid);
        STRUCT.iostat    = 1;
        
        %-% catch
        %-%
        %-%    STRUCT.iostat = -3;
        %-%    disp (['??? Error using ==> delft3d_io_mdf'])
        %-%    disp (['Error reading file: ',fname])
        %-%
        %-% end % catch
        
    end % if fid < 0
    
end %elseif length(tmp)>0

if nargout==1
    varargout = {STRUCT};
else
    varargout = {STRUCT,STRUCT.iostat};
end

% ------------------------------------
% --WRITE-----------------------------
% ------------------------------------


function iostat=Local_write(OS,filename,STRUC,varargin),

iostat        = 1;

%% Input

OPT.case      = 'lower';
OPT.selection = {};
OPT.stamp     = 1;

OPT = setproperty(OPT,varargin);

if OPT.stamp
    STRUC.commnt  = ['Written $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_mdf.m $ $Id: delft3d_io_mdf.m 16363 2020-05-04 15:38:58Z kaaij $ on ',datestr(now)];
end

fid          = fopen(filename,'w');
if     strcmpi(lower(OS(1)),'u')
    EOL = '\n';
elseif strcmpi(lower(OS(1)),'w')
    EOL = '\r\n';
end

if ~isempty(OPT.selection)
    fldnames = OPT.selection;
else
    if    strcmpi(OPT.case,'lower')
        fldnames = lower(fieldnames(STRUC));
    elseif strcmpi(OPT.case,'upper')
        fldnames = upper(fieldnames(STRUC));
    elseif strcmpi(OPT.case,'auto')
        fldnames =      (fieldnames(STRUC));
    else
        error('case should be lower/upper/auto')
    end
end

for i=1:length(fldnames)
    
    keyword  = char(fldnames{i});
    keyword6 = pad(keyword,6,' ');
    
    if ~isfield(STRUC,keyword)
        error(['"',keyword,'" is not a valid mdf keyword, please mind that keywords are case-sesitive'])
    else
        value    = STRUC.(keyword);
    end
    
    %% HANDLE SPECIAL CASES (A LOT)
    %  that makes tdatom or GUI fail to read these items
    
    if iscell(value)
        value0 = value;
        value  = [];
        for i=1:length(value0)
            value = strvcat(value,['#',char(value0{i}),'#',]);
        end
    elseif ischar(value)
        if strcmpi(keyword6,'Runtxt')
            if size(value,2) > 30
                value = line2block(value,30);
            end
        end
        value = addrowcol(value,[0],[-1 1],'#');
    elseif isnumeric(value)
        
        if isempty(value)
            value = '[.]';
        else
            %% values that need to be written column wise rather than row wise (although short row vectors are allowed)
            %  pad keywordf to six with spaces
            if strcmpi(keyword6,'Thick ') | ...
                    strcmpi(keyword6,'Rettis') | ...
                    strcmpi(keyword6,'Rettib') | ...
                    strcmpi(keyword6,'u0    ') | ...
                    strcmpi(keyword6,'v0    ') | ...
                    strcmpi(keyword6,'s0    ') | ...
                    strcmpi(keyword6,'t0    ') | ...
                    strcmpi(keyword6,'c01   ') | ...
                    strcmpi(keyword6,'c02   ') | ...
                    strcmpi(keyword6,'c03   ') | ...
                    strcmpi(keyword6,'c04   ') | ...
                    strcmpi(keyword6,'c01   ') | ...
                    strcmpi(keyword6,'ilAggr')
                value=value(:);
            end
            value = num2str(value);
        end
    end
    
    % These calls below erase values from the original mdf file, I have no clue
    % why this is done, but I've removed 3 of them that I don't agree with by using the call
    % && isempty(value). This only sets empty values to its originals. (Freek Scheel, 2015)
    
    if strcmpi(keyword6,'MNtd  ')
        value = ['[ ] [ ] [ ] [ ] ',value];
    end
    
    if strcmpi(keyword6,'MNbar ')
        value = ['[ ] [ ] # #'];
    end
    
    if strcmpi(keyword6,'MNwlos')
        value = ['[ ] [ ]'];
    end
    
    if strcmpi(keyword6,'MNgrd ')
        value = ['[ ] [ ]'];
    end
    
    if strcmpi(keyword6,'MNdry ')
        value = ['[ ] [ ]'];
    end
    
    if strcmpi(keyword6,'MNcrs ')
        value = ['[ ] [ ] [ ] [ ]'];
    end
    
    if strcmpi(keyword6,'Prmap ') && isempty(value)
        value = ['[.] '];
    end
    
    if strcmpi(keyword6,'Prhis ') && isempty(value)
        value = ['[.] [.] [.] '];
    end
    
    if strcmpi(keyword6,'Tpar  ')
        value = ['[.] [.]'];
    end
    
    if strcmpi(keyword6,'XYpar ')
        value = ['[.] [.]'];
    end
    
    if strcmpi(keyword6,'Eps   ')
        value = ['[.]'];
    end
    
    if strcmpi(keyword6,'Z0v   ') && isempty(value)
        value = ['[.]'];
    end
    
    if strcmpi(keyword6,'Cmu   ')
        value = ['[.]'];
    end
    
    if strcmpi(keyword6,'Cpran ')
        value = ['[.]'];
    end
    
    %% Write key word and value
    
    for i=1:size(value,1)
        if i==1
            fprintf (fid,'%s = %s \n',keyword6,value(i,:));
        else
            fprintf (fid,'%s  %s \n','       ',value(i,:)); % where value needs multiple lines but keyword not
        end
    end
    
end

iostat = fclose  (fid);

if iostat==0
    disp(['File ',filename,' successfully written']);
    % Set it to 1, that is what is said in the help:
    iostat = iostat + 1;
else
    disp(['Error: file ',filename,' NOT successfully written']);
end

% ------------------------------------
% --STRSELECT-------------------------
% ------------------------------------

function varargout = strselect(s,varargin)
%STRSELECT Remove leading and trailing blanks.
%   strselect(S) selects


s1         = s([]);
findstatus = 0;
selectbehaviour = 'smallest_subsets_strings';
selectbehaviour = 'largest_overall_string';
startoffset     =  1; % when 0 start pattern is included in slected string
endoffset       =  1; % when 0 end   pattern is included in slected string
warningsoff     = 1;

if nargin==2
    selectstart = varargin{1};
    selectend   = selectstart;
else
    selectstart = varargin{1};
    selectend   = varargin{2};
end

if ~isempty(s) & ~isstr(s)
    warning('Input must be a string.')
    findstatus = -1;
end


if isempty(s)
    findstatus = -2;
else
    
    indices_start= findstr(s,selectstart);
    indices_end  = findstr(s,selectend  );
    
    if isempty(indices_start)
        if ~warningsoff
            disp('No start of substring found')
        end
        findstatus = -3;
    elseif isempty(indices_end)
        if ~warningsoff
            disp('No end of substring found')
        end
        findstatus = -4;
    else
        switch  lower(selectbehaviour)
            case 'smallest_subsets_strings'
                if strcmpi(selectstart,selectend)
                    if odd(size(indices_start))
                        if ~warningsoff
                            disp('unenclosed string')
                        end
                        findstatus = -5;
                    else
                        % indices_start==indices_end
                        indices_start = indices_start(1:2:end-1);
                        indices_end   = indices_end  (2:2:end  );
                    end
                else
                    if ~length(indices_start)==length(indices_start);
                        if ~warningsoff
                            disp('unenclosed string')
                        end
                        findstatus = -6;
                    end
                end
                % check if each substring start after the previous ended
                for i=1:length(indices_start)-1
                    if indices_start(i+1) < indices_end(i)
                        if ~warningsoff
                            disp('Intertwined pairs')
                        end
                        findstatus = -7;
                    end
                end
                for i=1:length(indices_start)
                    s1{i} = s(:,min(indices_start(i))+ length(selectstart):...
                        max(indices_end  (i))-1);
                end
                findstatus = 1;
            case 'largest_overall_string'
                s1 = s(:,min(indices_start)+length(selectstart):...
                    max(indices_end  )-1);
                findstatus = 1;
        end
    end
    
end

if sign(findstatus)==-1
    s1 = s([]);
end

if nargout==1
    varargout = {s1};
else
    varargout = {s1,findstatus};
end

function out = odd(in)
%ODD
% out = odd(x) is 1 where x is odd.
%
% SEE ALSO: mod, sign


out = mod(in,2)==1;

%% EOF
