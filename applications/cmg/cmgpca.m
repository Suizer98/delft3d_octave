function cmgpca(u,v,onoff)
 
%a function for principal component analysis.
% 
% cmgpca(u,v,[onoff]);
% 
% u, v = vectors of the two components of, e.g. currents.
% onoff = flag determine if data points are plotted (=1) or not (=0, default)
% 
% jpx @ usgs, 01-04-01
% 
if nargin<1
	help(mfilename);
	return;
elseif nargin<2
	fprintf('\nAt least two input arguments are needed.\n');
	return;
elseif nargin<3
	onoff=0;
end;
if any(size(u)-size(v))
	fprintf('\nSizes of the first two arguments must agree.\n');
elseif size(u,2)>1
	fprintf('\nThe first two arguments cannot be matrices.\n');
end;
timeplt_figure(12,1,'anything');
indx=find(isnan(u)==0);u=u(indx);v=v(indx);
indx=find(isnan(v)==0);u=u(indx);v=v(indx);

mu=mean(u);mv=mean(v);
covar=cov(u,v);
[eigvec,eigval]=eig(covar);

[spd,direc]=cmguv2spd(mu,mv);

if eigval(2,2)>eigval(1,1)
	cols=[2 1];
else
	cols=[1 2];
end;
majr=sqrt(eigval(cols(1),cols(1)));
[junk,majaz]=cmguv2spd(eigvec(1,cols(1)),eigvec(2,cols(1)));

minr=sqrt(eigval(cols(2),cols(2)));
[junk,minaz]=cmguv2spd(eigvec(1,cols(2)),eigvec(2,cols(2)));

set(gcf,'units','norm');

hh2(1)=subplot(212);
set(hh2(1),'position',[.1 .05 .8 .19]);

hh2(2)=text(.2,.8,['Speed= ' num2str(spd) ';  Direction= ' num2str(direc) ] );
set(hh2(2),'color','b');

hh2(3)=text(.2,.5,['Major axis: Magnitude= ' num2str(majr*2) ';  Azimuth= ' num2str(majaz) ] );
set(hh2(3),'color','r');
hh2(4)=text(.2,.2,['Minor axis: Magnitude= ' num2str(minr*2) ';  Azimuth= ' num2str(minaz) ] );
set(hh2(4),'color','r');
axis off;

hand=subplot(211);
if onoff
	ticks=ceil(length(u)/5000);
	plot(u(1:ticks:end),v(1:ticks:end),'.g','markersize',1)
end;
hold on;
set(hand,'position',[.1 .35 .8 .6]);

[x1,y1]=cmgspd2uv(majr,majaz);
[x2,y2]=cmgspd2uv(minr,minaz);

hh1=plot([x1 -x1],[y1 -y1],'-r',[x2 -x2],[y2 -y2],'-r','linewidth',2);

theta=2*pi*(1:64)/64;
theta=[0 theta];
xx=majr*cos(theta);
yy=minr*sin(theta);
angle=-majaz*pi/180+pi/2;
xxx=xx*cos(angle)-yy*sin(angle);
yyy=xx*sin(angle)+yy*cos(angle);
hh1(3)=plot(xxx,yyy,'r');


axis('square');

if onoff>0
	s=min([max(abs(u)),max(abs(v))]);
	s=ceil(0.75*s/10)*10;
else
	s=ceil(max([max([x1,y1,x2,y2]),mu,mv])/10)*10;
end;
axis([-s s -s s])

hh1(4)=plot([0; mu],[0; mv],'-b','linewidth',1);

xlabel(strrep(inputname(1),'_','\_'));
ylabel(strrep(inputname(2),'_','\_'));

box on;
hold off;

return;