%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_check_status_runs_folder.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_check_status_runs_folder.m $
%
%Check status runs folder

function D3D_check_status_runs_folder(fdir_runs,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'structure',1);

parse(parin,varargin{:});

is_structured=parin.Results.structure;

%% CALC

dire=dir(fdir_runs);

ndir=numel(dire);
kadd=0;
for kdir=3:ndir
    
    fdir_loc=fullfile(dire(kdir).folder,dire(kdir).name);
    
    if is_structured
        tok=regexp(dire(kdir).name,'r\d{3}','once'); %an alternative is to check if it is a simulations run with <D3D_simpath>, but it will be more expensive
    else
        simdef=D3D_simpath(fdir_loc);
        tok='42';
        if simdef.err>0
            tok='';
        end
    end
    if isempty(tok); continue; end
    
    kadd=kadd+1;
    
    
    fdir{kadd,1}=fdir_loc;
    
    simdef.D3D.dire_sim=fdir_loc;
    [sta(kadd,1),tim(kadd,1),tgen(kadd,1),version{kadd,1},tim_ver(kadd,1),source{kadd,1}]=D3D_status(simdef);
    
    messageOut(NaN,sprintf('processing %4.2f %%',kdir/ndir*100));
end

nadd=numel(sta);
vsim=1:1:nadd;

%% WRITE

fdir_write=fullfile(fdir_runs,'00_status');

mkdir_check(fdir_write,NaN,1,0)  %break and no display

fpath_res=fullfile(fdir_write,'results.txt');
fid=fopen(fpath_res,'w');
fprintf(fid,'Columns: \n');
fprintf(fid,'1: Directory \n');
fprintf(fid,'2: Status. 1=not started, 2=running, 3=done, 4=exit but did not reach final time \n');
fprintf(fid,'3: Computational time [s] \n');
fprintf(fid,'4: Date of the run \n');
fprintf(fid,'5: Software version \n');
fprintf(fid,'6: Date of the version \n');
fprintf(fid,'7: Source \n');
fprintf(fid,' \n');
for kadd=1:nadd
    if isnat(tgen(kadd))
        tgen_str='';
    else
        tgen_str=datestr(tgen(kadd));
    end
    if isnat(tim_ver(kadd))
        tim_ver_str='';
    else
        tim_ver_str=datestr(tim_ver(kadd));
    end
    fprintf(fid,'%s, %d, %15.2f, %s, %s, %s, %s \n',fdir{kadd},sta(kadd),seconds(tim(kadd)),tgen_str,version{kadd},tim_ver_str,source{kadd});
end
fclose(fid);

%% PLOT

%%
figure
hold on
han.sfig(1,1)=subplot(1,1,1);
han.s=scatter(vsim,sta,'filled');
han.sfig(1,1).YTick=1:1:4;  
han.sfig(1,1).YTickLabel={'not started','running','done','interrupted'};
print(gcf,fullfile(fdir_write,'sta.png'),'-dpng','-r300');

%%
figure
hold on
han.sfig(1,1)=subplot(1,1,1);
title('Simulations that started')
han.s=scatter(tim_ver,sta,'filled');
han.sfig(1,1).YTick=1:1:4;  
han.sfig(1,1).YTickLabel={'not started','running','done','interrupted'};
print(gcf,fullfile(fdir_write,'sta_tim.png'),'-dpng','-r300');

%%
bol_done=sta==3;
figure
hold on
scatter(tim_ver(bol_done),tim(bol_done),'filled');
ylabel('Computational time')
xlabel('Software date')
title('Simulations that run correctly')
print(gcf,fullfile(fdir_write,'tim.png'),'-dpng','-r300');

end %function


