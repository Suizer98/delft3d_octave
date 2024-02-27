%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: latex_calendar.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/latex/latex_calendar.m $
%
%Description

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% INPUT

year_in=2022;
fpath='C:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\latex\calendar.tex';
fpath_csv='C:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\latex\calendar.csv';

%% CALC

fid=fopen(fpath,'w');
fid_csv=fopen(fpath_csv,'w');
dtim_loc=datetime(year_in,1,1);
year_loc=year(dtim_loc);
wk_day=NaN(1,7);

fprintf(fid,'\\documentclass[10pt]{article}\r\n');
% fprintf(fid,'\\usepackage{tabularx}\r\n');
fprintf(fid,'\\usepackage{booktabs}\r\n');
fprintf(fid,'\\usepackage{longtable}\r\n');
fprintf(fid,'\\usepackage{multirow}\r\n');
fprintf(fid,'\\usepackage{array}\r\n');
fprintf(fid,'\\usepackage{float}\r\n');
fprintf(fid,'\\usepackage{graphicx}\r\n');

% fprintf(fid,'\\usepackage[margin=2cm,landscape,a3paper]{geometry}

fprintf(fid,'\\begin{document}\r\n');

fprintf(fid,'\\renewcommand\\arraystretch{2}\r\n');
fprintf(fid,'\\begin{longtable}{|p{1.25cm}|p{1.25cm}|p{1.25cm}|p{1.25cm}|p{1.25cm}|p{1.25cm}|p{1.25cm}|}\r\n');
fprintf(fid,'\\midrule \r\n');
% fprintf(fid,'\\begin{center}\r\n');
% fprintf(fid,'\\begin{tabular}{r|r|r|r|r|r|r}\r\n');        
		   
% fprintf(fid,'\\rotatebox[origin=c]{90}{Lunes} & & & & & & \\\\ \r\n');
fprintf(fid,'\\parbox[t]{1.25cm}{\\multirow{3}{*}{\\rotatebox[origin=c]{90}{Lunes}}} & & & & & & \\\\ \r\n');
fprintf(fid,'\\midrule \r\n');
while year_loc==year_in
    idx_wk=weekday(dtim_loc); %1 is Sunday
    if idx_wk==1
        idx_wk=7;
    else
        idx_wk=idx_wk-1;
    end
    wk_day(idx_wk)=day(dtim_loc);

    if idx_wk==7 || (month(dtim_loc)==12 && day(dtim_loc)==31)
        bol_nan=isnan(wk_day);
        wk_day_str=cellfun(@(X)num2str(X),num2cell(wk_day),'UniformOutput',false);
        wk_day_str=cellfun(@(X)strrep(X,'NaN',''),wk_day_str,'UniformOutput',false);
        fprintf(fid,'%s & %s & %s & %s & %s & %s & %s \\\\ \r\n',wk_day_str{:});
        fprintf(fid_csv,'%s , %s , %s , %s , %s , %s , %s \r\n',wk_day_str{:});
        fprintf(fid,'\\midrule \r\n');
        wk_day=NaN(1,7);
    end
    dtim_loc=dtim_loc+days(1);
    year_loc=year(dtim_loc);
end %year


% fprintf(fid,'\\end{tabular}\r\n');
% fprintf(fid,'\\end{center}\r\n');
fprintf(fid,'\\end{longtable}\r\n');
fprintf(fid,'\\end{document}\r\n');

fclose(fid);
fclose(fid_csv);

%% COMPILE
% messageOut(NaN,'compiling')
% latex_compile(fpath);
% messageOut(NaN,'done')





