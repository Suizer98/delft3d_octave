function varargout = delft3d_io_aru_arv(varargin)
%DELFT3D_IO_ARU_ARV   read and write Delft3D .aru and .arv files
%
% %example:
% S.data{1}.comment = '# Example aru/arv file';
% S.data{2}.n = 12;
% S.data{2}.m = 20;
% S.data{2}.definition = 8;
% S.data{2}.percentage = 0.4;
% S.data{3}.n1 = 10;
% S.data{3}.m1 = 20;
% S.data{3}.n2 = 40;
% S.data{3}.m2 = 23;
% S.data{3}.definition = 13;
% S.data{3}.percentage = 0.4;
% S.data{4}.comment = '*another comment';
%
% %save example file 
% delft3d_io_aru_arv('write','example.aru',S);
%
% %read example file 
% T = delft3d_io_aru_arv('read','example.aru');
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd,
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva,
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src,
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd,

% delft3d_io_aru_arv_version = '1.0beta';
if nargin ==1
    error(['At least 2 input arguments required: d3d_io_...(''read''/''write'',filename)'])
end

if nargin ==2
    cmd   = varargin{1};
    fname1 = varargin{2};
end

if nargin == 3
    cmd    = varargin{1};
    fname1 = varargin{2};
    T      = varargin{3};
end


%% Read
if strcmp(cmd,'read')
    tmp               = dir(fname1);
    if length(tmp)==0
        error(['aru/arv file ''',fname1,''' does not exist.'])
    end
    
    S=Local_read(fname1);
    varargout{1}  = S;
    %% Write
elseif strcmp(cmd,'write')
    tmp               = dir(fname1);
    if length(tmp)>0
        error(['aru/arv file ''',fname1,''' already exists.'])
    end
    S=Local_write(fname1,T);
    varargout{1}  = S.iostat;
else
    help('delft3d_io_aru_arv')
end
end


function S = Local_write(varargin)
filename = varargin{1};
T        = varargin{2};
fid = fopen(filename,'w');
S.iostat = -1;

for k = 1:length(T.data);
    counts = [ ...
        length(setdiff(lower(fieldnames(T.data{k})),{'comment'})), ...
        length(setdiff(lower(fieldnames(T.data{k})),{'nm','definition','percentage'})), ...
        length(setdiff(lower(fieldnames(T.data{k})),{'n','m','definition','percentage'})), ...
        length(setdiff(lower(fieldnames(T.data{k})),{'n1','m1','n2','m2','definition','percentage'})), ...
        length(setdiff(lower(fieldnames(T.data{k})),{'x','y','z','definition','percentage'})), ...
        ];
    if length(setdiff(lower(fieldnames(T.data{k})),{'nm','x','y','z','definition','percentage'})) == 0; 
        counts(5) = 0;
    end
    [y, type_no] = min(counts);
    switch (type_no)
        case 1
            fprintf(fid,'%s\n',T.data{k}.comment);
        case 2
            fprintf(fid,'%5i %5i  %f\n',T.data{k}.nm, T.data{k}.definition, T.data{k}.percentage);
        case 3
            fprintf(fid,'%5i %5i %5i  %f\n',T.data{k}.n, T.data{k}.m, T.data{k}.definition, T.data{k}.percentage);
        case 4
            fprintf(fid,'%5i %5i %5i %5i %5i  %f\n',T.data{k}.n1, T.data{k}.m1, T.data{k}.n2, T.data{k}.m2, T.data{k}.definition, T.data{k}.percentage);
        case 5
            fprintf(fid,'%18.8f %18.8f %18.8f %5i  %f\n',T.data{k}.x, T.data{k}.y, T.data{k}.z, T.data{k}.definition, T.data{k}.percentage);
    end
    if y ~= 0
        fclose(fid)
        error('incorrect structure passed to delft_io_aru_arv');
    end
end
S.iostat = 1;
fclose(fid);
end

function S = Local_read(varargin)

S.filename = varargin{1};

fid          = fopen(S.filename,'r');
if fid==-1
    S.iostat   = fid;
else
    S.iostat   = -1;
    line_no = 0;
    S.count.comments = 0;
    S.count.nm       = 0;
    S.count.n_and_m  = 0;
    S.count.block    = 0;    
    while 1
        %% get line
        newline          = fgetl(fid);
        if ~ischar(newline);break, end % -1 when eof
        line_no = line_no + 1;
        if (length(newline) > 0)
            if (sum(strfind('#*',newline(1)))>0);
                type    = 'comment';
                content = newline;
                S.count.comments = S.count.comments+1;
            else
                content = str2num(newline);
                if length(content) == 4;
                    type    = 'n m definition percentage';
                    S.count.n_and_m = S.count.n_and_m + 1;
                elseif length(content) == 5;
                    type    = 'x y z definition percentage';
                    S.count.block = S.count.block + 1;    
                elseif length(content) == 6;
                    type    = 'n1 m1 n2 m2 definition percentage';
                    S.count.block = S.count.block + 1;    
                elseif length(content) == 3;
                    type    = 'nm definition percentage';
                    S.count.nm = S.count.nm + 1;
                else
                    type    = 'unknown';
                    content = newline;
                end
            end
        else
            type    = 'comment';
            content = newline;
        end
        count = 0;
        desc = regexp(type,' ','split');
        if length(desc) == 1;
            S.data{line_no}.(desc{1}) = content;
        else
            for str = regexp(type,' ','split')
                count = count+1;
                S.data{line_no}.(str{1}) = content(count);
            end
        end
    end
    fclose(fid);
    S.iostat   = 1;
end

if (S.iostat == -1)
    error(['Error reading aru/arv file ',S.filename]);
end
end
