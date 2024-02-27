function ddb_plotDelft3DWAVE(option,varargin)

% Option can be on of three things: plot, delete, update
%
% The function refreshScreen always uses the option inactive.
% Plot Delft3DFLOW is only used for one domain!

handles=getHandles;

vis=1;
act=0;
dact=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'active'}
                act=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'deactivate'}
                dact=varargin{i+1};                
        end
    end
end

if dact
    vis=0;
end

n1=1;
n2=handles.model.delft3dwave.domain.nrgrids;
    
for id=n1:n2
    
    % Exception for grid, make grid grey if it's not the active grid
    % or if all domains are selected and not active
    if dact==1
        col=[0.7 0.7 0.7];
    elseif id~=awg
        col=[0.7 0.7 0.7];
    else
        col=[0.35 0.35 0.35];
    end
    
    % Always plot grid (even is vis is 0)
    handles=ddb_Delft3DWAVE_plotGrid(handles,option,'wavedomain',id,'color',col,'visible',vis);

end

% Plot active grid on top
try
    uistack(handles.model.delft3dwave.domain.domains(awg).grid.plotHandles,'top');
end

handles=ddb_Delft3DWAVE_plotBathy(handles,option,'visible',vis,'active',act);

handles=ddb_Delft3DWAVE_plotBoundaries(handles,option,'visible',vis,'active',act);

handles=ddb_Delft3DWAVE_plotObstacles(handles,option,'visible',vis,'active',act);

handles=ddb_Delft3DWAVE_plotOutputLocations(handles,option,'visible',vis,'active',act);

setHandles(handles);
