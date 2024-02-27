function wl = makeTidePrediction(tim, components, amplitudes, phases, latitude, varargin)
%MAKETIDEPREDICTION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   wl = makeTidePrediction(tim, components, amplitudes, phases, latitude, varargin)
%
%   Input:
%   tim        =
%   components =
%   amplitudes =
%   phases     =
%   latitude   =
%   varargin   =
%
%   Output:
%   wl         =
%
%   Example
%   makeTidePrediction
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

% $Id: makeTidePrediction.m 11762 2015-03-03 11:02:31Z ormondt $
% $Date: 2015-03-03 19:02:31 +0800 (Tue, 03 Mar 2015) $
% $Author: ormondt $
% $Revision: 11762 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TideStations/makeTidePrediction.m $
% $Keywords: $

%%
timeZone=0;
timeZoneStation=0;
maincomponents=0;
saseqx=0;
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'timezone'}
                timeZone=varargin{i+1};
            case{'timezonestation'}
                timeZoneStation=varargin{i+1};
            case{'maincomponents'}
                maincomponents=varargin{i+1};
            case{'saseqx'}
                saseqx=varargin{i+1};
        end
    end
end

const=t_getconsts;
k=0;
for i=1:length(amplitudes)
    cmp=components{i};
    cmp = delft3d_name2t_tide(cmp);
    if length(cmp)>4
        cmp=cmp(1:4);
    end
    name=[cmp repmat(' ',1,4-length(cmp))];
    ju=strmatch(name,const.name,'exact');
    if isempty(ju)
%        disp(['Could not find ' name ' - Component skipped.']);
    else
        icont=1;
        if maincomponents
            % Only use main components
            switch lower(cmp)
                case{'m2','s2','k2','n2','k1','o1','p1','q1','mf','mm','m4','ms4','mn4'}
                    % Skip this component
                    icont=1;
                case{'sa','ssa'}
%                case{'m2','s2','k2','n2','k1','o1','p1','q1'}
                    % Continue
                    icont=0;
                otherwise
                    % Skip this component
                    icont=0;
            end
        end
                
        if icont
            k=k+1;
            names(k,:)=name;
            freq(k,1)=const.freq(ju);
            tidecon(k,1)=amplitudes(i);
            tidecon(k,2)=0;
            % convert time zone
            if timeZone~=0
                phases(i)=phases(i)+360*(timeZone+timeZoneStation)*const.freq(ju);
                phases(i)=mod(phases(i),360);
            end
            tidecon(k,3)=phases(i);
            if saseqx
                % Reference date SA component defined at spring equinox
                switch lower(name)
                    case{'sa  '}
                        tidecon(k,3)=tidecon(k,3)+77; % Reference date SA component defined at spring equinox
                end
            end
            tidecon(k,4)=0;
        end
    end
end

%if ~use_xtide
    
    % Use t_predic.m
    
    wl=t_predic(tim,names,freq,tidecon,latitude);
    
% else
% 
%     % Use t_xtide.m
% 
%     xtide_struc=load('t_xtide.mat');
%     
%     xtide_struc.xharm.station='station';
%     xtide_struc.xharm.units='meters  ';
%     xtide_struc.xharm.longitude=-74;
%     xtide_struc.xharm.latitude=latitude;
%     xtide_struc.xharm.timezone=0;
%     xtide_struc.xharm.datum=0;
%     
%     xtide_struc.xharm.A=zeros(1,size(xtide_struc.xharm.A,2));
%     xtide_struc.xharm.kappa=xtide_struc.xharm.A;
%     
%     % Fill amplitudes and phases
%     for ii=1:length(freq)
%         ju=[];
%         for jj=1:size(xtide_struc.xtide.name,1)
%             if strcmpi(deblank2(xtide_struc.xtide.name(jj,:)),deblank2(names(ii,:)))
%                 ju=jj;
%                 break
%             end
%         end
%         if ~isempty(ju)
%             xtide_struc.xharm.A(ju)=tidecon(ii,1);
%             xtide_struc.xharm.kappa(ju)=tidecon(ii,3);
% %             disp([names(ii,:) ' ' num2str(tidecon(ii,1)) ' ' num2str(tidecon(ii,3))])
%         else
%             disp(['Component ' deblank2(names(ii,:)) ' not found!']);
%         end
%     end
%         
%     xtide_station='station';
%     info=t_xtide(xtide_station,tim,'units','metres','format','info','xtide_struc',xtide_struc);
%     wl=t_xtide(xtide_station,tim+info.timezone/24,'units','metres','xtide_struc',xtide_struc);
%     wl=wl-info.datum;
% 
% end

%     xtide_station='atlantic city';
%     info=t_xtide(xtide_station,tim,'units','metres','format','info');
%     wl=t_xtide(xtide_station,tim+info.timezone/24,'units','metres');
%     wl=wl-info.datum;

% wl1=t_predic(datenum(2010,1,1):1/24:datenum(2010,2,1),names,freq,tidecon,33)
% 
% try
% close(20)
% end
% try
% close(21)
% end
% 
% figure(20)
% plot(wl1,'b');hold on;
% 
% wl2=t_xtide('La Jolla',(datenum(2010,1,1):1/24:datenum(2010,2,1))+info.timezone/24,'units','metres')-info.datum
% plot(wl2,'r');hold on;
% 
% figure(21)
% plot(wl2-wl1)
% shite=0
% for ii=1:size(info.freq,1)
%     freqstr{ii}=deblank(info.freq(ii,:));
% end
% format short
% for j=1:size(names,1)
%     ff=deblank(names(j,:));
%     disp(ff)
%     imtch=strmatch(ff,freqstr,'exact');
%     if ~isempty(imtch)
%         disp([tidecon(j,1) info.A(imtch)]);
%         disp([tidecon(j,3) info.kappa(imtch)]);
%     end
% end
% %[wl,tdummy]=delftPredict2007(components,squeeze(tidecon(:,1)),squeeze(tidecon(:,3)),tim(1),tim(end),1);
% 
% % wl2=t_predic(tim,names,freq,tidecon);
% % df=wl-wl2;
% % figure(20)
% % plot(df)

