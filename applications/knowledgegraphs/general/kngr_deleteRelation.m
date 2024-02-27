function deleteRelation(from, to)

if nargin == 0 % if no input arguments are available ...
    try % ... try to get input from gui
        from = get(findobj('tag','frmtxt'),'string');
        to   = get(findobj('tag','totxt'),'string');
    catch % ... if that doesn't work get input from the commandline
        from = input('From :          ', 's');
        to   = input('To :            ', 's');
    end
end

%% initialise globals
global ontology session;

%% process input to proper sessionfile format
% see if the 'from' and the 'to' vertex are already present in the graph somewhere
% if not the deleteRelation script will stop executing
try
    idfrom = find(ismember(session.vertices(:,1), from));
catch
    return
end
try
    idto   = find(ismember(session.vertices(:,1), to));
catch
    return
end

%% reset relevant values in the edges matrix to zero
session.edges(idfrom, idto) = 0;
session.edges(idto, idfrom) = 0;

%% reset edgeHandles to zero
session.edgeHandles(idfrom,idto) = 0;
session.edgeHandles(idto,idfrom) = 0;

%% reset edgeLabels to zero
session.edgeLabels (idfrom,idto) = 0;
session.edgeLabels (idto,idfrom) = 0;

%% clear vertex positions and remove fields from session variable
session.vertices(:,3:end)=[];
session = rmfield(session,'edgeHandles');
session = rmfield(session,'edgeLabels');

%% clear axes and redraw graph
cla;plotGraph(gcf)