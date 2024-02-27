function locs = readqinsy(fname, locs)
% Read or scan Qinsy datafile using mex-file
% 
% CALL:
%  locs = readqinsy(fname)          (scan file)
%  locs = readqinsy(fname, locs)    (read file)
%   
% INPUT:
%  fname: String, name of quinsy file. If this is the only input argument, 
%         the output argument will only contain the header data.
%  locs:  Struct array, this value must be equal to or a subset of the 
%         output of an earlier call to readqinsy. It tells the function 
%         which data to retrieve from file. 
%   
% OUTPUT:
%  locs:  Struct array with 1 record per location:
%         +----sLoccod (char array)
%         +----marker (double)
%         +----aantal (double)
%         +----lBegdat (double)
%         +----iBegtyd (double)
%         +----lEnddat (double)
%         +----iEndtyd (double)
%         +----xy (double)
%         +----z (double)
%         
%         If "readqinsy" was called with 1 argument only the header data
%         will be nonempty (sLoccod, marker and aantal). 
% 
%         If called with 2 input arguments also the remaining (data) fields
%         are returned nonempty.  
% 
% EXAMPLE:
%  locs = readqinsy(fname);
%  data = readqinsy(fname,locs(2:2:end));
% 
% See also: readrwslod

%   
% APPROACH:
%   Deze functie is geimplementeerd als mex file.
%   De file oufwrite_external.c bevat de corresponderende C-code
%   
% COMPILEREN
%          mcc -xh -d build readqinsy csource\readqinsyheader_external.c csource\readqinsydata_external.c
% 
if nargin==0
    %test mode
    s=readqinsy('c:\d\modelit\Ma\RIKZraaidata\20060922\amela56_2006_rikz_ascii.txt');
    disp ('fase 1 done');
    %   locs=readqinsy('H:\morfdata\amld02dgpsrw.txt',s);
    return
end
 
% if nargin<1
%     error('Er dient een filenaam opgegeven te worden');
% end
if nargin>2
    error('Teveel invoerargumenten');
end
if nargout>1
    error('Teveel uitvoerargumenten');
end
if ~exist(fname,'file')
    eprintf('File %s bestaat niet',fname);
end
if nargin==1;
    %gebruik mex file
    %BOUWEN MET: mex readqinsyheader_external.c 
    locs=readqinsyheader_external(fname);
    if isempty(locs)
        %WIJZ ZIJPP20090527
        waitfor(warndlg(sprintf('Geen geldige locaties gevonden in file %s',fname),...
            'Geen locaties gevonden','modal'));
    end
    %deblank locatiecodes
    for k=1:length(locs)
        locs(k).sLoccod=deblank(locs(k).sLoccod);
    end
end
if nargin==2;
    locs=readqinsydata1(fname,locs);
end

%__________________________________________________________________________
function fulldate=xpand(smalldate,opt)
% INPUT
%     smalldate: YYMMDD or YYYYMMDD
%     
% OUTPUT    
%     fulldate: YYYYMMDD

%Extract MMDD    
MMDD=rem(smalldate,10000);

%Extract YY    
YY=floor(smalldate/10000);
%YY is a vector with YYYY or YY

%append century (if applicable)
YYYY=getyear(YY,opt); 

fulldate=10000*YYYY+MMDD;

%__________________________________________________________________________
function locs=readqinsydata1(fname,locs)
%Voorverwerking: lees ruwe data in
aantal=sum(cat(1,locs.aantal));
%gebruik mex file
%BOUWEN MET:  mex readqinsydata_external.c
[XX,YY,ZZ,DDvec,TTvec]=readqinsydata_external(fname,locs,aantal);

%WIJZ ZIJPP 20100611: alle datums expanderen en daarna pas max en min
%bepalen. Anders kan max < min na xpand
DDvec=xpand(DDvec,1);

%Naverwerking: interpreteer data
Begin=1;
for k=1:length(locs)
    Einde=locs(k).aantal+Begin-1;
    locs(k).xy=[XX(Begin:Einde),YY(Begin:Einde)];
    locs(k).z= ZZ(Begin:Einde);
    
    tmpdate=10000*double(DDvec(Begin:Einde))+double(TTvec(Begin:Einde));
    
    [dummy,fmin]=min(tmpdate);
    locs(k).lBegdat=double(DDvec(fmin));
    locs(k).iBegtyd=double(TTvec(fmin));
    
    [dummy,fmax]=max(tmpdate);
    locs(k).lEnddat=double(DDvec(fmax));
    locs(k).iEndtyd=double(TTvec(fmax));
end


% function [XX,YY,ZZ,DDvec,TTvec]=readqinsydata(fname,locs,aantal);
% %#external
% error('readqinsy.dll missing');
% 
% function locs=readqinsyheader(fname);
% %#external
% error('readqinsy.dll missing');


% % 		function locs=readqinsyheader(fname)
% % 		locs=load_cmp('qinsydat.mat','locs');
% % 		
% % 		function locs=readqinsydata1(fname,sellocs)
% % 		locstrs=strvcat(sellocs.sLoccod);
% % 		locs=load_cmp('qinsydat.mat','locs');
% % 		allstrs=strvcat(locs.sLoccod);
% % 		f=str_is_in(locstrs,allstrs);
% % 		locs=locs(f);
