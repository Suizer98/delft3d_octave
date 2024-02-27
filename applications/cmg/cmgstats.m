function cmgstats(x,dof)

%a function to compute the error bar, mean, standard deviation, maximum
% and minimum of a time-series.
% 
% cmgstats(x,[dof])
% 
% x = time-series, vector or matrix. if matrix, calculations are 
% 	performed along each column.
% dof = degree of freedom, optional. if omitted, users are asked to choose
% 	a value of autocorrelation scale to estimate the dof.
% 
% All output are printed in the command window.
% 
% jpx @ usgs, 01-03-01
% 
if nargin<1 help(mfilename);return;end;
	
[m,n]=size(x);
if m==1
	x=x(:);
end;
[m,n]=size(x);
x=cmgdataclean(x);

stats.max=max(x);
stats.min=min(x);
stats.mean=[];
stats.std=[];
for i=1:n
	indx=find(isnan(x(:,i))==0);
	stats.mean=[stats.mean mean(x(indx,i))];
	stats.std=[stats.std std(x(indx,i))];
end;
if nargin<2
	answer=1;
	if n>1
		answer=inputdlg('Which column to use for DOF estimate?',...
			'Your selection',1,{'1'});
		answer=str2num(char(answer));
		if answer<1 | answer>n
			errordlg('Input Bin number is out of range. Aborted!','Error');
			return;
		end;
	end;
	y=x(:,answer);
% 	indx=find(isnan(y)==0);
% 	y=y(indx);
	ngaps=cmgidgaps(y);
	if ngaps>0
		answer=questdlg([num2str(ngaps) ' gaps found, replace with the mean?'],'Warning','Yes','No','Yes');
		switch answer
		case 'No'
			return;
		case 'Yes'
			xx=isnan(y);
			dat2=y;
			jnan=find(xx==1);
			dat2(jnan)=[];
			dat2=mean(dat2);
			y(jnan)=dat2;
		end;
	end;
	[out1,out2]=xcorr(y-mean(y),'coeff');
	out1(1:length(y)-1)=[];
	out2(1:length(y)-1)=[];
	dum=find(out1<=0.1);
	if ~isempty(dum)
		if dum(1) < length(out1)-50
			dum=dum(1)+50;
		else
			dum=length(out1);
		end;
	else 
		dum=length(out1);
	end;
	
	figure(11);
	plot(out2(1:dum),out1(1:dum));
	ha(1)=text(5,0.9,'Pick an auto-correlation scale...');
	ha(2)=text(5,0.8,'Move the cross-hair to an appropriate point and then click.');
	ha(3)=text(5,0.7,'You *MUST* click in order to continue!');
	set(ha,'fontsize',15);
	set(ha(3),'color','red','fontsize',20);
	ok=0;
	while ~ok
		[xx,yy]=ginput(1);
		xx=round(abs(xx));
		def{1}=num2str(xx);
		def{2}=num2str(yy);
		answer=inputdlg('Is the selected autocorrelation scale value OK?',...
			'Your selection',1,def);
		ok=~isempty(answer);
	end;
	dof=round(length(y)/xx);
	close(11);
end;
stats.ebar=[];
for i=1:n
	indx=find(isnan(x(:,i))==0);
	stats.ebar=[stats.ebar std(x(indx,i))*mdsti(0.05,dof)/sqrt(dof+1)];
end;

fprintf('\n==== Statistics Report START================\n');
fprintf('      Degree of freedom:%5d\n',dof);
fprintf('%55s\n',' Bin#      MEAN  ERRORBAR      STDV       MAX       MIN');
for ijk=1:n
	fprintf('%5d%10.4f%10.4f%10.4f%10.4f%10.4f\n',...
		ijk,stats.mean(ijk),stats.ebar(ijk),stats.std(ijk),...
		stats.max(ijk),stats.min(ijk));
end;
fprintf('==== Statistics Report END==================\n');