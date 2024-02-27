function LDB2LAT(LDBfilename,LATfilename)
%LDB2LAT : Convert a LDB file to a LAT file
%
%   Syntax:
%     function LDB2LAT(LDBfilename,LATfilename)
% 
%   Input:
%     LDBfilename     (optional) String, cell or struct with filename (and directory) with LDB files
%     LATfilename     (optional) String with name of LAT output file
% 
%   Output:
%     .lat file
%   
%   Example:
%     LDB2LAT('test.ldb','test.lat');
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

% $Id: LDB2LAT.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/engines/LDB2LAT.m $
% $Keywords: $

if nargin>=1
    if isstr(LDBfilename)
        [pathname,filen1,filen2]=fileparts(LDBfilename);
        filenames = [filen1,filen2];
    elseif isstruct(LDBfilename)
        if isfield(LDBfilename,'name')
            pathname  = '';        
            for ii=1:length(LDBfilename)
                filenames{ii} = LDBfilename(ii).name;
            end
        else
            pathname  = LDBfilename.path;
            filenames = LDBfilename.files;
        end
    end
    if isstr(LDBfilename)
        filenames = {LDBfilename};
    end
else
    [filenames, pathname] = uigetfile( ...
    {  '*.ldb','LDB-files (*.ldb)'; ...
       '*.pol','POL-files (*.pol)'; ...
       '*.tek','TEK-files (*.tek)'; ...
       '*.*',  'All Files (*.*)'}, ...
       'Pick a file', ...
    'MultiSelect', 'on');
    filenames={filenames};
end

if nargin<2
    LATfilename = [pathname,filesep,filenames{1}(1:end-4),'.LAT'];
end

identifier1=fopen(LATfilename,'wt');
AantalPolygons=length(filenames);

totaal=zeros(AantalPolygons,1);
for ii=1:AantalPolygons
    %read polygon
    clear X Y
    [X Y]=landboundary('read',[pathname,filesep,filenames{ii}]);
    
    nummer=1;a=2;b=size(X,1);
    for iiii=2:size(X,1)
        if isnan(X(iiii))
            b=iiii-1;
            X2{ii,nummer}=X(a:b);
            Y2{ii,nummer}=Y(a:b);
            nummer=nummer+1;
            a=iiii+1;
            totaal(ii)=totaal(ii)+1;
        end
    end
    %X2{ii,nummer}=X(a:b);
    %Y2{ii,nummer}=Y(a:b);
    
    %totaal(ii)=totaal(ii)+1;
end

fprintf(identifier1, 'Polygons\n');
fprintf(identifier1, '%3.0f\n',sum(totaal));

for ii=1:AantalPolygons
  
    AantalPolygons2=totaal(ii);
    for iii=1:AantalPolygons2
        %Print aantal
        %Kop
        fprintf(identifier1, 'Color              R         G         B\n');
        fprintf(identifier1, ' 255           255         0\n');
        fprintf(identifier1, 'Number of points\n');
        %kop2
        fprintf(identifier1, '%3.0f\n',length(X2{ii,iii})+1);
        fprintf(identifier1, '         X [m]     Y [m] \n');
        %schrijf XY data weg
        for iiiii=1:length(X2{ii,iii});
        	fprintf(identifier1, '%7.0f        %7.0f \n',X2{ii,iii}(iiiii),Y2{ii,iii}(iiiii));
        end
        fprintf(identifier1, '%7.0f        %7.0f \n',X2{ii,iii}(1),Y2{ii,iii}(1));
    end
end
fclose(identifier1);