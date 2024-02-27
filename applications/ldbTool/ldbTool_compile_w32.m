delete('bin\*');
mkdir bin;
%  add wlsettings and oesettings
if isempty(which('drawgrid'))
    wlsettings;
end
if isempty(which('grid_orth_getDataOnLine'))
    run('F:\Repositories\OeTools\oetsettings.m');
end

% remove annoying startup.m in wafo dir from path
rmpath('F:\Repositories\McTools\mc_applications\mc_wave\wafo\docs\');

% add all detran routines
addpath('LT_engines');
fid=fopen('complist','wt');
fprintf(fid,'%s\n','-a');
fprintf(fid,'%s\n','ldbTool.m');

% Add engines
flist=dir('LT_engines');
for i=1:length(flist)
        fname=flist(i).name;
        switch fname
                case{'.','..','.svn'}
                otherwise
                    fprintf(fid,'%s\n',fname);
        end
end

% Add gui-routines
addpath('LT_gui');
flist=dir('LT_gui');
for i=1:length(flist)
        fname=flist(i).name;
        switch fname
                case{'.','..','.svn','LT_about.txt'}
                otherwise
                    fprintf(fid,'%s\n',fname);
        end
end

fclose(fid);

try
    fid=fopen('ldbtoolicon.rc','wt');
    fprintf(fid,'%s\n','ConApp ICON ldbTool.ico');
    fclose(fid);
    system(['"' matlabroot '\sys\lcc\bin\lrc" /i "' pwd '\ldbtoolicon.rc"']);
end
 
mcc -m -d bin ldbTool.m -B complist -M ldbtoolicon.res 

delete('ldbtoolicon.rc');
delete('ldbtoolicon.res');

dos(['copy ' which('LT_about.txt') ' bin']);
revnumb = '????';
if isappdata(0,'revisionnumber')
    revnumb = num2str(getappdata(0,'revisionnumber'));
else
    try
        [tf str] = system(['svn info ' fileparts(which('ldbTool.m'))]);
        str = strread(str,'%s','delimiter',char(10));
        id = strncmp(str,'Revision:',8);
        if any(id)
            revnumb = strcat(str{id}(min(strfind(str{id},':'))+1:end));
        end
    catch me
        % don't mind
    end
end
strfrep(fullfile('bin','LT_about.txt'),{'\$revision','\$year','\$month'},{revnumb,datestr(now,'mmmm'),datestr(now,'yyyy')});
delete('complist');