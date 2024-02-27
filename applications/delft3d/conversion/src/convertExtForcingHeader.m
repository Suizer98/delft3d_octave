% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


% Read the header of the ext-file (in directory 'data')  
fidexthea   = fopen(['extheader.ext'],'r');
fidext      = fopen(fileext,'wt');
while ~feof(fidexthea);
    tline   = fgetl(fidexthea);
    fprintf(fidext,[tline,'\n']);
end
fprintf(fidext,[,'\n']);