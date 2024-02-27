function ddb_Delft3DWAVE_editBoundaryConditions(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch varargin{ii}
            case{'addsegment'}
                addSegment;
            case{'deletesegment'}
                deleteSegment;
        end
    end
end

%%
function addSegment

handles=gui_getUserData;
iac=handles.model.delft3dwave.domain.activeboundary;
nrseg=handles.model.delft3dwave.domain.boundaries(iac).nrsegments;
handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg+1).condspecatdist=handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg).condspecatdist;
handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg+1).waveheight=handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg).waveheight;
handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg+1).period=handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg).period;
handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg+1).direction=handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg).direction;
handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg+1).dirspreading=handles.model.delft3dwave.domain.boundaries(iac).segments(nrseg).dirspreading;
handles.model.delft3dwave.domain.boundaries(iac).nrsegments=nrseg+1;
handles.model.delft3dwave.domain.boundaries(iac).activesegment=nrseg+1;
for ii=1:nrseg+1
    handles.model.delft3dwave.domain.boundaries(iac).segmentnames{ii}=['Segment ' num2str(ii)];
end
gui_setUserData(handles);

%%
function deleteSegment

handles=gui_getUserData;
iac=handles.model.delft3dwave.domain.activeboundary;
nrseg=handles.model.delft3dwave.domain.boundaries(iac).nrsegments;
if nrseg>1
    handles.model.delft3dwave.domain.boundaries(iac).segments=removeFromStruc(handles.model.delft3dwave.domain.boundaries(iac).segments,handles.model.delft3dwave.domain.boundaries(iac).activesegment);
    handles.model.delft3dwave.domain.boundaries(iac).nrsegments=handles.model.delft3dwave.domain.boundaries(iac).nrsegments-1;
    handles.model.delft3dwave.domain.boundaries(iac).activesegment=min(handles.model.delft3dwave.domain.boundaries(iac).activesegment,handles.model.delft3dwave.domain.boundaries(iac).nrsegments);
    handles.model.delft3dwave.domain.boundaries(iac).segmentnames=[];
    for ii=1:nrseg-1
        handles.model.delft3dwave.domain.boundaries(iac).segmentnames{ii}=['Segment ' num2str(ii)];
    end
    gui_setUserData(handles);
end
