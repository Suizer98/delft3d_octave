function varargout = xls2struct(fname,varargin)
%XLS2STRUCT    Read table from xls file into matlab struct fields 
%
% DATA = xls2struct(fname)
% DATA = xls2struct(fname,work_sheet_name)
% DATA = xls2struct(fname,work_sheet_name,<keyword,value>)
% DATA = xls2struct(fname,<keyword,value>)
%
% [DATA,units         ] = xls2struct(fname,work_sheet_name,<keyword,value>)
% [DATA,units,metainfo] = xls2struct(fname,work_sheet_name,<keyword,value>)
%
% where the xls has the following structure:
% * optionally every (!) line starting with special char is interpreted as a comment line.
% * optionally headerlines can be skipped
% * fieldnames (column names) at the first line.
% * optionally units at the second line.
% * all text fields with text 'NaN' are interpreted as numeric NaNs
%
% Example:
%
% +---------------+---------------+---------------+-----------------+-+-----------------+
% |# textline 1   |               |               |                 | |                 |
% |# textline 2   |               |               |                 | |                 |
% |# textline 3   |               |               |                 | |                 |
% | columnname_01 | columnname_02 | columnname_03 | columnname_04   | |                 |  
% | units         | units         | units         | units           | |                 |
% | number/string | number/string | number/string | number/string   |:| number/string   |
% | number/string | number/string | number/string | number/string   |:| number/string   |
% | number/string | number/string | number/string | number/string   |:| number/string   |
% | ...           | ...           | ...           | ...             | | ...             |
% | number/string | number/string | number/string | number/string   |:| number/string   |
% +---------------+---------------+---------------+-----------------+-+-----------------+
%
% and <keyword,value> pairs are:
%
% * error        throw error when instead of returning empty matrices.
% * units        whether units at are present at 2nd line (default false)
% * fillstr      str that represents dummy string values that should be replaced with number fillnum
%                (Default {}, suggestion: {'NA'})
% * fillnum      number that replaces fillstr (Default NaN)
% * commentstyle list of characters that define start of a header row, default {'%*#'} OR 
% * headerlines  number of header rows to skip
% * last2d       inserts all data to the right of the last column name 
%                into the last variable such that the last variable is a (ragged) 2D array
%                (default false as otherwise crap cratch notes might end up in your data)
%
% Notes:
% 
% + The last columns extending the fieldnames are added to the 
%   last fieldname as array. Make sure there's no extra columnwith spaces !
%   In case of error just delete the (seemingly) empty rows and columns.
% + Elements where excel displays #DIV/0! or where you entered the 
%   string 'nan' are considered as numerical nans.
% + Do not use 'units' as a fieldname, since the units (2nd line)
%   are already loaded to a field called 'units', with a subield
%   for every main field.
%
% See also: CSV2STRUCT, NC2STRUCT, LOAD & SAVE('-struct',...)
%           STRUCT2XLS, XLSDATE2DATENUM, XLSREAD, XLSWRITE (2006b+, otherwise mathsworks downloadcentral) 

% Tested for matlab releases 2009b, 2008a, 2007ab, 2006B and 6.5

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2011 Delft University of Technology
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

% $Id: xls2struct.m 12483 2016-01-07 10:49:31Z gerben.deboer.x $
% $Date: 2016-01-07 18:49:31 +0800 (Thu, 07 Jan 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12483 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/xls2struct.m $
% $Keywords$

% 2008, Apr 18: made fldname always valid with mkvbar
% 2009, Apr 03: check whether first cell of line is number, do not call iscommentline on numbers

% TO DO:
% * Add keywords/properties above columns: as in:
% +---------------+---------------+---------------+---------------+
% |# textline 1   |               |               |               |
% |# textline 2   |               |               |               |
% |# textline 3   |               |               |               |

% | KEYWORD01     | VALUE01       |               |               |
% | KEYWORD02     | VALUE02       |               |               |
% | KEYWORD03     | VALUE03       |               |               |
% | ...           | ...           |               |               |
% | KEYWORD0n     | VALUE0n       |               |               |

% | columnname_01 | columnname_02 | columnname_03 | columnname_04 |  
% | units         | units         | units         | units         |
% | number/string | number/string | number/string | number/string |
% | number/string | number/string | number/string | number/string |
% | number/string | number/string | number/string | number/string |
% | ...           | ...           | ...           | ...           |
% | number/string | number/string | number/string | number/string |
% +---------------+---------------+---------------+---------------+

   if strcmp(version('-release'),'13')
      disp('xlsread: Only properly tested for in R14 and higher.')
   end

%% Input

   OPT.error        = true;   
   OPT.units        = false;
   OPT.sheet        = [];
   OPT.debug        = 0;
   OPT.fillstr      = {};
   OPT.fillnum      = NaN;
   OPT.last2d       = 0;
   OPT.commentstyle = '%*#';
   OPT.headerlines  = 0;
   
   if nargin==0
      varargout = {OPT};
      return
   end

   if ~odd(nargin)
      OPT.sheet = varargin{1};
      i     = 2;
   else
      i     = 1;
   end

   OPT           = setproperty(OPT,varargin{i:end});
   
   if nargin==0
      output = OPT;
      return
   end
   
%% Read

   META.filename = fname;
   iostat        = 1;
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
   
      META.filedate     = tmp.date;
      META.filebytes    = tmp.bytes;
   
      sptfilenameshort = filename(fname);
         
   %% Load raw data
   
      if ~isempty(OPT.sheet)
         if strfind(version('-release'),'13')==1
             
             [tstdat,tsttxt] = xlsread(fname,OPT.sheet); % ,'basic'
             
             dimtxt = size(tsttxt);
             dimdat = size(tstdat);
             maxdim = max(dimtxt,dimdat);
             
             tstraw = tsttxt; % is already cell
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   if (i1 > dimtxt(1) | ...
                       i2 > dimtxt(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                    else
                      if isempty(tsttxt{i1,i2})
                         if (i1 <= dimdat(1)) & (i2 <= dimdat(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                         end
                      elseif strcmpi(tsttxt{i1,i2},'nan')
                         tstraw{i1,i2} = nan; 
                      end
                   end % if
                end % i2
             end % i1
         else
             [tstdat,tsttxt,tstraw] = xlsread(fname,OPT.sheet); % ,'basic'
             maxdim = size(tstraw);
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   if strcmpi(tstraw{i1,i2},'nan')
                      tstraw{i1,i2} = nan; 
                   elseif strcmpi(tstraw{i1,i2},'ActiveX VT_ERROR: '); 
                   % In matlab 7.3.0.267 (R2006b) xlsread gives for 
                   % #DIV/0! the following: 'ActiveX VT_ERROR: '
                      tstraw{i1,i2} = nan; 
                   end % if
                end % i2
             end % i1
         end % release
      else
         if strfind(version('-release'),'13')==1
             
             [tstdat,tsttxt] = xlsread(fname); % ,'basic'
             dimtxt = size(tsttxt);
             dimdat = size(tstdat);
             maxdim = max(dimtxt,dimdat);
             
             tstraw = tsttxt; % is already cell
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   if (i1 > dimtxt(1) | ...
                       i2 > dimtxt(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                    else
                      if isempty(tsttxt{i1,i2})
                         if (i1 <= dimdat(1)) & (i2 <= dimdat(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                         end
                      elseif strcmpi(tsttxt{i1,i2},'nan')
                         tstraw{i1,i2} = nan; 
                      end
                   end % if
                end % i2
             end % i1
         else
             [tstdat,tsttxt,tstraw] = xlsread(fname); % 'basic'
             maxdim = size(tstraw);
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   % tstraw{i1,i2}
                   if ischar(tstraw{i1,i2})
                      if strcmpi(strtrim(tstraw{i1,i2}),'nan') % remove leading and trailing blanks for reading *.csv files.
                         tstraw{i1,i2} = nan; 
                      elseif strcmpi(tstraw{i1,i2},'ActiveX VT_ERROR: '); 
                      % In matlab 7.3.0.267 (R2006b) xlsread gives for 
                      % #DIV/0! the following: 'ActiveX VT_ERROR: '
                         tstraw{i1,i2} = nan; 
                      end % if
                   end
                end % i2
                %pausedisp
             end % i1
         end % release
      end
      
   %% Take care of fact that excel skips certain rows/columns
   %  depending on data type (numerical/string)
      
	commentlines       = zeros(1,size(tstraw,1));
      if iscell(tsttxt) & ischar(OPT.commentstyle)
         for j=1:size(tstraw,1)
            if ~isnan(tstraw{j,1})
            if ~isnumeric(tstraw{j,1})
            commentlines(j) = iscommentline(char(tstraw{j,1}(1)),OPT.commentstyle);
            else
            commentlines(j) = 0;
            end
            end
         end
      end
     commentlines(1:OPT.headerlines) = 1;
      
     %row_skipped_in_numeric_data = size(tstraw,1) - size(tstdat,1);
     %col_skipped_in_numeric_data = size(tstraw,2) - size(tstdat,2);
      
   %% Test entire columns for presence of non-numbers.
   %  One single non-number is sufficient to treat entire column as text.

      numeric_columns = repmat(true ,[1 size(tstraw,2)]);
      txt_columns     = repmat(false,[1 size(tstraw,2)]);
      
      if OPT.units
         rowoffset = 1;
      else
         rowoffset = 0;
      end
      
      % Per column ...
      for i2=1:size(tstraw,2)
      
         % ... check all rows
         index = find(~commentlines);
         for irow=index(2+rowoffset):size(tstraw,1)

            % apply string codes for numeric missing values
            tstraw(irow, i2)    = cellstrrepnum(tstraw(irow, i2),OPT.fillstr,OPT.fillnum);
            
            if ~isnumeric(tstraw{irow, i2});

               numeric_columns(i2) = false;
               txt_columns    (i2) = true;
               break
               
            end
         end
            
      end
      
   %% Take care of nans
      
      % for i=1:size(tsttxt,1)
      % for j=1:size(tsttxt,2)
      %    if strcmp(      tsttxt{i,j} ,'#N/A') | ...
      %       strcmp(lower(tsttxt{i,j}),'nan' )
      %       tstdat(i - row_skipped_in_numeric_data,...
      %              j - col_skipped_in_numeric_data) = nan;
      %       tsttxt{i,j} = '';
      %    end
      % end
      % end
      
   %% Take care of commentlines and header
   
      not_a_comment_line = find(~commentlines);
      
      fldnames           = tsttxt(not_a_comment_line(1),:);
      if OPT.units
      units              = tsttxt(not_a_comment_line(2),:);
      end
      
   %% Remove empty field names at end of row
      
      nfld         = length(fldnames);
      fldnamesmask = ones(1,nfld);
      for ifld   = 1:nfld
         if  strcmp(fldnames{ifld},'') | ...
            isempty(fldnames{ifld})
            fldnamesmask(ifld) = 0;
         end
      end
      fldnames = {fldnames{fldnamesmask==1}};
      %fldnames          = fldnames(find(~strcmp(fldnames,'')));
      nfld               = length(fldnames);
      
   %% Read data

      for ifld   = 1:nfld
      
         fldname         = mkvar(strtrim(char(fldnames{ifld})));
         
         if isempty(fldname)
            break
         end

         ifld2 = ifld;
         if OPT.last2d & ifld==nfld;
         ifld2 = size(tstraw,2);  % sometimes there's crap scratch notes in your last columns, these shoudl not end up in your last column
         end
         
         if OPT.debug
             disp([num2str(ifld,'%0.3d'),'/',num2str(nfld,'%0.3d'),...
                   ' [text type: '    ,num2str(txt_columns(ifld)),...
                   ' or numeric type ',num2str(numeric_columns(ifld)),']',...
                   ': fldname: "',fldname,'"',]);
         end
         
         if OPT.units
            unit            = char(units   {ifld});
            UNITS.(fldname) = unit;
         end
         
         if OPT.units
            offset = 1;
         else
            offset = 0;
         end
            
         if numeric_columns(ifld)
            DAT.(fldname)    = tstraw(not_a_comment_line(2+offset:end),ifld:ifld2);
            DAT.(fldname)    = cell2mat(DAT.(fldname));
         else
            if iscell(tsttxt)
              if OPT.last2d & ifld==nfld;
                matrix = tstraw(not_a_comment_line(2+offset:end),ifld:ifld2);
                DAT.(fldname) = cell(size(matrix,1),1);
                for irow=1:size(matrix,1)
                  row = {matrix{irow,:}};
                  try
                    if ~iscellstr(row)
                      row = cell2mat(row); % not for chars
                    end
                    DAT.(fldname){irow} = row(~isnan(row));
                  catch
                    mask = repmat(false,size(row));
                    for jj=1:length(row)
                    mask(jj) = all(~isnan(row{jj}));
                    end
                    DAT.(fldname){irow} = {row{mask}};
                  end
                end
              else
                DAT.(fldname) = tstraw(not_a_comment_line(2+offset:end),ifld:ifld2);
              end
            else
               error('tsttxt not char')
            end
         end
   
      end

         
      end % if length(tmp)==0
      
      META.iomethod = 'xls2struct';
      META.read_at  = datestr(now);
      META.iostatus = iostat;
      ii = 0;
      for i=1:length(commentlines)
        if commentlines(i)
          ii = ii+1;
          META.commentlines(ii) = tstraw(i,1);
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
      error('syntax [DATA,<units>] = xls2struct(...)')
   end
   
%% EOF