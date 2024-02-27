%DELFT3D_IO_TEST test for delft3d_io_*** tools
%
%See also: DELFT3D

%% https://svn.oss.deltares.nl/repos/openearthmodels/trunk/deltares/brazil_patos_lagoon_52S_32E/
folder = 'd:\checkouts\OpenEarthModels\deltares\brazil_patos_lagoon_52S_32E\';

%% load entire mode input
M     = delft3d_io_mdf('read',[folder,'3d1.mdf']);
G     = delft3d_io_grd('read',[folder,M.keywords.filcco]);
G     = delft3d_io_dep('read',[folder,M.keywords.fildep],G,'dpsopt',M.keywords.dpsopt); % TODO not G.dep = ...
G     = delft3d_io_dry('read',[folder,M.keywords.fildry],G);

G.bnd = delft3d_io_bnd('read',[folder,M.keywords.filbnd],G);
G.crs = delft3d_io_crs('read',[folder,M.keywords.filcrs],G);
G.src = delft3d_io_src('read',[folder,M.keywords.filsrc],G);
G.obs = delft3d_io_obs('read',[folder,M.keywords.filsta],G);
G.thd = delft3d_io_thd('read',[folder,M.keywords.filtd ],G);

%% plot for interactive visual inspection
close all
pcolorcorcen(G.cor.x,G.cor.y,G.cen.dep.*G.cen.mask,'k'); % make dry cells transparent, but do draw grid lines
hold on
axis equal
if strcmpi(G.CoordinateSystem,'spherical')
   tickmap('ll')
   axislat()
else
   tickmap('xy')
end
grid on
plot(G.bnd.x',G.bnd.y','-','linewidth',2,'color',[0 0 1]);% TODO gaps
plot(G.crs.X ,G.crs.Y ,'-','linewidth',2,'color',[0 1 1]);
%text(G.crs.x ,G.crs.y ,{G.crs.DATA.name},'color',[0 1 1],'fontsize',8); %TODO calculate mean x

plot(G.src.x ,G.src.y ,'d','linewidth',2,'color',[1 0 1]);
text(G.src.x ,G.src.y ,addrowcol(char({G.src.DATA.name}),0,-1,' '),'color',[1 0 1],'fontsize',8);

plot(G.obs.x ,G.obs.y ,'x','linewidth',2,'color',[1 1 0]);
text(G.obs.x ,G.obs.y ,addrowcol(G.obs.namst,0,-1,' '),'color',[1 1 0],'fontsize',8);

plot(G.thd.X ,G.thd.Y ,'-','linewidth',2,'color',[1 1 0]);
colorbarwithvtext('bathymetry [m]')

%% test writing
delft3d_io_thd('write','thd.tek',G.thd,'format','ldb')
[T.thd.x,T.thd.y] = landboundary('read','thd.tek');
plot(T.thd.x,T.thd.y,'--','linewidth',3,'color',[1 1 0]);
