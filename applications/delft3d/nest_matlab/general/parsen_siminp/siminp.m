function S=siminp(S,file_waquaref,selection,varargin)
%SIMINP Read Simona Input File
%    S = SIMINP(FILENAME) reads the specified FILENAME as a Simona Input File
%    and returns a structure S containing the parsed input tree.

%----- LGPL --------------------------------------------------------------------
%
%   Copyright (C) 2011-2012 Stichting Deltares.
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation version 2.1.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, see <http://www.gnu.org/licenses/>.
%
%   contact: delft3d.support@deltares.nl
%   Stichting Deltares
%   P.O. Box 177
%   2600 MH Delft, The Netherlands
%
%   All indications and logos of, and references to, "Delft3D" and "Deltares"
%   are registered trademarks of Stichting Deltares, and remain the property of
%   Stichting Deltares. All rights reserved.
%
%-------------------------------------------------------------------------------
%   http://www.deltaressystems.com
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/nest_matlab/general/parsen_siminp/siminp.m $
%   $Id: siminp.m 18358 2022-09-11 09:21:52Z kaaij $
%
% Parse commands
%

LP = [1 1];
F = read_simona_format_table(file_waquaref);
Field = F.Field;

%
% Reduce to limited part of siminp file
%

if ~isempty(selection)
    S.File = reduce_siminp(selection ,S.File,Field);
end

S.ParsedTree = [];
if nargin>3
   debug = 1;
else
    debug = 0;
end
[S,LP] = subtreeparse(S,LP,Field,debug);
[Keyword,LP] = getnextkeyword(S.File,LP);
if isempty(Keyword)
   dprintf(debug,'Succesfull finished reading %s.\n',S.FileName);
else
   error('%s not recognized',Keyword)
end

%--------------------------------------------------------------------------
function [S,LP0,found] = subtreeparse(S,LP,Field,debug)
if isfield(Field,'Field')
   %
   % Intermediate level: define all fields.
   %
   for i=1:length(Field)
      S.ParsedTree.(Field(i).Name) = [];
   end
   %
   Keyword='';
   while isempty(Keyword)
      LP0 = LP;
      [Keyword,LP] = getnextkeyword(S.File,LP);
      while isempty(Keyword) && isfield(S,'CallingLocation')
         LP = S.CallingLocation;
         LP0 = LP;
         S.CallingFile.ParsedTree = S.ParsedTree;
         S = S.CallingFile;
         [Keyword,LP] = getnextkeyword(S.File,LP);
      end
      if isempty(Keyword)
         break
      elseif strcmp(Keyword,'INCLUDE')
         %
         % INCLUDE [FILE =] filename
         %
         [Keyword,LP] = getnextkeyword(S.File,LP);
         if strcmp(Keyword,'FILE')
            [Keyword,LP] = getnextkeyword(S.File,LP);
         end
         FileName = Keyword;
         %
         dprintf(debug,'INCLUDE %s\n',FileName);
         INCLUDE = readsiminp(S.FileDir,FileName(2:end-1));
         INCLUDE.CallingFile=S;
         INCLUDE.ParsedTree=INCLUDE.CallingFile.ParsedTree;
         INCLUDE.CallingLocation=LP;
         %
         S = INCLUDE;
         LP = [1 1];
         Keyword = '';
         %
      elseif strcmp(Keyword,'INSERT')
         %
         % INSERT [FILE =] filename [NHEADINGS = ...] [NUMBER = ...] [FORMAT = ...]
         %
         [Keyword,LP] = getnextkeyword(S.File,LP);
         if strcmp(Keyword,'FILE')
            [Keyword,LP] = getnextkeyword(S.File,LP);
         end
         FileName = Keyword;
         %
         dprintf(debug,'INSERT %s\n',FileName);
         %
         % NHEADINGS: OPTIONAL
         %
         [Keyword,LP1] = getnextkeyword(S.File,LP);
         Nheadings = 0;
         if strcmp(Keyword,'NHEADINGS')
            [Keyword,LP] = getnextkeyword(S.File,LP1);
            Nheadings = str2double(Keyword);
            [Keyword,LP1] = getnextkeyword(S.File,LP);
         end
         if Nheadings<0 || Nheadings~=round(Nheadings)
            error('INSERT Keyword with invalid NHEADINGS value')
         end
         %
         % NUMBER: MANDATORY
         %
         if strcmp(Keyword,'NUMBER')
            [Keyword,LP] = getnextkeyword(S.File,LP1);
            Number = str2double(Keyword);
            if Number<0 || Number~=round(Number)
               error('INSERT Keyword with invalid NUMBER value')
            end
         else
            error('INSERT Keyword without mandatory NUMBER keyword')
         end
         %
         % FORMAT: OPTIONAL
         %
         [Keyword,LP1] = getnextkeyword(S.File,LP);
         Format = 0;
         if strcmp(Keyword,'FORMAT')
            [Keyword,LP] = getnextkeyword(S.File,LP1);
            Format = str2double(Keyword);
         end
         if Format<0 || Format>6 || Format~=round(Format)
            error('INSERT Keyword with invalid FORMAT value')
         end
         %
         error('INSERT Keyword not yet implemented')
         %
      elseif strcmp(Keyword,'SET')
         %
         % SET ECHO/NOECHO/NOWRITESDS/MAXWARN number/MAXERROR number
         %
         [Keyword,LP] = getnextkeyword(S.File,LP);
         switch Keyword
            case {'ECHO','NOECHO','NOWRITESDS'}
            case {'MAXWARN','MAXERROR'}
               [Keyword,LP] = getnextkeyword(S.File,LP);
               Number = str2double(Keyword);
               if Number<0 || Number~=round(Number)
                  error('SET Keyword with invalid number')
               end
            otherwise
               error('SET Keyword with unknown flag or variable')
         end
         [Keyword,LP] = getnextkeyword(S.File,LP);
         %
         %warning('SET Keyword not skipped')
         %
      end
      %
      if ~isempty(Keyword)
          if length(Keyword) >= 5
              if strncmp(Keyword,'POWER',min(length(Keyword),5))
                  i = 1;
              end
          end
         found = 0;
         for i = 1:length(Field)
            if Field(i).Nchar > 0
               if strncmp(Keyword,Field(i).Name,Field(i).Nchar)
                  dprintf(debug,'%s recognized as %s',Keyword,Field(i).Name);
                  %
                  % TK: For power stations; split power from the integer following the keyword
                  nr_int = [];
                  nr_int = find (ismember(Keyword,'0123456789'),1,'first');
                  if ~isempty(nr_int)
                      if LP(2)==1
                         LP(1)=LP(1) - 1;
                         LP(2)=length(S.File{LP(1)})+1;
                      end
                      insertspaceafter = LP(2)-length(Keyword)-1-Field(i).Nchar;
                      S.File{LP(1)} = [S.File{LP(1)}(1:insertspaceafter) ...
                         ' ' S.File{LP(1)}(insertspaceafter+1:end)];
                      [Keyword,LP] = getnextkeyword(S.File,LP0);
                  end
                  %% TK
                  found = 1;
               end
            elseif Field(i).Nchar == 0
               [S,LP0] = subtreeparse(S,LP0,Field(i).Field,debug);
            elseif Field(i).Nchar < 0
               if strncmp(Keyword,Field(i).Name,-Field(i).Nchar)
                  if length(Keyword) == -Field(i).Nchar
                     dprintf(debug,'%s recognized as %s',Keyword,Field(i).Name);
                     found = 1;
                  else
                     if any(Keyword(-Field(i).Nchar+1)=='1234567890')
                        % split number from keyword
                        if LP(2)==1
                           LP(1)=LP(1)-1;
                           LP(2)=length(S.File{LP(1)})+1;
                        end
                        insertspaceafter = LP(2)-length(Keyword)-1-Field(i).Nchar;
                        S.File{LP(1)} = [S.File{LP(1)}(1:insertspaceafter) ...
                           ' ' S.File{LP(1)}(insertspaceafter+1:end)];
                        [Keyword,LP] = getnextkeyword(S.File,LP0);
                        dprintf(debug,'%s recognized as %s',Keyword,Field(i).Name);
                        found = 1;
                     else
                        % not a match: negative Nchar requires an exact match!
                     end
                  end
               end
            end
            if found
               seqnr = [];
               if isequal(Field(i).Type,'SEQ_KEY') || isequal(Field(i).Type,'SEKESE')
                  %
                  % sequence number
                  %
                  [Keyword,LP] = getnextkeyword(S.File,LP);

                  %
                  % Remove zero's at the beginning of the squence number
                  %
                  while strcmp(Keyword(1),'0');Keyword = Keyword(2:end);end
                  seqnr = sscanf(Keyword,'%i',1);
                  dprintf(debug,'[%i]\n',seqnr);
               else
                  dprintf(debug,'\n');
               end
               Tree = S.ParsedTree;
               S.ParsedTree=[];
               tmp = Tree.(Field(i).Name);
               [S,LP] = subtreeparse(S,LP,Field(i).Field,debug);

               %
               % TK Hier puntnaam vullen
               %

               if ~isempty(seqnr)
                  S.ParsedTree.SEQNR=seqnr;
               end
               if isempty(tmp)
                  %
                  % First occurrence of keyword
                  %
                  S.ParsedTree = setfield(Tree,Field(i).Name,S.ParsedTree);
               else
                  %
                  % Subsequent occurrences of keyword
                  %
                  tmp(end+1)=S.ParsedTree;
                  S.ParsedTree = setfield(Tree,Field(i).Name,tmp);
               end
               Keyword='';
               break
            end
         end
      end
   end
else
   %
   % End level: define all fields.
   %
   for i=1:length(Field)
      S.ParsedTree.(Field(i).Name) = Field(i).Default;
   end
   %
   ilast = 0;
   found = 1;
   while found
      LP0 = LP;
      [Keyword,LP] = getnextkeyword(S.File,LP);
      while (isempty(Keyword) && isfield(S,'CallingLocation')) || strcmp(Keyword,'INCLUDE')
          if isempty(Keyword)
              LP = S.CallingLocation;
              LP0 = LP;
              S.CallingFile.ParsedTree = S.ParsedTree;
              S = S.CallingFile;
          else % strcmp(Keyword,'INCLUDE')
              %
              % INCLUDE [FILE =] filename
              %
              [Keyword,LP] = getnextkeyword(S.File,LP);
              if strcmp(Keyword,'FILE')
                  [Keyword,LP] = getnextkeyword(S.File,LP);
              end
              FileName = Keyword;
              %
              dprintf(debug,'INCLUDE %s\n',FileName);
              INCLUDE = readsiminp(S.FileDir,FileName(2:end-1));
              INCLUDE.CallingFile=S;
              INCLUDE.ParsedTree=INCLUDE.CallingFile.ParsedTree;
              INCLUDE.CallingLocation=LP;
              %
              S = INCLUDE;
              LP = [1 1];
          end
          [Keyword,LP] = getnextkeyword(S.File,LP);
      end
      %
      found = 0;
      for i = 1:length(Field)
         if Field(i).Nchar > 0
            if strncmp(Keyword,Field(i).Name,Field(i).Nchar)
               dprintf(debug,'%s recognized as %s',Keyword,Field(i).Name);
               found = 1;
               break
            end
         elseif Field(i).Nchar < 0
            if strncmp(Keyword,Field(i).Name,-Field(i).Nchar)
               if length(Keyword) == -Field(i).Nchar
                  dprintf(debug,'%s recognized as %s',Keyword,Field(i).Name);
                  found = 1;
                  break
               else
                  if any(Keyword(-Field(i).Nchar+1)=='1234567890')
                     % split number from keyword
                     if LP(2)==1
                        LP(1)=LP(1)-1;
                        LP(2)=length(S.File{LP(1)})+1;
                     end
                     insertspaceafter = LP(2)-length(Keyword)-1-Field(i).Nchar;
                     S.File{LP(1)} = [S.File{LP(1)}(1:insertspaceafter) ...
                        ' ' S.File{LP(1)}(insertspaceafter+1:end)];
                     [Keyword,LP] = getnextkeyword(S.File,LP0);
                     dprintf(debug,'%s recognized as %s',Keyword,Field(i).Name);
                     found = 1;
                     break
                  else
                     % not a match: negative Nchar requires an exact match!
                  end
               end
            end
         end
      end
      %
      if ~found
         if ~isempty(Keyword) && any(Keyword(1)=='-1234567890.''')
            ifrom = ilast + 1;
            ilast = ilast + 1;
            LP = LP0;
            found = 1;
         else
            ifrom = 0;
            ilast = -1;
         end
      else
         %numfound = numfound + 1;
         dprintf(debug,'\n');
         ifrom = i;
         ilast = i;
      end
      for i = ifrom:ilast
         switch Field(i).Type
            case {1,2,3}
               nrepeat = Field(i).JRep;
               if nrepeat ~= 1
                  if nrepeat == 0
                     nrepeat = inf;
                     buffer_increment = 10000;
                     buffer_length = buffer_increment;
                  else
                     buffer_length = nrepeat;
                  end
                  if Field(i).Type == 3
                     buffer = repmat({[]},1,buffer_length);
                  else
                     buffer = zeros(1,buffer_length);
                  end
                  ibuf = 1;
               end
               ii = 1;
               while ii<=nrepeat
                  [Keyword,LP] = getnextkeyword(S.File,LP);
                  while isempty(Keyword) && isfield(S,'CallingLocation')
                     LP = S.CallingLocation;
                     LP0 = LP;
                     S.CallingFile.ParsedTree = S.ParsedTree;
                     S = S.CallingFile;
                     [Keyword,LP] = getnextkeyword(S.File,LP);
                  end
                  switch Field(i).Type
                     case 1 % integer
                         %
                         % Remove 0's in front of intger (sscanf cant
                         % handle this
                         %
                        while strcmp(Keyword(1),'0') && numel(Keyword) > 1 ;Keyword = Keyword(2:end);end
                        val = sscanf(Keyword,'%i',1);
                        if isempty(val)
                           if Field(i).JRep==0
                              LP = LP0;
                              break
                           else
                              error('Missing integer for %s',Field(i).Name)
                           end
                        elseif nrepeat == 1
                            switch Field(i).IRep
                                case 0
                                    S.ParsedTree.(Field(i).Name)(end+1) = val;
                                case 1
                                    S.ParsedTree.(Field(i).Name) = val;
                                otherwise
                                    if length(S.ParsedTree.(Field(i).Name))<Field(i).IRep
                                        S.ParsedTree.(Field(i).Name)(end+1) = val;
                                    else
                                        error('Too many occurrences of %s',Field(i).Name)
                                    end
                            end
                        else
                           buffer(ibuf) = val;
                           ibuf = ibuf + 1;
                           if ibuf > buffer_length && nrepeat >= ibuf
                              buffer_length = buffer_length + buffer_increment;
                              buffer(buffer_length) = 0;
                           end
                        end
                        dprintf(debug,'%s = %i\n',Field(i).Name,val);
                     case 2 % float
                        val = sscanf(Keyword,'%f',1);
                        if isempty(val)
                           if Field(i).JRep==0
                              LP = LP0;
                              break
                           else
                              error('Missing floating point value for %s',Field(i).Name)
                           end
                        elseif nrepeat == 1
                           S.ParsedTree.(Field(i).Name) = val;
                        else
                           buffer(ibuf) = val;
                           ibuf = ibuf + 1;
                           if ibuf > buffer_length && nrepeat >= ibuf
                              buffer_length = buffer_length + buffer_increment;
                              buffer(buffer_length) = 0;
                           end
                        end
                        dprintf(debug,'%s = %g\n',Field(i).Name,val);
                     case 3 % string
                        if Keyword(1)~=''''
                           if Field(i).JRep==0
                              LP = LP0;
                              break
                           else
                              error('String expected for %s',Field(i).Name)
                           end
                        elseif nrepeat == 1
                           S.ParsedTree.(Field(i).Name) = Keyword(2:end-1);
                        else
                           buffer{ibuf} = Keyword;
                           ibuf = ibuf + 1;
                           if ibuf > buffer_length && nrepeat >= ibuf
                              buffer_length = buffer_length + buffer_increment;
                              buffer{buffer_length} = [];
                           end
                        end
                        dprintf(debug,'%s = %s\n',Field(i).Name,Keyword);
                  end
                  LP0 = LP;
                  ii = ii + 1;
               end
               if nrepeat ~= 1
                  if Field(i).IRep == 0
                     S.ParsedTree.(Field(i).Name)(end+1,:) = buffer(1:ibuf-1);
                  else
                     S.ParsedTree.(Field(i).Name) = buffer(1:ibuf-1);
                  end
               end
            case 4 % key
               S.ParsedTree.(Field(i).Name) = true;
               dprintf(debug,'%s\n',Field(i).Name);
             otherwise
               S.ParsedTree.(Field(i).Name) = [];
%               error('Keyword ''%s'' type %i not yet implemented',Field(i).Name,Field(i).Type)
         end
      end
   end
end

%--------------------------------------------------------------------------
function [Keyword,LP] = getnextkeyword(File,LP)
if isempty(LP)
   L = 1;
   i = 1;
else
   L = LP(1);
   i = LP(2);
end

delimiters = [9:13 32];

if L > length(File)
   Keyword = '';
   return
end
string = File{L};
len = length(string);

while any(string(i) == delimiters)
    i = i + 1;
    if i > len
       L = L+1;
       string = File{L};
       len = length(string);
       i = 1;
       if L > length(File)
          Keyword = '';
          LP = [L i];
          return
       end
    end
end
start = i;

if string(start) == ''''
   i = i + 1;
   if i <= len
      while string(i) ~= ''''
         i = i + 1;
         if i > len
            break
         end
      end
      finish = i;
      i = i + 1;
   else
      error('Line ends with opening quote: "%s"',string)
   end
else
   while ~any(string(i) == delimiters)
      i = i + 1;
      if i > len
         break
      end
   end
   finish = i - 1;
end

if i > len
   L = L+1;
   i = 1;
end
Keyword = string(start:finish);

LP = [L i];

%------------------------------------------------------------------------------
function dprintf(fid,varargin)
if fid>0
    fprintf(fid,varargin{:});
end

%------------------------------------------------------------------------------

function Format = read_simona_format_table(filename)

fid=fopen(filename,'r');
if fid<0
   error('Cannot read format');
end

% UTIL/SIREFT/SIRT06.F
%

%     Explanation:
%     This subroutine reads the IREP-record (type definition
%     record) from the file containing standard REFERENCE table,
%     updates the description array KDESCR and the coupled arrays
%     (KEYWRD, KEYINF, KEYTYP and IDEFLT) and the type definition
%     array ITYPAR.
%     The IREP-record has the following form:
%
%     IREP=<irep> NAME=<kname> NCHAR=<nchar> JREP=<jrep>
%                 TYPE=<jtype> <keytype>[=<rvalue>]
%
%     where:
%     <irep>      is an integer number indicating the number of
%                 repetitions for the group: NAME ... TYPE=<type>
%                 (if irep=0, then the number of repetitions is
%                 not defined)
%     <kname>     is the keyword-name
%     <nchar>     is the number of significant positions in the
%                 keyword read from the Input file (if nchar<0,
%                 then the keyword must be exactly -nchar long)
%     <jrep>      is an integer number indicating the number of
%                 repetitions for the group: TYPE=<type>
%                 (if jrep=0, then the number of repetitions is
%                 not defined)
%     <jtype>     type of variable associated with this keyword:
%                 jtype=1: integer data type
%                 jtype=2: real    data type
%                 jtype=3: string  data type
%     <keytype>   is the type indication of the keyword to be stored
%                 in the array KEYTYP; the legal values for keytype:
%                 MAND     : keyword is mandatory             (itype:=1)
%                 OPT      : keyword is optional              (itype:=2)
%                 DEF      : keyword is free and has a default
%                            value                            (itype:=3)
%                 SEQ_DAT  : keyword is mandatory, sequential and is
%                            followed by data directly        (itype:=4)
%                 REP      : keyword is mandatory with repeated sequential
%                            order, but the sequence number need not
%                            be specified by the user         (itype:=5)
%                 SEQ_KEY  : keyword is mandatory with sequential order
%                            followed by assigned keys        (itype:=6)
%                 SEQ_SEQ  : keyword is mandatory with sequential order
%                            followed by a sequential key directly
%                                                             (itype:=7)
%                 SEKESE   : keyword is mandatory with sequential order
%                            followed by assigned keys, followed by a
%                            second sequential key            (itype:=8)
%                 XOR      : keyword of exclusive/or group which has a
%                            group value                      (itype:=12)
%                 AND      : relation keyword, only meaningfull if a
%                            number of another key has been specified
%                                                             (itype:=13)
%
%     <rvalue>    default value (meaningful only in combination
%                 with <keytype>=DEF, XOR or AND).

%
% Read Table name ...
%
Line = getnext(fid);
[Table,Name]= strtok(Line);
Format.Name = strtok(Name);
%
[Line,Format.Field] = processkeys(fid);
%
% Close file ...
%
fclose(fid);

function [Line,Format] = processkeys(fid)

separators = sprintf(' \\/=(),:;\t');

%
% Read Number of keys ...
%
Line = getnext(fid);
NKeys = sscanf(Line,'NKEY = %i');
if isempty(NKeys)
   %
   % No subkeys
   %
   i = 0;
   while ~feof(fid)
      i = i + 1;
      %
      % Process current line
      %
      % IREP = 1  NAME = WAQUA        NCHAR = 5  JREP = 1   TYPE = 4   XOR1
      % IREP = 1  NAME = EXPERIMENT   NCHAR =10  JREP = 1   TYPE = 3   OPT
      % IREP = 1  NAME = OVERWRITE    NCHAR = 9  JREP = 1   TYPE = 4   DEF = 0
      %
      [Format(i).IRep , idum, cdum, inext] = sscanf(Line,' IREP = %i');
      Line = Line(inext:end);
      [Format(i).Name , idum, cdum, inext] = sscanf(Line,' NAME = %s',1);
      Line = Line(inext:end);
      [Format(i).Nchar, idum, cdum, inext] = sscanf(Line,' NCHAR = %i');
      Line = Line(inext:end);
      [Format(i).JRep, idum, cdum, inext] = sscanf(Line,' JREP = %i');
      Line = Line(inext:end);
      [Format(i).Type, idum, cdum, inext] = sscanf(Line,' TYPE = %i');
      Line = Line(inext:end);
      [parse, idum, cdum, inext] = sscanf(Line,' %c',3);
      Line = Line(inext:end);
      Format(i).Mandatory = 0;
      Format(i).Default = [];
      Format(i).XOr = [];
      Format(i).And = [];
      if isequal(parse,'MAN') % MAND
         Format(i).Mandatory = 1;
      else
         if isequal(parse,'DEF')
            Format(i).Default = sscanf(Line,' = %f');
         elseif isequal(parse,'OPT')
         elseif isequal(parse,'XOR') % XOR1, XOR 1
            valstr = strtok(Line,separators);
            Format(i).XOr = str2num(valstr);
         elseif isequal(parse,'AND')
            valstr = strtok(Line,separators);
            Format(i).And = str2num(valstr);
         else
            fprintf('Unknown identification "%s%s"\n',parse,Line)
         end
      end
      %
      % Read next line (elementary field or new key) ...
      %
      Line = getnext(fid);
      %
      % Check whether this is a new field or new key
      %
      if isempty(sscanf(Line,' IREP = %i'))
         %
         % New key
         %
         break
      end
   end
else
   %
   % Process keys ...
   %
   Line = getnext(fid);
   for i = 1:NKeys
      %
      % Add current key to structure ...
      %
      %1         IDENTIFICATION      NCHAR = 5                     MAND
      %
      [nr, Line] = strtok(Line);
      [nm, Line] = strtok(Line);
      [nc, idum, cdum, inext] = sscanf(Line,' NCHAR = %i');
      Line = Line(inext:end);
      nt = strtok(Line);
      %
      % Process key fields and read new key ...
      %
      [Line,subfields] = processkeys(fid);
      %
      Format(i).Name = nm;
      Format(i).Nchar = nc;
      Format(i).Type = nt;
      Format(i).Field = subfields;
   end
end


function Line = getnext(fid);
while 1
   Line = strtrim(fgetl(fid));
   if feof(fid)
      if ~isempty(Line)
         if Line(1) == '#'
            Line = '';
         end
      end
      return
   elseif isempty(Line)
   elseif Line(1) ~= '#'
      return
   end
end


function siminp = reduce_siminp(subfields,siminp,Field)

hulp    = [];
no_lev  = length(subfields);

%
% For all levels
%

for ilev = 1: no_lev
   clear siminp_h
   siminp_h = siminp;
   foundrec_start = 1;
   foundrec_stop  = length(siminp_h);

   for ifield = 1: length(Field)
%      found = strfind( lower(subfields{ilev}(1:min(length(Field(ifield).Name),length(subfields{ilev})))),lower(Field(ifield).Name));
      found = strncmpi( subfields{ilev},Field(ifield).Name,min(length(Field(ifield).Name),length(subfields{ilev})));
      if found
          nrfield = ifield;
          break
      end
   end

   %
   % Exception for ketyword General
   %

   if ilev == 1 && strcmpi(subfields{ilev},'general')
       ipos            = strcmpi('general',siminp_h);
   else
       ipos            = strncmpi(subfields{ilev},siminp_h,min(length(Field(ifield).Name),length(subfields{ilev})));
   end

   foundrec_start  = find(ipos>0,1);

   if isempty(foundrec_start)
       siminp = [];
       return
   end

   found = true;
   irec  = foundrec_start + 1;

   while found && irec <= length(siminp_h)
       found = false;
       found = parsethisrec(Field(nrfield).Field,siminp_h{irec},found);
       irec = irec + 1;
   end

   foundrec_stop = irec - 1;

   hulp{end+1} = siminp_h{foundrec_start};

   clear siminp;

   for irec = foundrec_start+1:foundrec_stop
      siminp{irec-foundrec_start} = siminp_h{irec};
   end


   if ilev < no_lev
      Field = Field(nrfield).Field;
   end

end

istart = length(hulp);
for irec = 1:length(siminp)
   hulp{irec+istart} = siminp{irec};
end

clear siminp

siminp = hulp;

function found = parsethisrec(Field,rec,found)


if found
    return
elseif ismember(rec(1),'-.0123456789') || strcmp (rec(1),'''')
    found = true;
    return
else
    for ifield = 1: length(Field)
        if abs(Field(ifield).Nchar) > 0
            if strncmpi (Field(ifield).Name,rec,abs(Field(ifield).Nchar))
                found = true;
                break
            end
        elseif ismember(rec(1),'-.0123456789') || strcmp (rec(1),'''')
            found = true;
            break
        end

        if ~found
            if isfield(Field,'Field')
                found = parsethisrec(Field(ifield).Field,rec,found);
            end
        end
    end
end


