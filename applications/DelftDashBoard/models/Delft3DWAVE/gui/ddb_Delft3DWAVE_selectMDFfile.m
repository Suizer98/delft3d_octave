function ddb_Delft3DWAVE_selectMDFfile(varargin)

handles=getHandles;

filename=handles.model.delft3dwave.domain.mdffile;
MDF=ddb_readMDFText(filename);
ItDate=datenum(MDF.itdate,'yyyy-mm-dd');
ComStartTime=ItDate+MDF.flpp(1)/1440;
ComInterval=MDF.flpp(2)/1440;
ComStopTime=ItDate+MDF.flpp(3)/1440;
handles.model.delft3dwave.domain.referencedate=ItDate;
handles.model.delft3dwave.domain.availableflowtimes=datestr(ComStartTime:ComInterval:ComStopTime);

setHandles(handles);
