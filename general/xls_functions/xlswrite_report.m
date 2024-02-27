function xlswrite_report(filename,cell_arr,sheetname,varargin)
%xlswrite_report

%
% Function                      : Generates a "report" xls file whereas matlab's own xlswrite produces
%                                 a rather messy excel file. The top row an left most column are assumed to
%                                 be describtive and displayed in a different color than the "body".
% usage (identical to xlswrite) : xlswrite_report(filename,cell_arr,sheetname, ... , ...)
%                                 filename  = name of the resulting xls file
%                                 cell_arr  = cell array of values/names to be written to the excell file
%                                 sheetname = name of the sheet in the xls file
%                                 optional property/value pairs are:
%                                 'format'   xls format like for instance '0.00'
%                                 'colwidth' vector of nrow column widths (pts)
%
%                                 an example of how to use this functions is given in xls_xmp.m
%
% start with setting the optional property/value pairs

OPT.format      = '0.000';
OPT.Comments    = '';
OPT.colwidth(1) = 20;
for i_col = 2: size(cell_arr,2)
    OPT.colwidth(i_col) = 20;
end
OPT        = setproperty(OPT,varargin);
no_com     = length(OPT.Comments);

%%
filename =  relativeToabsolutePath(filename);

% write default file

for i_com = 1 :no_com
    tmp_arr{i_com,2} = OPT.Comments{i_com};
end
for i_row = 1: size(cell_arr,1)
    for i_col = 1: size(cell_arr,2)
        tmp_arr{i_row + no_com,i_col} = cell_arr{i_row,i_col};
    end
end
cell_arr = tmp_arr;
no_col = size(cell_arr,2);

xlswrite(filename,cell_arr,sheetname);

%% and now modify, start with deliting empty sheets

delete_empty_excelsheets(filename);

% set column widths
set_colwidth_excel      (filename,sheetname,1,OPT.colwidth(1));
for i_col = 2: size(cell_arr,2)
    set_colwidth_excel      (filename,sheetname,i_col,OPT.colwidth(i_col));
end

% merge the comment lines
for i_com = 1: no_com
    range = det_excel_range(i_com,2,i_com,no_col,'rowcol');
    xlsallign(filename,sheetname,range,'mergecells',1);
end

if no_com > 0
    range = det_excel_range(1,1,1 + no_com,1,'rowcol');
    xlsallign(filename,sheetname,range,'mergecells',1);
end

% Comment lines Italic
if no_com > 0
    range = det_excel_range(1,2,no_com,2,'rowcol');
    xlsfont  (filename,sheetname,range,'size',12,'fontstyle','italic' );
end
% topline allign right and bold font
range = det_excel_range(1 + no_com,1,size(cell_arr,1),1,'rowcol');
xlsallign(filename,sheetname,range,'horizontal',2);
xlsfont  (filename,sheetname,range,'size',12,'fontstyle','bold' );
range = det_excel_range(1 + no_com,2,1 + no_com,size(cell_arr,2),'rowcol');
xlsallign(filename,sheetname,range,'horizontal',4);
xlsfont  (filename,sheetname,range,'size',12,'fontstyle','bold' );

% set format interior
if ~iscell(OPT.format)
    range            = det_excel_range(2 + no_com,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
    set_format_excel (filename,sheetname,range,OPT.format);
else
    no_row = size(cell_arr,2) - 1;
    for i_row = 1: no_row
        range            = det_excel_range(2 + no_com,1 + i_row,size(cell_arr,1),1 + i_row,'rowcol');
        set_format_excel (filename,sheetname,range,OPT.format{i_row});
    end
end
    

% set borders
range            = det_excel_range(1         ,1,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1         ,2,1 + no_com, size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1 + no_com,2,1 + no_com, size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1 + no_com,2,1 + no_com, size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1 + no_com,1,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1,1,1,size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'InsideVertical',1,4,1);

range            = det_excel_range(2,1,size(cell_arr,1),1,'rowcol');
xlsborder        (filename,sheetname,range,'InsideHorizontal',1,3,1);

range            = det_excel_range(2 + no_com,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'InsideHorizontal',2,2,1);
xlsborder        (filename,sheetname,range,'InsideVertical'  ,2,2,1);

% Set Colors

range            = det_excel_range(1+no_com,2,1+no_com,size(cell_arr,2),'rowcol');
set_color_excel  (filename,sheetname,range,[255 255 0],'rgb');

range            = det_excel_range(2+no_com,1,size(cell_arr,1),1,'rowcol');
set_color_excel  (filename,sheetname,range,[0 255 255],'rgb');

range            = det_excel_range(2+no_com,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
set_color_excel  (filename,sheetname,range,[192 192 192],'rgb');

if no_com > 0
    range            = det_excel_range(1       ,2,no_com          ,size(cell_arr,2),'rowcol');
    set_color_excel  (filename,sheetname,range,[255 0 0],'rgb');
end

