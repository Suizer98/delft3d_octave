function [x,y] = EHY_find_selfintersect(pol)

% ask user for file
if ~exist('pol','var')
        [filename, pathname]=uigetfile('*.*','Open a .pol, .pli or .ldb file');
    if isnumeric(filename); disp('EHY_find_selfintersect stopped by user.'); return; end
    pol = [pathname filename];
end

% get pol from file
if ~isnumeric(pol) && exist(pol,'file')
    pol = io_polygon('read',pol);
end
    
%% selfintersect
[x0,y0] = selfintersect(pol(:,1),pol(:,2));

%% figure
figure('units','normalized','outerposition',[0 0 1 1]);
hold on
plot(pol(:,1),pol(:,2),'k','linewidth',1)
scatter(x0,y0,100,'rx')
