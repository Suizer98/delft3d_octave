function kngr_addRelation(from, to, type)

if nargin == 0 % if no input arguments are available ...
    try % ... try to get input from gui
        from = get(findobj('tag','frmtxt'),'string');
        to   = get(findobj('tag','totxt'),'string');
        type = get(findobj('tag','type'),'Value')-1;
    catch % ... if that doesn't work get input from the commandline
        from = input('From :          ', 's');
        to   = input('To :            ', 's');
        type = input('Relation type : ', 's');
    end
end

if type == 0
    return
end

%% initialise globals 
global ontology session;

%% process input to proper sessionfile format
% see if the 'from' and the 'to' vertex are already present in the graph somewhere
try
    idfrom = find(ismember(session.vertices(:,1), from));
catch
    idfrom = [];
end
try
    idto   = find(ismember(session.vertices(:,1), to));
catch
    idto = [];
end

% check if the relation to add is a new one
newedge = 0;
if isempty(idfrom)
    newedge = 1;
    if ~isfield(session,'vertices')
        idfrom = 1;
    else
        idfrom = size(session.vertices,1)+1;
    end
    session.vertices{idfrom,1} = from;
    session.vertices{idfrom,2} = [rand(1,10)*10, rand(1,10)*10];
end

if isempty(idto)
    newedge = 1;
    idto = size(session.vertices,1)+1;
    session.vertices{idto,1} = to;
    session.vertices{idto,2} = [rand(1,10)*10, rand(1,10)*10];
end

if ~isfield(session,'edges')
    session.edges = sparse(1,1);
end
session.edges(idfrom, idto) = type;
if ~ontology(type).oneway
    session.edges(idto, idfrom) = type;
else
    session.edges(idto, idfrom) = 0;
end

if size(session.edges,1)~=size(session.edges,1)
    disp('warning: something went wrong adding relation. Edge matrix shaped wrong!')
end

if newedge
    session.edgeHandles(idfrom,idto) = 0;
    session.edgeHandles(idto,idfrom) = 0;
    session.edgeLabels (idfrom,idto) = 0;
    session.edgeLabels (idto,idfrom) = 0;
end

session.vertices(:,3:end)=[];
session = rmfield(session,'edgeHandles');
session = rmfield(session,'edgeLabels');
cla

kngr_plotGraph(gcf)  