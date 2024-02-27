function cosmos_writeMDW(hm,m,fname)

model=hm.models(m);

inpdir=[model.dir 'input' filesep];

fid=fopen(fname,'wt');

itdate=D3DTimeString(model.refTime,'itdatemdf');

dtmap=num2str(model.mapTimeStep);
dtcom=num2str(model.comTimeStep);
%dthot=num2str(hm.runInterval*60);
dthot=num2str(12*60);

k=0;
for i=1:length(model.nestedWaveModels)
    % A model is nested in this Delft3D-WAVE model
    mm=model.nestedWaveModels(i);
    k=k+1;
    locfile{k}=[hm.models(mm).runid '.loc'];
end

% for i=1:model.nrStations
%     if model.stations(i).storeSP2
%         k=k+1;
%         locfile{k}=[model.stations(i).SP2id '.loc'];
%     end
% end

for istat=1:model.nrStations
    for i=1:model.stations(istat).nrDatasets
        if strcmpi(model.stations(istat).datasets(i).parameter,'sp2')
            k=k+1;
            locfile{k}=[model.stations(istat).datasets(i).sp2id '.loc'];
            xy=model.stations(istat).location;
            save([hm.tempDir locfile{k}],'xy','-ascii');
        end
    end
end

nloc=k;

fprintf(fid,'%s\n','[WaveFileInformation]');
fprintf(fid,'%s\n','   FileVersion = 02.00');
fprintf(fid,'%s\n','[General]');
fprintf(fid,'%s\n','   ProjectName      = ');
fprintf(fid,'%s\n','   ProjectNr        = ');
fprintf(fid,'%s\n','   Description1     = ');
fprintf(fid,'%s\n','   Description2     = ');
fprintf(fid,'%s\n','   Description3     = ');
fprintf(fid,'%s\n',['   ReferenceDate    = ' itdate]);
fprintf(fid,'%s\n','   DirConvention    = nautical');
if model.nonstationary
    fprintf(fid,'%s\n','   SimMode          = non-stationary');
    fprintf(fid,'%s\n',['   TimeStep         = ' num2str(model.waveTimeStep)]);
else
    fprintf(fid,'%s\n','   SimMode          = stationary');
end
fprintf(fid,'%s\n','   OnlyInputVerify  = false');
if strcmpi(model.dirSpace,'circle')
    fprintf(fid,'%s\n','   DirSpace         = circle');
else
    fprintf(fid,'%s\n','   DirSpace         = sector');
    fprintf(fid,'%s\n',['   StartDir         = ' num2str(model.startDir)]);
    fprintf(fid,'%s\n',['   EndDir           = ' num2str(model.endDir)]);
end
fprintf(fid,'%s\n',['   NDir             = ' num2str(model.nDirBins)]);
fprintf(fid,'%s\n','   FreqMin          = 5.0000001e-002');
fprintf(fid,'%s\n','   FreqMax          = 1.0000000e+000');
fprintf(fid,'%s\n','   NFreq            = 24');
fprintf(fid,'%s\n','   TimePoint        = 0.0000000e+000');
fprintf(fid,'%s\n','   WaterLevel       = 0.0000000e+000');
fprintf(fid,'%s\n','   XVeloc           = 0.0000000e+000');
fprintf(fid,'%s\n','   YVeloc           = 0.0000000e+000');
fprintf(fid,'%s\n','   WindSpeed        = 6.0000000e+000');
fprintf(fid,'%s\n','   WindDir          = 3.3000000e+002');
if ~isempty(model.waveRstFile)
    starttime=datestr(model.tWaveStart,'yyyymmdd.HHMMSS');
    fprintf(fid,'%s\n',['   HotFileID        = ' starttime]);
end
if exist([inpdir model.name '.obw'],'file')
    fprintf(fid,'%s\n',['   ObstacleFile      = ' model.name '.obw']);
end
fprintf(fid,'%s\n','[Constants]');
fprintf(fid,'%s\n','   Gravity          = 9.8100004e+000');
fprintf(fid,'%s\n','   WaterDensity     = 1.0250000e+003');
fprintf(fid,'%s\n','   NorthDir         = 9.0000000e+001');
fprintf(fid,'%s\n','   MinimumDepth     = 5.0000001e-002');
fprintf(fid,'%s\n','[Processes]');
fprintf(fid,'%s\n','   GenModePhys      = 3');
fprintf(fid,'%s\n','   WaveSetup        = false');
fprintf(fid,'%s\n','   WaveForces       = dissipation');
fprintf(fid,'%s\n','   Breaking         = true');
fprintf(fid,'%s\n','   BreakAlpha       = 1.0000000e+000');
fprintf(fid,'%s\n','   BreakGamma       = 7.3000002e-001');
fprintf(fid,'%s\n',['   BedFriction      = ' model.waveBedFric]);
fprintf(fid,'%s\n',['   BedFricCoef      = ' num2str(model.waveBedFricCoef)]);
fprintf(fid,'%s\n','   Triads           = false');
fprintf(fid,'%s\n','   Diffraction      = false');
fprintf(fid,'%s\n','   WindGrowth       = true');
if isfield(model,'whiteCapping')
    wcap=model.whiteCapping;
else
    wcap='Komen';
end
fprintf(fid,'%s\n',['   WhiteCapping     = ' wcap]);
fprintf(fid,'%s\n','   Quadruplets      = true');
fprintf(fid,'%s\n','   Refraction       = true');
fprintf(fid,'%s\n','   FreqShift        = true');
fprintf(fid,'%s\n','[Numerics]');
fprintf(fid,'%s\n','   DirSpaceCDD      = 5.0000000e-001');
fprintf(fid,'%s\n','   FreqSpaceCSS     = 5.0000000e-001');
fprintf(fid,'%s\n','   RChHsTm01        = 2.0000000e-002');
fprintf(fid,'%s\n','   RChMeanHs        = 2.0000000e-002');
fprintf(fid,'%s\n','   RChMeanTm01      = 2.0000000e-002');
fprintf(fid,'%s\n','   PercWet          = 9.8000000e+001');
fprintf(fid,'%s\n',['   MaxIter          = ' num2str(model.maxIter)]);
% if exist([inpdir model.name '.obw'],'file')
%     fprintf(fid,'%s\n','[ObstacleFileInformation]');
%     fprintf(fid,'%s\n',['   PolygonFile      = ' model.name '.pol']);
%     fprintf(fid,'%s\n','[Obstacle]');
%     fprintf(fid,'%s\n','   Name             = L001');
%     fprintf(fid,'%s\n','   Type             = sheet');
%     fprintf(fid,'%s\n','   TransmCoef       = 0.0');
%     fprintf(fid,'%s\n','   Reflections      = no');
% end
fprintf(fid,'%s\n','[Output]');
fprintf(fid,'%s\n','   TestOutputLevel  = 0');
fprintf(fid,'%s\n','   TraceCalls       = false');
fprintf(fid,'%s\n','   UseHotFile       = true');
fprintf(fid,'%s\n',['   MapWriteInterval = ' dtmap]);
fprintf(fid,'%s\n','   WriteCOM         = true');
fprintf(fid,'%s\n',['   COMWriteInterval = ' dtcom]);
fprintf(fid,'%s\n',['   Int2KeepHotfile  = ' dthot]);
fprintf(fid,'%s\n',['   FlowGrid         = ' model.name '.grd']);
for i=1:nloc
    fprintf(fid,'%s\n',['   LocationFile     = ' locfile{i}]);
end
% fprintf(fid,'%s\n','   WriteSpec1D      = true');
fprintf(fid,'%s\n','   WriteSpec2D      = true');
fprintf(fid,'%s\n','[Domain]');
fprintf(fid,'%s\n',['   Grid             = ' model.name '_swn.grd']);
fprintf(fid,'%s\n',['   BedLevel         = ' model.name '_swn.dep']);

fprintf(fid,'%s\n',['   FlowWaterLevel   = ' num2str(model.flowWaterLevel)]);
fprintf(fid,'%s\n',['   FlowBedLevel     = ' num2str(model.flowBedLevel)]);
fprintf(fid,'%s\n',['   FlowVelocity     = ' num2str(model.flowVelocity)]);
fprintf(fid,'%s\n',['   FlowWind         = ' num2str(model.flowWind)]);

if model.waveNested
    fprintf(fid,'%s\n','[Boundary]');
    % switch lower(hm.models(model.waveNestModelNr).type)
    %     case{'ww3'}
    %         fprintf(fid,'%s\n','   Definition = fromWWfile');
    %         fprintf(fid,'%s\n','   WWspecfile = ww3.spc');
    %     case{'delft3dflowwave'}
    %         fprintf(fid,'%s\n','   Definition       = fromsp2file');
    %         fprintf(fid,'%s\n',['   OverallSpecFile  = ' model.name '.sp2']);
    % end
    fprintf(fid,'%s\n','   Definition       = fromsp2file');
    fprintf(fid,'%s\n',['   OverallSpecFile  = ' model.name '.sp2']);
end

fclose(fid);
