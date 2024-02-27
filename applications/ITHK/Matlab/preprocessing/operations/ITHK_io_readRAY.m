function [RAYdata]=ITHK_io_readRAY(RAYfilename)
%read RAY : Reads ray-files
%
%   Syntax: 
%     function [RAYdata] = ITHK_io_readRAY(RAYfilename)
% 
%   Input:
%     RAYfilename     string, cell or struct with filename (and directory) with ray files
%  
%   Output:
%     RAYdata       struct with contents of ray file
%                     .name     :  string with filename
%                     .path     :  string with path of file
%                     .info     :  cell with header info of RAY file (e.g. pro-file used)
%                     .time     :  (optional) Time instance of time-series file
%                     .equi     :  equilibrium angle degrees relative to 'hoek'
%                     .c1       :  coefficient c1 [-] (used for scaling of sediment transport of S-phi curve)
%                     .c2       :  coefficient c2 [-] (used for shape of S-phi curve)
%                     .h0       :  active height of profile [m]
%                     .hoek     :  coast angle specified in LT computation
%                     .QSoffset :  (optional) Offset of the S-Phi curve due to tide driven net sediment transport
%                     .fshape   :  shape factor of the cross-shore distribution of sediment transport [-]
%                     .Xb       :  coastline point [m]
%                     .perc2    :  distance from coastline point beyond which 2% of transport is located [m]
%                     .perc20   :  distance from coastline point beyond which 20% of transport is located [m]
%                     .perc50   :  distance from coastline point beyond which 50% of transport is located [m]
%                     .perc80   :  distance from coastline point beyond which 80% of transport is located [m]
%                     .perc100  :  distance from coastline point beyond which 100% of transport is located [m]
%
%   Example:
%     [RAYdata] = ITHK_io_readRAY('test.ray')
%     [RAYdata] = ITHK_io_readRAY({'test1.ray'},{'test2.ray'})
%     [RAYdata] = ITHK_io_readRAY(dir('*.ray'))
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

% $Id: ITHK_io_readRAY.m 6477 2012-06-19 16:44:39Z huism_b $
% $Date: 2012-06-20 00:44:39 +0800 (Wed, 20 Jun 2012) $
% $Author: huism_b $
% $Revision: 6477 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/ITHK_io_readRAY.m $
% $Keywords: $

R=struct;
filedata2={};
if isstr(RAYfilename)
    filedata2={RAYfilename};
elseif iscell(RAYfilename)
    filedata2=RAYfilename;
elseif isstruct(RAYfilename)
    for jj=1:length(RAYfilename)
        filedata2{jj}=RAYfilename(jj).name;
    end
end

%% read RAY file
for ii=1:length(filedata2)
    [pth,nm1,nm2]   = fileparts(filedata2{ii});
    R(ii).name      = [nm1,nm2];
    R(ii).path      = [pth];
    fid1            = fopen(filedata2{ii},'r');
    a=[];
    for iii=1:6
        tline = fgetl(fid1);
        a=strvcat(tline(1:end));
        R(ii).info{iii}=a;
    end
    tline = fgetl(fid1);tline = fgetl(fid1);
    DATA  = strread(tline);
    jj=1;
    
    if length(DATA)==14
        %% timeseries ray + QSoffset
        while ~feof(fid1)
            if jj>1; tline = fgetl(fid1); end
            [R(ii).time(jj,1),   R(ii).equi(jj,1),   R(ii).c1(jj,1),      R(ii).c2(jj,1), ...
             R(ii).h0(jj,1),     R(ii).hoek(jj,1),   R(ii).fshape(jj,1),  QSoffset, ...
             R(ii).Xb(jj,1),     R(ii).perc2(jj,1),  R(ii).perc20(jj,1),  R(ii).perc50(jj,1), ...
             R(ii).perc80(jj,1), R(ii).perc100(jj,1)]   = strread(tline,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
            R(ii).QSoffset(jj,1)=QSoffset;
            [R(ii).Cequi(jj)]=computeEQUI(R(ii).equi(jj),R(ii).c1(jj),R(ii).c2(jj),R(ii).hoek(jj),R(ii).QSoffset(jj));
            jj=jj+1;
        end
    elseif length(DATA)==13
        %% timeseries ray
        while ~feof(fid1)
            if jj>1; tline = fgetl(fid1); end
            [R(ii).time(jj,1),   R(ii).equi(jj,1),   R(ii).c1(jj,1),       R(ii).c2(jj,1), ...
             R(ii).h0(jj,1),     R(ii).hoek(jj,1),   R(ii).fshape(jj,1), ...
             R(ii).Xb(jj,1),     R(ii).perc2(jj,1),  R(ii).perc20(jj,1),   R(ii).perc50(jj,1), ...
             R(ii).perc80(jj,1), R(ii).perc100(jj,1)]   = strread(tline,'%f%f%f%f%f%f%f%f%f%f%f%f%f');
            R(ii).QSoffset(jj,1)=0;
            [R(ii).Cequi(jj)]=computeEQUI(R(ii).equi(jj),R(ii).c1(jj),R(ii).c2(jj),R(ii).hoek(jj),R(ii).QSoffset(jj));
            jj=jj+1;
        end
    elseif length(DATA)<12
        if length(DATA)==7
            %% normal ray + QSoffset
            R(ii).time = [];
            [R(ii).equi,  R(ii).c1,    R(ii).c2, ...
             R(ii).h0,    R(ii).hoek,  R(ii).fshape,  QSoffset] = strread(tline,'%f%f%f%f%f%f%f');
        else
            %% normal ray
            R(ii).time = [];
            [R(ii).equi,  R(ii).c1,    R(ii).c2, ...
             R(ii).h0,    R(ii).hoek,  R(ii).fshape] = strread(tline,'%f%f%f%f%f%f');
            QSoffset=0;
        end
        tline = fgetl(fid1);tline = fgetl(fid1);
        [R(ii).Xb R(ii).perc2 R(ii).perc20 R(ii).perc50 R(ii).perc80 R(ii).perc100]=strread(tline,'%f%f%f%f%f%f');
        R(ii).QSoffset=QSoffset;
        [R(ii).Cequi]=computeEQUI(R(ii).equi,R(ii).c1,R(ii).c2,R(ii).hoek,R(ii).QSoffset);
    end
    fclose all;
end
RAYdata=R;
end

%% SUBFUNCTION computeEQUI
function [Cequi]=computeEQUI(equi,c1,c2,hoek,QSoffset)
    %  INPUT:
    %    equi      Relative angle of eq. coastline with only waves [°]
    %    c1        S-Phi parameter 1
    %    c2        S-Phi parameter 2
    %    hoek      Current coastline angle
    %    QSoffset  Sediment transport for angles rota [m3/yr]
    %  
    %  OUTPUT:
    %    Cequi   Equilibrium coastline angle [°N]
    Cangle    = [(hoek-equi)-70:0.1:(hoek-equi)+70];
    phi_r     = Cangle-(hoek-equi);
    QS        = -c1.*phi_r.*exp(-((c2.*phi_r).^2)) +QSoffset/1000;
    if max(QS)>=0 && min(QS)<=0
        id        = find(abs(QS)==min(abs(QS)));
    elseif max(QS)<0
        id        = find(QS==max(QS));
    elseif min(QS)>0
        id        = find(QS==min(QS));
    end
    Cequi     = Cangle(id(1));
end
