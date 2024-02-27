function handles=ddb_readMDW(handles,filename)

MDW = ddb_readDelft3D_keyWordFile(filename,'allowspaces',1);

handles.model.delft3dwave.domain.activedomain=1;

handles.model.delft3dwave.domain.referencedate=floor(now);

%% General
fldnames=fieldnames(MDW.general);
for ii=1:length(fldnames)
    handles.model.delft3dwave.domain.(fldnames{ii})=MDW.general.(fldnames{ii});
end
handles.model.delft3dwave.domain.referencedate=datenum(handles.model.delft3dwave.domain.referencedate);
handles.model.delft3dwave.domain.timepoint=handles.model.delft3dwave.domain.referencedate+handles.model.delft3dwave.domain.timepoint/1440.0;
handles.model.delft3dwave.domain.selectedtime = handles.model.delft3dwave.domain.timepoint;
handles.model.delft3dwave.domain.listtimes={datestr(handles.model.delft3dwave.domain.timepoint,'yyyy mm dd HH MM SS')};
handles.model.delft3dwave.domain.listflowtimes={''}; 

%% Constants
fldnames=fieldnames(MDW.constants);
for ii=1:length(fldnames)
    handles.model.delft3dwave.domain.(fldnames{ii})=MDW.constants.(fldnames{ii});
end

%% Processes
fldnames=fieldnames(MDW.processes);
for ii=1:length(fldnames)
    handles.model.delft3dwave.domain.(fldnames{ii})=MDW.processes.(fldnames{ii});
end
switch lower(handles.model.delft3dwave.domain.bedfriction)
    case{'jonswap'}
        handles.model.delft3dwave.domain.bedfriccoefjonswap=handles.model.delft3dwave.domain.bedfriccoef;
    case{'collins'}
        handles.model.delft3dwave.domain.bedfriccoefcollins=handles.model.delft3dwave.domain.bedfriccoef;
    case{'madsen et al.'}
        handles.model.delft3dwave.domain.bedfriccoefmadsen=handles.model.delft3dwave.domain.bedfriccoef;
end

%% Numerics
fldnames=fieldnames(MDW.numerics);
for ii=1:length(fldnames)
    handles.model.delft3dwave.domain.(fldnames{ii})=MDW.numerics.(fldnames{ii});
end

%% Output
fldnames=fieldnames(MDW.output);
for ii=1:length(fldnames)
    handles.model.delft3dwave.domain.(fldnames{ii})=MDW.output.(fldnames{ii});
end
if ~iscell(handles.model.delft3dwave.domain.locationfile)
    v=handles.model.delft3dwave.domain.locationfile;
    if ~isempty(v)
        handles.model.delft3dwave.domain.locationfile=[];
        handles.model.delft3dwave.domain.locationfile{1}=v;
    end
end


%% Domains
ndomains=length(MDW.domain);
handles.model.delft3dwave.domain.gridnames={''};
handles.model.delft3dwave.domain.nrdomains=ndomains;
handles.model.delft3dwave.domain.domains=[];
handles.model.delft3dwave.domain.nrgrids=ndomains;
for id=1:ndomains
    handles.model.delft3dwave.domain.domains=ddb_initializeDelft3DWAVEDomain(handles.model.delft3dwave.domain.domains,id);
    fldnames=fieldnames(MDW.domain(id));
    for ii=1:length(fldnames)
        handles.model.delft3dwave.domain.domains(id).(fldnames{ii})=MDW.domain(id).(fldnames{ii});
    end
    handles.model.delft3dwave.domain.domains(id).gridname=handles.model.delft3dwave.domain.domains(id).grid(1:end-4);
    handles.model.delft3dwave.domain.gridnames{id}=handles.model.delft3dwave.domain.domains(id).grid(1:end-4);
end
handles = ddb_Delft3DWAVE_setNestGrids(handles);
for id=1:ndomains
    if isfield(handles.model.delft3dwave.domain.domains(id),'nestedindomain')
        if ~isempty(handles.model.delft3dwave.domain.domains(id).nestedindomain)
            handles.model.delft3dwave.domain.domains(id).nestgrid=handles.model.delft3dwave.domain.gridnames{handles.model.delft3dwave.domain.domains(id).nestedindomain};
        end
    end
end

%% Boundaries
if isfield(MDW,'boundary')
    nbnd=length(MDW.boundary);
    handles.model.delft3dwave.domain.nrboundaries=nbnd;
    handles.model.delft3dwave.domain.boundaries=[];
    for ib=1:nbnd
        handles.model.delft3dwave.domain.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.model.delft3dwave.domain.boundaries,ib);
        fldnames=fieldnames(MDW.boundary(ib));
        for ii=1:length(fldnames)
            if ~iscell(MDW.boundary(ib).(fldnames{ii}))
                handles.model.delft3dwave.domain.boundaries(ib).(fldnames{ii})=MDW.boundary(ib).(fldnames{ii});
            end
        end
        handles.model.delft3dwave.domain.boundarynames{ib}=handles.model.delft3dwave.domain.boundaries(ib).name;
        if isfield(MDW.boundary(ib),'waveheight')
            if iscell(MDW.boundary(ib).waveheight)
                handles.model.delft3dwave.domain.boundaries(ib).alongboundary='varying';
                handles.model.delft3dwave.domain.boundaries(ib).nrsegments=length(MDW.boundary(ib).waveheight);
                for iseg=1:handles.model.delft3dwave.domain.boundaries(ib).nrsegments
                    handles.model.delft3dwave.domain.boundaries(ib).segmentnames{iseg}=['Segment ' num2str(iseg)];
                    handles.model.delft3dwave.domain.boundaries(ib).segments(iseg).waveheight=MDW.boundary(ib).waveheight{iseg};
                    handles.model.delft3dwave.domain.boundaries(ib).segments(iseg).condspecatdist=MDW.boundary(ib).condspecatdist{iseg};
                    handles.model.delft3dwave.domain.boundaries(ib).segments(iseg).period=MDW.boundary(ib).period{iseg};
                    handles.model.delft3dwave.domain.boundaries(ib).segments(iseg).direction=MDW.boundary(ib).direction{iseg};
                    handles.model.delft3dwave.domain.boundaries(ib).segments(iseg).dirspreading=MDW.boundary(ib).dirspreading{iseg};
                end
            end
        end
    end
end
