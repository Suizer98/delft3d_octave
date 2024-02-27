function varargout = csv2struct(fname,varargin)
%CSV2STRUCT    Read table from xls file into matlab struct fields 
%
%    DATA = csv2struct(fname)
%
% reads columns from fname into struct fields. The 1st csv row
% is used to make the field names, any "" are removed, illegals characters
% become _. The 2nd line can optionally be used for units (default off) 
%
%    [DATA,units] = csv2struct(fname,'units',1,<keyword,value>)
%
% For other keywords + defaults call without arguments: csv2struct()
%
% e.g. D = csv2struct('somefile.csv','delimiter',';','commentstyle','%')
%
% where the csv has the following structure:
% * optionally every (!) line starting with special char is interpreted as a comment line.
% * optionally headerlines can be skipped
% * fieldnames (column names) at the first line.
% * optionally units at the second line.
% * Column values are smartly mapped to numeric, columns where char conversion
%   yields any NaN are kept as char (incl. lines with pure text, excl. empty values)
%
% Double quotes are kept, unless explicitly specified not to, for 
% (1) column names and (2) column values  with keyword 'quotes' as 
% a two-element vector. For example in:
% +---------------->
% | column1,column2
% | "Korea, Democratic People's Republic of","120,540"
% | "Korea, Republic of","100,210"          
% +---------------->
% "korea, republic of" or "100,000" would otherwise yield 
% two columns each due to their internal comma's, e.g.
% Example: D = csv2struct('koreas.csv','delimiter',',','quotes',[0 1])
%
% See also: XLS2STRUCT, NC2STRUCT, LOAD & SAVE('-struct',...)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
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

% $Id: csv2struct.m 12895 2016-09-21 20:23:19Z gerben.deboer.x $
% $Date: 2016-09-22 04:23:19 +0800 (Thu, 22 Sep 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12895 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/csv2struct.m $
% $Keywords$

%% options

   OPT.delimiter    = ',';
   OPT.error        = 0;
   OPT.quotes       = [0 0];
   OPT.units        = false;
   OPT.commentstyle = '#'; % switched to lower case 2013-05
   OPT.headerlines  = 0;
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin{:});
   
%% get meta-info

   META.name = fname;
   tmp           = dir(fname);

   if length(tmp)==0
      
      if OPT.error
         error(['Error finding file: ',fname])
      else
         iostat = -1;
         DAT    = [];
         UNITS  = [];
      end
      
   elseif length(tmp)>0

      META.date     = tmp.date;
      META.bytes    = tmp.bytes;
      META.datenum  = tmp.datenum; % not for old matlab versions

      fid      = fopen(fname);
      for i=1:OPT.headerlines
      rec      = fgetl(fid);
      end
      rec      = fgetl_no_comment_line(fid,OPT.commentstyle);
      col      = textscan(rec,'%s','Delimiter',OPT.delimiter);
      if OPT.quotes(1)
      colnames = cellfun(@(x) x([2:end-1]),col{1},'UniformOutput',0);
      else
      colnames = col{1};
      end

      if length(OPT.quotes) > 1
       if OPT.quotes(2)
       fmt      = repmat('%q',[1 length(colnames)]);
       else
       fmt      = repmat('%s',[1 length(colnames)]);
       end
      else
       fmt      = repmat('%s',[1 length(colnames)]);
      end
   
      if OPT.units
      rec      = fgetl_no_comment_line(fid,OPT.commentstyle);
      units    = textscan(rec,fmt,'Delimiter',OPT.delimiter,'commentstyle',OPT.commentstyle);
      UNITS    = cellfun(@(x) x{1}([2:end-1]),units,'UniformOutput',0);
      else
      UNITS    = [];
      end
   
   %% load
   
      RAW = textscan(fid,fmt,'Delimiter',OPT.delimiter,'commentstyle',OPT.commentstyle);
      fclose(fid);
      for icol=1:length(RAW)
          
         % turn csv column name intor struct name, ignore "
          fldname = mkvar(colnames{icol});
         if colnames{icol}(1)  =='"';fldname = fldname(3:end);end % x_*
         if colnames{icol}(end)=='"';fldname = fldname(1:end-1);end % *_
         
         if OPT.quotes(2)
            % check whether each cellstr begins and ends with a "
            % i.e. whether it is a string, if yes, remove leading and trailing "
            % skip empty columns
            % TO DO Else make number: only when quotes are not present
            % [icol all(cell2mat(cellfun(@(x) length(x)>2,RAW{icol},'UniformOutput',0)))]
            if all(cell2mat(cellfun(@(x) length(x)>2,RAW{icol},'UniformOutput',0)))
              if all(all(char(cellfun(@(x) x([1 end]),RAW{icol},'UniformOutput',0))=='"'))
                fldname = mkvar(colnames{icol});
                DAT.(fldname) = cellfun(@(x) x([2:end-1]),RAW{icol},'UniformOutput',0);
                % THIS SHOULD REMAIN A CHAR
              else
                DAT.(fldname) = cellfun(@(x) x,RAW{icol},'UniformOutput',0);
                DAT.(fldname) = col2mat(RAW{icol});
              end
            else
               DAT.(fldname) = cellfun(@(x) x,RAW{icol},'UniformOutput',0);
               DAT.(fldname) = col2mat(RAW{icol});
            end
         else
            DAT.(fldname) = col2mat(RAW{icol});
         end
         
      end

   end
   

%% out

   if nargout<2
      varargout = {DAT};
   elseif nargout==2
      varargout = {DAT,UNITS};
   elseif nargout==3
      varargout = {DAT,UNITS,META};
   else
      error('syntax [DATA,<units>] = csv2struct(...)')
   end
   
function mat = col2mat(col)
        
   mat = str2double(col);
   if any(isnan(mat) & cellfun(@(x) ~isempty(x),col) & ~strcmpi(col,'nan'))
      mat = col; % revert entire col
   end        
   
%% EOF   