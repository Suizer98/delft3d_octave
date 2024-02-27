function [range] = det_excel_range (col_start,row_start,col_stop,row_stop,varargin)
%det_excel_range convert integer index to excel row/column string
%
% [range] = det_excel_range (col_start,row_start,col_stop,row_stop)
%
% Specified as colrow (Exceltype) or rowcol (more mathematical).
% default is colrow
%
% Example:
% det_excel_range(1,2,3,4) yields 'A2:C4';
%
% See also: xls_functions, xls, xlsread, xlswrite

%% Switch rows and colums

nVarargins = length(varargin);

if nVarargins == 1
   if strcmpi (varargin{1},'rowcol');

      col_tmp   = col_start;
      col_start = row_start;
      row_start = col_tmp;

      col_tmp  = col_stop;
      col_stop = row_stop;
      row_stop = col_tmp;
   end
end

%% convert start and stop column (nr) to excel character

if col_start <= 26
   c1 = char(64 + col_start);
else
   ihulp1 = floor(col_start/26);
   ihulp2 = mod  (col_start,26);
   c1     = [char(64 + ihulp1) char(64 + ihulp2)];
end

if col_stop <= 26
   c2 = char(64 + col_stop);
else
   ihulp1 = floor(col_stop/26);
   ihulp2 = mod  (col_stop,26);
   c2     = [char(64 + ihulp1) char(64 + ihulp2)];
end

%% construct the excel range

range     = [c1 num2str(row_start) ':' c2 num2str(row_stop)];
