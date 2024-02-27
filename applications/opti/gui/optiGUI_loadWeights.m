function optiGUI_loadWeights


[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));
inputType=get(findobj(fig,'tag','inputType'),'value');

switch inputType
    case 3
        msgbox('Weights will be loaded automatically for mormerge input type!');
        oldPat=pwd;
        cd([this.input(dg).dataFileRoot filesep this.input(dg).dataDirPrefix]);
        mergeFile = dir('*.mm');
        if length(mergeFile) > 1
            error('Please verify that only 1 mm-file is present...');
            return
        end
        merge=textread(mergeFile.name,'%s','delimiter','\n','headerlines',9);
        weightFac = 0;
        for ii= 1 : length(merge)
            [dum, temp]             = strtok(char(merge(ii)),'=');
            [tCondMap, tWeightFac]  = strtok(temp(2:end),':');
            condMap{ii}             = cellstr(tCondMap(~isspace(tCondMap)));
            weightFac(ii)           = str2num(tWeightFac(2:end));
        end
        this.weights = weightFac / sum (weightFac);
        cd(oldPat);
    otherwise
        [namW,patW]=uigetfile('*.tek','Select tekal-file with weights');
        if namW==0
           return
        end
        try
            tek=tekal('read',[patW filesep namW]);
            this.weights=tek.Field.Data(:,2)';
            this.weights=this.weights/sum(this.weights);
        catch
            error('No valid file format found. Tekal file should have one block with a N x 2 data array.');
        end
end

this.input(dg).target=[]; %target wissen,want die is gebaseerd op weights.
set(findobj(fig,'tag','weightBox'),'String',[repmat('condition ',length(this.weights),1) num2str([1:length(this.weights)]','%4.0f') repmat(': ',length(this.weights),1) num2str(this.weights','%3.3f')]);
set(fig,'userdata',this);
