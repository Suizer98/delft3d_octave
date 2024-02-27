function ddb_saveMDW(handles)

wave=handles.model.delft3dwave.domain;

% Get also the flowfile; if any
try
wave.mdffile = wave.flowfile;
catch
end

%if wave.coupledwithflow
if ~isempty(wave.mdffile)
    wave.comwriteinterval=handles.model.delft3dflow.domain(1).comInterval;
end

ndomains=length(wave.domains);
MDW.WaveFileInformation.FileVersion.value = '02.00';

%% General
MDW.General.ProjectName.value  = wave.projectname;
MDW.General.ProjectNr.value    = wave.projectnr;
try
    if (~isempty(wave.description{1}))
        MDW.General.Description1.value = wave.description{1};
    end
    if (~isempty(wave.description{2}))
        MDW.General.Description2.value = wave.description{2};
    end
    if (~isempty(wave.description{3}))
        MDW.General.Description3.value = wave.description{3};
    end
end
MDW.General.FlowFile.value = wave.mdffile;
MDW.General.OnlyInputVerify.value = wave.onlyinputverify;
MDW.General.OnlyInputVerify.type  = 'boolean';
MDW.General.SimMode.value  = wave.simmode;
switch lower(wave.simmode)
    case{'non-stationary'}
        MDW.General.TimeStep.value      = wave.timestep;
        MDW.General.TimeStep.type = 'real';
        
        
        
end

MDW.General.DirConvention.value = wave.dirconvention;
MDW.General.ReferenceDate.value = datestr(wave.referencedate,29);
if wave.nrobstacles>0
    MDW.General.ObstacleFile.value  = wave.obstaclefile;
end
if ~isempty(wave.tseriesfile)
    MDW.General.TSeriesFile.value   = wave.tseriesfile;
    if ~isempty(wave.timepntblock)
        MDW.General.TimePntBlock.value  = wave.timepntblock;
        MDW.General.WindSpeed.type      = 'integer';
    end
end
if isempty(wave.timepntblock) && ~isempty(wave.timepoint)
    MDW.General.TimePoint.value     = 1440.0*(wave.timepoint-wave.referencedate);
    MDW.General.TimePoint.type      = 'real';
end
MDW.General.WaterLevel.value    = wave.waterlevel;
MDW.General.WaterLevel.type     = 'real';
MDW.General.XVeloc.value        = wave.xveloc;
MDW.General.XVeloc.type         = 'real';
MDW.General.YVeloc.value        = wave.yveloc;
MDW.General.YVeloc.type         = 'real';
MDW.General.WindSpeed.value     = wave.windspeed;
MDW.General.WindSpeed.type      = 'real';
MDW.General.WindDir.value       = wave.winddir;
MDW.General.WindDir.type        = 'real';
if ~isempty(wave.hotfileid)
    MDW.General.HotFileID.value       = wave.hotfileid;
end
if ~isempty(wave.meteofile)
    MDW.General.Meteofile.value       = wave.meteofile;
end

%% Constants
MDW.Constants.Gravity.value       = wave.gravity;
MDW.Constants.Gravity.type        = 'real';
MDW.Constants.WaterDensity.value  = wave.waterdensity;
MDW.Constants.WaterDensity.type   = 'real';
MDW.Constants.NorthDir.value      = wave.northdir;
MDW.Constants.NorthDir.type       = 'real';
MDW.Constants.MinimumDepth.value  = wave.minimumdepth;
MDW.Constants.MinimumDepth.type   = 'real';

%% Processes
MDW.Processes.GenModePhys.value   = wave.genmodephys;
MDW.Processes.GenModePhys.type    = 'integer';
MDW.Processes.WaveSetup.value     = wave.wavesetup;
MDW.Processes.WaveSetup.type      = 'boolean';
MDW.Processes.Breaking.value      = wave.breaking;
MDW.Processes.Breaking.type       = 'boolean';
MDW.Processes.BreakAlpha.value    = wave.breakalpha;
MDW.Processes.BreakAlpha.type     = 'real';
MDW.Processes.BreakGamma.value    = wave.breakgamma;
MDW.Processes.BreakGamma.type     = 'real';
MDW.Processes.Triads.value        = wave.triads;
MDW.Processes.Triads.type         = 'boolean';
MDW.Processes.TriadsAlpha.value   = wave.triadsalpha;
MDW.Processes.TriadsAlpha.type    = 'real';
MDW.Processes.TriadsBeta.value    = wave.triadsbeta;
MDW.Processes.TriadsBeta.type     = 'real';

MDW.Processes.BedFriction.value   = wave.bedfriction;
switch wave.bedfriction
    case{'jonswap'}
        MDW.Processes.BedFricCoef.value    = wave.bedfriccoefjonswap;
        MDW.Processes.BedFricCoef.type     = 'real';
    case{'collins'}
        MDW.Processes.BedFricCoef.value    = wave.bedfriccoefcollins;
        MDW.Processes.BedFricCoef.type     = 'real';
    case{'madsen'}
        MDW.Processes.BedFricCoef.value    = wave.bedfriccoefmadsen;
        MDW.Processes.BedFricCoef.type     = 'real';
end

MDW.Processes.Diffraction.value    = wave.diffraction;
MDW.Processes.Diffraction.type     = 'boolean';
if wave.diffraction
    MDW.Processes.DiffracCoef.value    = wave.diffraccoef;
    MDW.Processes.DiffracCoef.type     = 'real';
    MDW.Processes.DiffracSteps.value   = wave.diffracsteps;
    MDW.Processes.DiffracSteps.type    = 'integer';
    MDW.Processes.DiffracProp.value    = wave.diffracprop;
    MDW.Processes.DiffracProp.type     = 'boolean';
end
MDW.Processes.WindGrowth.value     = wave.windgrowth;
MDW.Processes.WindGrowth.type      = 'boolean';
MDW.Processes.WhiteCapping.value   = wave.whitecapping;
MDW.Processes.Quadruplets.value    = wave.quadruplets;
MDW.Processes.Quadruplets.type     = 'boolean';
MDW.Processes.Refraction.value     = wave.refraction;
MDW.Processes.Refraction.type      = 'boolean';
MDW.Processes.FreqShift.value      = wave.freqshift;
MDW.Processes.FreqShift.type       = 'boolean';
MDW.Processes.WaveForces.value     = wave.waveforces;

%% Numerics
MDW.Numerics.DirSpaceCDD.value   = wave.dirspacecdd;
MDW.Numerics.DirSpaceCDD.type    = 'real';
MDW.Numerics.FreqSpaceCSS.value  = wave.freqspacecss;
MDW.Numerics.FreqSpaceCSS.type   = 'real';
MDW.Numerics.RChHsTm01.value     = wave.rchhstm01;
MDW.Numerics.RChHsTm01.type      = 'real';
MDW.Numerics.RChMeanHs.value     = wave.rchmeanhs;
MDW.Numerics.RChMeanHs.type      = 'real';
MDW.Numerics.RChMeanTm01.value   = wave.rchmeantm01;
MDW.Numerics.RChMeanTm01.type    = 'real';
MDW.Numerics.PercWet.value       = wave.percwet;
MDW.Numerics.PercWet.type        = 'real';
MDW.Numerics.MaxIter.value       = wave.maxiter;
MDW.Numerics.MaxIter.type        = 'integer';

%% Output
MDW.Output.TestOutputLevel.value  = wave.testoutputlevel;
MDW.Output.TestOutputLevel.type   = 'integer';
MDW.Output.TraceCalls.value       = wave.tracecalls;
MDW.Output.TraceCalls.type        = 'boolean';
MDW.Output.UseHotFile.value       = wave.usehotfile;
MDW.Output.UseHotFile.type        = 'boolean';
MDW.Output.MapWriteInterval.value = wave.mapwriteinterval;
MDW.Output.MapWriteInterval.type  = 'real';
MDW.Output.WriteCOM.value         = wave.writecom;
MDW.Output.WriteCOM.type          = 'boolean';
MDW.Output.COMWriteInterval.value = wave.comwriteinterval;
MDW.Output.COMWriteInterval.type  = 'real';
MDW.Output.Int2KeepHotfile.value  = wave.int2keephotfile;
MDW.Output.Int2KeepHotfile.type   = 'real';
MDW.Output.AppendCOM.value        = wave.appendcom;
MDW.Output.AppendCOM.type         = 'boolean';
for ii=1:length(wave.locationfile)
    if ~isempty(wave.locationfile{ii})
        if wave.locationsets(ii).nrpoints>0
            MDW.Output.(['LocationFile' num2str(ii)]).value     = wave.locationfile{ii};
            MDW.Output.(['LocationFile' num2str(ii)]).keyword   = 'LocationFile';
        end
    end
end
MDW.Output.WriteTable.value       = wave.writetable;
MDW.Output.WriteTable.type        = 'boolean';
MDW.Output.WriteSpec1D.value      = wave.writespec1d;
MDW.Output.WriteSpec1D.type       = 'boolean';
MDW.Output.WriteSpec2D.value      = wave.writespec2d;
MDW.Output.WriteSpec2D.type       = 'boolean';

%% Domains
for i=1:ndomains
    if strcmpi(wave.domains(i).gridname(end-2:end),'grd')
        MDW.Domain(i).Grid.value           = wave.domains(i).gridname;
    else
        MDW.Domain(i).Grid.value           = [wave.domains(i).gridname '.grd'];
    end
        
%    MDW.Domain(i).Grid.value           = wave.domains(i).grid;

%     if ~isempty(wave.domains(i).bedlevelgrid)
%         MDW.Domain(i).BedLevelGrid.value   = wave.domains(i).bedlevelgrid;
%     end
    if ~isempty(wave.domains(i).bedlevel)
        MDW.Domain(i).BedLevel.value       = wave.domains(i).bedlevel;
    end
    MDW.Domain(i).DirSpace.value       = wave.domains(i).dirspace;
    MDW.Domain(i).NDir.value           = wave.domains(i).ndir;
    MDW.Domain(i).NDir.type            = 'integer';
    MDW.Domain(i).StartDir.value       = wave.domains(i).startdir;
    MDW.Domain(i).StartDir.type        = 'real';
    MDW.Domain(i).EndDir.value         = wave.domains(i).enddir;
    MDW.Domain(i).EndDir.type          = 'real';
    MDW.Domain(i).NFreq.value          = wave.domains(i).nfreq;
    MDW.Domain(i).NFreq.type           = 'integer';
    MDW.Domain(i).FreqMin.value        = wave.domains(i).freqmin;
    MDW.Domain(i).FreqMin.type         = 'real';
    MDW.Domain(i).FreqMax.value        = wave.domains(i).freqmax;
    MDW.Domain(i).FreqMax.type         = 'real';
    if ~isempty(wave.domains(i).nestgrid)
        inest=strmatch(wave.domains(i).nestgrid,wave.gridnames,'exact');
        % This check should not have to happen
        if ~isempty(inest)
            MDW.Domain(i).NestedInDomain.value = inest;
            MDW.Domain(i).NestedInDomain.type  = 'integer';
        end
    end
    MDW.Domain(i).FlowBedLevel.value   = wave.domains(i).flowbedlevel;
    MDW.Domain(i).FlowBedLevel.type    = 'integer';
    MDW.Domain(i).FlowWaterLevel.value = wave.domains(i).flowwaterlevel;
    MDW.Domain(i).FlowWaterLevel.type  = 'integer';
    MDW.Domain(i).FlowVelocity.value   = wave.domains(i).flowvelocity;
    MDW.Domain(i).FlowVelocity.type    = 'integer';
    MDW.Domain(i).FlowWind.value       = wave.domains(i).flowwind;
    MDW.Domain(i).FlowWind.type        = 'integer';
    MDW.Domain(i).Output.value         = wave.domains(i).output;
    MDW.Domain(i).Output.type          = 'boolean';
    % TODO vegetation
end

%% Boundaries
for i=1:wave.nrboundaries
    
    MDW.Boundary(i).Name.value           = wave.boundaries(i).name;
    MDW.Boundary(i).Definition.value     = wave.boundaries(i).definition;
    
    switch lower(wave.boundaries(i).definition)
        case{'orientation'}
            MDW.Boundary(i).Orientation.value    = wave.boundaries(i).orientation;
        case{'grid-coordinates'}
            MDW.Boundary(i).StartCoordM.value    = wave.boundaries(i).startcoordm;
            MDW.Boundary(i).StartCoordM.type     = 'integer';
            MDW.Boundary(i).EndCoordM.value      = wave.boundaries(i).endcoordm;
            MDW.Boundary(i).EndCoordM.type       = 'integer';
            MDW.Boundary(i).StartCoordN.value    = wave.boundaries(i).startcoordn;
            MDW.Boundary(i).StartCoordN.type     = 'integer';
            MDW.Boundary(i).EndCoordN.value      = wave.boundaries(i).endcoordn;
            MDW.Boundary(i).EndCoordN.type       = 'integer';
        case{'xy-coordinates'}
            MDW.Boundary(i).StartCoordX.value    = wave.boundaries(i).startcoordx;
            MDW.Boundary(i).StartCoordX.type     = 'real';
            MDW.Boundary(i).EndCoordX.value      = wave.boundaries(i).endcoordx;
            MDW.Boundary(i).EndCoordX.type       = 'real';
            MDW.Boundary(i).StartCoordY.value    = wave.boundaries(i).startcoordy;
            MDW.Boundary(i).StartCoordY.type     = 'real';
            MDW.Boundary(i).EndCoordY.value      = wave.boundaries(i).endcoordy;
            MDW.Boundary(i).EndCoordY.type       = 'real';
        case{'fromsp2file'}
            MDW.Boundary(i).OverallSpecFile.value = wave.boundaries(i).overallspecfile;
    end
    
    switch lower(wave.boundaries(i).definition)
        case{'orientation','grid-coordinates','xy-coordinates'}
            
            MDW.Boundary(i).SpectrumSpec.value   = wave.boundaries(i).spectrumspec;
            switch lower(wave.boundaries(i).spectrumspec)
                case{'parametric'}
                    MDW.Boundary(i).SpShapeType.value   = wave.boundaries(i).spshapetype;
                    switch lower(wave.boundaries(i).spshapetype)
                        case{'jonswap'}
                            MDW.Boundary(i).PeakEnhancFac.value = wave.boundaries(i).peakenhancfac;
                            MDW.Boundary(i).PeakEnhancFac.type  = 'real';
                        case{'pierson-moskowitz'}
                        case{'gauss'}
                            MDW.Boundary(i).GaussSpread.value = wave.boundaries(i).gaussspread;
                            MDW.Boundary(i).GaussSpread.type  = 'real';
                    end
                    MDW.Boundary(i).PeriodType.value    = wave.boundaries(i).periodtype;
                    MDW.Boundary(i).DirSpreadType.value = wave.boundaries(i).dirspreadtype;
                    switch lower(wave.boundaries(i).alongboundary)
                        case{'uniform'}
                            MDW.Boundary(i).WaveHeight.value     = wave.boundaries(i).waveheight;
                            MDW.Boundary(i).WaveHeight.type      = 'real';
                            MDW.Boundary(i).Period.value         = wave.boundaries(i).period;
                            MDW.Boundary(i).Period.type          = 'real';
                            MDW.Boundary(i).Direction.value      = wave.boundaries(i).direction;
                            MDW.Boundary(i).Direction.type       = 'real';
                            MDW.Boundary(i).DirSpreading.value   = wave.boundaries(i).dirspreading;
                            MDW.Boundary(i).DirSpreading.type    = 'real';
                        otherwise
                            for k=1:length(wave.boundaries(i).segments)
                                MDW.Boundary(i).(['CondSpecAtDist' num2str(k)]).value       = wave.boundaries(i).segments(k).condspecatdist;
                                MDW.Boundary(i).(['CondSpecAtDist' num2str(k)]).type        = 'real';
                                MDW.Boundary(i).(['CondSpecAtDist' num2str(k)]).keyword     = 'CondSpecAtDist';
                                MDW.Boundary(i).(['WaveHeight' num2str(k)]).value     = wave.boundaries(i).segments(k).waveheight;
                                MDW.Boundary(i).(['WaveHeight' num2str(k)]).type      = 'real';
                                MDW.Boundary(i).(['WaveHeight' num2str(k)]).keyword   = 'WaveHeight';
                                MDW.Boundary(i).(['Period' num2str(k)]).value         = wave.boundaries(i).segments(k).period;
                                MDW.Boundary(i).(['Period' num2str(k)]).type          = 'real';
                                MDW.Boundary(i).(['Period' num2str(k)]).keyword       = 'Period';
                                MDW.Boundary(i).(['Direction' num2str(k)]).value      = wave.boundaries(i).segments(k).direction;
                                MDW.Boundary(i).(['Direction' num2str(k)]).type       = 'real';
                                MDW.Boundary(i).(['Direction' num2str(k)]).keyword    = 'Direction';
                                MDW.Boundary(i).(['DirSpreading' num2str(k)]).value   = wave.boundaries(i).segments(k).dirspreading;
                                MDW.Boundary(i).(['DirSpreading' num2str(k)]).type    = 'real';
                                MDW.Boundary(i).(['DirSpreading' num2str(k)]).keyword = 'DirSpreading';
                            end
                    end
                    
                otherwise
                    MDW.Boundary(i).SpectrumSpec.value      = 'from file';
                    MDW.Boundary(i).Spectrum.value          = wave.boundaries(i).spectrum;
            end
    end
    
end

fname=[handles.model.delft3dwave.domain.mdwfile];

ddb_saveDelft3D_keyWordFile(fname, MDW);

if strcmpi(wave.coupling,'uncoupled')
    % Uncoupled model, write WAVE only batch file
    ddb_Delft3DWAVE_writeBatchFile(wave.mdwfile);
end
