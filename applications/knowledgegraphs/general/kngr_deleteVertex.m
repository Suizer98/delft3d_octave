function deleteVertex(idfrom)

global session;

if nargin == 0
    try
        idfrom = find(ismember(vertcat(session.vertices{:,3}),gco));
    end
end

%% strip session variable of object handles
session.vertices(:,3:end)=[];
session = rmfield(session,'edgeHandles');
session = rmfield(session,'edgeLabels');

%% remove row from vertices and row and column of edges
session.vertices(idfrom,:)=[];
session.edges(:,idfrom)=[];
session.edges(idfrom,:)=[];

%% clear the current axes and replot the graph
cla; plotGraph(gcf)  