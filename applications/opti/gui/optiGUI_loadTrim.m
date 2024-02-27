function optiGUI_loadTrim

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

[trimNam,trimPat, filterindex] = uigetfile( {'*.dat;*.def','trim-files (*.dat,*.def)'},'Select (one of the) trim file(s)');
if trimNam==0
    return
end

N1=vs_use([trimPat,trimNam],'quiet');
% [p1,p2]=fileparts(N1.FileName);
[p1,p2]=fileparts(N1.DatExt);
[p3,p4]=fileparts(p1);

inputType=this.input(dg).inputType;
switch inputType
    case 1
        this.input(dg).dataFileRoot=[N1.FileName '.dat'];
        this.input(dg).dataDirPrefix=[];
        this.input(dg).dataFilePrefix=[];
    case 2        
        this.input(dg).dataFileRoot=p3;
        this.input(dg).dataDirPrefix=char(inputdlg('Specify prefix of subdirs with data files','Opti - Datagroup Input Processor',1,{strtok(p4,'0')}));
        this.input(dg).dataFilePrefix=p2(6:end);
    case 3
        this.input(dg).dataFileRoot=p3;
        this.input(dg).dataDirPrefix='merge';
        this.input(dg).dataFilePrefix=p2(6:end);
end
noFrac=N1.ElmDef(find(strcmp('SBUU',{N1.ElmDef.Name}))).Size(3);
set(findobj(fig,'tag','fractions'),'string',[num2str(noFrac) ' sediment fractions found in trim-file']);
set(findobj(fig,'tag','timesteps'),'string',[num2str(N1.GrpDat(1).SizeDim) ' timesteps found in trim-file']);
set(findobj(fig,'tag','trimfile'),'string',N1.FileName);
if noFrac>1
    set(findobj(fig,'tag','dataSedimentFraction'),'string',{vs_get(N1,'map-const','NAMSED','quiet'),'Sum of all fractions'});
else
    set(findobj(fig,'tag','dataSedimentFraction'),'string',{vs_get(N1,'map-const','NAMSED','quiet')});
end
optiGUI_setTimeFormat;
set(fig,'userdata',this);
