function plotXB1D(fig,xdata,tdata,zdata,names,ylimin)

figure(fig);hold on;

nvar=size(zdata);
if length(nvar)==4
    nvar=nvar(4);
else
    nvar=1;
end

cols=['k','r','g','b','m','k','r','g','b','m','k','r','g','b','m','k','r','g','b','m' 'k','r','g','b','m','k','r','g','b','m','k','r','g','b','m','k','r','g','b','m'];

for i=1:nvar
    eval(['p' num2str(i) '=plot(xdata,squeeze(zdata(:,:,1,i)),cols(i));']);
end
yl=ylim;
if exist('ylimin','var')
    if strcmpi('ylimin','fixed')
        ylim(yl);
    else

        yl=ylimin;
        ylim(yl);
    end
end

l=legend(names,'location','eastoutside');
t1=title([num2str(tdata(1)) ' s'])';

for i=1:length(tdata)
    for ii=1:nvar
        eval(['set(p' num2str(ii) ',''ydata'',squeeze(zdata(:,:,i,ii)));']);
    end
    set(t1,'string',[num2str(tdata(i)) ' s']);
    pause(.5)
end



