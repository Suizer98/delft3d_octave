function str=justletters(str)

for ii=1:length(str)
    if (double(str(ii))>=97 && double(str(ii))<=122) || ...
            (double(str(ii))>=65 && double(str(ii))<=90)
    else
        str(ii)=' ';
    end
end
str(str==' ')='';
