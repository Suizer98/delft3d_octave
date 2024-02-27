function handles = ddb_plotXBeach(option, varargin)

handles=getHandles;

vis=1;
act=0;
idomain=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'active'}
                act=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                idomain=varargin{i+1};
        end
    end
end

if idomain==0
    % Update all domains
    n1=1;
    n2=handles.model.xbeach.nrDomains;
else
    % Update one domain
    n1=idomain;
    n2=n1;
end

if idomain==0 && ~act
    vis=0;
end

for id=n1:n2
    
    try
        handles=ddb_XBeach_plotBathymetry(handles,option,'domain',idomain);
        if  handles.model.xbeach.domain(idomain).ny  == 0 
            handles=ddb_XBeach_plotGrid(handles,option,'domain',idomain);
        end
    end
    
end

% Grid
try
xl(1)=min(min(handles.model.xbeach.domain(id).grid.x));
xl(2)=max(max(handles.model.xbeach.domain(id).grid.x));
yl(1)=min(min(handles.model.xbeach.domain(id).grid.y));
yl(2)=max(max(handles.model.xbeach.domain(id).grid.y));
handles=ddb_zoomTo(handles,xl,yl,0.1);
catch
end
