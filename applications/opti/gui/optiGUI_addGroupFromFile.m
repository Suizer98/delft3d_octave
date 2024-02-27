function optiGUI_addGroupFromFile

[but,fig]=gcbo;
thisOld=get(fig,'userdata');

optiGUI_gui2struct;

%ask if current opti results can be deleted
if isfield(thisOld.iteration,'iteration')
   cont=questdlg('Current opti-results will be deleted, do you want to continue?','OptiGUI','Yes','No','Yes');
   if strcmp(cont,'No');
      return;
   end
end

%open mat-file with opti-structure
[namO,patO]=uigetfile('*.mat','Open opti structure');
if namO==0
    return
end
load([patO filesep namO]);

if ~exist('this')
    errordlg('no opti structure found in mat-file!')
    return
end

%check if the number of conditions is correct
if size(this.input(1).data,2)~=size(thisOld.input(1).data,2)
   errordlg('Number of conditions must be equal!');
   return
end

nodgOld=length(thisOld.input);
nodg=length(this.input);

%check for multiple datagroups in new file
if length(nodg)>1
   seldg=str2num(char(inputdlg([num2str(nodg) ' datagroups found in file, specify which datagroups you want to use'],'OptiGUI',1,{'1,2'})));
else
   seldg=1;
end

%add data to 'old' structure
for ii=1:length(seldg)
   thisOld.input(nodgOld+ii)=this.input(seldg(ii));
   thisOld.dataGroupWeights(nodgOld+ii)=0;
end

optiGUI_resetResults;

set(findobj(fig,'tag','maxDg'),'string',num2str(length(thisOld.input)));
set(fig,'userdata',thisOld);
optiGUI_struct2gui(fig);
