function cosmos_nestingXBeachFlow(hm,m)

tmpdir=hm.tempDir;

curdir=pwd;

mm=hm.models(m).flowNestModelNr;

dr=hm.models(mm).dir;

outputdir=[dr 'archive' filesep 'output' filesep hm.cycStr filesep ''];
[success,message,messageid]=copyfile([outputdir 'trih-*'],tmpdir,'f');

cd(tmpdir);

try
        
    nstadm=[hm.models(m).datafolder 'nesting' filesep hm.models(m).name '.nst'];

    [status,message,messageid]=copyfile([hm.models(m).datafolder 'nesting' filesep hm.models(m).name '.bnd'],tmpdir,'f');
    [status,message,messageid]=copyfile([hm.models(m).datafolder 'nesting' filesep hm.models(m).name '.nst'],tmpdir,'f');

    fid=fopen('nesthd2.inp','wt');
%    fprintf(fid,'%s\n',[hm.models(m).dir 'nesting' filesep hm.models(m).name '.bnd']);
    fprintf(fid,'%s\n',[hm.models(m).name '.bnd']);
    fprintf(fid,'%s\n',[hm.models(m).name '.nst']);
    fprintf(fid,'%s\n',hm.models(mm).runid);
    fprintf(fid,'%s\n','temp.bct');
    fprintf(fid,'%s\n','dummy.bcc');
    fprintf(fid,'%s\n','nest.dia');
    fprintf(fid,'%s\n','0.0');
    fclose(fid);

    system([hm.exeDir 'nesthd2.exe < nesthd2.inp']);
    fid=fopen('smoothbct.inp','wt');
    fprintf(fid,'%s\n','temp.bct');
    fprintf(fid,'%s\n',[hm.models(m).name '.bct']);
    fprintf(fid,'%s\n','3');

    fclose(fid);

    system([hm.exeDir 'smoothbct.exe < smoothbct.inp']);

    delete('nesthd2.inp');
    delete('nest.dia');
    delete('smoothbct.inp');

    delete('temp.bct');
    delete('dummy.bcc');
    delete('trih*');

    delete([tmpdir hm.models(m).name '.bnd']);
    delete([tmpdir hm.models(m).name '.nst']);

catch
    disp('An error occured during nesting');
end

cd(curdir);

ConvertBct2XBeach([tmpdir hm.models(m).name '.bct'],[tmpdir 'tide.txt'],hm.models(m).tFlowStart); %FIXME
delete([tmpdir hm.models(m).name '.bct']);
