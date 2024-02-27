function ddb_TideDatabaseToolbox_calibrate(varargin)
%DDB_TIDEDATABASETOOLBOX_CALIBRATE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TideDatabaseToolbox_calibrate(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TideDatabaseToolbox_calibrate
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_TideDatabaseToolbox_calibrate.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TideDatabase/ddb_TideDatabaseToolbox_calibrate.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('tidedatabasepanel.calibrate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'calibrate'}
            calibrate;
        case{'savenewfourierfile'}
            saveNewFourierFile;
    end
end

%%
function calibrate

wb = waitbox('Calibrating ...');pause(0.1);

try
    
    handles=getHandles;
    
    [x,y,comp,amp,phi]=readFourierFile(handles.toolbox.tidedatabase.fourierFile);
    
    ii=handles.toolbox.tidedatabase.activeModel;
    name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    model=handles.activeModel.name;
    bnd=handles.model.(model).domain(ad).openBoundaries;
    for ib=1:length(bnd)
        switch bnd(ib).side
            case{'left'}
                ma=bnd(ib).M1+1;
                mb=bnd(ib).M2+1;
                na=bnd(ib).N1;
                nb=bnd(ib).N2;
            case{'right'}
                ma=bnd(ib).M1-1;
                mb=bnd(ib).M2-1;
                na=bnd(ib).N1;
                nb=bnd(ib).N2;
            case{'bottom'}
                ma=bnd(ib).M1;
                mb=bnd(ib).M2;
                na=bnd(ib).N1+1;
                nb=bnd(ib).N2+1;
            case{'top'}
                ma=bnd(ib).M1;
                mb=bnd(ib).M2;
                na=bnd(ib).N1-1;
                nb=bnd(ib).N2-1;
        end
        xb(ib,1)=handles.model.(model).domain(ad).gridXZ(ma,na);
        yb(ib,1)=handles.model.(model).domain(ad).gridYZ(ma,na);
        xb(ib,2)=handles.model.(model).domain(ad).gridXZ(mb,nb);
        yb(ib,2)=handles.model.(model).domain(ad).gridYZ(mb,nb);
    end
    cs0.name='WGS 84';
    cs0.type='spherical';
    [xb,yb]=ddb_coordConvert(xb,yb,handles.screenParameters.coordinateSystem,cs0);
    
    for i=1:length(amp)
        
        [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',xb,'y',yb,'constituent',comp{i});
        ampz=squeeze(ampz(i,:,:));
        phasez=squeeze(phasez(i,:,:));
        
        for ib=1:length(bnd)
            
            compSetA=bnd(ib).compA;
            compSetB=bnd(ib).compB;
            astrosets=handles.model.(model).domain(ad).astronomicComponentSets;
            for iastr=1:length(astrosets)
                astrosetNames{iastr}=lower(astrosets(iastr).name);
            end
            isetA=strmatch(lower(compSetA),astrosetNames,'exact');
            isetB=strmatch(lower(compSetB),astrosetNames,'exact');
            
            ja=strmatch(comp{i},handles.model.(model).domain(ad).astronomicComponentSets(isetA).component,'exact');
            jb=strmatch(comp{i},handles.model.(model).domain(ad).astronomicComponentSets(isetB).component,'exact');
            
            switch bnd(ib).side
                case{'left'}
                    ma=bnd(ib).M1+1;
                    mb=bnd(ib).M2+1;
                    na=bnd(ib).N1;
                    nb=bnd(ib).N2;
                case{'right'}
                    ma=bnd(ib).M1-1;
                    mb=bnd(ib).M2-1;
                    na=bnd(ib).N1;
                    nb=bnd(ib).N2;
                case{'bottom'}
                    ma=bnd(ib).M1;
                    mb=bnd(ib).M2;
                    na=bnd(ib).N1+1;
                    nb=bnd(ib).N2+1;
                case{'top'}
                    ma=bnd(ib).M1;
                    mb=bnd(ib).M2;
                    na=bnd(ib).N1-1;
                    nb=bnd(ib).N2-1;
            end
            
            ampfaca=ampz(ib,1)/amp{i}(ma,na);
            ampfacb=ampz(ib,2)/amp{i}(mb,nb);
            if phasez(ib,1)-phi{i}(ma,na)>180
                phifaca=phasez(ib,1)-(phi{i}(ma,na)+360);
            elseif phasez(ib,1)-phi{i}(ma,na)<-180
                phifaca=phasez(ib,1)+360-phi{i}(ma,na);
            else
                phifaca=phasez(ib,1)-phi{i}(ma,na);
            end
            if phasez(ib,2)-phi{i}(mb,nb)>180
                phifacb=phasez(ib,2)-(phi{i}(mb,nb)+360);
            elseif phasez(ib,2)-phi{i}(mb,nb)<-180
                phifacb=phasez(ib,2)+360-phi{i}(mb,nb);
            else
                phifacb=phasez(ib,2)-phi{i}(mb,nb);
            end
            
            ampfaca(isnan(ampfaca))=1.0;
            ampfacb(isnan(ampfacb))=1.0;
            phifaca(isnan(phifaca))=0.0;
            phifacb(isnan(phifacb))=0.0;
            ampfaca=min(max(ampfaca,0.5),2.0);
            ampfacb=min(max(ampfacb,0.5),2.0);
            
            
            model=handles.activeModel.name;
            handles.model.(model).domain(ad).astronomicComponentSets(isetA).correction(ja)=1;
            handles.model.(model).domain(ad).astronomicComponentSets(isetA).amplitudeCorrection(ja)=handles.model.(model).domain(ad).astronomicComponentSets(isetA).amplitudeCorrection(ja)*ampfaca;
            handles.model.(model).domain(ad).astronomicComponentSets(isetA).phaseCorrection(ja)=handles.model.(model).domain(ad).astronomicComponentSets(isetA).phaseCorrection(ja)+phifaca;
            handles.model.(model).domain(ad).astronomicComponentSets(isetB).correction(jb)=1;
            handles.model.(model).domain(ad).astronomicComponentSets(isetB).amplitudeCorrection(jb)=handles.model.(model).domain(ad).astronomicComponentSets(isetB).amplitudeCorrection(jb)*ampfacb;
            handles.model.(model).domain(ad).astronomicComponentSets(isetB).phaseCorrection(jb)=handles.model.(model).domain(ad).astronomicComponentSets(isetB).phaseCorrection(jb)+phifacb;
            
        end
        
    end
    
    close(wb);
    
    [filename, pathname, filterindex] = uiputfile('*.cor', 'Select Astronomic Corrections File',handles.model.(model).domain(ad).corFile);
    if ~isempty(pathname)
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        
        handles.model.(model).domain(ad).corFile=filename;
        handles=ddb_saveCorFile(handles,ad);
        handles=ddb_countOpenBoundaries(handles,ad);
        setHandles(handles);
    end
    
catch
    close(wb);
    ddb_giveWarning('text','An error occured while calibrating!');
end


%%
function saveNewFourierFile

handles=getHandles;

wb = waitbox('Saving ...');pause(0.1);

[x,y,comp,amp,phi]=readFourierFile(handles.toolbox.tidedatabase.fourierFile);
ddb_saveAstroMapFile(handles.toolbox.tidedatabase.fourierOutFile,x,y,comp,amp,phi);

close(wb);

%%
function [x,y,comp,amp,phi]=readFourierFile(fname)

fi=tekal('read',fname);

for i=1:length(fi.Field)
    mmax=fi.Field(i).Size(3);
    nmax=fi.Field(i).Size(4);
    str=fi.Field(i).Name;
    str=strread(str,'%s','delimiter',' ');
    f(i)=str2double(str{3});
    x=squeeze(fi.Field(i).Data(:,:,1));
    y=squeeze(fi.Field(i).Data(:,:,2));
    amp0=squeeze(fi.Field(i).Data(:,:,7));
    phi0=squeeze(fi.Field(i).Data(:,:,8));
    kcs0=squeeze(fi.Field(i).Data(:,:,9));
    kfu0=squeeze(fi.Field(i).Data(:,:,10));
    kfv0=squeeze(fi.Field(i).Data(:,:,11));
    x=reshape(x,mmax,nmax);
    y=reshape(y,mmax,nmax);
    amp0=reshape(amp0,mmax,nmax);
    phi0=reshape(phi0,mmax,nmax);
    kcs0=reshape(kcs0,mmax,nmax);
    kfu0=reshape(kfu0,mmax,nmax);
    kfv0=reshape(kfv0,mmax,nmax);
    x(x==999.999)=NaN;
    y(y==999.999)=NaN;
    amp0(amp0==999.999)=NaN;
    phi0(phi0==999.999)=NaN;
    amp{i}=amp0;
    phi{i}=phi0;
    amp{i}(kcs0+kfu0+kfv0<3)=NaN;
    phi{i}(kcs0+kfu0+kfv0<3)=NaN;
end

const=t_getconsts;
freqs=const.freq; % freq in cycles per hour
freqs=360*freqs;

for i=1:length(amp)
    ifreq= abs(freqs-f(i))==min(abs(freqs-f(i)));
    comp{i}=deblank(upper(const.name(ifreq,:)));
end

