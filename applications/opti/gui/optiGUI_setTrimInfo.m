function optiGUI_setTrimInfo(fig);

if nargin==0
    [but,fig]=gcbo;
end
this=get(fig,'userdata');

dg=str2num(get(findobj(fig,'tag','curDg'),'string'));
inputType=this.input(dg).inputType;

try
    switch inputType
        case 1
            trimFileName=this.input(dg).dataFileRoot;
        case 2
            dirs=dir([this.input(dg).dataFileRoot filesep this.input(dg).dataDirPrefix '*']);
            trimFileName=[this.input(dg).dataFileRoot filesep dirs(1).name filesep 'trim-' this.input(dg).dataFilePrefix '.dat'];
        case 3
            mergeFile=dir([this.input(dg).dataFileRoot filesep this.input(dg).dataDirPrefix filesep '*.mm']);
            if length(mergeFile) > 1
                error('Please verify that only 1 mm-file is present...');
                return
            end
            merge=textread([this.input(dg).dataFileRoot filesep this.input(dg).dataDirPrefix filesep mergeFile.name],'%s','delimiter','\n','headerlines',9);
            [dum, temp]             = strtok(char(merge(1)),'=');
            [tCondMap, tWeightFac]  = strtok(temp(2:end),':');
            condMap                 = cellstr(tCondMap(~isspace(tCondMap)));
            trimFileName=[this.input(dg).dataFileRoot filesep condMap{1} filesep 'trim-' this.input(dg).dataFilePrefix '.dat'];
    end
    N1=vs_use(trimFileName,'quiet');
    N1.FileName; %to check if the trim exist, otherwise it continues at 'catch'
    noFrac=N1.ElmDef(find(strcmp('SBUU',{N1.ElmDef.Name}))).Size(3);
    set(findobj(fig,'tag','fractions'),'string',[num2str(noFrac) ' sediment fractions found in trim-file']);
    set(findobj(fig,'tag','timesteps'),'string',[num2str(N1.GrpDat(1).SizeDim) ' timesteps found in trim-file']);
    set(findobj(fig,'tag','trimfile'),'string',N1.FileName);
    if noFrac>1
        set(findobj(fig,'tag','dataSedimentFraction'),'string',{vs_get(N1,'map-const','NAMSED','quiet'),'Sum of all fractions'});
    else
        set(findobj(fig,'tag','dataSedimentFraction'),'string',{vs_get(N1,'map-const','NAMSED','quiet')});
    end
catch
    set(findobj(fig,'tag','fractions'),'string','.. sediment fractions found in trim-file');
    set(findobj(fig,'tag','timesteps'),'string','.. timesteps found in trim-file');
    set(findobj(fig,'tag','trimfile'),'string','no trim-file loaded');    
    set(findobj(fig,'tag','dataSedimentFractions'),'string','First load trim-file');
end