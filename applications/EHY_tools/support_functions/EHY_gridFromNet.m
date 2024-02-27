function GRID = EHY_gridFromNet(fileNet)

% Reconstruct a delft3D mn based grid from a Dflowfm net file. Net file
% must be written using with cell Info 
%
%% Read net file
net = EHY_getGridInfo(fileNet,{'XYcor'});
Xnet = net.Xcor;
Ynet = net.Ycor;

try
    netElemNode = ncread(fileNet,'NetElemNode');
catch
    warning('Reconstructing netElmNode from Link information. Can be time consuming. Consider writing net file with Cell Information');
    netElemNode = EHY_create_netElemNode(fileNet);
    for i_node = 1: size(netElemNode,2)
        %lower left corner, smallest number, first
        [~,index] = min(netElemNode(:,i_node));
        if index > 1
            for i_corner = 1: 4
                nr(i_corner) = index + i_corner - 1 ;
                if nr(i_corner) > 4; nr(i_corner) = nr(i_corner) - 4; end
            end
            netElemNode(:,i_node) = netElemNode(nr,i_node);
        end
        
        % orientation, ll cornre, lr corner, ur corner ul corner
        if netElemNode(2,i_node) < netElemNode(4,i_node)
            tmp                   = netElemNode(4,i_node);
            netElemNode(4,i_node) = netElemNode(2,i_node);
            netElemNode(2,i_node) = tmp;
        end
    end
    
end

%% First active cell (m,n) = (2,2) (like in Delft3D-Flow
m_act(1)   = 2;
n_act(1)   = 2;
nr_cell(1) = 1000;

Xcor(m_act - 1, n_act -1) = Xnet(netElemNode(1,nr_cell)); Ycor(m_act - 1, n_act -1) = Ynet(netElemNode(1,nr_cell)); 
Xcor(m_act    , n_act -1) = Xnet(netElemNode(2,nr_cell)); Ycor(m_act    , n_act -1) = Ynet(netElemNode(2,nr_cell));
Xcor(m_act    , n_act   ) = Xnet(netElemNode(3,nr_cell)); Ycor(m_act    , n_act   ) = Ynet(netElemNode(3,nr_cell));
Xcor(m_act - 1, n_act   ) = Xnet(netElemNode(4,nr_cell)); Ycor(m_act - 1, n_act   ) = Ynet(netElemNode(4,nr_cell));

%% Mask to be able to check if all node links are found
netElemNode(5:8,:) = 1;

%% Find neighbours until no neighbours can't be found
while sum(sum(netElemNode(5:8,:),2),1) > 0
    [Xcor,Ycor,netElemNode,nr_cell,m_act,n_act] = findMyNeigbours(Xcor,Ycor,Xnet,Ynet,netElemNode,nr_cell,m_act,n_act);
end

%% Zere values replaced by NaN's
Xcor(Xcor == 0.) = NaN;
Ycor(Ycor == 0.) = NaN;

%% Write temporary grid file and read so all grid information is tored in GRID
GRID.cor.x            = Xcor';
GRID.cor.y            = Ycor';
GRID.missingvalue     = NaN;
delft3d_io_grd('write','tmp_tk.grd',GRID,'ask',false);
GRID = delft3d_io_grd('read','tmp_tk.grd');
delete('tmp_tk.grd');
delete('tmp_tk.end');

end

function [Xcor,Ycor,netElemNode,nr_cell,m_act,n_act] = findMyNeigbours(Xcor,Ycor,Xnet,Ynet,netElemNode,nr_cell,m_act,n_act)
nr_cell(1)
m_now = m_act(1);
n_now = n_act(1);

% Right neighbour
nr = find(netElemNode(1,:) == netElemNode(2,nr_cell(1)));
netElemNode(6,nr_cell(1)) = 0;

if ~isempty(nr) && netElemNode(8,nr) ~= 0
    m_act(end + 1) = m_now + 1;
    n_act(end + 1) = n_now;
    nr_cell(end + 1) = nr;
    Xcor(m_act(end)    , n_act(end) -1) = Xnet(netElemNode(2,nr_cell(end))); Ycor(m_act(end)    , n_act(end) - 1) = Ynet(netElemNode(2,nr_cell(end)));
    Xcor(m_act(end)    , n_act(end)   ) = Xnet(netElemNode(3,nr_cell(end))); Ycor(m_act(end)    , n_act(end)    ) = Ynet(netElemNode(3,nr_cell(end)));
    netElemNode(8,nr) = 0;
end

% Upper neighbour
nr = find(netElemNode(2,:) == netElemNode(3,nr_cell(1)));
netElemNode(7,nr_cell(1)) = 0;

if ~isempty(nr) && netElemNode(5,nr) ~= 0
    m_act  (end + 1) = m_now;
    n_act  (end + 1) = n_now + 1;
    nr_cell(end + 1) = nr;
    Xcor(m_act(end)    , n_act(end)   ) = Xnet(netElemNode(3,nr_cell(end))); Ycor(m_act(end)    , n_act(end)   ) = Ynet(netElemNode(3,nr_cell(end)));
    Xcor(m_act(end) - 1, n_act(end)   ) = Xnet(netElemNode(4,nr_cell(end))); Ycor(m_act(end) - 1, n_act(end)   ) = Ynet(netElemNode(4,nr_cell(end)));
    netElemNode(5,nr) = 0;
end

% left neighbour
nr = find(netElemNode(3,:) == netElemNode(4,nr_cell(1)));
netElemNode(8,nr_cell(1)) = 0;

if ~isempty(nr) && netElemNode(6,nr) ~= 0
    m_act  (end + 1) = m_now - 1;
    n_act  (end + 1) = n_now;
    nr_cell(end + 1) = nr;
    if m_act(end) == 1
        m_act             = m_act + 1; m_now = m_now + 1       ;
        Xcor(2:end + 1,:) = Xcor     ; Ycor(2:end + 1,:) = Ycor;
        Xcor(1,:) = NaN              ; Ycor(1,:) = NaN         ;
    end
    Xcor(m_act(end) - 1, n_act(end) -1) = Xnet(netElemNode(1,nr_cell(end))); Ycor(m_act(end) - 1, n_act(end) -1) = Ynet(netElemNode(1,nr_cell(end)));
    Xcor(m_act(end) - 1, n_act(end)   ) = Xnet(netElemNode(4,nr_cell(end))); Ycor(m_act(end) - 1, n_act(end)   ) = Ynet(netElemNode(4,nr_cell(end)));
    netElemNode(6,nr) = 0;
end

% lower neighbour
nr = find(netElemNode(4,:) == netElemNode(1,nr_cell(1)));
netElemNode(5,nr_cell(1)) = 0;

if ~isempty(nr) && netElemNode(7,nr) ~= 0
    m_act  (end + 1) = m_now;
    n_act  (end + 1) = n_now - 1;
    nr_cell(end + 1) = nr;
    if n_act(end) == 1
        n_act = n_act + 1;
        Xcor(:,2:end + 1) = Xcor ; Ycor(:,2:end + 1) = Ycor;
        Xcor(:,1)         = NaN  ; Ycor(:,1)         = NaN;
    end
    Xcor(m_act(end) - 1, n_act(end) - 1) = Xnet(netElemNode(1,nr_cell(end))); Ycor(m_act(end) - 1, n_act(end) - 1) = Ynet(netElemNode(1,nr_cell(end)));
    Xcor(m_act(end)    , n_act(end) - 1) = Xnet(netElemNode(2,nr_cell(end))); Ycor(m_act(end)    , n_act(end) - 1) = Ynet(netElemNode(2,nr_cell(end)));
    netElemNode(7,nr) = 0;
end

% find the first cell with neighbours
index = [];
for i_cell = 1: length(nr_cell)
    if sum(netElemNode((5:8), nr_cell(i_cell))) > 0
        index = i_cell;
        break
    end
end

if ~isempty(index) 
    nr_cell = nr_cell(index:end);
    m_act   = m_act  (index:end);
    n_act   = n_act  (index:end);
end

end

