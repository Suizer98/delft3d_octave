function nesthd_check

%NESTHD_CHECK test nesthd
%
%See also: nest_matlab
%% Settings
[path,~,~]      = fileparts(mfilename('fullpath'));
testdir         = [path filesep 'check'];

check_exe       = false;
check_comprompt = true;
check_nesthd1   = false;
check_nesthd2   = true;

%% set paths
if ~isdeployed && any(which('setproperty')) addpath(genpath('..\..\..\..\matlab')); end

%% Create list of directories
tmp             = dir(testdir);
index           = [tmp.isdir];
dirs            = tmp(index);
for i_dir = 3: length(dirs) tests{i_dir - 2} = [testdir filesep dirs(i_dir).name]; end

%% Create ini files
for i_test = 1: length(tests)
    nesthd1(i_test) = false;
    nesthd2(i_test) = false;
    if check_nesthd1
        if exist([tests{i_test} filesep 'nesthd1.template'],'file')
            nesthd1(i_test) = true;
            copyfile([tests{i_test} filesep 'nesthd1.template'],[tests{i_test} filesep 'nesthd1.ini']);
            substitute ('**rundir**',tests{i_test},[tests{i_test} filesep 'nesthd1.ini']);
        end
    end

    if check_nesthd2
        if exist([tests{i_test} filesep 'nesthd2.template'],'file')
            nesthd2(i_test) = true;
            copyfile([tests{i_test} filesep 'nesthd2.template'],[tests{i_test} filesep 'nesthd2.ini']);
            substitute ('**rundir**',tests{i_test},[tests{i_test} filesep 'nesthd2.ini']);
        end
    end
end

%% Windows batch file (first create)
t_start = now;
if check_exe
    fid = fopen ('run.bat','w+');
    for i_test = 1: length(tests)
        str_hd1 = ['nesthd ' tests{i_test} filesep 'nesthd1.ini'];
        str_hd2 = ['nesthd ' tests{i_test} filesep 'nesthd2.ini'];
        if nesthd1(i_test) fprintf(fid,'%s \n',str_hd1); end
        if nesthd2(i_test) fprintf(fid,'%s \n',str_hd2); end
    end
    fclose(fid);

    % than run and compare with previous results
    system('run.bat');

    for i_test = 1: length(tests)
        if nesthd2(i_test)
            nesthd_compare([tests{i_test} filesep 'nesthd2.ini']);
        end
    end
end

%% Check if running from matlab command prompt works
if check_comprompt
    for i_test = 1: length (tests)
        if nesthd1(i_test)
            nesthd        ([tests{i_test} filesep 'nesthd1.ini']);
            nesthd_compare([tests{i_test} filesep 'nesthd1.ini']);
            delete        ([tests{i_test} filesep 'nesthd1.ini']);
        end
        if nesthd2(i_test)
            disp(tests{i_test});
            nesthd        ([tests{i_test} filesep 'nesthd2.ini'],'check',true);
            nesthd_compare([tests{i_test} filesep 'nesthd2.ini']);
            delete        ([tests{i_test} filesep 'nesthd2.ini']);
        end
    end
end

%% Duration
t_dur = 1440.*60.*(now - t_start);
fid   = fopen(['compare_' datestr(now,'yyyymmdd') '.txt'],'a');
fprintf(fid,'\nTotal Duration [sec]: %6i \n',round(t_dur));
fclose (fid);
