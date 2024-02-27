function bct2bch(bctfile,bchfile,tstart,tstop,ncomp,varargin)
% Creates bch file from bct file (using 'good old' TYD2HAR.EXE)
% bct2bch(bctfile,bchfile,tstart,tstop,ncomp,varargin)
%
% e.g. bct2bch('DD_GOM2_4KM.bct','test.bch',datenum(2011,1,5),datenum(2011,1,6),4,'plot')
%
% By default, the A0 component is ignored. If A0 needs to be included in
% BCH file, use input argument INCLUDEA0.
% 
% e.g. bct2bch('DD_GOM2_4KM.bct','test.bch',datenum(2011,1,5),datenum(2011,1,6),4,'includea0')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
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

t2hfolder=fileparts(which('tyd2har.exe'));

icor=1;
deletetempfiles=1;
ianul=1;
iplot=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'keeptemporaryfiles'}
                deletetempfiles=0;
            case{'includea0'}
                ianul=1;
            case{'plot'}
                iplot=1;
        end
    end
end

% Read bct file
bct=bct_io('read',bctfile);

ict=1;
ih=1;
nt=size(bct.Table(1).Data,1);
ntot=length(bct.Table);
nriv=0;
tref=bct.Table(1).ReferenceTime;
tref=num2str(tref);
tref=datenum(tref,'yyyymmdd');
start=bct.Table(1).Data(1,1);
stap=bct.Table(1).Data(2,1)-bct.Table(1).Data(1,1);
beg=(tstart-tref)*1440;
per=(tstop-tstart)*1440;

fid=fopen('tyd2har1.inp','wt');
fprintf(fid,'%i %i %i %i %i %i %12.1f %12.1f %i %12.1f %12.1f %i\n',ict,ih,ianul,nt,ntot,nriv,start,stap,ncomp,beg,per,icor);
fclose(fid);

fid=fopen('tyd2har2.inp','wt');
fprintf(fid,'%s\n','tyd2har1.inp');
fprintf(fid,'%s\n',bctfile);
fprintf(fid,'%s\n',bchfile);
fprintf(fid,'%s\n','tyd2har.log');
fclose(fid);

system([t2hfolder filesep 'tyd2har.exe<tyd2har2.inp']);

if deletetempfiles
    delete('tyd2har1.inp');
    delete('tyd2har2.inp');
end    

if iplot
    for ii=1:ntot
        bch=delft3d_io_bch('read',bchfile);
        tbct=tref+bct.Table(ii).Data(:,1)/1440;        
        it1=find(tbct==tstart);
        it2=find(tbct==tstop);        
        bctt=bct.Table(ii).Data(it1:it2,1);
        bctt=bctt-bctt(1);
        bctt=bctt/1440;
        bcta=bct.Table(ii).Data(it1:it2,2);
        bctb=bct.Table(ii).Data(it1:it2,3);

        bcht=bctt(1):10/1440:bctt(end)';
        bcha=zeros(size(bcht));
        bchb=bcha;
        for ic=2:bch.nof
            freq=bch.frequencies(ic); % deg/h
            freq=freq*24;             % deg/d
            freq=freq*pi/180;         % rad/d
            va=bch.amplitudes(1,ii,ic-1)*cos(freq*bcht-pi*bch.phases(1,ii,ic-1)/180);
            vb=bch.amplitudes(2,ii,ic-1)*cos(freq*bcht-pi*bch.phases(2,ii,ic-1)/180);
            bcha=bcha+va;
            bchb=bchb+vb;
        end
        figure(ii)
        subplot(2,1,1)
        plot(bcht,bcha,'b');hold on;
        plot(bctt,bcta,'r');hold on;
        subplot(2,1,2)
        plot(bcht,bchb,'b');hold on;
        plot(bctt,bctb,'r');hold on;
    end
end

% 1 1 0 4321 38 0 -20360 10 4 0 750 1
%  
% c **********************************************************************
% c     in de invoer file worden achtereenvolgens ingelezen:
% c     ict, ih, ianul, nt,  ntot, nriv, start, stap, nc, beg,  per,  icor
% c
% c     voorbeeld invoerfile:
% c     2    2   0      1297 37    2     0.     10.   12  6740. 1480  1
% c
% c **********************************************************************
% C
% C     VARIABELE  BETEKENIS
% C     ---------  ---------
% C     ict        (1/2) respectievelijk harm. comp. of tijdserie
% C     ih         wel/niet (1/2) oneven componenten meenemen
% C     ianul      niet/wel (0/1) a0 correctie
% C     nt         Aantal tijdstappen in tijdseriefile
% C     Ntot       AANTAL tidal openings (inclusief rivieren)
% C     nriv       AANTAL rivier openings
% C     START      STARTTIJD TIJDREEKS (IN MINUTEN T.O.V. ITDATE)
% C     STAP       STAPGROOTTE IN MINUTEN
% C     nc         aantal componenten
% C     beg        starttijd analyse
% C     per        periode van de analyse
% C     icor       niet/wel (0/1) correctie fasehoeken begin-eind
