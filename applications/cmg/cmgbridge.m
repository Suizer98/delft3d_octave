function [dat,varargout]=cmgbridge(dat,nlin,nmaxbr,maxngaps);

%Program to fill gaps in time-series files using Joseph's 
% scheme( a spectral method) after filling short gaps with
% a linear fit from neighbors' values.
% 
% [dat,[nogap]]=cmgbridge(dat,nlin,nmaxbr,maxngaps)
% 
% 	dat = data to be bridged. if matrix, bridgeing performed on each column;
%	nogap = 0 if gaps found, 1 if no gaps, optional;
% 	nlin = max gap length to be filled linearly, optional (default =2)
% 	nmaxtbr = max gap length to be filled spectrally, optional (default = 48)
% 	maxngaps = max number of gaps to be filled, optional (default = 1000)
% 	
% Adapted from a Fortran program by jpx on 7-15-99
% modified on 12-14-00
% 
if nargin<4
	maxngaps=1000;
end;
if nargin<3
	nmaxbr=48;
end;
if nargin<2
	nlin=2;
end;
if nargin<1 help(mfilename); return; end;
	
nogap=[];
dat=dat;
% fprintf('\nMax. gap length to fill linearly: %2d ;',nlin);
% fprintf('\nMax. gap length to fill spectrally: %2d ;',nmaxbr);
% fprintf('\nMax. gaps to fill: %5d ;\n',maxngaps);

if size(dat,1)==1
	dat=dat(:);
end;
[m,n]=size(dat);

for i=1:n
	if n>1
		fprintf('\nColumn #%d\n',i);
	end;
	endgap=0;
	notfilled=0;
	thisdata=dat(:,i);
	[ngaps,nfirstbad,nlastbad,lgap]=cmgidgaps(thisdata,maxngaps);
	
	if ngaps<1
		nogap=[nogap 1];
	else
		if nlastbad(ngaps)>=m
			notfilled=notfilled+1;
			endgap=1;
			fprintf('\nFinal gap extends from %d to end of file therefore can not be filled.\n',...
				nfirstbad(ngaps));
		end;
		if ngaps>maxngaps
			notfilled=notfilled+1;
			fprintf('\nThe data has more than %d gaps. Only first %d gaps are bridged.\n',...
				maxngaps,maxngaps);
			ngaps=maxgaps
		end;
		
		redflag=1;
		for j=1:ngaps
			if ~(endgap & j==ngaps)
				if lgap(j)<=nlin
					[nfirstbad(j),nlastbad(j),thisdata]=...
						dolinbridge(nfirstbad(j),nlastbad(j),thisdata);
				end;
			end;
		end;
	
		[ngaps2,nfirstbad,nlastbad,lgap]=doreseq(ngaps,nfirstbad,nlastbad,lgap);
		if ngaps2<ngaps
			redflag=[redflag 0];
		end;
		ngaps=ngaps2;
		for j=1:ngaps
			if ~(endgap & j==ngaps)
				[nbefore,nafter,notfilled,nflag(j)]=...
					dogoodpts(j,m,nmaxbr,ngaps,nfirstbad,nlastbad,lgap,notfilled);
				
				if nflag(j)<1
					redflag=[redflag 0];
					thisdata=dobridgeit(nfirstbad(j),nlastbad(j),lgap(j),nbefore,nafter,thisdata);
				end;
			end;
		end;
		dat(:,i)=thisdata;
		nogap=[nogap all(redflag)];
	end; % if ngaps<1
end;
if nargout>1
	varargout(1)={nogap};
end;
return;					

function [newn1,newn2,newdat]=dolinbridge(n1,n2,dat)
% function to linearly fill in short gaps in data 
% using the NEIGHBORING good points

newdat=dat;
if n1==1
	fprintf('Gap cannot be filled: the first point is a NaN.\n');
	newn1=-99;
	newn2=-99;
	return;
end;
if n2==length(dat)
	fprintf('Gap cannot be filled: the last point is a NaN.\n');
	newn1=-99;
	newn2=-99;
	return;
end;
ng1=n1-1;
ng2=n2+1;
den=ng2-ng1;
npt=1;
for n=n1:n2
	fact=npt/den;
	newdat(n)=dat(ng1)+fact*(dat(ng2)-dat(ng1));
	npt=npt+1;
end;
fprintf('Short gap from %d to %d is linearly filled\n',n1,n2);

% c	SET n1 and n2 to -99 to mark that gaps filled
newn1=-99;
newn2=-99;

return


function [ngaps,nfirstbad,nlastbad,lgap]=doreseq(ngaps,nfirstbad,nlastbad,lgap);

% function to eliminate linearly-filled gaps from the list of gaps
% START at end of record and work back to first gap that has
% NOT been linearly filled (dolinbridge changed endpoints of
% filled gaps to -99)
% 
indx=find(nfirstbad<0);
ngaps=ngaps-length(indx);
lgap(indx)=[];
nfirstbad(indx)=[];
nlastbad(indx)=[];

return

function [nbefore,nafter,notfilled,nflag]=dogoodpts(igap,npts,nmaxbr,ngaps,nfirstbad,nlastbad,lgap,notfilled);

% c	Subroutine to look at the length of a data gap and number of 
% c	good points before and after a data gap to be filled spectrally.  
% c	Previously-filled gaps are not good points unless you take a
% c	second trip through the program.
% c	Subroutine writes message and sets nflag to 1 if it refuses to
% c	fill the gap because gap is too long, or to 10 if the lengths of
% c	the good points on either end of the gap is too short.
% c
% c	IMPORTS:
% c		igap: gap number
% c		npts: number of points in series
% c		nmaxbr: max # points to bridge
% c		nfirstbad,nlastbad,lgap: arrays of 1st & last points and lengths of gaps
% c		ngaps: the number of gaps in the file
% 
% c	IMPORTS/EXPORTS
% c		notfilled: the # gaps program refuses to fill
% c	EXPORTS:
% c		nflag: a don't-fill flag: 0=fill 1=gap too long 10=too few good points

nflag=0;
if lgap(igap)>nmaxbr
	nflag=1;
	notfilled=notfilled+1;
	nbefore=-999;
	nafter=-999;
	fprintf('Gap is too long to bridge: %d points.\n',lgap(igap));
	return;
end;

if igap==1
	nbefore=nfirstbad(igap)-1;
else
	nbefore=nfirstbad(igap)-nlastbad(igap-1)-1;
end;
if igap==ngaps
	nafter=npts-nlastbad(igap)-1;
else
	nafter=nfirstbad(igap+1)-nlastbad(igap)-1;
end;
if nbefore<100 & nbefore<2*lgap(igap)
	nflag=10;
	notfilled=notfilled+1;
	fprintf('Gap is not bridged: too few points before gap.\n');
	return;
end;
if nafter<100 & nafter<2*lgap(igap)
	nflag=10;
	notfilled=notfilled+1;
	fprintf('Gap is not bridged: too few points after gap.\n');
	return;
end;

return;


function dat=dobridgeit(nfirstbad,nlastbad,lgap,nbefore,nafter,dat)

% Modified from a FORTRAN program by jpx on 7-15-99

% c	SET up parameters for bridge
lxtnd=round(0.75*lgap);
if lxtnd<=0
	lxtnd=1;
elseif lgap==2
	lxtnd=-2;
end;

% c	CALL bridge with points before gap
nbefore=min(nbefore,200);
istart=nfirstbad-nbefore;
nb2=floor(nbefore/2);
ii=1;
dat=dobridge(dat,istart,nbefore,nb2,lxtnd,ii);

% c	CALL bridge with points after gap
istart=nlastbad+1;
nafter=min(nafter,200);
na2=floor(nafter/2);
ii=2;
dat=dobridge(dat,istart,nafter,na2,lxtnd,ii);

return

function x=dobridge(x,istart,m,mm,lx,ii)

% Identical to Joseph's UVTBR2

% Modified from a FORTRAN program by jpx on 7-15-99
global g;
lxtnd=abs(lx);

[g,p]=peflt(x,istart,m,mm);

switch ii
case 1
	g=g(:);
	g=flipud(g);
	jstart=istart+m;
	jend=jstart+lxtnd-1;
	k=jstart-mm;
	for j=jstart:jend
		dotprd=sum(x(k:k+mm-1).*g(1:mm));
		x(j)=dotprd;
		k=k+1;
	end;
case 2
	g=g(:);
	jstart=istart-1;
	jend=jstart-lxtnd+1;
	iflag=0;
	k=0;
	frac=0;
	jsave=0;
	for j=jstart:-1:jend
		k=k+1;
		dotprd=sum(x(j+1:j+mm).*g(1:mm));
		if ~isnan(x(j))
			if iflag==0
				iflag=1;
				jsave=j;
				if  lx<0
					dfrac=.333333333;
				else
					if lxtnd==1
						dfract=.5;
					else
						dfrac=1/(lxtnd-k+1);
					end;
				end;
			else
				frac=frac+dfrac;
			end;
			scrtch(k)=frac*x(j)+(1-frac)*dotprd;
		end;
		x(j)=dotprd;
	end;
	if jsave~=0
		k=jstart-jsave;
		for j=jsave:-1:jend
			k=k+1;
			x(j)=scrtch(k);
		end;
	end;
end;
				
return;	

function [g,p]=peflt(x,istart,n,mmax);

% C	BOTTERO'S SUBROUTINE BASED ON ANDERSON'S EQUATIONS IN
% C	VOL 39 NO 1 OF Geophysics 1974, p69-72.

% Modified from a FORTRAN program by jpx on 7-15-99

iend=istart+n-1;
sum1=sum(x(istart:iend).^2);
p=sum1/n;

m=1;
nmm=n-m;
b(1:nmm)=x(istart:istart+nmm-1);
bp(1:nmm)=x(istart+1:istart+nmm);

while m<=mmax
	if m>1
		nmm=n-m;
		for i=1:nmm
			b(i)=b(i)-aold(m-1)*bp(i);
			bp(i)=bp(i+1)-aold(m-1)*b(i+1);
		end;
	end;
	
	sum1=sum(b(1:nmm).*bp(1:nmm));
	sum2=sum(b(1:nmm).^2 + bp(1:nmm).^2);
	if sum2~=0
		a(m)=2*sum1/sum2;
	else
		a(m)=0;
	end;
	p=p*(1-a(m)^2);
	if m>1
		mm1=m-1;
		for k=1:mm1
			mmk=m-k;
			a(k)=aold(k)-a(m)*aold(mmk);
		end;
	end;
	aold(1:m)=a(1:m);
	
	m=m+1;
end;

g=a;

return;