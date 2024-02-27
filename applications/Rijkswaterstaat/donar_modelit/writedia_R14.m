function rc = writedia_R14(S, fname)
% Write DIA structure to file.
% 
% CALL:
%  rc = writedia_R14(S, fname)
% 
% INPUT:
%  S: Dia structure to save, fields:
%     +----IDT
%     |    +----sFiltyp (char)
%     |    +----sSyscod (char)
%     |    +----lCredat (double)
%     |    +----sCmtrgl (char)
%     +----blok
%     +----W3H (struct): see emptyW3H
%     +----MUX (struct): empty, see emptyMUX
%     +----TYP (struct): empty
%     +----RGH (struct): empty, see emptyRGH
%     +----RKS (struct): see emptyRKS
%     +----TPS (struct): empty, see emptyTPS
%     +----WRD (struct): see emptyWRD
%  fname: String with the name of the file to create.
%        
% OUTPUT:
%  rc: Integer returncode:
%      rc == 0 operation successful.
%      rc ~= 0 error, rc contains the DIM errorcode.
%        
% See also: readdia_R14, verifyDia

if nargin~=2
    dispmanpage;
    error('Het aantal invoerargumenten moet gelijk aan twee zijn');
end
if nargout>1
    dispmanpage;
    error('Er is ten hoogste 1 uitvoerargument toegestaan');
end
if isempty(S)
    return;
end
%WIJZ ZIJPP 20100610: add check on RKS record to prevent writing data that
%can not be read
rc=checkData(S);
if rc<0
    return
end
IDT=make_IDT(S.IDT);
fname=extensie(fname,'dia');
rc=writedia_mex(S,fname,IDT);
%__________________________________________________________________________
function rc=checkData(S)
for k=1:length(S.blok)
    rc=checkRKS(S.blok(k).RKS);
    if rc<0
        warning('Data corrupt of inconsistent in blok %d (Locatiecode=%s)',k,S.blok(k).W3H.sLoccod);
        return
    end
end
rc=0;
%__________________________________________________________________________
function ok=isvalidDate(t)
%check if date is of format YYYYMMDD
ok=false;
yyyy=floor(t/10000);
if yyyy<1500 || yyyy>2300
    return
end
mmdd=rem(t,10000);
mm=floor(mmdd/100);
dd=rem(mmdd,100);
str2=datestr(datenum(yyyy,mm,dd),'yyyymmdd');
str1=sprintf('%d',t);
if ~strcmp(str1,str2)
    return
end
ok=true;    
%__________________________________________________________________________
function ok=isvalidTime(t)
%check if time is of format HHMM
ok=false;
hh=floor(t/100);
if hh<0 || hh>23
    return
end
mm=rem(t,100);
if mm<0|| mm>59
    return
end
ok=true;
%__________________________________________________________________________
function S=make_IDT(IDT)
% INPUT
%     IDT: identificatie structure
%          voorbeeld:
%             sFiltyp: 'A'
%             sSyscod: 'CENT'
%             lCredat: 20000728
%             sCmtrgl: [5x0 char]
% OUTPUT
%     S: structure die zich zonder verdere analyse laat wegschrijven vanui
%     MEX file

S.sFiltyp=IDT.sFiltyp;
S.sSyscod=IDT.sSyscod;
S.lCredat=IDT.lCredat;
S.sCmtrgl0='';
S.sCmtrgl1='';
S.sCmtrgl2='';
S.sCmtrgl3='';
S.sCmtrgl4='';
IDT.sCmtrgl(:,61:end)=[]; %voorkom core dump bij foute commentaar regel
for row=1:size(IDT.sCmtrgl)
    switch row
        case 1
            S.sCmtrgl0=deblank(IDT.sCmtrgl(row,:));
        case 2
            S.sCmtrgl1=deblank(IDT.sCmtrgl(row,:));
        case 3
            S.sCmtrgl2=deblank(IDT.sCmtrgl(row,:));
        case 4
            S.sCmtrgl3=deblank(IDT.sCmtrgl(row,:));
        case 5
            S.sCmtrgl4=deblank(IDT.sCmtrgl(row,:));
    end
end
%__________________________________________________________________________
function     dispmanpage;
disp(strvcat(' ','Writedia, Versie 3, November 2002',' ',...
    '			writedia - schrijf DIA structure weg naar file',...
    '	',...
    '			CALL',...
    '             rc=writedia(S,fname)',...
    '			',...
    '			INPUT',...
    '             S    :  weg te schrijven DIA structure',...
    '             fname: (optioneel)naam van weg te schijven DIA file',...
    '    ',...
    '			OUTPUT',...
    '             rc   : returncode',...
    '                    rc=0 als functie succesvol is beeindigd',...
    '                    rc~=0 als er iets fout is gegaan, in dit geval bevat rc de DIM foutcode',...
    '                   ',...
    '			ZIE OOK',...
    '             DIAWRITE, DIAREAD, READDIA',...
    ' ',...
    'Er is een fout opgetreden:'));

