delete('bin\*');
mkdir bin;

%%  add wlsettings and oesettings
% wlsettings;
% addpath('d:\OpenEarthTools\matlab\'); oetsettings

% remove annoying startup.m in wafo dir from path
rmpath('D:\McTools\matlab\applications\wave\wafo\docs\');
rmpath('d:\Matlab\');
rmpath('Y:\app\MATLAB2009b\toolbox\stats');

%% Add all routines
addpath(genpath('engines'));
fid=fopen('complist','wt');
fprintf(fid,'%s\n','-a');
fprintf(fid,'%s\n','ucit_netcdf.m');

% Add engines
flist=dir('engines');
for i=1:length(flist)
        fname=flist(i).name;
        switch fname
                case{'.','..','.svn'}
                otherwise
                    fprintf(fid,'%s\n',fname);
        end
end

% Add gui-routines
addpath(genpath('gui'));
p = genpath('gui');
ids = strfind(p,';');
proceed = 1;
i = 1;

while proceed == 1
    fname = p(ids(i)+1:ids(i+1)-1);
    fp = strfind(fname,'\');
    fname_full = fname(fp(1)+1:end);
    fname_short = fname(fp(end)+1:end);
    switch fname_short
        case{'.','..','.svn','ucit_about.txt','prop-base', 'props','text-base','tmp','all-wcprops', 'entries', '*.svn-base'}
        otherwise         
            flist = dir(['gui\' fname_full '\*.m']);
            if ~isempty(flist)
                for j = 1 : length(flist)
                    fname_id = flist(j).name;
                    fprintf(fid,'%s\n',fname_id);
                    disp(['Added ' fname_id]);
                end
            end
    end
    i = i + 1;
    if i == length(ids)-1
        proceed = 0;
    end
    
end

% add additional functions (based on debugging)
fprintf(fid,'%s\n','inspect.m');
fprintf(fid,'%s\n','erosed.m');
  
fclose(fid);

try
    fid=fopen('\gui\base\Deltares_icon.rc','wt');
    fprintf(fid,'%s\n','ConApp ICON Deltares_logo_32x32.ico');
    fclose(fid);
    system(['"' matlabroot '\sys\lcc\bin\lrc" /i "' pwd 'Deltares_icon.rc"']);
end

% compile it
mcc -m -v -d bin ucit_netcdf.m -B complist -a ..\..\io\netcdf\netcdfAll-4.2.jar -a ucit_icons.mat -a EPSG.mat

% delete('Deltares_icon.rc');
% delete('Deltares_icon.res');

dos(['copy ' which('ucit_about.txt') ' bin']);
% dos(['copy ' which('ucit_icons.mat') ' bin']);
% dos(['copy ' which('EPSG.mat') ' bin']);
revnumb = '1';

if isappdata(0,'revisionnumber')
    revnumb = num2str(getappdata(0,'revisionnumber'));
else
    try
        [tf str] = system(['svn info ' fileparts(which('ucit_netcdf.m'))]);
        str = strread(str,'%s','delimiter',char(10));
        id = strncmp(str,'Revision:',8);
        if any(id)
            revnumb = strcat(str{id}(min(strfind(str{id},':'))+1:end));
        end
    catch me
        % don't mind
    end
end
strfrep(fullfile('bin','ucit_about.txt'),{'$revision','$year','$month'},{num2str(str2double(revnumb)),datestr(now,'mmmm'),datestr(now,'yyyy')});
delete('complist');