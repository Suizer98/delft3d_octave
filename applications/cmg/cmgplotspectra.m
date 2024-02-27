function [varargout]=cmgplotspectra(specStruct,varargin)
%A spectral plot function. REQUIRE spectral output from cmgspectra or cmgspecavg.
% 
% cmgplotspectra(specStruct,[options...])
% 
% specStruct = Structure array that at least contains these fields:
% 	.spec: auto- (size of M x 5) or cross- (size of M x 19) power spectra
% 	.freq: (M x 1) frequency in Hz
% 	.nfft: nfft used in computing the spectra
% options (need not to be in order): 
% 	one of the following plot types:
% 		'loglog' (default)
% 		'semilogx'
% 		'semilogy'
% 		'linear'
% 		'vp' (variance preserving)
% 	AND/OR
% 	one of the following plot contents:
% 		'auto': ploting two auto spectra
% 		'coquad': plotting co- and quad spectra
% 		'chph': plotting coherence and phase
% 		'rotary': plotting rotary spectra
% 		'combo': plotting auto-, rotary, coherence, and phase in one plot (default)
% 
% cmgplotspectra(specStruct,[ptype],[vari])
% 	
% jpx @ usgs, 01-05-01
% 
if nargin<1 
	help(mfilename);
	return;
elseif ~isstruct(specStruct)
	error([inputname(1) ' must be a structure array.'])
end;

% if nargin<2
% 	ptype='loglog';
% 	vari='combo';
% end;
% str1={'loglog','semilogx','smilogy','linear','vp'};
% str2={'auto','coquad','chph','rotary','combo'};
% if length(varargin)>1
% 	ptype=varargin{1};
% 	vari=varargin{2};
% elseif length(varargin)>0
% 	if any(strcmpi(varargin{1},str1))
% 		ptype=varargin{1};
% 		vari='combo';
% 	else
% 		ptype='loglog';
% 		vari=varargin{1};
% 	end;
% end;
% if isempty(ptype), ptype='loglog';end;
% if isempty(vari), vari='combo';end;
% if ~any(strcmpi(ptype,str1)) | ~any(strcmpi(vari,str2))
% 	help(mfilename);
% 	error('Check the spelling of the optional input arguments.');
% end;
param=paramparse(varargin);

varargout={param{2}};

myspec=specStruct.spec;
myfreq=specStruct.freq;
npieces=specStruct.npieces;
p=specStruct.conf;
nfft=specStruct.nfft;

o1cph=0.0387306544; % freq of O1 tide
m2cph=0.0805114007; % freq of M2 tide

nyqf=myfreq(end);

timeplt_figure(12,1,'anything');
xlab='Frequency, Hz';
ylab='PSD, ';

if size(myspec,2)==5  %auto-spectra
	bins=[];
	if size(myspec,3)>1
		bins=1:size(myspec,3);
		bins=inputdlg('Which bin(s) do you want to plot:',...
						'Input Bin Number',3,{['[' num2str(bins) ']']});
		if isempty(bins)
			close(12);
			return;
		end;
		bins=str2num(char(bins));
		myspec=myspec(:,:,bins);
	end;
	
	if size(myspec,3)>1   % spectra from ADCP
		myspec2(:,:)=myspec(:,1,:);
		myspec=myspec2;
		myspec=myspec*nfft/(2*nyqf); %Convert Power spectra to Power spectral density 
		if isequal(param{1},'vp')
			myspec=2.3*myspec.*(myfreq*ones(1,length(bins))); % for variance preserving plot
			ylab='2.3*Power (unit)^2';
		end;
		if max(myfreq)<0.025
			myfreq=myfreq*3600;
			xlab='Freqency, cph';
		end;
		[x,y]=meshgrid(myfreq,1:length(bins));
		waterfall(x,y,myspec');
		grid off;
		view(15,25);
		set(gca,'xscale','log','zscale','log','ylim',[1 length(bins)],...
			'ytick',1:1+floor(length(bins)/10):length(bins));
		if isequal(param{1},'vp')
			set(gca,'zscale','linear');
			view(25,45);
		end;
		dum=get(gca,'yticklabel');
		set(gca,'yticklabel',bins(str2num(dum)));
		xlabel(xlab);
		ylabel('Bin Number');
		zlabel(ylab);
		text(.7,.9,0.9,strrep(specStruct.name,'_','\_'),'units','normalized');
		myspec2=[];
	else
		myspec=myspec(:,1:3);
		tname=specStruct.name;
		
		doplot(myfreq,myspec,nfft,nyqf,param{1},tname,bins,xlab,ylab);
		
	end;

else  %cross-spectra
	tname=specStruct.name;
	[ss{1},ss{2}]=strtok(tname,', ');
	ss{2}=strtok(ss{2},', ');
	bins=[];
	switch param{2}
	case 'auto'
		ydata=real(myspec(:,[1 2 3 4]));
		doplot(myfreq,ydata,nfft,nyqf,param{1},' ',bins,xlab,ylab);
		legend(ss{1},ss{2});
		title(tname);
		
	case 'coquad'
		sss={' [Co]',' [Quad]'};
		for kk=1:2
			ydata=real(myspec(:,[kk+4 kk+4 kk+4]));
			subplot(1,2,kk);
			doplot(myfreq,ydata,nfft,nyqf,'semilogx',sss{kk},bins,xlab,ylab);
			title(tname);
			tickfix(gca);
		end;
	
	case 'chph'
		cols=[11 9];
		yls={'Phase, deg.','Coherence'};
		slevel={[],real(myspec(1,10))};
		for kk=1:2
			ydata=real(myspec(:,[cols(kk)*ones(3,1)]));
			subplot(2,1,kk);
			doplot(myfreq,ydata,2,1,'semilogx','',slevel{kk},xlab,yls{kk});
			if kk==1 
				set(gca,'ytick', -180:90:180,'ygrid','on'); 
			end;	
			title(tname);
		end;
	
	case 'rotary'
		ydata=real(myspec(:,[13 14 3 4]));
		doplot(myfreq,ydata,nfft,nyqf,param{1},' ',bins,xlab,ylab);
		legend('Clockwise','AntiClockwise');
		title(tname);
		
	case 'combo'	
		subplot(221);
		ydata=real(myspec(:,[1 2 3 4]));
		doplot(myfreq,ydata,nfft,nyqf,param{1},' ',bins,'',ylab);
		legend(ss{1},ss{2});
		title(tname);
		tickfix(gca);
		
		subplot(223);
		ydata=real(myspec(:,[13 14 3 4]));
		doplot(myfreq,ydata,nfft,nyqf,param{1},' ',bins,xlab,ylab);
		legend('Clockwise','AntiClockwise');
		title(tname);
		tickfix(gca);
		
		subplot(222);
		ydata=real(myspec(:,[11 11 11]));
		doplot(myfreq,ydata,2,1,'semilogx','',bins,'','Phase, deg.');
		set(gca,'ytick', -180:90:180,'ygrid','on');	
		title(tname);
		tickfix(gca);
		
		subplot(224)
		ydata=real(myspec(:,[9 9 9]));
		slevel=real(myspec(1,10));
		doplot(myfreq,ydata,2,1,'semilogx','',slevel,xlab,'Coherence');
		title(tname);
		tickfix(gca);
		
		xlab={' ',' ','Frequency, Hz','Frequency, Hz'};
		xlab2={' ',' ','Frequency, cph','Frequency, cph'};
		ylab={['PSD, '],'Phase, deg.',['PSD, '],'Coherence '};
		[s1,s2]=strtok(specStruct.name,', ');
		s2=strtok(s2,', ');
		tit={s1,s2,'Clockwise','AntiClock','Phase','Coherence'};
		
	end; % of switch
end;	
return;

function para=paramparse(cellin)
para={'loglog','combo'};

str(1).name={'loglog','semilogx','smilogy','linear','vp'};
str(2).name={'auto','coquad','chph','rotary','combo'};

n=length(cellin);
while n>0
	for i=1:length(str)
		if any(strcmpi(cellin{1},str(i).name))
			para{i}=cellin{1};
			break;
		end;
	end;
	cellin(1)=[];
	n=length(cellin);
end;
return;

function doplot(myfreq,myspec,nfft,nyqf,ptype,tname,bins,xlab,ylab)
o1cph=0.0387306544; % freq of O1 tide
m2cph=0.0805114007; % freq of M2 tide
[sm,sn]=size(myspec);
zz=min(real(min(myspec(:,1:sn-2))));
zz=log10(zz);
zz=fix(zz);
zz=10^zz;
if ~isequal(ptype,'loglog')
	myspec=[myspec(:,1:sn-2) nan*ones(sm,1) nan*ones(sm,1)];
else;
	myspec=[myspec(:,1:sn-2) zz.*myspec(:,sn-1) zz.*myspec(:,sn)];
end;
myspec=myspec*nfft/(2*nyqf); %Convert Power spectra to Power spectral density 

if isequal(ptype,'vp')
	myspec=2.3*myspec.*(myfreq*ones(1,sn)); % for variance preserving plot
	ylab='2.3*Power (unit)^2';
	ptype='semilogx';
elseif isequal(ptype,'linear')
	ptype='plot';
end;

if max(myfreq)<0.025  % plotting tide
	myfreq2=myfreq*3600;
	eval(['handles=' ptype '(myfreq2,myspec);']);
	xlabel('Frequency, cph');
	if max(myfreq)>2.77e-5
		set(gca,'xlim',[min(myfreq) max(myfreq)]*3600);
		hold on;
		ylimits=get(gca,'ylim');
		if isequal(ylab,'Coherence')
			ylimits=[0 1];
		end;
		eval(['lhand1=' ptype '([m2cph m2cph],ylimits,''k--'');']);
		eval(['lhand2=' ptype '([o1cph o1cph],ylimits,''k--'');']);
		hold off;
	else
		
	end;
else	
	myfreq2=myfreq;
	eval(['handles=' ptype '(myfreq,myspec);']);
	xlabel(xlab);
end;
if isequal(ylab,'Coherence')
	hold on; 
	semilogx(myfreq2([1 end]), bins*ones(2,1),'r--');
	bins=[];
	hold off;
	set(gca,'ylim',[0 1]);
end;	
set(handles(1:sn-2),'linewidth',1,'marker','s','markersize',2);
set(handles(2),'color','r');
set(handles(sn-1),'color','g','linewidth',0.5);
set(handles(sn),'color','g','linewidth',0.5);
ylabel(ylab);
text(.7,.9,[strrep(tname,'_','\_') num2str(bins)],'units','normalized');

return

function tickfix(hands)
lowhi=get(hands,'xlim');
lowhi=log10(lowhi);
lowhi=[floor(lowhi(1)) ceil(lowhi(2))];

set(hands,'xtick',10.^(min(lowhi):max(lowhi)));

return;