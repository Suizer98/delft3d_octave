function cosmos_writeMDF(hm,m,fname)

model=hm.models(m);

fid=fopen(fname,'wt');

inpdir=[model.datafolder 'input' filesep];

itdate=D3DTimeString(model.refTime,'itdatemdf');
tstart=num2str((model.tFlowStart-model.refTime)*1440);
tstop =num2str((model.tStop-model.refTime)*1440);
tout  =num2str((model.tOutputStart-model.refTime)*1440);
twav  =num2str((model.tWaveStart-model.refTime)*1440);
dt=num2str(model.timeStep);

dtmap=num2str(model.mapTimeStep);
dtcom=num2str(model.comTimeStep);
dthis=num2str(model.hisTimeStep);
%dtrst=num2str(model.rstInterval);
dtrst=num2str(720);

grd=wlgrid('read',[inpdir model.name '.grd']);
mmax=size(grd.X,1)+1;
nmax=size(grd.X,2)+1;
kmax=model.KMax;

fprintf(fid,'%s\n','Ident = #Delft3D-FLOW  .03.02 3.39.26#');
fprintf(fid,'%s\n','Runtxt= #                              #');
fprintf(fid,'%s\n',['Filcco= #' model.name '.grd#']);
fprintf(fid,'%s\n','Fmtcco= #FR#');
fprintf(fid,'%s\n','Grdang= 0.0000000e+000');
if ~strcmpi(model.coordinateSystemType,'geographic')    
    % Determine location of model
    if isempty(model.webSite(1).location)
        xloc=0.5*(model.xLim(1)+model.xLim(2));
        yloc=0.5*(model.yLim(1)+model.yLim(2));
    else
        xloc=model.webSite(iw).location(1);
        yloc=model.webSite(iw).location(2);
    end    
    [lon,lat]=convertCoordinates(xloc,yloc,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    fprintf(fid,'%s\n',['Anglat= ' num2str(lat)]);
    fprintf(fid,'%s\n',['Anglon= ' num2str(lon)]);
end
fprintf(fid,'%s\n',['Filgrd= #' model.name '.enc#']);
fprintf(fid,'%s\n','Fmtgrd= #FR#');
fprintf(fid,'%s\n',['MNKmax= ' num2str(mmax) ' ' num2str(nmax) '   ' num2str(kmax)]);
%fprintf(fid,'%s\n','Thick = 1.0000000e+002');
fprintf(fid,'%s\n',['Thick = ' num2str(model.thick(1))]);
for k=2:kmax
    fprintf(fid,'%s\n',['        ' num2str(model.thick(k))]);
end
fprintf(fid,'%s\n',['Fildep= #' model.name '.dep#']);
fprintf(fid,'%s\n','Fmtdep= #FR#');
if exist([inpdir model.name '.thd'],'file')
    fprintf(fid,'%s\n',['Filtd = #' model.name '.thd#']);
    fprintf(fid,'%s\n','Fmttd = #FR#');
end
if exist([inpdir model.name '.dry'],'file')
    fprintf(fid,'%s\n',['Fildry= #' model.name '.dry#']);
    fprintf(fid,'%s\n','Fmtdry= #FR#');
end
fprintf(fid,'%s\n',['Itdate= #' itdate '#']);
fprintf(fid,'%s\n','Tunit = #M#');
fprintf(fid,'%s\n',['Tstart= ' tstart]);
fprintf(fid,'%s\n',['Tstop = ' tstop]);
fprintf(fid,'%s\n',['Dt    = ' dt]);
fprintf(fid,'%s\n','Tzone = 0');

sub1='  W ';
if model.includeSalinity
    sub1(1)='S';
end
if model.includeTemperature
    sub1(2)='T';
end
fprintf(fid,'%s\n',['Sub1  = #' sub1 '#']);

sub2='   ';
if ~isempty(model.tracer)
    sub2(2)='C';
end
if strcmpi(model.type,'Delft3DFLOWWAVE')
    sub2(3)='W';
end
fprintf(fid,'%s\n',['Sub2  = #' sub2 '#']);

for j=1:length(model.tracer)
    cstr=[model.tracer(j).name repmat(' ',1,20-length(model.tracer(j).name))];
    fprintf(fid,'%s\n',['Namc' num2str(j) ' = #' cstr '#']);
end

fprintf(fid,'%s\n','Commnt=               ');
fprintf(fid,'%s\n','Wnsvwp= #N#');
fprintf(fid,'%s\n','Filwnd= #dummy.wnd#');
fprintf(fid,'%s\n','Fmtwnd= #FR#');
fprintf(fid,'%s\n','Wndint= #Y#');
if ~isempty(model.flowRstFile)
    % Using a restart file
    fprintf(fid,'%s\n','Restid= #rst#');
elseif model.makeIniFile
    % Using an ini file
    fprintf(fid,'%s\n',['Filic = #' model.name '.ini#']);    
    fprintf(fid,'%s\n','Fmtic = #FR#');
else
    % Uniform initial conditions
    fprintf(fid,'%s\n','Restid= ##');
    fprintf(fid,'%s\n',['Zeta0 = ' num2str(model.zeta0)]);
end
fprintf(fid,'%s\n',['Filbnd= #' model.name '.bnd#']);
fprintf(fid,'%s\n','Fmtbnd= #FR#');
if exist([inpdir model.name '.bct'],'file') || model.flowNested || strcmpi(model.flowNestType,'oceanmodel')
    fprintf(fid,'%s\n',['FilbcT= #' model.name '.bct#']);
    fprintf(fid,'%s\n','FmtbcT= #FR#');
end
if exist([inpdir model.name '.bca'],'file')
    fprintf(fid,'%s\n',['Filana= #' model.name '.bca#']);
    fprintf(fid,'%s\n','Fmtana= #FR#');
end
if exist([inpdir model.name '.bch'],'file')
    fprintf(fid,'%s\n',['FilbcH= #' model.name '.bch#']);
    fprintf(fid,'%s\n','FmtbcH= #FR#');
end
if model.includeSalinity || model.includeTemperature || ~isempty(model.discharge)
    fprintf(fid,'%s\n',['Filbcc= #' model.name '.bcc#']);
    fprintf(fid,'%s\n','Fmtbcc= #FR#');
end

if ~isempty(model.discharge)
    fprintf(fid,'%s\n',['Filsrc= #' model.name '.src#']);
    fprintf(fid,'%s\n','Fmtsrc= #FR#');
    fprintf(fid,'%s\n',['Fildis= #' model.name '.dis#']);
    fprintf(fid,'%s\n','Fmtdis= #FR#');
end

fprintf(fid,'%s\n','Ag    = 9.8100000e+000');
fprintf(fid,'%s\n','Rhow  = 1.0240000e+003');
fprintf(fid,'%s\n','Alph0 = [.]');
fprintf(fid,'%s\n','Tempw = 1.5000000e+001');
fprintf(fid,'%s\n','Salw  = 3.1000000e+001');
fprintf(fid,'%s\n','Rouwav= #FR84#');

if length(model.windStress)==4
    fprintf(fid,'%s\n',['Wstres= ' num2str(model.windStress(1)) '  ' num2str(model.windStress(2)) '  ' num2str(model.windStress(3)) '  ' num2str(model.windStress(4))]);
else
    fprintf(fid,'%s\n',['Wstres= ' num2str(model.windStress(1)) '  ' num2str(model.windStress(2)) ...
        '  ' num2str(model.windStress(3)) '  ' num2str(model.windStress(4)) ...
        '  ' num2str(model.windStress(5)) '  ' num2str(model.windStress(6)) ...
        ]);
end

fprintf(fid,'%s\n','Rhoa  = 1.1500000e+000');
fprintf(fid,'%s\n','Betac = 5.0000000e-001');
fprintf(fid,'%s\n','Equili= #Y#');
if kmax>1
    fprintf(fid,'%s\n','Tkemod= #K-epsilon   #');
else
    fprintf(fid,'%s\n','Tkemod= #            #');
end
if model.includeTemperature && model.includeHeatExchange
    fprintf(fid,'%s\n','Ktemp = 5');
    fprintf(fid,'%s\n','Fclou =  0.0000000e+000');
    fprintf(fid,'%s\n','Sarea =  6.0000000e+009');
    fprintf(fid,'%s\n',['Secchi=  ' num2str(model.secchidepth)]);
    fprintf(fid,'%s\n','Stantn=  1.4500000e-003');
    fprintf(fid,'%s\n','Dalton=  1.2000000e-003');
    fprintf(fid,'%s\n','Filtmp= #dummy.tem#');
    fprintf(fid,'%s\n','Fmttmp= #FR#');
else
    fprintf(fid,'%s\n','Ktemp = 0');
    fprintf(fid,'%s\n','Fclou = 0.0000000e+000');
    fprintf(fid,'%s\n','Sarea = 0.0000000e+000');
end
fprintf(fid,'%s\n','Temint= #Y#');
if model.useTidalForces
    fprintf(fid,'%s\n','Tidfor= #M2 S2 N2 K2 #');
    fprintf(fid,'%s\n','        #K1 O1 P1 Q1 #');
    fprintf(fid,'%s\n','        #MF MM SSA---#');
end
fprintf(fid,'%s\n',['Roumet= #' model.RouMet '#']);
if exist([inpdir model.name '.rgh'],'file')
    fprintf(fid,'%s\n',['Filrgh= #' model.name '.rgh#']);
    fprintf(fid,'%s\n','Fmtrgh= #FR#');
else
    fprintf(fid,'%s\n',['Ccofu = ' num2str(model.ccofu)]);
    fprintf(fid,'%s\n',['Ccofv = ' num2str(model.ccofu)]);
end
if exist([inpdir model.name '.edy'],'file')
    fprintf(fid,'%s\n',['Filedy= #' model.name '.edy' '#']);
else
    fprintf(fid,'%s\n',['Vicouv= ' num2str(model.VicoUV)]);
end
fprintf(fid,'%s\n',['Dicouv= ' num2str(model.DicoUV)]);
fprintf(fid,'%s\n','Htur2d= #N#');
fprintf(fid,'%s\n','Irov  = 0');
fprintf(fid,'%s\n','Iter  = 2');
fprintf(fid,'%s\n','Dryflp= #YES#');
fprintf(fid,'%s\n',['Dpsopt= #' model.DpsOpt '#']);
if strcmpi(model.layerType,'z')
    fprintf(fid,'%s\n','Dpuopt= #MIN#');
else    
    fprintf(fid,'%s\n',['Dpuopt= #'  model.DpuOpt '#']);
end
fprintf(fid,'%s\n','Dryflc= 1.0000000e-001');
fprintf(fid,'%s\n','Dco   = 1.0000000e+000');
if ~isempty(model.flowRstFile) || model.makeIniFile
    fprintf(fid,'%s\n','Tlfsmo= 0.0000000e+000');
else
    fprintf(fid,'%s\n','Tlfsmo= 1.2000000e+002');
end
fprintf(fid,'%s\n','ThetQH= 0.0000000e+000');
fprintf(fid,'%s\n','Forfuv= #N#');
fprintf(fid,'%s\n','Forfww= #N#');
if model.sigcor
    fprintf(fid,'%s\n','Sigcor= #Y#');
else
    fprintf(fid,'%s\n','Sigcor= #N#');
end
fprintf(fid,'%s\n','Trasol= #Cyclic-method#');
fprintf(fid,'%s\n',['Momsol= #' model.momSol '#']);
fprintf(fid,'%s\n',['Filsta= #' model.name '.obs#']);
fprintf(fid,'%s\n','Fmtsta= #FR#');
fprintf(fid,'%s\n','SMhydr= #YYYYY#');
fprintf(fid,'%s\n','SMderv= #NNNNNN#');
fprintf(fid,'%s\n','SMproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','PMhydr= #YYYYYY#');
fprintf(fid,'%s\n','PMderv= #NNN#');
fprintf(fid,'%s\n','PMproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','SHhydr= #YYYY#');
fprintf(fid,'%s\n','SHderv= #NNNNN#');
fprintf(fid,'%s\n','SHproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','SHflux= #NNNN#');
fprintf(fid,'%s\n','PHhydr= #YYYYYY#');
fprintf(fid,'%s\n','PHderv= #NNN#');
fprintf(fid,'%s\n','PHproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','PHflux= #NNNN#');
fprintf(fid,'%s\n','Online= #N#');
fprintf(fid,'%s\n','Waqmod= #N#');
if strcmpi(model.type,'Delft3DFLOWWAVE')
    fprintf(fid,'%s\n','WaveOL= #Y#');
end
if strcmpi(model.type,'Delft3DFLOWWAVE') && ~model.roller
    fprintf(fid,'%s\n','TpsCom= #Y#');
end
fprintf(fid,'%s\n','Prhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
fprintf(fid,'%s\n',['Flmap = ' tout '   ' dtmap '  ' tstop]);
fprintf(fid,'%s\n',['Flhis = ' tstart '  ' dthis '  ' tstop]);
fprintf(fid,'%s\n',['Flpp  = ' twav '   ' dtcom '  ' tstop]);
fprintf(fid,'%s\n',['Flrst = ' dtrst]);
if ~isempty(model.meteowind)
    if model.includeAirPressure
        fprintf(fid,'%s\n','Filwp = #meteo.amp#');
    end
    fprintf(fid,'%s\n','Filwu = #meteo.amu#');
    fprintf(fid,'%s\n','Filwv = #meteo.amv#');
    fprintf(fid,'%s\n','Wndgrd= #A#');
    if (~model.flowNested && ~strcmpi(model.flowNestType,'oceanmodel')) || model.applyPressureCorrection
        fprintf(fid,'%s\n',['Pavbnd= ' num2str(model.prCorr)]);
    end
    fprintf(fid,'%s\n','AirOut= #YES#');
end

if ~isempty(model.meteospw)
    fprintf(fid,'%s\n',['Filweb= #' model.meteospw '#']);
end

if model.includeTemperature && model.includeHeatExchange
    fprintf(fid,'%s\n','Filwr = #meteo.amr#');
    fprintf(fid,'%s\n','Filwt = #meteo.amt#');
    fprintf(fid,'%s\n','Filwc = #meteo.amc#');
    fprintf(fid,'%s\n','HeaOut= #YES#');
    if ~isempty(model.tmzRad)
        fprintf(fid,'%s\n',['TmZRad= ' num2str(model.tmzRad)]);
    end
end

if strcmpi(model.SMVelo,'GLM')
    fprintf(fid,'%s\n','SMVelo = #GLM#');
end
if model.cstBnd
    fprintf(fid,'%s\n','CstBnd= #YES#');
end

% Z-layers
if strcmpi(model.layerType,'z')
    fprintf(fid,'%s\n','Zmodel= #YES#');
    fprintf(fid,'%s\n',['ZTop  = ' num2str(model.zTop)]);
    fprintf(fid,'%s\n',['ZBot  = ' num2str(model.zBot)]);
end

if ~isempty(model.tmzRad)
    fprintf(fid,'%s\n',['TmzRad= ' num2str(model.tmzRad)]);
end

if strcmpi(model.flowNestType,'oceanmodel') || model.nudge
    fprintf(fid,'%s\n','Nudge = #Y#');
    fprintf(fid,'%s\n','NudVic= 50.0');
end

if ~isempty(model.tracer)
    for i=1:length(model.tracer)
        if model.tracer(i).decay>0
            fprintf(fid,'%s\n',['Decay' num2str(i) '= ' num2str(model.tracer(i).decay)]);
        end
    end
end

if model.roller
    fprintf(fid,'%s\n','Roller= #yes#');
    fprintf(fid,'%s\n','Gamdis= 0.7');
    fprintf(fid,'%s\n','betaro= 0.05');
    fprintf(fid,'%s\n','alfaro= 1.0');
    fprintf(fid,'%s\n','F_lam = -2');
    fprintf(fid,'%s\n','Thr   = 0.01');
end

if model.fourier
    fprintf(fid,'%s\n',['Filfou= #' model.name '.fou' '#']);
    [pathstr,name,ext]=fileparts(fname);
    fifou=fopen([pathstr filesep model.name '.fou'],'wt');
    fprintf(fifou,'%s      %s %s %i %f %f %s\n','wl',tout,tstop,1,1,0,'max');
    fclose(fifou);
end
% %% WAQ output
% switch(lower(model.type))
%     case{'delft3dflowpart','delft3dflowwavepart'}
%         fprintf(fid,'%s\n',['Flwq  = ' twav '   ' dtcom '  ' tstop]);
%         aggrstr=repmat(' 1',1,kmax);
%         fprintf(fid,'%s\n',['ilAggr=' aggrstr]);
%         fprintf(fid,'%s\n','WaqAgg= ##');        
% end

fclose(fid);
