function handles = ddb_saveMDF(handles, id)
%DDB_SAVEMDF  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_saveMDF(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_saveMDF
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=ddb_countOpenBoundaries(handles,id);

Flow=handles.model.delft3dflow.domain(id);

runid=handles.model.delft3dflow.domain(id).runid;

incconst=Flow.salinity.include || Flow.temperature.include || Flow.sediments.include || Flow.tracers;

MDF.Ident='Delft3D-FLOW  .03.02 3.39.26';
MDF.Runtxt=Flow.description;
MDF.Filcco=Flow.grdFile;
MDF.Fmtcco='FR';
if strcmp(handles.screenParameters.coordinateSystem.type,'Cartesian')
    MDF.Anglat=Flow.latitude;
    if Flow.longitude~=0
        MDF.Anglon=Flow.longitude;
    end
end
MDF.Grdang=Flow.orientation;
MDF.Filgrd=Flow.encFile;
MDF.Fmtgrd='FR';
MDF.MNKmax(1)=Flow.MMax;
MDF.MNKmax(2)=Flow.NMax;
MDF.MNKmax(3)=Flow.KMax;
MDF.Thick=Flow.thick;
if ~isempty(Flow.depFile)
    MDF.Fildep=Flow.depFile;
    MDF.Fmtdep= 'FR';
else
    MDF.DepUni=Flow.uniformDepth;
end
if Flow.nrDryPoints>0
    MDF.Fildry=Flow.dryFile;
    MDF.Fmtdry='FR';
end
if Flow.nrThinDams>0
    MDF.Filtd=Flow.thdFile;
    MDF.Fmttd='FR';
end
if Flow.nrWeirs2D>0
    MDF.Fil2dw=Flow.w2dFile;
end
MDF.Itdate=D3DTimeString(Flow.itDate,'ItDateMDF');
MDF.Tunit='M';
tstart=(Flow.startTime-Flow.itDate)*1440.0;
tstop=(Flow.stopTime-Flow.itDate)*1440.0;
MDF.Tstart=tstart;
MDF.Tstop=tstop;
MDF.Dt=Flow.timeStep;
MDF.Tzone=0;
MDF.Sub1='    ';
if Flow.salinity.include
    MDF.Sub1(1)='S';
end
if Flow.temperature.include
    MDF.Sub1(2)='T';
end
if Flow.wind
    MDF.Sub1(3)='W';
end
if Flow.secondaryFlow
    MDF.Sub1(4)='I';
end
MDF.Sub2='   ';
if Flow.nrDrogues>0
    MDF.Sub2(1)='P';
end
if Flow.sediments.include || Flow.tracers
    MDF.Sub2(2)='C';
end
if Flow.waves
    MDF.Sub2(3)='W';
end
k=0;
if Flow.sediments.include
    for i=1:Flow.nrSediments
        k=k+1;
        MDF.(['Namc' num2str(k)])=[Flow.sediment(i).name repmat(' ',1,20-length(Flow.sediment(i).name))];
    end
end
if Flow.tracers
    for i=1:Flow.nrTracers
        k=k+1;
        MDF.(['Namc' num2str(k)])=[Flow.tracer(i).name repmat(' ',1,20-length(Flow.tracer(i).name))];
    end
end
switch Flow.windType
    case{'uniform','equidistant','spiderweb'}
        MDF.Wnsvwp='N';
    case{'curvilinear'}
        MDF.Wnsvwp='Y';
end
MDF.Wndint=Flow.wndInt;
if Flow.wind
    % Always write wnd file
    if ~isempty(Flow.wndFile)
        MDF.Filwnd=Flow.wndFile;
    end
    switch Flow.windType
        case{'uniform'}
            if ~isempty(Flow.wndFile)
                MDF.Filwnd=Flow.wndFile;
            end
        case{'equidistant'}
            if ~isempty(Flow.amuFile)
                MDF.Filwu=Flow.amuFile;
            end
            if ~isempty(Flow.amvFile)
                MDF.Filwv=Flow.amvFile;
            end
            if ~isempty(Flow.ampFile)
                MDF.Filwp=Flow.ampFile;
            end
            % if met
            %     MDF.Wndgrd=Flow.wndgrd;
            %     MDF.MNmaxw=Flow.MNmaxw;
            % end
            
        case{'curvilinear'}
            if ~isempty(Flow.wndFile)
                MDF.Filwnd=Flow.wndFile;
            end
    end
end
if ~isempty(Flow.spwFile)
    MDF.Filweb=Flow.spwFile;
end

switch Flow.initialConditions,
    case{'unif'}
        MDF.Zeta0=Flow.zeta0;
        MDF.U0=Flow.u0;
        MDF.V0=Flow.v0;
        if Flow.salinity.include
            val=zeros(Flow.KMax,1)+Flow.salinity.ICConst;
            MDF.S0=val;
        end
        if Flow.temperature.include
            val=zeros(Flow.KMax,1)+Flow.temperature.ICConst;
            MDF.T0=val;
        end
        k=0;
        if Flow.sediments.include
            for i=1:Flow.nrSediments
                k=k+1;
                val=zeros(Flow.KMax,1)+Flow.sediment(i).ICConst;
                MDF.(['C0' num2str(k)])=val;
            end
        end
        if Flow.tracers
            for i=1:Flow.nrTracers
                k=k+1;
                val=zeros(Flow.KMax,1)+Flow.tracer(i).ICConst;
                MDF.(['C0' num2str(k)])=val;
            end
        end
    case{'ini'}
        MDF.Filic=Flow.iniFile;
        MDF.Fmtic='FR';
    case{'rst'}
        MDF.Restid=Flow.rstId;
    case{'trim'}
        MDF.Restid=Flow.trimId;
end
if Flow.nrOpenBoundaries>0
    MDF.Filbnd=Flow.bndFile;
    MDF.Fmtbnd='FR';
end
if Flow.nrHarmo>0
    MDF.FilbcH=Flow.bchFile;
    MDF.FmtbcH='FR';
end
if incconst && Flow.nrOpenBoundaries>0
    MDF.FilbcC=Flow.bccFile;
    MDF.FmtbcC='FR';
end
if Flow.nrTime>0
    MDF.FilbcT=Flow.bctFile;
    MDF.FmtbcT='FR';
end
if Flow.nrAstro>0
    MDF.Filana=Flow.bcaFile;
    MDF.Fmtana='FR';
end
if Flow.nrCor>0
    MDF.Filcor=Flow.corFile;
    MDF.Fmtcor='FR';
end
if Flow.nrCor>0
    MDF.Filcor=Flow.corFile;
    MDF.Fmtcor='FR';
end
if ~isempty(Flow.bc0File)
    MDF.Filbc0=Flow.bc0File;
    MDF.Fmtbc0= 'FR';
end
if incconst
    for i=1:Flow.nrOpenBoundaries
        MDF.Rettis(i)=Flow.openBoundaries(i).THLag(1);
        MDF.Rettib(i)=Flow.openBoundaries(i).THLag(2);
    end
end
MDF.Ag=Flow.g;
MDF.Rhow=Flow.rhoW;
MDF.Alph0=[];
MDF.Tempw=Flow.tempW;
MDF.Salw=Flow.salW;
if Flow.waves
    MDF.Rouwav=Flow.rouWav;
else
    MDF.Rouwav='    ';
end
%if Flow.nrWindStressBreakpoints==2
%    MDF.Wstres=[Flow.windStressCoefficients(1) Flow.windStressSpeeds(1) Flow.windStressCoefficients(2) Flow.windStressSpeeds(2)];
%else
%    MDF.Wstres=[Flow.windStressCoefficients(1) Flow.windStressSpeeds(1) Flow.windStressCoefficients(2) Flow.windStressSpeeds(2) Flow.windStressCoefficients(3) Flow.windStressSpeeds(3)];
%end
%
% To allow for more than 3 break points - Should not affect normal course
% of operations - cleaner version
MDF.Wstres(1:2:2*Flow.nrWindStressBreakpoints) = Flow.windStressCoefficients;
MDF.Wstres(2:2:2*Flow.nrWindStressBreakpoints) = Flow.windStressSpeeds;

MDF.Rhoa=Flow.rhoAir;
MDF.Betac=Flow.betaC;
if Flow.equili==1
    MDF.Equili='Y';
else
    MDF.Equili='N';
end
if Flow.KMax>1
    MDF.Tkemod=[Flow.verticalTurbulenceModel repmat(' ',1,12-length(Flow.verticalTurbulenceModel))];
else
    MDF.Tkemod='            ';
end
MDF.Ktemp=Flow.kTemp;
MDF.Fclou=Flow.fClou;
MDF.Sarea=Flow.sArea;
if Flow.kTemp~=0 && Flow.temperature.include
    MDF.Secchi=Flow.secchi;
    MDF.Stantn=Flow.stanton;
    MDF.Dalton=Flow.dalton;
    try
    MDF.Filtmp=Flow.tmpFile;
    MDF.Fmttmp='FR';
    end
    if ~isempty(Flow.amtFile)
        MDF.Filwt=Flow.amtFile;
    end
    if ~isempty(Flow.amcFile)
        MDF.Filwc=Flow.amcFile;
    end
    if ~isempty(Flow.amrFile)
        MDF.Filwr=Flow.amrFile;
    end
end

if Flow.temint==1
    MDF.Temint='Y';
else
    MDF.Temint='N';
end

% Tidal forces
if handles.model.delft3dflow.domain(id).tidalForces
    MDF.Tidfor{1}='------------';
    MDF.Tidfor{2}='------------';
    MDF.Tidfor{3}='------------';
    if handles.model.delft3dflow.domain(id).tidalForce.M2
        MDF.Tidfor{1}(1:3)='M2 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.S2
        MDF.Tidfor{1}(4:6)='S2 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.N2
        MDF.Tidfor{1}(7:9)='N2 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.K2
        MDF.Tidfor{1}(10:12)='K2 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.K1
        MDF.Tidfor{2}(1:3)='K1 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.O1
        MDF.Tidfor{2}(4:6)='O1 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.P1
        MDF.Tidfor{2}(7:9)='P1 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.Q1
        MDF.Tidfor{2}(10:12)='Q1 ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.MF
        MDF.Tidfor{3}(1:3)='MF ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.MM
        MDF.Tidfor{3}(4:6)='MM ';
    end
    if handles.model.delft3dflow.domain(id).tidalForce.SSA
        MDF.Tidfor{3}(7:9)='SSA';
    end
else
    MDF.Tidfor='';
end

MDF.Roumet=Flow.roughnessType;
if Flow.uniformRoughness
    MDF.Ccofu=Flow.uRoughness;
    MDF.Ccofv=Flow.vRoughness;
else
    MDF.Filrgh=Flow.rghFile;
end

MDF.Xlo=Flow.xlo;
MDF.Vicouv=Flow.vicoUV;
MDF.Dicouv=Flow.dicoUV;
if ~isempty(Flow.edyFile)
    MDF.Filedy=Flow.edyFile;
end
if Flow.HLES==1
    MDF.Htur2d='Y';
    MDF.Htural=Flow.Htural;
    MDF.Hturnd=Flow.Hturnd;
    MDF.Hturst=Flow.Hturst;
    MDF.Hturlp=Flow.Hturlp;
    MDF.Hturrt=Flow.Hturrt;
    MDF.Hturdm=Flow.Hturdm;
    MDF.Hturel= 'Y';
else
    MDF.Htur2d='N';
end
if Flow.KMax>1
    MDF.Vicoww=Flow.vicoWW;
    MDF.Dicoww=Flow.dicoWW;
end

MDF.Irov=Flow.irov;
if Flow.irov==1
    MDF.Z0v=Flow.z0v;
end
if Flow.nrSediments>0
    MDF.Filsed=Flow.sedFile;
    MDF.Filmor=Flow.morFile;
end
MDF.Iter=Flow.iter;
if Flow.dryFlp
    MDF.Dryflp='YES';
else
    MDF.Dryflp='NO';
end
MDF.Dpsopt=Flow.dpsOpt;
MDF.Dpuopt=Flow.dpuOpt;
MDF.Dryflc=Flow.dryFlc;
MDF.Dco=Flow.dco;
MDF.Tlfsmo=Flow.smoothingTime;
MDF.ThetQH=Flow.thetQH;
if Flow.forresterHor==1
    MDF.Forfuv='Y';
else
    MDF.Forfuv='N';
end
if Flow.forresterVer==1
    MDF.Forfww='Y';
else
    MDF.Forfww='N';
end
if Flow.sigmaCorrection
    MDF.Sigcor='Y';
else
    MDF.Sigcor='N';
end
MDF.Trasol=Flow.traSol;
MDF.Momsol=Flow.momSol;

if Flow.nrDischarges>0
    MDF.Filsrc=Flow.srcFile;
    MDF.Fmtsrc='FR';
    MDF.Fildis=Flow.disFile;
    MDF.Fmtdis='FR';
end

if Flow.nrObservationPoints>0
    MDF.Filsta=Flow.obsFile;
    MDF.Fmtsta='FR';
end
if Flow.nrCrossSections>0
    MDF.Filcrs=Flow.crsFile;
    MDF.Fmtcrs='FR';
end
if Flow.nrDrogues>0
    MDF.Filpar=Flow.droFile;
    MDF.Fmtpar='FR';
end

MDF.SMhydr=Flow.SMhydr; 
MDF.SMderv=Flow.SMderv; 
MDF.SMproc=Flow.SMproc; 
MDF.PMhydr=Flow.PMhydr; 
MDF.PMderv=Flow.PMderv; 
MDF.PMproc=Flow.PMproc; 
MDF.SHhydr=Flow.SHhydr; 
MDF.SHderv=Flow.SHderv; 
MDF.SHproc=Flow.SHproc; 
MDF.SHflux=Flow.SHflux; 
MDF.PHhydr=Flow.PHhydr; 
MDF.PHderv=Flow.PHderv; 
MDF.PHproc=Flow.PHproc; 
MDF.PHflux=Flow.PHflux; 

if Flow.storeglm
    MDF.SMvelo='GLM'; 
end
    
if Flow.onlineVisualisation
    MDF.Online='Y';
else
    MDF.Online='N';
end
if Flow.onlineCoupling
    MDF.Waqmod='Y';
else
    MDF.Waqmod='N';
end
if Flow.onlineWave
    MDF.WaveOL='Y';
else
    MDF.WaveOL='N';
end
MDF.Prhis=[0 0 0];
tstart=(Flow.mapStartTime-Flow.itDate)*1440.0;
tstop=(Flow.mapStopTime-Flow.itDate)*1440.0;
tint=Flow.mapInterval;
MDF.Flmap=[tstart tint tstop];
tstart=(Flow.startTime-Flow.itDate)*1440.0;
tstop=(Flow.stopTime-Flow.itDate)*1440.0;
if Flow.nrObservationPoints>0
    MDF.Flhis=[tstart Flow.hisInterval tstop];
else
    MDF.Flhis=[tstart 0.0 tstop];
end
tstart=(Flow.comStartTime-Flow.itDate)*1440.0;
tstop=(Flow.comStopTime-Flow.itDate)*1440.0;
tint=Flow.comInterval;
MDF.Flpp =[tstart tint tstop];
MDF.Flrst=Flow.rstInterval;

% WAQ input
if Flow.WAQcomInterval>0
    tstart=(Flow.WAQcomStartTime-Flow.itDate)*1440.0;
    tstop=(Flow.WAQcomStopTime-Flow.itDate)*1440.0;
    tint=Flow.WAQcomInterval;
    MDF.Flwq =[tstart tint tstop];
    MDF.ilAggr = str2num(Flow.ilAggr{1});
    MDF.WaqAgg = Flow.WaqAgg;
end

if Flow.airOut
    MDF.AirOut='Y';
end

if Flow.heatOut
    MDF.HeaOut='Y';
end

% Rainfall
try
if Flow.Evaint
    MDF.Evaint='Y';
end
if Flow.Maseva
    MDF.Maseva='Y';
end
if ~isempty(Flow.Fileva)
    MDF.Fileva=Flow.Fileva;
    MDF.Qevap='derived';
end
if ~isempty(Flow.Filwpr)
    MDF.Filwpr=Flow.Filwpr;
end
catch
end

        

%% Z layers
if Flow.KMax>1
    if strcmpi(Flow.layerType,'z')
        MDF.Zmodel='Y';
        MDF.Zbot=Flow.zBot;
        MDF.Ztop=Flow.zTop;
    end
end

%% Roller model
if Flow.roller.include && Flow.waves
    MDF.Roller='Y';
    if Flow.roller.snellius
        MDF.Snelli='Y';
    else
        MDF.Snelli='N';
    end
    MDF.Gamdis=Flow.roller.gamDis;
    MDF.Betaro=Flow.roller.betaRo;
    MDF.F_lam=Flow.roller.fLam;
    MDF.Thr=Flow.roller.thr;
end

if Flow.cstBnd
    MDF.CstBnd='Y';
end

if Flow.pAvBnd>0
    MDF.Pavbnd=Flow.pAvBnd;
end

if Flow.nudge
    MDF.Nudge='Y';
end

if Flow.fourier.include
    if ~isempty(Flow.fouFile)
        MDF.Filfou=Flow.fouFile;
    end
end

if Flow.timeZoneSolarRadiation~=0
    MDF.TmZRad=Flow.timeZoneSolarRadiation;
end

if ~isempty(Flow.trafrm)
    MDF.TraFrm=Flow.trafrm;
end

if Flow.retmp
    MDF.ReTMP='Y';
end

if ~Flow.ocorio
    MDF.OCorio='N';
end

if ~isempty(Flow.z0lFile)
    MDF.Filz0l=Flow.z0lFile;
end

%% Now save everything to mdf file
fname=[handles.model.delft3dflow.domain(id).runid '.mdf'];

fid=fopen(fname,'w');

Names = fieldnames(MDF);

for i=1:length(Names)
    switch lower(Names{i})
        case{'runtxt'}
            Runtxt=strvcat(MDF.Runtxt);
            if size(Runtxt,1)==0
                Runtxt=' ';
            end
            rtxt=deblank(Runtxt(1,:));
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= #' rtxt repmat(' ',1,30-length(rtxt)) '#'];
            fprintf(fid,'%s\n',str);
            n=size(Runtxt,1);
            for j=2:min(n,10)
                str=['        #' deblank(Runtxt(j,:)) repmat(' ',1,30-length(deblank(Runtxt(j,:)))) '#'];
                fprintf(fid,'%s\n',str);
            end
        case{'mnkmax','tzone','ktemp','irov','iter','hturnd','mnmaxw','ilaggr'}
            % integers
            n=length(getfield(MDF,Names{i}));
            fmt=[repmat(' %3i',1,n)];
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= ' num2str(getfield(MDF,Names{i}),fmt) ];
            fprintf(fid,'%s\n',str);
        case{'alph0','u0','v0'}
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= [.]' ];
            fprintf(fid,'%s\n',str);
        case{'thick','rettis','rettib','s0','t0','c01','c02','c03','c04','c05','c06','c07','c08','c09'}
            par=getfield(MDF,Names{i});
            sz=length(par);
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= ' num2str(par(1),'%16.7e')];
            fprintf(fid,'%s\n',str);
            if sz>1
                for j=2:sz
                    str=[repmat(' ',1,8) num2str(par(j),'%16.7e')];
                    fprintf(fid,'%s\n',str);
                end
            end
        case{'tidfor'}
            if ~isempty(MDF.Tidfor)
                str=['Tidfor= #' MDF.Tidfor{1} '#'];
                fprintf(fid,'%s\n',str);
                str=['        #' MDF.Tidfor{2} '#'];
                fprintf(fid,'%s\n',str);
                str=['        #' MDF.Tidfor{3} '#'];
                fprintf(fid,'%s\n',str);
            end
        otherwise
            if ischar(getfield(MDF,Names{i}))
                % string
                str=[Names{i} repmat(' ',1,6-length(Names{i})) '= #' getfield(MDF,Names{i}) '#'];
            else
                % scientific
                n=length(getfield(MDF,Names{i}));
                fmt=[repmat(' %15.7e',1,n)];
                str=[Names{i} repmat(' ',1,6-length(Names{i})) '= ' num2str(getfield(MDF,Names{i}),fmt) ];
            end
            fprintf(fid,'%s\n',str);
    end
end
fclose(fid);

if handles.model.delft3dflow.domain(id).waves && handles.model.delft3dflow.domain(id).onlineWave
    ddb_writeBatchFile(runid,'mdwfile',handles.model.delft3dwave.domain.mdwfile);
    try
    ddb_writeDioConfig('.\');
    end
else
    ddb_writeBatchFile(runid);
end
