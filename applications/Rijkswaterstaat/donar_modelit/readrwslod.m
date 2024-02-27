function locs = readrwslod(fname, locs)
% Scan or read rwslod data file using mex file
%
% CALL:
%  locs = readrwslod(fname)       (scan file)
%  locs = readrwslod(fname, locs) (read file)
%
% INPUT:
%  fname: String, name of rwslod file. If this is the only input argument,
%         the output argument will only contain the header data.
%  locs:  Struct array, this value must be equal to or a subset of the 
%         output of an earlier call to readrwslod. It tells the function 
%         which data to retrieve from file.
%
% OUTPUT:
%  locs: Struct array
%        If called with only filename (scanning mode), readrewslod will
%        only return the header fields. A struct array with the following
%        fields is returned:
%        +----longdate (double)
%        +----sLoccod (char array)
%        +----raailocatie (double array)
%        +----aantal (double)
%        +----marker (double)
%
%        If called with 2 argumenets (read mode) a more elaborate struct
%        array is returned:
%        +----longdate (double)
%        +----sLoccod (char array)
%        +----raailocatie (double array)
%        +----aantal (double)
%        +----marker (double)
%        +----xy (int32 array)
%        +----z (int32 array)
%        +----lBegdat (double)
%        +----iBegtyd (double)
%        +----lEnddat (double)
%        +----iEndtyd (double)
%
% EXAMPLE:
%      locs = readrwslod(fname);
%      data = readrwslod(fname,locs(2:2:end));
%
% See also: readqinsy

% revisions:
%     20100730 WIJZ ZIJPP: bug hersteld inlezen meervoudige raai

%
% AANPAK
%   Deze functie is geimplementeerd als mex file.
%   De file oufwrite_external.c bevat de corresponderende C-code
%
% COMPILEREN
%          OBSOLETE: mcc -xh  -d build readrwslod csource\readrwslodheader_external.c csource\readrwsloddata_external.c

% if nargin==0
%     locs=readrwslod('H:\morfdata\smallrwslod.txt');
%     %     locs=readrwslod('H:\morfdata\jarkus00schoog');
%     %   locs=readrwslod('H:\morfdata\amld02dgpsrw.txt',locs);
%     locs=1;
%     disp after
%     return
% end

if nargin<1
    error('Er dient een filenaam opgegeven te worden');
end
if nargin>2
    error('Teveel invoerargumenten');
end
if nargout>1
    error('Teveel uitvoerargumenten');
end
if ~exist(fname,'file')%WIJZ ZIJPP 20090320: remove exist_cmp
    eprintf('File %s bestaat niet',fname);
end

if nargin==1;
    %gebruik mex file
    %BOUWEN MEX FILE: mex readrwslodheader_external.c
    rawlocs=readrwslodheader_external(fname);
    if isempty(rawlocs)
        locs=[];
    else
        %interpreteer velden
        for k=1:length(rawlocs)
            %dsprintf('%d(%d)',k,length(rawlocs));
            %lees datum uit regel 1
            [dates] = sscanf(rawlocs(k).str1,'%d',3);
            locs(k).longdate=dates(1)+100*dates(2)+10000*getyear(dates(3),0);

            %lees raailocatie uit regel 6

            line=rawlocs(k).str6;
            [dummy,COUNT,ERRMSG,NEXTINDEX] = sscanf(line,'%d',1);
            [locs(k).sLoccod,COUNT,ERRMSG,NEXTINDEX] = sscanf(line(NEXTINDEX:end),'%s',1);

            raailocatie = sscanf(line(NEXTINDEX:end),'%f');
            raailocatie=raailocatie(:);
            locs(k).raailocatie=raailocatie(end-3:end);
            locs(k).aantal=rawlocs(k).aantal;
            locs(k).marker=rawlocs(k).marker;
        end
    end
end
if nargin==2;
    locs=readrwsloddata1(fname,locs);
end


% % function S=readrwslodheader(fname);
% % %#external
% % error('readrwslod.dll missing');

%__________________________________________________________________________
function locs=readrwsloddata1(fname,locs)

%Voorverwerking: lees ruwe data in
aantal=sum(cat(1,locs.aantal));

%gebruik mex file
%BOUWEN MEX FILE: mex readrwsloddata_external.c
[XX,YY,ZZ,DDvec]=readrwsloddata_external(fname,locs,aantal);

%Na verwerking
Begin=1;
for k=1:length(locs)
    Einde=locs(k).aantal+Begin-1;

    if length(XX)<Einde
        eprintf('File %s: EOF bereikt in data blok',fname);
    end

    locs(k).xy=[XX(Begin:Einde),YY(Begin:Einde)];
    locs(k).z=[ZZ(Begin:Einde)];

    datum=DDvec(Begin:Einde);
    [st_date,st_time]=interpjul(min(datum));
    [end_date,end_time]=interpjul(max(datum));

    locs(k).lBegdat=st_date;
    locs(k).iBegtyd=st_time;
    locs(k).lEnddat=end_date;
    locs(k).iEndtyd=end_time;
    %WIJZ ZIJPP 20100730
    % herstellen bug inlezen rwslod files met meerdere blokken
    % FOUT:    Einde=Einde+1;
    % GOED:
    Begin=Einde+1;
end

% % function [XX,YY,ZZ,DDvec]=readrwsloddata(fname,locs,aantal)
% % %#external
% % error('readrwslod.dll missing');

%__________________________________________________________________________
function [end_date,end_time]=interpjul(dd)
%reken Julian date om
dnew=datenum(1970,1,1,0,0,dd);
[y,m,d,h,mi,s] = datevec(dnew+1/2880); %voeg halve minuut toe en ron af naar beneden op minuten
end_date=d+100*m+10000*y;
end_time=mi+100*h;

