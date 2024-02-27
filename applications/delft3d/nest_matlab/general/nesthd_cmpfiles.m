function nesthd_cmpfiles(files,varargin)

opt.Filename = '';
opt.Refdir   = '.';
if ~isempty(varargin)
    opt = setproperty(opt,varargin);
end

if ~isempty(opt.Filename)
    fid = fopen(opt.Filename,'a');
end

% cmpfiles : compare file in cell array files with original fles (extension .org)

for itest = 1:length(files)
    if ~isempty(files{itest})
        [~,name,ext] = fileparts(files{itest});
        fileName{1} = [opt.Refdir filesep [name ext]];
        if strcmpi(ext(2:length(ext)),'tim')
            fileList = dir([opt.Refdir filesep '*.tim']);
            for ifile = 1: length(fileList)
                fileName{ifile} = [opt.Refdir filesep fileList(ifile).name];
            end
        end
        
        for ifile = 1: length(fileName)
            
            if exist([fileName{ifile} '.org'],'file')
                line_n = nesthd_reatxt( fileName{ifile}        );
                line_o = nesthd_reatxt([fileName{ifile} '.org']);
                
                identical = true;
                if length(line_n) == length(line_o)
                    for iline = 1: length(line_n)
                        identical = strcmp(line_n{iline},line_o{iline});
                        if ~identical;break;end;
                    end
                else
                    identical = false;
                end
                
                if identical
                    string = ['Identical     : ' fileName{ifile}];
                else
                    string = ['NOT Identical : ' fileName{ifile}];
                end
            else
                string = ['New testcase  : ' fileName{ifile}];
                copyfile(fileName{ifile},[fileName{ifile} '.org']);
            end
            
            if ~isempty(opt.Filename)
                fprintf(fid,'%s \n',string);
            else
                disp(string);
            end
            
        end
    end
end

if ~isempty(opt.Filename)
    fclose (fid);
end

