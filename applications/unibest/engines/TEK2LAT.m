function TEK2LAT(TEKfilename,LATfilename)
%TEK2LAT : Convert a TEK file to a LAT file
%
%   Syntax:
%     function TEK2LAT(TEKfilename,LATfilename)
% 
%   Input:
%     TEKfilename     (optional) String, cell or struct with filename (and directory) with TEK files
%     LATfilename     (optional) Cell string with name of LAT of componets of output file (.txt files)
% 
%   Output:
%     .txt files for each of the selected TEK files
%   
%   Example:
%     TEK2LAT
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: TEK2LAT.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/engines/TEK2LAT.m $
% $Keywords: $

if nargin>=1
    if isstr(TEKfilename)
        [pathname,filen1,filen2]=fileparts(TEKfilename);
        filenames = [filen1,filen2];
    elseif isstruct(TEKfilename)
        if isfield(TEKfilename,'name')
            pathname  = '';        
            for ii=1:length(TEKfilename)
                filenames{ii} = TEKfilename(ii).name;
            end
        else
            pathname  = TEKfilename.path;
            filenames = TEKfilename.files;
        end
    end
    if isstr(TEKfilename)
        filenames = {TEKfilename};
    end
else
    [filenames, pathname] = uigetfile({'*.tek','TEK-files (*.ray)';'*.*',  'All Files (*.*)'},'Pick a file','MultiSelect', 'on');
    filenames={filenames};
end

for ii=1:length(filenames)
    fid1 = fopen(char([pathname,filesep,filenames{ii}]));
    inhoud=fread(fid1);
    inhoud=[13;10;inhoud];
    idREGELEINDE=find(inhoud==13);
    idSTER=find(inhoud==42);
    punt1=idREGELEINDE(find(inhoud(idREGELEINDE(1:end-1)+2)==42));
    punt2=punt1+22;
    punt3=punt1+28;
    totaal=size(punt1,1)-1;
    
    kop1=[double('Color              R         G         B')';32;13;10;...
          double(' 0             0           0')';32;13;10;...
          double('Number of points')';32;13;10;32];
    kop2=[32;13;10;double('         X [m]     Y [m]')';32];
    
    for iii=1:totaal
                    
        aantal(iii)=str2num(char(inhoud(punt3(totaal-iii+1)+4:punt3(totaal-iii+1)+8))');
        inhoud=[inhoud(1:punt1(totaal-iii+1)+1);...
                kop1;...
                double(num2str(aantal(iii)))';...
                kop2;
                inhoud(punt3(totaal-iii+1)+16:end)];
    end
    %Voeg kop in
    regel1=[double('Polygons')';32;13;10;32;double(num2str(totaal))';32];
    inhoud=[regel1;inhoud];
    %Verwijder z-waarden
    idREGELEINDE=find(inhoud==13);
    for iii=1:size(idREGELEINDE,1)-1
        idREGELEINDE=find(inhoud==13);
        if idREGELEINDE(iii+1)-idREGELEINDE(iii)>32
            inhoud=[inhoud(1:idREGELEINDE(iii+1)-18);inhoud(idREGELEINDE(iii+1):end)];
        end
    end
    %Verwijder laatste regel
    idREGELEINDE=find(inhoud==13);
    inhoud=inhoud(1:idREGELEINDE(size(idREGELEINDE,1)-1)-2);
    %Verwijder dubbele enters
    inhoud=inhoud(inhoud>13|inhoud<13);
    
    fclose(fid1);
    
    if nargin<2
        outputname=[filenames{ii}(1:end-4) '2LAT.TXT'];
    else
        outputname=[LATfilename{ii} '.TXT'];
    end
    fid2 = fopen(outputname,'wt');
    fwrite(fid2,inhoud);
    fclose(fid2);
end
