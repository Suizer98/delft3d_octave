% usage: changeCaxis(n12,act);
%        change
%        n12 - 1/2 lower/upper limit
%        act   '+'/'-' increase/descrease 
function []=changeCaxis(n12,act,cb);
CBpos=get(cb,'position');xl=get(cb,'xlim');
cax=caxis;
dcax=(cax(2)-cax(1))/50;
if act=='-',
 cax(n12)=floor((cax(n12)-dcax)*100)/100;
else
 cax(n12)=ceil((cax(n12)+dcax)*100)/100;
end
caxis(cax);reset(cb);
set(cb,'box','on','position',CBpos,'yaxislocation','right',...
    'FontWeight','bold','XLim',xl,'Ylim',cax,'xtick',[],'Layer','top');
return
