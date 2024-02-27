function [RAYdata] = readRAY(RAYfilename)
%read RAY : Reads ray-files
%
%   Syntax: 
%     function [RAYdata] = readRAY(RAYfilename)
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
%                     .hass     : (OPTIONAL), only if high_angle_stability_switch is specified in the Ray file
%
%   Calling readRAY without an input variable will return a default RAYdata output structure 
%
%   Multiple Ray-files can be read with a RAYfilename cell ({1xN} or {Nx1})
%   or filename (dir) structure (as indicated above). An example of the
%   resulting RAYdata multi-structure can also be generated using
%   readRAY(number_of_ray_files). Also see example 2 below.
%
%
%   Examples 1:
%     [RAYdata] = readRAY('test.ray')
%     [RAYdata] = readRAY({'test1.ray'},{'test2.ray'})
%     [RAYdata] = readRAY(dir('*.ray'))
%
%   Example 2:
%     disp('A default RAYdata structure for 10 Ray files looks like:');
%     disp(' '); RAYdata = readRAY(10); disp(RAYdata);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%       bas.huisman@deltares.nl
%
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%       freek.scheel@deltares.nl
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

% $Id: readRAY.m 18214 2022-06-29 13:39:47Z huism_b $
% $Date: 2022-06-29 21:39:47 +0800 (Wed, 29 Jun 2022) $
% $Author: huism_b $
% $Revision: 18214 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readRAY.m $
% $Keywords: $

    if nargin == 0

        RAYdata = create_RAYdata_struct;

    elseif nargin == 1

        if isnumeric(RAYfilename)
            for ii=1:RAYfilename
                RAYdata(1,ii) = create_RAYdata_struct;
            end
            return
        end

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
            for iii=1:6
                tline = fgetl(fid1);
                R(ii).info{iii}=strvcat(tline(1:end));
            end
            tline = fgetl(fid1);

            % Read content of file
            inh=fread(fid1);

            % Find line-ends
            inh=inh(inh~=13); % remove 13
            id10=find(inh(2:end)==10 & inh(1:end-1)~=10)+1; % read line-ends (id=10), but only the first if their are two consecutive line-ends.
            if inh(1)==10;id10=[1,id10];end

            % Read 1st content line to know the number of columns
            DATA=strread(char(inh(1:id10)'));
            nrlines=length(id10);
            nrcolumns=length(DATA);        

            %--------------------------------------------------------------
            %% TIME-SERIES FILE
            %--------------------------------------------------------------
            if nrcolumns>=13
                % scan and retrieve data
                DATA0=sscanf(char(inh),'%f',[nrcolumns nrlines])';
                R(ii).time      = DATA0(:,1);  
                R(ii).equi      = DATA0(:,2);  
                R(ii).c1        = DATA0(:,3);     
                R(ii).c2        = DATA0(:,4); 
                R(ii).h0        = DATA0(:,5);    
                R(ii).hoek      = DATA0(:,6);  
                R(ii).fshape    = DATA0(:,7); 
                qq = 0;
                R(ii).QSoffset  = 0;
                if (length(DATA)==14 && DATA0(:,end)~=1) || (length(DATA)==15)
                    R(ii).QSoffset  = DATA0(:,8);                           % timeseries ray with tide offset
                    qq = 1;
                end
                R(ii).Xb        = DATA0(:,8+qq);    
                R(ii).perc2     = DATA0(:,9+qq); 
                R(ii).perc20    = DATA0(:,10+qq); 
                R(ii).perc50    = DATA0(:,11+qq); 
                R(ii).perc80    = DATA0(:,12+qq);
                R(ii).perc100   = DATA0(:,13+qq);
                R(ii).hass      = ones(size(R(ii).c1));
                if length(DATA)==(14+qq)                      % timeseries ray with high-angle stability switch
                    R(ii).hass            = DATA0(:,14+qq);
                end
                R(ii).Cequi       = computeEQUI(R(ii).equi,R(ii).c1,R(ii).c2,R(ii).hoek,R(ii).QSoffset);

            %--------------------------------------------------------------
            %% STATIC CLIMATE
            %--------------------------------------------------------------    
            else
                % read 1st line
                R(ii).time     = [];
                R(ii).equi     = DATA(1);
                R(ii).c1       = DATA(2);
                R(ii).c2       = DATA(3);
                R(ii).h0       = DATA(4);
                R(ii).hoek     = DATA(5);
                R(ii).fshape   = DATA(6);
                R(ii).QSoffset = 0;
                R(ii).hass     = 1;
                if nrcolumns>=7
                    if DATA(7)~=1
                    R(ii).QSoffset = DATA(7);
                    else
                    R(ii).hass = DATA(7); 
                    end
                end
                if nrcolumns==8
                    R(ii).hass = DATA(8); 
                end

                % read 2nd line
                DATA2=strread(char(inh(id10(2)+1:id10(3))'));
                R(ii).Xb      = DATA2(1);
                R(ii).perc2   = DATA2(2);
                R(ii).perc20  = DATA2(3);
                R(ii).perc50  = DATA2(4);
                R(ii).perc80  = DATA2(5);
                R(ii).perc100 = DATA2(6);
                R(ii).hass    = 0;
                if length(DATA2)>=7
                    R(ii).hass    = DATA2(7);
                end
                R(ii).Cequi = computeEQUI(R(ii).equi,R(ii).c1,R(ii).c2,R(ii).hoek,R(ii).QSoffset);
            end
            fclose all;
        end
        RAYdata=R;

    else
        % Should not be possible to get here:
        error(['Specified ' num2str(nargin) ' input variables, maximum is 1'])
    end

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
    
    Cequi=nan(size(equi));
    for jj=1:length(equi)
        if c1(jj) == 0
            % No transports
            Cequi(jj,1) = hoek(jj)-equi(jj);
        else
            Cangle    = [(hoek(jj)-equi(jj))-70:0.1:(hoek(jj)-equi(jj))+70];
            phi_r     = Cangle-(hoek(jj)-equi(jj));
            QS        = -c1(jj).*phi_r.*exp(-((c2(jj).*phi_r).^2)) +QSoffset(jj)/1000;
            if max(QS)>=0 && min(QS)<=0
                id        = find(abs(QS)==min(abs(QS)));
            elseif max(QS)<0
                id        = find(QS==max(QS));
            elseif min(QS)>0
                id        = find(QS==min(QS));
            end
            Cequi(jj,1)     = Cangle(id(1));
        end
    end
end

%% Subfunction make empty structure

function R = create_RAYdata_struct

R.name     = []; % string with filename
R.path     = []; % string with path of file
R.info     = []; % cell with header info of RAY file (e.g. pro-file used)
R.time     = []; % (optional) Time instance of time-series file
R.equi     = []; % equilibrium angle degrees relative to 'hoek'
R.c1       = []; % coefficient c1 [-] (used for scaling of sediment transport of S-phi curve)
R.c2       = []; % coefficient c2 [-] (used for shape of S-phi curve)
R.h0       = []; % active height of profile [m]
R.hoek     = []; % coast angle specified in LT computation
R.QSoffset = []; % (optional) Offset of the S-Phi curve due to tide driven net sediment transport
R.fshape   = []; % shape factor of the cross-shore distribution of sediment transport [-]
R.Xb       = []; % coastline point [m]
R.perc2    = []; % distance from coastline point beyond which 2% of transport is located [m]
R.perc20   = []; % distance from coastline point beyond which 20% of transport is located [m]
R.perc50   = []; % distance from coastline point beyond which 50% of transport is located [m]
R.perc80   = []; % distance from coastline point beyond which 80% of transport is located [m]
R.perc100  = []; % distance from coastline point beyond which 100% of transport is located [m]
R.hass     = []; %(OPTIONAL), only if high_angle_stability_switch is specified in the Ray file

R.specification.name     = 'string with filename';
R.specification.path     = 'string with path of file';
R.specification.info     = 'cell with header info of RAY file (e.g. pro-file used)';
R.specification.time     = '(optional) Time instance of time-series file';
R.specification.equi     = 'equilibrium angle degrees relative to ''hoek''';
R.specification.c1       = 'coefficient c1 [-] (used for scaling of sediment transport of S-phi curve)';
R.specification.c2       = 'coefficient c2 [-] (used for shape of S-phi curve)';
R.specification.h0       = 'active height of profile [m]';
R.specification.hoek     = 'coast angle specified in LT computation';
R.specification.QSoffset = '(optional) Offset of the S-Phi curve due to tide driven net sediment transport';
R.specification.fshape   = 'shape factor of the cross-shore distribution of sediment transport [-]';
R.specification.Xb       = 'coastline point [m]';
R.specification.perc2    = 'distance from coastline point beyond which 2% of transport is located [m]';
R.specification.perc20   = 'distance from coastline point beyond which 20% of transport is located [m]';
R.specification.perc50   = 'distance from coastline point beyond which 50% of transport is located [m]';
R.specification.perc80   = 'distance from coastline point beyond which 80% of transport is located [m]';
R.specification.perc100  = 'distance from coastline point beyond which 100% of transport is located [m]';
R.specification.hass     = '(OPTIONAL!) only if high_angle_stability_switch must be specified in the Ray file (requires recent dll''s), leave empty if not used';

end