function jarkus_plotMKL(xMKL, transect, result);
% plot MCL

x           = transect.xe(~isnan(transect.ze));
z           = transect.ze(~isnan(transect.ze));

figure(1); clf

% plot transect
ph1         = plot(x, z); set(gca,'xdir','reverse');hold on

% plot volume patch
volumepatch = [result.xActive' fliplr(result.xActive'); result.z2Active' fliplr(result.zActive')]';
ph2         = patch(volumepatch(:,1), volumepatch(:,2), ones(size(volumepatch(:,2)))*-(length(result)),'b');

% plot MCL point
zMKL        = interp1(transect.xe(~isnan(transect.ze)), transect.ze(~isnan(transect.ze)), xMKL);
ph3         = plot(xMKL,zMKL); 
set(ph3,'marker','o','markeredgecolor','b','markerfacecolor','g','markersize',6,'linewidth',1.5)

% plot MLW
ph2         = plot([min(x) max(x)],[transect.MLW transect.MLW],'-.g','linewidth',1);
th2         = text(max(x)-100,transect.MLW,'MLW \rightarrow');
set(th2,'fontsize',8,'fontweight','bold','HorizontalAlignment','right','VerticalAlignment','middle');

% plot over that a vertical line at CoastlinePosition
YLim        = get(gca,'YLim');
ph3         = plot([xMKL xMKL],[min(YLim) max(YLim)],'-.r','linewidth',1);

% plot MCL text
th3         = text(xMKL,min(YLim)+0.05*(max(YLim) - min(YLim)),'X_{mkl} \rightarrow');
set(th3,'fontsize',8,'fontweight','bold','HorizontalAlignment','right','VerticalAlignment','middle');

% set labels and title
xlabel('Cross shore distance [m]');
ylabel('Elevation [m to datum]', 'Rotation', 270, 'VerticalAlignment', 'top');
title(['MKL for targetyear ',num2str(transect.year),' : ' num2str(xMKL, '%4.0f'), ' m to RSP-line'], 'fontsize', 9, 'fontweight','bold');
