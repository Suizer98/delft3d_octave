function [file,number_rows]=file_read(pathfile)

fileID_in=fopen(pathfile,'r'); %file identifier of the input file
number_rows=1;
while ~feof(fileID_in)
file{number_rows,1}=fgets(fileID_in); 
number_rows=number_rows+1;
end
number_rows=number_rows-1;