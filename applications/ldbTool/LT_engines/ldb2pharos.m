function ldb2pharos(ldbName)
%LDB2PHAROS Convert ldb to Pharos layout file
%
% Input is the name of the ldb-file or a nx2 matrix
% Converts ldb-file (landboundary) to Pharos-layout-file (txt)
% and checks whether directions (clockwise or anti-clockwise) are ok
% and flips layout if necessary
% You can also perform translation in x and/or y direction
%
% Syntax:
% ldb2pharos(ldb)
%
% ldb:      the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
%           (optional)
%
% See also: LDBTOOL, LDB2KML, LDB2SHAPE

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Tim Raaijmakers 
%       (help blocks by Arjan Mol)
%
%       tim.raaijmakers@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
if nargin==0
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    [nam, pat]=uigetfile('*.ldb','Select landboundary-file');
    ldbName = [pat nam];
end

if isnumeric(ldbName)
    ldb=ldbName;
    [nam,pat]=uiputfile('*.txt','Export to Pharos layout-file')
    pharosName=[pat nam];
else
    ldb=landboundary('read',ldbName);
    pharosName=[ldbName(1:end-4) '.txt'];
end

if isempty(ldb)
    return
end

if size(ldb,2) > 2
    ldb = ldb(:,1:2);
end

if ~isnan(ldb(1,1))
    ldb=[nan nan;ldb];
end

if ~isnan(ldb(end,1))
    ldb=[ldb;nan nan];
end

id=find(isnan(ldb(:,1)));

minX = min(ldb(:,1));
minY = min(ldb(:,2));

corrOutput=questdlg('Do you want to translate the data (to reduce the number of digits in Pharos)','ldb2pharos','Yes, indeed!','No, thanks!','No, thanks!');
switch corrOutput
    case 'Yes, indeed!'
        prompt={strvcat(['Enter the correction on the x-coordinates (just translation).'],['Positive value means subtraction.'],['The minimum x-value is currently: ',num2str(minX,'%2.2f')]),strvcat(['Enter the correction on the y-coordinates (just translation).'],['Positive value means subtraction.'],['The minimum y-value is currently: ',num2str(minY,'%2.2f')]),};
        def={'0','0'};
        dlgTitle='ldb2pharos';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
    otherwise
        answer = {'0','0','0'};
end

numSegments = length(id)-1;
PharInner = [];

for ii=1:numSegments
    xNew = ldb(id(ii)+1:id(ii+1)-1,1) - str2num(answer{1});
    yNew = ldb(id(ii)+1:id(ii+1)-1,2) - str2num(answer{2});
    ldbCell{ii} = [xNew,yNew];
    xC = mean(ldbCell{ii}(:,1)); % x of gravity centre of ldb
    yC = mean(ldbCell{ii}(:,2)); % y of gravity centre of ldb
    A = mod(180*atan2(ldbCell{ii}(:,1)-xC,ldbCell{ii}(:,2)-yC)/pi,360);
    Adiff = median([A(2:10:end)-A(1:10:end-1)]); % calculate median difference in angle around gravity centre between ldb-points
    if min(ldbCell{ii}(:,1)) == minX-str2num(answer{1}) & min(ldbCell{ii}(:,2)) == minY-str2num(answer{2})
        % then this part must be the outer line and thus layout of Pharos
        PharOuter = ii;
        % check whether this part is in the correct order  
        if Adiff > 0 % then the (nautical) angle will predominantly increase: clockwise, but should be anti-clockwise!! so change order of ldb
            ldbCell{ii} = flipud(ldbCell{ii}); 
            disp(['The outer Pharos boundary is flipped to anti-clockwise']);
        else
            disp(['The outer Pharos boundary was in the correct anti-clockwise direction']);
        end
    else
        % all other parts are inner boundaries
        PharInner = [PharInner,ii];
        % check whether this part is in the correct order  
        if Adiff < 0 % then the (nautical) angle will predominantly decrease: anti-clockwise, but should be clockwise!! so change order of ldb
            ldbCell{ii} = flipud(ldbCell{ii});    
            disp(['Inner Pharos boundary nr ',num2str(length(PharInner)),' is flipped to clockwise']);
        else
            disp(['Inner Pharos boundary nr ',num2str(length(PharInner)),' was in the correct clockwise direction']);
        end        
    end
end

% write results to layout-file and plot in figure
figure;
fid = fopen(pharosName,'w');
fprintf(fid,'%s\n',['Pharos layout file, based on landboundary ',nam(1:end-4),', corrected with x=x-',answer{1},' and y=y-',answer{2}]);
fprintf(fid,'%i\n',numSegments);
% write outer boundary
fprintf(fid,'%i %i\n',[size(ldbCell{PharOuter},1),2]');
fprintf(fid,'%2.2f %2.2f\n',ldbCell{PharOuter}');
plot(ldbCell{PharOuter}(:,1),ldbCell{PharOuter}(:,2),'b','linewidth',2); hold on; axis equal; grid on;
for jj = [1:floor(length(ldbCell{PharOuter}(:,1))/100):length(ldbCell{PharOuter}(:,1))]
    text(ldbCell{PharOuter}(jj,1),ldbCell{PharOuter}(jj,2),num2str(jj),'color',[0 0 1]);
end
% write inner boundaries
for ii = 1:length(PharInner)
    fprintf(fid,'%i %i\n',[size(ldbCell{PharInner(ii)},1),2]');
    fprintf(fid,'%2.2f %2.2f\n',ldbCell{PharInner(ii)}');    
    plot(ldbCell{PharInner(ii)}(:,1),ldbCell{PharInner(ii)}(:,2),'r');
    for jj = [1:round(length(ldbCell{PharInner(ii)}(:,1))/25):length(ldbCell{PharInner(ii)}(:,1))]
        text(ldbCell{PharInner(ii)}(jj,1),ldbCell{PharInner(ii)}(jj,2),num2str(jj),'color',[1 0 0]);
    end
end
fclose(fid);
legend('Outer boundary of Pharos model: check anti-clockwise!','Inner boundaries of Pharos model: check clockwise!');
print(gcf,'-dpng','-r200',[pat nam(1:end-4),'.png']);
