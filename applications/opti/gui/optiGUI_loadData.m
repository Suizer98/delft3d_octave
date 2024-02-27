function optiGUI_loadData

[but,fig]=gcbo;

this=get(fig,'userdata');
optiGUI_gui2struct;
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

if isempty(deblank(this.input(dg).dataFileRoot))|isempty(this.input(dg).trimTimeStep)
    errordlg('Cannot load data, first specify all input data');
    return
end
    

dataType=get(findobj(fig,'tag','dataType'),'value');
inputType=get(findobj(fig,'tag','inputType'),'value');

optiGUI_resetData; % clear 'old' data


switch dataType
    case 1
        this=optiReadTransportData(this,dg,inputType,this.input(dg).dataFileRoot,this.weights);
    case 2
        this=optiReadSedEroData(this,dg,inputType,this.input(dg).dataFileRoot,this.weights);
end

if dg>1
   if size(this.input(dg).data,2)~=size(this.input(dg-1).data,2)
      errordlg('Number of conditions must be equal!');
      return
   end
end

set(fig,'userdata',this);
optiGUI_struct2gui(fig);