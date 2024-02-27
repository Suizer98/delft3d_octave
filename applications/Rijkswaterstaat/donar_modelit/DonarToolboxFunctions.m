function info = DonarToolboxFunctions
%

if nargout == 1
    DISK=upper(pwd); %ZIJPP: location may be c: or h:
    DISK(3:end)='';
    info.name = 'Modelit DONAR Toolbox';
    info.date = datestr(now,'dd-mmm-yyyy');
    info.version = '1.0.0';
    info.matlabversion = 'R2006B';
    info.matlabdate = '03-Aug-2006';
    info.intro = [DISK,'\d\Modelit\ma\MBDUtils\diaroutines\intro.htm'];
    info.install = [DISK,'\d\Modelit\ma\MBDUtils\diaroutines\install.pdf'];
else
    readdia_R14;
    writedia_R14;
    emptyDia;
    emptyblok;
    emptyRGH;
    emptyW3H;
    emptyWRD;
    emptyMUX;
    emptyTPS;
    cmp_taxis;
    duration;
    splitlongdate;
    bepaal_tijdstap;
    blok_select;
    combineTPS;
    combineRKS;
    set_taxis;
    readrwslod;
    readqinsy;
    long2datenum;
    datenum2long;
    datenum2str;
    bepaal_tijdstap;
end