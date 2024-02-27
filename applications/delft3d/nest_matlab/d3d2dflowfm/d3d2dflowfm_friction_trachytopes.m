function varargout=d3d2dflowfm_friction_trachytopes(varargin)
% Generate and write D-Flow FM trachytope *.arl from Delft3D definition
% d3d2dflowfm_friction_trachytopes generates and writes D-Flow FM roughness
%         trachytopes distribution file (.arl) from space varying
%         d3d-flow roughness from trachytopes distribution file (.aru/.arv)
%
%         Input arguments:
%                1) Name of the delft3d grid file (*.grd)
%                2) Name of the delft3d friction from trachytope file (*.aru)
%                3) Name of the delft3d friction from trachytope file (*.arv)
%                4) Name of the dflowfm network file(*_net.nc)
%                5) Name of the dflowfm trachytope file(*.arl)
%                6) (optional) Integer specifying the debugmode (0=no/1=yes)
%                7) (optional) Integer specifying the removal of previous links (0=no/1=yes)
%                    - if no block inputs are present, the simulation
%                    result is the same.
%
% See also: dflowfm_io_mdu dflowfm_io_xydata d3d2dflowfm_friction_xyz

filgrd         = varargin{1};
filaru         = varargin{2};
filarv         = varargin{3};
filnet         = varargin{4};
filarl         = varargin{5};

assert(exist(filgrd,'file')==2,'Delft3D grid file does not exist');
assert(exist(filaru,'file')==2,'Delft3D aru file does not exist');
assert(exist(filarv,'file')==2,'Delft3D arv file does not exist');
assert(exist(filnet,'file')==2,'DFlowFM net file does not exist');
assert(exist(filarl,'file')==0,'DFlowFM arl file already exists, please rename old file or specify different filename');

debugmodeverbose = 0;

if (nargin == 7)
    removepreviouslinks = varargin{7};
    removepreviouslinks_set = 1;
    debugmode = varargin{6};
else
    removepreviouslinks = 1;
    removepreviouslinks_set = 0;
    debugmode = 0;
end

if (nargin == 6)
    debugmode = varargin{6};
end

%
% Read associated .aru and arv. files
%

if debugmode
tic
disp('##### Loading Files (aru/arv) #####');
end
S_u = delft3d_io_aru_arv('read',filaru);
S_v = delft3d_io_aru_arv('read',filarv);
if debugmode
toc
disp('##### Loading Files complete (aru/arv) #####');
end

if S_u.count.block + S_v.count.block == 0
    if ~removepreviouslinks_set
        % Do not remove previous links because it is much faster
        removepreviouslinks = 0;
        warning('Setting removepreviouslinks=0 for faster conversion')
    else
        warning('Consider setting removepreviouslinks=0 for faster conversion')
    end
end

%
% Read the grid information
%

if debugmode
tic
disp('##### Loading Files (grd) #####');
end
grid           = delft3d_io_grd('read',filgrd);
mmax           = grid.mmax;
nmax           = grid.nmax;
xcoor_u        = grid.u_full.x;
ycoor_u        = grid.u_full.y;
xcoor_v        = grid.v_full.x;
ycoor_v        = grid.v_full.y;
if debugmode
toc
disp('##### Loading Files complete (grd) #####');
end
%
% Read the net information
%

if debugmode
tic
disp('##### Loading Files (net) #####');
end

GF = dflowfm.readNet(filnet);

if debugmode
toc
disp('##### Loading Files complete (net) #####');
end
%
% Get u/v grid points and find associated net link
%
L_u = zeros(nmax,mmax);
L_v = zeros(nmax,mmax);

%
% Build kd-trees
%
if debugmode
disp('##### Build Tree #####');
tic
end

missing_val = -999;
U = [xcoor_u(:),ycoor_u(:)];
U(union(find(isnan(xcoor_u(:))),find(isnan(ycoor_u(:)))),:) = [];
V = [xcoor_v(:),ycoor_v(:)];
V(union(find(isnan(xcoor_v(:))),find(isnan(ycoor_v(:)))),:) = [];

tree_u = createns(U,'nsmethod','kdtree');
tree_v = createns(V,'nsmethod','kdtree');

if debugmode
toc
disp('##### Build Tree complete #####');
end


if debugmode
disp('##### Build Mapping #####');
tic
end
h = waitbar(0,'Build mapping');
for L = 1:GF.edge.NetLinkSize;
    P = mean([GF.node.x(GF.edge.NetLink(:,L)).',GF.node.y(GF.edge.NetLink(:,L)).']);
    [idx_u,d_u] = knnsearch(tree_u,P,'k',1);
    udir = d_u<10e-14;
    [idx_v,d_v] = knnsearch(tree_v,P,'k',1);
    vdir = d_v<10e-14;
    assert(udir~=vdir);
    if udir
        L_u(idx_u) = L;
        %P_found = [xcoor_u(idx_u) ycoor_u(idx_u)];
    else
        L_v(idx_v) = L;
        %P_found = [xcoor_v(idx_v) ycoor_v(idx_v)];
    end
    %if debugmode
    %    assert(sum((P_found-P).^2)<1e-14)
    %end
    if mod(L,100) == 0;
        waitbar(L/GF.edge.NetLinkSize,h)
    end
end
delete(h); 

if debugmode
toc
disp('##### Build Mapping complete #####');
end
%
% Create structure for .arl file
%

if debugmode
disp('##### Create .arl file #####');
tic
end
k = 1;
S_l.data{k}.comment = ['* Converted from Delft3D input files'];
L_all = {L_u,L_v};
x_all = {xcoor_u,xcoor_v};
y_all = {ycoor_u,ycoor_v};
dir_all = 'uv';
cc = 0;
for T = [S_u, S_v]
    cc = cc + 1;
    LL = L_all{cc};
    xL = x_all{cc};
    yL = y_all{cc};
    k = k+1;
    S_l.data{k}.comment = ['* Based on ',T.filename];
    j = 1;
    jlist = [];
    lenTdata = length(T.data);
    h = waitbar(0,sprintf('Processing arl in %s-direction',dir_all(cc)));
    while j <= lenTdata;
        if debugmodeverbose
            disp(['Processing line ', num2str(j), ' of ', num2str(lenTdata)]);
        end
        if mod(j,100) == 0;
            waitbar(j/lenTdata,h)
        end
        if (length(setdiff(lower(fieldnames(T.data{j})),{'comment'})) == 0);
            if debugmodeverbose
                disp('Processing comment')
            end
            k = k+1;
            S_l.data{k}.comment = T.data{j}.comment;
            j = j + 1;
        elseif (length(setdiff(lower(fieldnames(T.data{j})),{'n','m','definition','percentage'})) == 0);
            if debugmodeverbose
                disp('Processing n m values')
            end
            j0 = j;
            jlist = j0;
            jnotlist = [];
            followup = 1;
            if debugmodeverbose
                disp('... Read next link?')
            end
            while (followup) && (j < length(T.data))
                if (followup) && (length(setdiff(lower(fieldnames(T.data{j+1})),{'n','m','definition','percentage'})) == 0)
                    if (T.data{j+1}.n == T.data{j0}.n) && (T.data{j+1}.m == T.data{j0}.m)
                        followup = 1;
                        j = j+1;
                        if j > j0;
                            jlist = [jlist,j];
                        end
                    else
                        followup = 0;
                    end
                elseif (followup) && (length(setdiff(lower(fieldnames(T.data{j+1})),{'comment'})) == 0)
                    j = j+1;
                    jnotlist = [jnotlist,j];
                else
                    followup = 0;
                end
            end
            L = LL(T.data{j0}.n,T.data{j0}.m);
            x = xL(T.data{j0}.n,T.data{j0}.m);
            y = yL(T.data{j0}.n,T.data{j0}.m);
            z = 0.0;   % dummy value for now.
            k0 = k+1;  %keep track of first index to be written to
            for ji = jnotlist;
                if ji<jlist(end)   %done to ensure comments come before the point they are defined
                    k = k+1;
                    S_l.data{k}.comment = T.data{ji}.comment;
                end
            end
            if ~isnan(L)
                for ji = jlist;
                    k = k+1;
                    S_l.data{k}.definition = T.data{ji}.definition;
                    S_l.data{k}.percentage = T.data{ji}.percentage;
                    S_l.data{k}.nm = L;
                    S_l.data{k}.x  = x;
                    S_l.data{k}.y  = y;
                    S_l.data{k}.z  = z;
                end
                if removepreviouslinks
                    %search backwards and remove earlier instances of link L
                    ki = k0-1;
                    if debugmodeverbose
                        disp(['... Removing previous instances of L ', num2str(L)])
                    end
                    while ki > 0;
                        if (length(setdiff(lower(fieldnames(S_l.data{ki})),{'nm','definition','percentage'})) == 0)
                            if (S_l.data{ki}.nm == L);
                                S_l.data = {S_l.data{1:ki-1},S_l.data{ki+1:end}};
                                k  = k-1;
                                k0 = k0-1;
                            end
                        end
                        ki = ki-1;
                    end
                end
            end
            j = jlist(end) + 1;
        elseif (length(setdiff(lower(fieldnames(T.data{j})),{'n1','m1','n2','m2','definition','percentage'})) == 0);
            if debugmodeverbose
                disp('Processing block values')
            end
            j0 = j;
            jlist = j0;
            jnotlist = [];
            followup = 1;
            if debugmodeverbose
                disp('... Read next line ?')
            end
            while (followup) && (j < length(T.data))
                if (followup) && (length(setdiff(lower(fieldnames(T.data{j+1})),{'n1','m1','n2','m2','definition','percentage'})) == 0)
                    if (T.data{j+1}.n1 == T.data{j0}.n1) && (T.data{j+1}.m1 == T.data{j0}.m1) && ...
                            (T.data{j+1}.n2 == T.data{j0}.n2) && (T.data{j+1}.m2 == T.data{j0}.m2)
                        followup = 1;
                        j = j+1;
                        if j>j0
                            jlist = [jlist,j];
                        end
                    else
                        followup = 0;
                    end
                elseif (followup) && (length(setdiff(lower(fieldnames(T.data{j+1})),{'comment'})) == 0)
                    j = j+1;
                    jnotlist = [jnotlist,j];
                else
                    followup = 0;
                end
            end
            k0 = k+1;  %keep track of first index to be written to
            for ji = jnotlist;
                if ji<jlist(end)   %done to ensure comments come before the point they are defined
                    k = k+1;
                    S_l.data{k}.comment = T.data{ji}.comment;
                end
            end
            for m = T.data{j0}.m1:T.data{j0}.m2
                for n = T.data{j0}.n1:T.data{j0}.n2
                    L = LL(n,m);
                    x = xL(n,m);
                    y = yL(n,m);
                    z = 0.0;   % dummy value for now.
                    if ~isnan(L)
                        for ji = jlist;
                            k = k+1;
                            S_l.data{k}.definition = T.data{ji}.definition;
                            S_l.data{k}.percentage = T.data{ji}.percentage;
                            S_l.data{k}.nm = L;
                            S_l.data{k}.x  = x;
                            S_l.data{k}.y  = y;
                            S_l.data{k}.z  = z;
                        end
                        if removepreviouslinks
                            %search backwards and remove earlier instances at link L
                            ki = k0-1;
                            if debugmodeverbose
                                disp(['... Removing previous instances of L ', num2str(L)])
                            end
                            while ki > 0;
                                if (length(setdiff(lower(fieldnames(S_l.data{ki})),{'nm','definition','percentage'})) == 0)
                                    if (S_l.data{ki}.nm == L);
                                        S_l.data = {S_l.data{1:ki-1},S_l.data{ki+1:end}};
                                        k  = k-1;
                                        k0 = k0-1;
                                    end
                                end
                                if (length(setdiff(lower(fieldnames(S_l.data{ki})),{'nm','x','y','z','definition','percentage'})) == 0)
                                    if (S_l.data{ki}.nm == L);
                                        S_l.data = {S_l.data{1:ki-1},S_l.data{ki+1:end}};
                                        k  = k-1;
                                        k0 = k0-1;
                                    end
                                end
                                ki = ki-1;
                            end
                        end
                    end
                end
            end
            j = jlist(end) + 1;
        end
        %disp([j, jlist])
    end
    delete(h);
end
if debugmode
toc
disp('##### Create .arl file complete #####');
end

%
% Write structure to .arl file (reusing Delft3d routine)
%
if debugmode
    disp('##### Writing to file ##### ')
    tic
end
T = delft3d_io_aru_arv('write',filarl,S_l);
if debugmode
    toc
    disp('##### Writing to file complete ##### ')
end
end

function found = isbetween(ax, ay, bx, by, cx, cy)
% returns 1 if (cx,cy) lies between the line segment (ax,ay) - (bx,by)
epsilon = 1e-8;
crossproduct = (cy - ay) * (bx - ax) - (cx - ax) * (by - ay);
found = 1;
if abs(crossproduct) > epsilon;
    found = 0;
end
dotproduct = (cx - ax) * (bx - ax) + (cy - ay)*(by - ay);
if dotproduct < 0
    found = 0;
end
squaredlengthba = (bx - ax)*(bx - ax) + (by - ay)*(by - ay);
if dotproduct > squaredlengthba
    found = 0;
end
end

function L = find_net_link(x,y,GF,L);
% start search from L because net-links of the previous search are likely
% to be close to the next searched after
L0 = L;
found = 0;
while L < GF.cor.nLink
    L = L+1;
    nl = GF.cor.Link(:,L);
    xL = GF.cor.x(nl);
    yL = GF.cor.y(nl);
    if isbetween(xL(1),yL(1),xL(2),yL(2),x,y)
        found = 1;
        break
    end
end
if (~found)
    L = 0;
    while L <= L0
        L = L+1;
        nl = GF.cor.Link(:,L);
        xL = GF.cor.x(nl);
        yL = GF.cor.y(nl);
        if isbetween(xL(1),yL(1),xL(2),yL(2),x,y)
            found = 1;
            break
        end
    end
end
if ((found == 0) || isnan(x) || isnan(y))
    L = NaN;
end
end