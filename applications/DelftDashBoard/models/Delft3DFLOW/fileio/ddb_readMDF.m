function handles = ddb_readMDF(handles, filename, id)
%DDB_READMDF  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readMDF(handles, filename, id)
%
%   Input:
%   handles  =
%   filename =
%   id       =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_readMDF
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
MDF=ddb_readMDFText(filename);

%% Grid and bathymetry
handles.model.delft3dflow.domain(id).pathmodel=pwd;
handles.model.delft3dflow.domain(id).grdFile=MDF.filcco;
handles.model.delft3dflow.domain(id).description=MDF.runtxt;
if isfield(MDF,'anglat')
    handles.model.delft3dflow.domain(id).latitude=MDF.anglat;
end
if isfield(MDF,'anglon')
    handles.model.delft3dflow.domain(id).longitude=MDF.anglon;
end
handles.model.delft3dflow.domain(id).orientation=MDF.grdang;
handles.model.delft3dflow.domain(id).encFile=MDF.filgrd;
handles.model.delft3dflow.domain(id).MMax=MDF.mnkmax(1);
handles.model.delft3dflow.domain(id).NMax=MDF.mnkmax(2);
handles.model.delft3dflow.domain(id).KMax=MDF.mnkmax(3);
handles.model.delft3dflow.domain(id).lastKMax=handles.model.delft3dflow.domain(id).KMax;
handles.model.delft3dflow.domain(id).thick=MDF.thick;
handles.model.delft3dflow.domain(id).dryFile=MDF.fildry;
handles.model.delft3dflow.domain(id).thdFile=MDF.filtd;
handles.model.delft3dflow.domain(id).w2dFile=MDF.fil2dw;
if isfield(MDF,'fildep')
    handles.model.delft3dflow.domain(id).depFile=MDF.fildep;
    handles.model.delft3dflow.domain(id).uniformDepth=10.0;
    handles.model.delft3dflow.domain(ad).depthSource='file';
else
    handles.model.delft3dflow.domain(id).depFile='';
    handles.model.delft3dflow.domain(id).uniformDepth=10.0;
    handles.model.delft3dflow.domain(ad).depthSource='uniform';
end;

%% Time frame
handles.model.delft3dflow.domain(id).itDate=datenum(MDF.itdate,'yyyy-mm-dd');
handles.model.delft3dflow.domain(id).itDateString=datestr(handles.model.delft3dflow.domain(id).itDate,'yyyy mm dd');
handles.model.delft3dflow.domain(id).startTime=handles.model.delft3dflow.domain(id).itDate+MDF.tstart/1440.0;
handles.model.delft3dflow.domain(id).stopTime= handles.model.delft3dflow.domain(id).itDate+MDF.tstop/1440.0;
handles.model.delft3dflow.domain(id).timeStep=MDF.dt;
handles.model.delft3dflow.domain(id).timeZone=MDF.tzone;

%% Constituents and processes
if ~isempty(MDF.sub1)
    if MDF.sub1(1)=='S'
        handles.model.delft3dflow.domain(id).salinity.include=1;
        handles.model.delft3dflow.domain(id).constituents=1;
    end
    if MDF.sub1(2)=='T'
        handles.model.delft3dflow.domain(id).temperature.include=1;
        handles.model.delft3dflow.domain(id).constituents=1;
    end
    if MDF.sub1(3)=='W'
        handles.model.delft3dflow.domain(id).wind=1;
    end
    if MDF.sub1(4)=='I'
        handles.model.delft3dflow.domain(id).secondaryFlow=1;
    end
end
if ~isempty(MDF.sub2)
    if MDF.sub2(2)=='C'
        handles.model.delft3dflow.domain(id).constituents=1;
    end
    if MDF.sub2(3)=='W'
        handles.model.delft3dflow.domain(id).waves=1;
    end
end
for i=1:5
    fld=deblank(getfield(MDF,['namc' num2str(i)]));
    if ~isempty(fld)
        if strcmpi(fld(1:min(8,length(fld))),'sediment')
            handles.model.delft3dflow.domain(id).sediments.include=1;
            handles.model.delft3dflow.domain(id).nrSediments=handles.model.delft3dflow.domain(id).nrSediments+1;
            handles.model.delft3dflow.domain(id).nrConstituents=handles.model.delft3dflow.domain(id).nrConstituents+1;
            k=handles.model.delft3dflow.domain(id).nrSediments;
            handles.model.delft3dflow.domain(id).sediment(k).name=deblank(fld);
            handles.model.delft3dflow.domain(id).sediment(k).type='non-cohesive';
            handles.model.delft3dflow.domain(id).sediments.sedimentNames{k}=deblank(fld);
        else
            handles.model.delft3dflow.domain(id).tracers=1;
            handles.model.delft3dflow.domain(id).nrConstituents=handles.model.delft3dflow.domain(id).nrConstituents+1;
            handles.model.delft3dflow.domain(id).nrTracers=handles.model.delft3dflow.domain(id).nrTracers+1;
            k=handles.model.delft3dflow.domain(id).nrTracers;
            handles.model.delft3dflow.domain(id).tracer(k).name=deblank(fld);
        end
    end
end


%% Wind
handles.model.delft3dflow.domain(id).wndFile=MDF.filwnd;
if MDF.wnsvwp=='N'
    handles.model.delft3dflow.domain(id).windType='uniform';
else
    handles.model.delft3dflow.domain(id).windType='curvilinear';
end

%% Initial conditions
handles.model.delft3dflow.domain(id).zeta0=MDF.zeta0;
handles.model.delft3dflow.domain(id).u0=0.0;
handles.model.delft3dflow.domain(id).v0=0.0;
handles.model.delft3dflow.domain(id).s0=0.0;
handles.model.delft3dflow.domain(id).c0=0.0;

if ~isempty(MDF.filic)
    handles.model.delft3dflow.domain(id).iniFile=MDF.filic;
    handles.model.delft3dflow.domain(id).initialConditions='ini';
else
    handles.model.delft3dflow.domain(id).iniFile='';
end
if ~isempty(MDF.restid)
    handles.model.delft3dflow.domain(id).rstId=MDF.restid;
    handles.model.delft3dflow.domain(id).initialConditions='rst';
else
    handles.model.delft3dflow.domain(id).rstId='';
end
% if isfield(MDF,'trim')
%     handles.model.delft3dflow.domain(id).RstId=MDF.restid;
%     handles.model.delft3dflow.domain(id).InitialConditions='rst';
% else
%     handles.model.delft3dflow.domain(id).RstId='';
% end

%% Boundaries
handles.model.delft3dflow.domain(id).bndFile=MDF.filbnd;
handles.model.delft3dflow.domain(id).bchFile=MDF.filbch;
handles.model.delft3dflow.domain(id).bctFile=MDF.filbct;
handles.model.delft3dflow.domain(id).bcaFile=MDF.filana;
handles.model.delft3dflow.domain(id).corFile=MDF.filcor;
handles.model.delft3dflow.domain(id).bcqFile=MDF.filbcq;
handles.model.delft3dflow.domain(id).bc0File=MDF.filbc0;
if isfield(MDF,'filbcc')
    handles.model.delft3dflow.domain(id).bccFile=MDF.filbcc;
else
    handles.model.delft3dflow.domain(id).bccFile='';
end

%% Sources and sinks
handles.model.delft3dflow.domain(id).srcFile=MDF.filsrc;
handles.model.delft3dflow.domain(id).disFile=MDF.fildis;

%% Constants
handles.model.delft3dflow.domain(id).g=MDF.ag;
handles.model.delft3dflow.domain(id).rhoW=MDF.rhow;
%Alph0 = [.]
handles.model.delft3dflow.domain(id).tempW=MDF.tempw;
handles.model.delft3dflow.domain(id).salW=MDF.salw;
if ~isempty(deblank(MDF.rouwav))
    handles.model.delft3dflow.domain(id).rouWav=MDF.rouwav;
end
handles.model.delft3dflow.domain(id).nrWindStressBreakpoints=length(MDF.wstres)/2;
% if handles.model.delft3dflow.domain(id).nrWindStressBreakpoints==2
%     handles.model.delft3dflow.domain(id).windStressCoefficients=[MDF.wstres(1) MDF.wstres(3)];
%     handles.model.delft3dflow.domain(id).windStressSpeeds=[MDF.wstres(2) MDF.wstres(4)];
% else
%     handles.model.delft3dflow.domain(id).windStressCoefficients=[MDF.wstres(1) MDF.wstres(3) MDF.wstres(5)];
%     handles.model.delft3dflow.domain(id).windStressSpeeds=[MDF.wstres(2) MDF.wstres(4) MDF.wstres(6)];
% end
handles.model.delft3dflow.domain(id).windStressCoefficients=MDF.wstres(1:2:end);
handles.model.delft3dflow.domain(id).windStressSpeeds=MDF.wstres(2:2:end);

%% Heat model
handles.model.delft3dflow.domain(id).rhoAir=MDF.rhoa;
handles.model.delft3dflow.domain(id).betaC=MDF.betac;
handles.model.delft3dflow.domain(id).kTemp=MDF.ktemp;
handles.model.delft3dflow.domain(id).fClou=MDF.fclou;
handles.model.delft3dflow.domain(id).sArea=MDF.sarea;
handles.model.delft3dflow.domain(id).secchi=MDF.secchi;
handles.model.delft3dflow.domain(id).stantn=MDF.stantn;
handles.model.delft3dflow.domain(id).dalton=MDF.dalton;

if isfield(MDF,'filtmp')
    if ~isempty(MDF.filtmp)
        handles.model.delft3dflow.domain(id).tmpFile=MDF.filtmp;
    end
end

if MDF.temint(1)=='N'
    handles.model.delft3dflow.domain(id).temint=0;
else
    handles.model.delft3dflow.domain(id).temint=1;
end

%% Tidal forces
if ~isempty(MDF.tidfor)
    handles.model.delft3dflow.domain(id).tidalForces=1;
    for i=1:3
        line1=MDF.tidfor{i};
        for j=1:4
            str=line1((j-1)*3+1:(j-1)*3+3);
            if ~strcmpi(str,'---')
                handles.model.delft3dflow.domain(id).tidalForce.(deblank(str))=1;
            end
        end
    end
end

%% Roughness
handles.model.delft3dflow.domain(id).roughnessType=MDF.roumet;
handles.model.delft3dflow.domain(id).uRoughness=MDF.ccofu;
handles.model.delft3dflow.domain(id).vRoughness=MDF.ccofv;
handles.model.delft3dflow.domain(id).xlo=MDF.xlo;
handles.model.delft3dflow.domain(id).irov=MDF.irov;
handles.model.delft3dflow.domain(id).rghFile='';
handles.model.delft3dflow.domain(id).uniformRoughness=1;
if isfield(MDF,'filrgh')
    if ~isempty(MDF.filrgh)
        handles.model.delft3dflow.domain(id).rghFile=MDF.filrgh;
        handles.model.delft3dflow.domain(id).uniformRoughness=0;
    end
end

%% Viscosity
handles.model.delft3dflow.domain(id).vicoUV=MDF.vicouv;
handles.model.delft3dflow.domain(id).dicoUV=MDF.dicouv;
if MDF.htur2d(1)=='N'
    handles.model.delft3dflow.domain(id).HLES=0;
else
    handles.model.delft3dflow.domain(id).HLES=1;
    handles.model.delft3dflow.domain(id).Htural=MDF.htural;
    handles.model.delft3dflow.domain(id).Hturnd=MDF.hturnd;
    handles.model.delft3dflow.domain(id).Hturst=MDF.hturst;
    handles.model.delft3dflow.domain(id).Hturlp=MDF.hturlp;
    handles.model.delft3dflow.domain(id).Hturrt=MDF.hturrt;
    handles.model.delft3dflow.domain(id).Hturdm=MDF.hturdm;
    handles.model.delft3dflow.domain(id).Hturel=1;
end
if isfield(MDF,'vicoww')
    handles.model.delft3dflow.domain(id).vicoWW=MDF.vicoww;
end
if isfield(MDF,'dicoww')
    handles.model.delft3dflow.domain(id).dicoWW=MDF.dicoww;
end
if MDF.equili(1)=='N'
    handles.model.delft3dflow.domain(id).equili=0;
else
    handles.model.delft3dflow.domain(id).equili=1;
end
if isempty(deblank(MDF.tkemod))
    handles.model.delft3dflow.domain(id).verticalTurbulenceModel='K-epsilon   ';
else
    handles.model.delft3dflow.domain(id).verticalTurbulenceModel=MDF.tkemod;
end
if isfield(MDF,'filedy')
    if ~isempty(MDF.filedy)
        handles.model.delft3dflow.domain(id).edyFile=MDF.filedy;
        handles.model.delft3dflow.domain(id).uniformEddyViscosity=0;
    end
end

%% Morphology
if isfield(MDF,'filsed')
    handles.model.delft3dflow.domain(id).sedFile=MDF.filsed;
else
    handles.model.delft3dflow.domain(id).sedFile='';
end
if isfield(MDF,'filmor')
    handles.model.delft3dflow.domain(id).morFile=MDF.filmor;
else
    handles.model.delft3dflow.domain(id).morFile='';
end

%% Numerical
handles.model.delft3dflow.domain(id).iter=MDF.iter;
if strcmpi(MDF.dryflp(1),'n')
    handles.model.delft3dflow.domain(id).dryFlp=0;
else
    handles.model.delft3dflow.domain(id).dryFlp=1;
end
handles.model.delft3dflow.domain(id).dpsOpt=MDF.dpsopt;
handles.model.delft3dflow.domain(id).dpuOpt=MDF.dpuopt;
handles.model.delft3dflow.domain(id).dryFlc=MDF.dryflc;
handles.model.delft3dflow.domain(id).dco=MDF.dco;
handles.model.delft3dflow.domain(id).smoothingTime=MDF.tlfsmo;
handles.model.delft3dflow.domain(id).thetQH=MDF.thetqh;

if strcmpi(MDF.forfuv(1),'n')
    handles.model.delft3dflow.domain(id).forresterHor=0;
else
    handles.model.delft3dflow.domain(id).forresterHor=1;
end
if strcmpi(MDF.forfww(1),'n')
    handles.model.delft3dflow.domain(id).forresterVer=0;
else
    handles.model.delft3dflow.domain(id).forresterVer=1;
end
if strcmpi(MDF.sigcor(1),'n')
    handles.model.delft3dflow.domain(id).sigmaCorrection=0;
else
    handles.model.delft3dflow.domain(id).sigmaCorrection=1;
end
handles.model.delft3dflow.domain(id).traSol=MDF.trasol;
handles.model.delft3dflow.domain(id).momSol=MDF.momsol;

%% Observations
handles.model.delft3dflow.domain(id).obsFile=MDF.filsta;
handles.model.delft3dflow.domain(id).crsFile=MDF.filcrs;
handles.model.delft3dflow.domain(id).droFile=MDF.filpar;

%% Coupling
if strcmpi(MDF.online(1),'n')
    handles.model.delft3dflow.domain(id).onlineVisualisation=0;
else
    handles.model.delft3dflow.domain(id).onlineVisualisation=1;
end
if isfield(MDF,'waqmod')
    if strcmpi(MDF.waqmod(1),'n')
        handles.model.delft3dflow.domain(id).waqMod=0;
    else
        handles.model.delft3dflow.domain(id).waqMod=1;
    end
end

%% Wave online
if isfield(MDF,'waveol')
    if strcmpi(MDF.waveol(1),'n')
        handles.model.delft3dflow.domain(id).onlineWave=0;
    else
        handles.model.delft3dflow.domain(id).onlineWave=1;
    end
end

% Output details
handles.model.delft3dflow.domain(id).SMhydr=MDF.smhydr;
handles.model.delft3dflow.domain(id).SMderv=MDF.smderv;
handles.model.delft3dflow.domain(id).SMproc=MDF.smproc;
handles.model.delft3dflow.domain(id).PMhydr=MDF.pmhydr;    
handles.model.delft3dflow.domain(id).PMderv=MDF.pmderv;       
handles.model.delft3dflow.domain(id).PMproc=MDF.pmproc;
handles.model.delft3dflow.domain(id).SHhydr=MDF.shhydr;      
handles.model.delft3dflow.domain(id).SHderv=MDF.shderv;     
handles.model.delft3dflow.domain(id).SHproc=MDF.shproc;
handles.model.delft3dflow.domain(id).SHflux=MDF.shflux;      
handles.model.delft3dflow.domain(id).PHhydr=MDF.phhydr;    
handles.model.delft3dflow.domain(id).PHderv=MDF.phderv;       
handles.model.delft3dflow.domain(id).PHproc=MDF.phproc;
handles.model.delft3dflow.domain(id).PHflux=MDF.phflux;      
if isfield(MDF,'smvelo')
    if MDF.smvelo(1)=='G'
        handles.model.delft3dflow.domain(id).storeglm=1;
    end
end

%% Output
handles.model.delft3dflow.domain(id).prHis=MDF.prhis;
handles.model.delft3dflow.domain(id).mapStartTime=handles.model.delft3dflow.domain(id).itDate+MDF.flmap(1)/1440;
handles.model.delft3dflow.domain(id).mapInterval=MDF.flmap(2);
handles.model.delft3dflow.domain(id).mapStopTime=handles.model.delft3dflow.domain(id).itDate+MDF.flmap(3)/1440;
handles.model.delft3dflow.domain(id).hisInterval=MDF.flhis(2);
handles.model.delft3dflow.domain(id).comStartTime=handles.model.delft3dflow.domain(id).itDate+MDF.flpp(1)/1440;
handles.model.delft3dflow.domain(id).comInterval=MDF.flpp(2);
handles.model.delft3dflow.domain(id).comStopTime=handles.model.delft3dflow.domain(id).itDate+MDF.flpp(3)/1440;
handles.model.delft3dflow.domain(id).rstInterval=MDF.flrst;

%% Meteo data on equidistant grid
handles.model.delft3dflow.domain(id).ampFile=MDF.filwp;
handles.model.delft3dflow.domain(id).amuFile=MDF.filwu;
handles.model.delft3dflow.domain(id).amvFile=MDF.filwv;
handles.model.delft3dflow.domain(id).wndgrd=MDF.wndgrd;
handles.model.delft3dflow.domain(id).MNmaxw=MDF.mnmaxw;

handles.model.delft3dflow.domain(id).amtFile=MDF.filwt;
handles.model.delft3dflow.domain(id).amcFile=MDF.filwc;
handles.model.delft3dflow.domain(id).amrFile=MDF.filwr;

handles.model.delft3dflow.domain(id).spwFile=MDF.filweb;
if ~isempty(handles.model.delft3dflow.domain(id).spwFile)
    handles.model.delft3dflow.domain(id).windType='spiderweb';
end

if ~isempty(handles.model.delft3dflow.domain(id).amuFile)
    handles.model.delft3dflow.domain(id).windType='equidistant';
end

if isfield(MDF,'pavbnd')
    handles.model.delft3dflow.domain(id).pAvBnd=MDF.pavbnd;
end

if isfield(MDF,'nudge')
    if MDF.nudge(1)=='Y'
        handles.model.delft3dflow.domain(id).nudge=1;
    end
end

handles.model.delft3dflow.domain(id).Filwpr=MDF.filwpr;
handles.model.delft3dflow.domain(id).Fileva=MDF.fileva;
handles.model.delft3dflow.domain(id).Evaint=MDF.evaint;
handles.model.delft3dflow.domain(id).Maseva=MDF.maseva;

%% Z-layers
if isfield(MDF,'zmodel')
    if strcmpi(MDF.zmodel(1),'y')
        handles.model.delft3dflow.domain(id).layerType='z';
    end
end
if isfield(MDF,'zbot')
    handles.model.delft3dflow.domain(id).zBot=MDF.zbot;
end
if isfield(MDF,'ztop')
    handles.model.delft3dflow.domain(id).zTop=MDF.ztop;
end

%% Roller model
if isfield(MDF,'roller')
    if strcmpi(MDF.roller(1),'y')
        handles.model.delft3dflow.domain(id).roller.include=1;
    end
end
if isfield(MDF,'snelli')
    if strcmpi(MDF.snelli(1),'y')
        handles.model.delft3dflow.domain(id).roller.snellius=1;
    end
end
if isfield(MDF,'gamdis')
    handles.model.delft3dflow.domain(id).roller.gamDis=MDF.gamdis;
end
if isfield(MDF,'betaro')
    handles.model.delft3dflow.domain(id).roller.betaRo=MDF.betaro;
end
if isfield(MDF,'f_lam')
    handles.model.delft3dflow.domain(id).roller.flam=MDF.f_lam;
end
if isfield(MDF,'thr')
    handles.model.delft3dflow.domain(id).roller.thr=MDF.thr;
end

if isfield(MDF,'cstbnd')
    if strcmpi(MDF.cstbnd(1),'y')
        handles.model.delft3dflow.domain(id).cstBnd=1;
    end
end

if isfield(MDF,'airout')
    if strcmpi(MDF.airout(1),'y')
        handles.model.delft3dflow.domain(id).airOut=1;
    end
end

if isfield(MDF,'heaout')
    if strcmpi(MDF.heaout(1),'y')
        handles.model.delft3dflow.domain(id).heatOut=1;
    end
end

if isfield(MDF,'filfou')
    if ~isempty(MDF.filfou)
        handles.model.delft3dflow.domain(id).fouFile=MDF.filfou;
        handles.model.delft3dflow.domain(id).fourier.include=1;
    end
end

if isfield(MDF,'tmzrad')
    handles.model.delft3dflow.domain(id).timeZoneSolarRadiation=MDF.tmzrad;
end

if isfield(MDF,'trafrm')
    handles.model.delft3dflow.domain(id).trafrm=MDF.trafrm;
end

if isfield(MDF,'retmp')
    if strcmpi(MDF.retmp(1),'y')
        handles.model.delft3dflow.domain(id).retmp=1;
    end
end

if isfield(MDF,'ocorio')
    if strcmpi(MDF.ocorio(1),'n')
        handles.model.delft3dflow.domain(id).ocorio=0;
    end
end

if isfield(MDF,'filz0l')
    handles.model.delft3dflow.domain(id).z0lFile=MDF.filz0l;
end

% Cstbnd= #yes#
% TraFrm= #vrijn2004.frm#
% Trtrou= #Y#
% Trtdef= #vrijn04.trt#
% Trtu  = #trtuv.inp#
% Trtv  = #trtuv.inp#
% TrtDt = 2.

