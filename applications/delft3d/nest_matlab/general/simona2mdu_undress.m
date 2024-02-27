function simona2mdu_undress(filinp,filout,varargin)

% siminp2mdu_thd : Undresses a file, i.e. removes all comments

fid_inp = fopen(filinp,'r') ;
fid_out = fopen(filout,'w+');

opt.comments = [];
opt = setproperty(opt,varargin);

while ~feof(fid_inp)
    line = strtrim(fgetl(fid_inp));
    write = true;
    if ~isempty(line)
        for icom = 1: length(opt.comments)
            if strcmp(line(1),opt.comments{icom})
                write = false;
            end
        end
    else
        write = false;
    end

    if write
        for icom = 1: length(opt.comments)
            index = strfind(line,opt.comments{icom});
            if ~isempty(index)
                line = line(1:index(1) - 1);
            end
        end
        fprintf(fid_out,'%s \n',line);
    end
end

fclose(fid_inp);
fclose(fid_out);
