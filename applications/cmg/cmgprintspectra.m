function cmgprintspectra(specStruct,varargin)

%Print spectra to a file. REQUIRE spectral output from cmgspectra or cmgspecavg.
% 
% cmgprintspectra(specStruct,[ptype],[frange])
% 
% specStruct = Structure array that at least contains these fields:
% 	.spec: auto- (size of M x 5) or cross- (size of M x 19) power spectra
% 	.freq: (M x 1) frequency in Hz
% 	.nfft: nfft used in computing the spectra
% 	.npieces: number of pieces 
% 	.conf: confidence level
% 	.name:
% ptype = one of two choices (optional):
% 	'chph': print auto- and cross- spectral properties (default)
% 	'rotary': print auto- and rotary spectral properties
% frange: =[low high], 2 elements define the range of period (in hours) that
% 	is interested in printing.
% 	
% jpx @ usgs, 01-12-01
% 
if nargin<1 
	help(mfilename);
	return;
elseif ~isstruct(specStruct)
	error([inputname(1) ' must be a structure array.'])
end;

if nargin<2
	ptype='chph';
	frange=[];
end;
if length(varargin)>1
	if ischar(varargin{1})
		ptype=varargin{1};
		frange=varargin{2};
	else
		ptype=varargin{2};
		frange=varargin{1};
	end;
elseif length(varargin)>0
	if ischar(varargin{1})
		ptype=varargin{1};
		frange=[];
	else
		ptype='chph';
		frange=varargin{1};
	end;
end;
str1={'chph','rotary'};
if ~any(strcmpi(ptype,str1)) | (length(frange)~=2 & ~isempty(frange))
	help(mfilename);
	error('Check the optional input arguments.');
end;

myspec=specStruct.spec;
myfreq=specStruct.freq;
npieces=specStruct.npieces;
p=specStruct.conf;
nfft=specStruct.nfft;
tname=specStruct.name;
pd=myspec(:,end); % period in hours
if isempty(frange)
	frange=pd([end 1]);
elseif frange(1)< pd(end) | frange(end)>pd(1)
	error('Check the frange input.');
else
	indx=find(pd>=frange(1) & pd<=frange(2));
	myspec=myspec(indx,:);
end;

[ss{1},ss{2}]=strtok(tname,', ');
ss{2}=strtok(ss{2},', ');
[m,n]=size(myspec);
if n==19
	fname=[inputname(1) '_' epicremover(ss{1}) '_' epicremover(ss{2}) '.spectra'];
	if strcmpi(ptype,'chph')
		specprint=myspec(:,[1:12,18,19]);
		myformat=['%4.3E\t\t%6.3E\t\t%2.2f\t\t%3.2f\t\t%+6.3E\t\t%+6.3E\t\t%6.3E\t\t%6.3E\t\t',...
			'%2.2f\t\t%2.2f\t\t%+04.0f\t\t%4.1f\t\t%2.0f\t\t%7.4f']; 
	else
		specprint=myspec(:,[1:6,13:19]);
		myformat=['%4.3E\t\t%6.3E\t\t%2.2f\t\t%3.2f\t\t%+6.3E\t\t%+6.3E\t\t%6.3E\t\t%6.3E\t\t',...
			'%+2.2f\t\t%+04.0f\t\t%2.2f\t\t%2.0f\t\t%7.4f']; 
	end;
else
	specprint=myspec;
	myformat=['%4.3E\t\t%2.2f\t\t%3.2f\t\t%2.0f\t\t%7.4f']; 
	fname=[inputname(1) '_' epicremover(ss{1}) '.spectra'];
end;

fid=fopen(fname,'w');

fprintf(fid,['\t\t\t\t\t\t\t\t','AUTO- and CROSS-SPECTRAL COMPUTATION\n\n']);
fprintf(fid,'\t\t\t\t\t\t\t\tA1 = %s,\t%s\n', ss{1},inputname(1));
if n==19 fprintf(fid,'\t\t\t\t\t\t\t\tA2 = %s,\t%s\n', ss{2},inputname(1)); end;
fprintf(fid,'\tCONFIDENCE LEVEL = %2d\t\t\t\t\tBASIC BAND WIDTH = \n',p*100);
fprintf(fid,'\tNUMBER OF PIECES = %4d\t\t\t\t\tBASIC DEGREES OF FREEDOM = \n',npieces);
fprintf(fid,'\tSTART TIME = \t\t\t\t\t\t\tEND TIME = \n');
if n==19 fprintf(fid,'\tA POSITIVE PHASE AT A GIVEN FREQUENCY INDICATES THAT A2 LEADS A1 AT THAT FREQUENCY.\n\n');end;
if n==19
	if strcmpi(ptype,'chph')
	fprintf(fid,'\tAUTOSPECTRUM\t\tCONFIDENCE\t\tCROSS-SPECTRUM\t\t\tTRANSFER FUNCTION');
	fprintf(fid,'\t\tCOHERENCE\t\tPHASE\t\t # FREQ.  PERIOD\n');
	fprintf(fid,' A1           A2        MIN     MAX     CO-         QUAD-       EST.        C.I.');
	fprintf(fid,'       EST.  SIG.LEV    EST.   (+-)  IN BAND  HOURS\n\n');
	else
	fprintf(fid,'\tAUTOSPECTRUM\t\tCONFIDENCE\t\tCROSS-SPECTRUM\t\t\tCLOCK\t\tACLOCK');
	fprintf(fid,'\t\tROTARY\tELLIP\tELLIP # FREQ. PERIOD\n');
	fprintf(fid,' A1           A2        MIN     MAX     CO-         QUAD-');
	fprintf(fid,'       SPEC        SPEC        COEF    ORIENT  STAB  IN BAND  HOURS\n\n');
	end;
else
	fprintf(fid,'AUTOSPEC\tCONFIDENCE\t # FREQ.  PERIOD\n');
	fprintf(fid,' A1         MIN     MAX  IN BAND  HOURS\n\n');
end;

myformat=strrep(myformat,'\t\t','\t');
fprintf(fid,[myformat '\n'],specprint');
fclose(fid);

edit(fname);
return;
	
function noepic=epicremover(withepic)
% to remove the epic code from the new variables

noepic=withepic;
if isempty(withepic)
	return;
end;
indx=findstr(withepic,'_');
if ~isempty(indx)
	if length(indx)>1
		subj=withepic(indx(1)+1 : indx(2) -1);
	else
		subj=withepic(indx(1)+1 : end);
	end;
	if ~isempty(str2num(subj)) & isreal(str2num(subj))
		noepic=[withepic(1: indx(1)-1) withepic(indx(1)+2+length(subj) : end)];
	end;
else
	noepic=withepic;
end;
if strcmp(noepic(end),'\')
	noepic(end)=[];
end;
return;
