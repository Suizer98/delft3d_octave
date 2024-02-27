function ddb_Delft3DWAVE_hydrodynamics(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'sethydrodynamics'}
            setHydrodynamics;
        case{'checkwaterlevel'}
            checkWaterLevel;
        case{'checkbedlevel'}
            checkBedLevel;
        case{'checkcurrent'}
            checkCurrent;
        case{'checkwind'}
            checkWind;
    end
end

%%
function setHydrodynamics

handles=getHandles;
if strcmp(handles.model.delft3dwave.domain.coupling,'uncoupled')

   handles.model.delft3dwave.domain.mdffile = '';
   handles.model.delft3dwave.domain.coupledwithflow=0;
   handles.model.delft3dwave.domain.writecom = 0;

elseif strcmp(handles.model.delft3dwave.domain.coupling,'ddbonline')

   if handles.model.delft3dflow.domain(1).comInterval==0 || handles.model.delft3dflow.domain(1).comStartTime==handles.model.delft3dflow.domain(1).comStopTime
      ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!');
   end

   handles.model.delft3dwave.domain.referencedate=handles.model.delft3dflow.domain(1).itDate;
   handles.model.delft3dwave.domain.mapwriteinterval=handles.model.delft3dflow.domain(1).mapInterval;
   handles.model.delft3dwave.domain.comwriteinterval=handles.model.delft3dflow.domain(1).comInterval;
   handles.model.delft3dwave.domain.writecom=1;
   handles.model.delft3dwave.domain.coupledwithflow=1;
   handles.model.delft3dwave.domain.mdffile=handles.model.delft3dflow.domain(1).mdfFile;
   handles.model.delft3dwave.domain.domains(1).flowbedlevel=1;
   handles.model.delft3dwave.domain.domains(1).flowwaterlevel=1;
   handles.model.delft3dwave.domain.domains(1).flowvelocity=1;
   if handles.model.delft3dflow.domain(1).wind
       handles.model.delft3dwave.domain.domains(1).flowwind=1;
   else
       handles.model.delft3dwave.domain.domains(1).flowwind=0;
   end
   handles.model.delft3dflow.domain(1).waves=1;
   handles.model.delft3dflow.domain(1).onlineWave=1;

else
   
    if isempty(handles.model.delft3dwave.domain.mdffile) || strcmp(handles.model.delft3dwave.domain.mdffile,handles.model.delft3dflow.domain(1).mdfFile)
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            %ii=findstr(filename,'.mdf');
            handles.model.delft3dwave.domain.mdffile=filename;%filename(1:ii-1);
        else
            return
        end
    end

    if ~exist(handles.model.delft3dwave.domain.mdffile,'file')
        ddb_giveWarning('text',[handles.model.delft3dwave.domain.mdffile 'does not exist!']);
        return
    end
    
    MDF=ddb_readMDFText(handles.model.delft3dwave.domain.mdffile);
    handles.model.delft3dwave.domain.referencedate=datenum(MDF.itdate,'yyyy-mm-dd');
    handles.model.delft3dwave.domain.mapwriteinterval=MDF.flmap(2);
    handles.model.delft3dwave.domain.comwriteinterval=MDF.flpp(2);
    handles.model.delft3dwave.domain.writecom=1;
    handles.model.delft3dwave.domain.coupledwithflow=1;
    
    if strcmp(handles.model.delft3dwave.domain.coupling,'otheronline')
        if ~strcmp(MDF.waveol,'Y')
            ddb_giveWarning('text','Please make sure to tick the option ''Online Delft3D WAVE'' in Delft3D-FLOW model!');
        end
        if MDF.flpp(2)==0 || MDF.flpp(1)==MDF.flpp(3)
            ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!');
        end
    end
    
end

setHandles(handles);

%%
function checkWaterLevel
handles=getHandles;
val=handles.model.delft3dwave.domain.domains(awg).flowwaterlevel;
iac=handles.model.delft3dwave.domain.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.domains(n).flowwaterlevel=val;
end
setHandles(handles);

%%
function checkBedLevel
handles=getHandles;
val=handles.model.delft3dwave.domain.domains(awg).flowbedlevel;
iac=handles.model.delft3dwave.domain.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.domains(n).flowbedlevel=val;
end
setHandles(handles);

%%
function checkCurrent
handles=getHandles;
val=handles.model.delft3dwave.domain.domains(awg).flowvelocity;
iac=handles.model.delft3dwave.domain.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.domains(n).flowvelocity=val;
end
setHandles(handles);

%%
function checkWind
handles=getHandles;
val=handles.model.delft3dwave.domain.domains(awg).flowwind;
iac=handles.model.delft3dwave.domain.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.model.delft3dwave.domain.domains(n).flowwind=val;
end
setHandles(handles);
