function drive=filedrive(fname)
% Find drive part of file
while 1
    fp=fileparts(fname);
    if strcmpi(fp,fname)
        break
    end
    fname=fp;
end
drive=fp;
