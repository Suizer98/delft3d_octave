function varargout =cmgidgaps(dat,maxgaps)

%function to identify the endpoints of gaps in the series
% 
% [ngaps,nfirstbad,nlastbad,lgap]=cmgidgaps(dat,maxgaps)
% 
% dat = input data series. if dat is a matrix, gap search is performed
% 		column by column.
% maxgaps = max number of gaps to be filled, optional (default = 1000)
% ngaps = the number of gaps to fill (excludes gaps that
% 	can't be filled because they go to the end of the file)
% nfirstbad,nlastbad,lgap = integer arrays containing the
% 	point#s for the first bad point of each gap and the last
% 	bad point, and the length of each gap
% 
% adapted from a fortran program bridge.f by jpx on 7-12-99
% modified on 12-14-00
% 
if nargin<1 help(mfilename); return; end;

[m,n]=size(dat);

if nargin<2
	maxgaps=1000;
end;
m=length(dat);
dat=cmgdataclean(dat);

ngaps=0;
notfilled=0;
endgap=0;
lgap=0;
nfirstbad=nan;
nlastbad=nan;
mydata=find(isnan(dat)==1);

if isempty(mydata)
	fprintf('\nNo gap is found.\n');
else
	ngaps=ngaps+1;
	nfirstbad(ngaps)=mydata(1);
	nlastbad(ngaps)=mydata(1);
	tot=length(mydata);
	for j=2:tot
		if (mydata(j)-mydata(j-1) >1 | mod(mydata(j),m)==1) & j<=tot
			ngaps=ngaps+1;
			nfirstbad(ngaps)=mydata(j);
			nlastbad(ngaps)=mydata(j);
		else
			nlastbad(ngaps)=mydata(j);
		end;
	end;
	lgap=nlastbad-nfirstbad+1;
	[nrow1,ncol1]=ind2sub(size(dat),nfirstbad);
	[nrow2,ncol2]=ind2sub(size(dat),nlastbad);
	for k=1:ngaps
		if size(dat,2)>1
			fprintf('Gap# %d, %d:%d in column %d, length= %d\n',...
				k,nrow1(k),nrow2(k),ncol1(k),lgap(k));
		else
			fprintf('Gap# %d, %d:%d, length= %d\n',...
				k,nrow1(k),nrow2(k),lgap(k));
		end;	
	end;
end;
if nargout>0
	varargout(1)={ngaps};
end;
if nargout>1
	varargout(2)={nfirstbad};
end;
if nargout>2
	varargout(3)={nlastbad};
end;
if nargout>3
	varargout(4)={lgap};
end;
return;