function varargout = extract_d3d_2_cfx(filmap,varargin)

% extract_d3d_2_cfx extracts water level and velocity data from a trim file
%                   writes to csv file that can be used by cfx and/or
%                   returns a matrix with:
%                   x,y,z,hydrostatic pressure,vel_x,vel_y, vel_z, water_fraction
%
% Syntax:
%         extract_d3d_2_cfx(trimfile,<keyword>,<value>), or,
%  data = extract_d3d_2_cfx(trimfile,<keyword>,<value>)
% Input:
%   trimfile = name of the Delft3D-Flow map file
%
% Implemented <keyword>/<value> pairs:
%   Time   =  either the integer time step number
%             or, the real matlab time,
%             or, a date/time vector (as returned by datevec [1984 12 24 0 0 0])
%             default (not specified) first time step on file
%
%             NOTE: If you use reals note that "734167." is seen as "734167", use "734167.00001" instead
%
%   Range      =  a 2x2 matrix giving the range to be extracted, integer grid  indexes     [m1 ,n1 ;m2 ,n2 ], or,
%                                                                real    world coordinates [xll,yll;xur,yur]
%                 default (not specified) [1,mmax;1,nmax]
%   Filcsv     =  name of csv file to write results to
%   Filcsv_hyd =  name of csv file to write hydrostatic pressure and air volume to
%   Filcsv_vel =  name of csv file to write velocities to
%   Rhow       =  density of water (kg/m3)
%                 default (not specified) 1024 (kg/m3)
%   Ag         =  acceleration of gravity (m2/s)
%                 default (not specified) 9.81 (m2/s)
%   Factor     =  integer specifying to coarsen the output data
%                 default (not specified) 1
%   z_values   =  aray of z-values were to give the velocities (for a depth-averaged simulation a logarithmic velocity profile is assumed
%                                                               for a 3-dimension simulation, values are obtained from a spline interpolation)
%                 default (not specified) 0
%   Manning    =  Manning value to be used in logarithmic velocity profile
%                 default (not specified) 0.024
%
% Examples:
%   extract_d3d_2_cfx('trim-3d_001_neap.dat','Time','20030320 000000','Range',[80,100;90,110],'Filcsv','tst.csv')
%   extract_d3d_2_cfx('trim-3d_001_neap.dat','Time',23               ,'Range',[80,100;90,110],'Filcsv','tst.csv')
%   extract_d3d_2_cfx('trim-3d_001_neap.dat','Time',731660.00        ,'Range',[80,100;90,110],'Filcsv','tst.csv')
%   data = extract_d3d_2_cfx('trim-3d_001_neap.dat','Time',[1984 12 24 0 0 0],'Range',[80,100;90,110])
%
% V1.01 : Pressure added as 4th column (TK), re-arrangement of code
% V1.02 : Interpolate depth averaged simulation to fixed z values
%
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
%
%       theo.vanderkaaij@deltares.nl
%
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
% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version
%
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/extract_d3d_2_cfx.m $
% $Keywords: $


%% Open nefis file and extract Fieldnames
File       = qpfopen(filmap);
Fields     = qpread(File);
Fieldnames = {Fields.Name};

%% Read the bed level, use to determine mmax and nmax;
Data       = qpread (File,'bed level in water level points','data',0,0,0);
dep        = Data.Val;

mmax = size(dep,1);
nmax = size(dep,2);

%% Optional arguments
OPT.Range        = [1,mmax;1,nmax];
OPT.Filcsv       = '';
OPT.Filcsv_hyd   = '';
OPT.Filcsv_vel   = '';
OPT.Time         = 1;
OPT.Rhow         = 1023.0; % By default assume density of sea water
OPT.Ag           = 9.81;   % Acceleration of gravity
OPT.Factor       = 1;      % Coarse output
OPT.z_values     = 0;      %
OPT.Manning      = 0.024;  % Manning value to be used in logarithmic velocity profile
OPT              = setproperty(OPT,varargin);

%% Time, integer, timestepnumber, real, matlab time, datevec
Time_Real    = false;
Time_Datevec = false;
if length(OPT.Time) > 1
    Time_Datevec = true;
elseif OPT.Time ~= floor(OPT.Time)
    Time_Real = true;
end

if Time_Real || Time_Datevec
    if Time_Datevec
        OPT.Time = datenum(OPT.Time);
    end
    % determine timestepnumber
    [~,OPT.Time] = min(abs(qpread(File,'water level','times')- OPT.Time));
end

%% Read the water levels;
Data       = qpread (File,'water level','data',OPT.Time,0,0);
s1         = Data.Val;

%% Read Velocity data
if ~isempty( find(strcmp('velocity',Fieldnames) == 1))
    % 3D simulation
    Data = qpread (File,'velocity','griddata',OPT.Time,0,0);
    kmax = size(Data.X,3);
else
    % 2Dh simulation
    Data = qpread (File,'depth averaged velocity','griddata',OPT.Time,0,0);
    kmax = 1;
end

% Interpolate to fixed levels
if length(OPT.z_values) > 1
    kmax = length(OPT.z_values) - 3;
end

%% initialise heights, velocities and pressures
z_coor(1:mmax,1:nmax,1:kmax + 3) = 0.;
u_vel (1:mmax,1:nmax,1:kmax + 3) = 0.;
v_vel (1:mmax,1:nmax,1:kmax + 3) = 0.;
w_vel (1:mmax,1:nmax,1:kmax + 3) = 0.;
pres  (1:mmax,1:nmax,1:kmax + 3) = 0.;
frac  (1:mmax,1:nmax,1:kmax + 3) = 1.0;
height(1:mmax,1:nmax,1:kmax + 3) = NaN;

%% Extract coordinates (and determine pressures)
x_coor = Data.X;
y_coor = Data.Y;

%% Convert from world coordinates to grid indexes (if Range is specified in reals)
if OPT.Range(1,1) ~= floor(OPT.Range(1,1))
    % Define square
    x(1) = OPT.Range(1,1); y(1) = OPT.Range(1,2);
    x(2) = OPT.Range(2,1); y(2) = OPT.Range(1,2);
    x(3) = OPT.Range(2,1); y(3) = OPT.Range(2,2);
    x(4) = OPT.Range(1,1); y(4) = OPT.Range(2,2);
    % find belonging m and n coordinates
    for i_pnt = 1: length(x)
        dist = sqrt((x_coor(:,:,1) - x(i_pnt)).^2 + (y_coor(:,:,1) - y(i_pnt)).^2);
        [~,ind] = min(dist(:));
        [m(i_pnt),n(i_pnt)] = ind2sub(size(dist),ind);
    end
    OPT.Range = [min(m) - OPT.Factor, min(n) - OPT.Factor; max(m) + OPT.Factor, max(n) + OPT.Factor];
end

%% Extract Values: "Normal approach" just extract values from the Delft3D map file
if length(OPT.z_values) == 1
    % bed
    for m = OPT.Range(1,1):OPT.Range(2,1)
        for n = OPT.Range(1,2):OPT.Range(2,2)
            z_coor(m,n,1) = dep(m,n);
            pres  (m,n,1) = (s1(m,n) - dep(m,n))*OPT.Rhow*OPT.Ag;
        end
    end

    % computational layers
    if kmax == 1
        z_coor(:,:,2) =  dep + (s1 - dep)/2.;
        pres  (:,:,2) = ((s1 - dep)/2.)*OPT.Rhow*OPT.Ag;
    else
        for k = 1: kmax
            k_act = kmax - k + 1; % Switch direction, from top to bottom to bottom to top
            z_coor(:,:,k+1) = Data.Z(:,:,k_act);
            pres  (:,:,k+1) = (s1 - Data.Z(:,:,k_act))*OPT.Rhow*OPT.Ag;
        end
    end

    % Water surface
    z_coor(:,:,kmax + 2) =  s1;

    % Air
    z_coor(:,:,kmax + 3) =  s1 + 0.001 ; % Air 1 mm above water surface
    frac  (:,:,kmax + 3) = 0.0;          % Water fraction

    %% Extract velocities
    if kmax == 1
        u_vel(:,:,2)   = Data.XComp;
        v_vel(:,:,2)   = Data.YComp;
    else
        for k = 1: kmax
            k_act = kmax - k + 1; % Switch direction, from top to bottom to bottom to top
            u_vel(:,:,k+1)   = Data.XComp(:,:,k_act);
            v_vel(:,:,k+1)   = Data.YComp(:,:,k_act);
            w_vel(:,:,k+1)   = Data.ZComp(:,:,k_act);
        end
    end

%% Interpolate to fixed z-layer heights
else
    for m = OPT.Range(1,1):OPT.Range(2,1)
        for n = OPT.Range(1,2):OPT.Range(2,2)
            for k = 1: kmax + 3
                % Levels
                z_coor(m,n,k) = OPT.z_values(k);
                % hydrostatic pressure
                if z_coor(m,n,k) > dep(m,n) && z_coor(m,n,k) < s1(m,n)
                    height(m,n,k) = z_coor(m,n,k) - dep(m,n);
                    pres  (m,n,k) = height(m,n,k)*OPT.Rhow*OPT.Ag;
                end
                if z_coor(m,n,k) >= s1(m,n)
                    height(m,n,k) = s1(m,n) - dep(m,n);
                    frac  (m,n,k) = 0.0; % air instead of water
                end
                % velocities
                if ~isfield(Data,'Z')
                    % 2Dh simulation, assume logarithmic velocity profile
                    if ~isnan(height(m,n,k))
                        kappa        = 0.4; % Von Karman constant
                        Chezy        = (height(m,n,k)^(1./6.))/OPT.Manning;
                        ks           = 12.*(s1(m,n) - dep(m,n))/(10^(Chezy/18.));
                        z0           = ks/30.;
                        u_vel(m,n,k) = (Data.XComp(m,n)*sqrt(OPT.Ag)/Chezy)*log(height(m,n,k)/z0); %Logarithmic velocity profile u_vel
                        v_vel(m,n,k) = (Data.YComp(m,n)*sqrt(OPT.Ag)/Chezy)*log(height(m,n,k)/z0); %Logarithmic velocity profile v_vel
                    end
                else
                    % 3 Dimensional simulation
                    if ~isnan(x_coor(m,n)) && ~isnan(s1(m,n))
                        if  z_coor (m,n,k) > dep (m,n)
                            if z_coor(m,n,k) <  s1 (m,n)
                                % interpolate
                                u_vel(m,n,k) = interp1(squeeze(Data.Z(m,n,:)),squeeze(Data.XComp(m,n,:)),z_coor(m,n,k),'linear','extrap');
                                v_vel(m,n,k) = interp1(squeeze(Data.Z(m,n,:)),squeeze(Data.YComp(m,n,:)),z_coor(m,n,k),'linear','extrap');
                                w_vel(m,n,k) = interp1(squeeze(Data.Z(m,n,:)),squeeze(Data.ZComp(m,n,:)),z_coor(m,n,k),'linear','extrap');
                            elseif k > 1
                                u_vel(m,n,k) = u_vel(m,n,k-1);
                                v_vel(m,n,k) = v_vel(m,n,k-1);
                            end
                        end
                    end
                end
            end
        end
    end
end


%% Fill matrix for writing
 i_tel = 0;
 for k = 0 : kmax + 2
     for m = OPT.Range(1,1): OPT.Factor: OPT.Range(2,1)
         for n = OPT.Range(1,2): OPT.Factor: OPT.Range(2,2)
             if ~isnan(x_coor(m,n,1))
                 i_tel = i_tel + 1;
                 % x,y,z-coordinates
                 M(i_tel,1) = x_coor(m,n,1);
                 M(i_tel,2) = y_coor(m,n,1);
                 M(i_tel,3) = z_coor(m,n,k+1);

                 % Hydrostatic pressure
                 M(i_tel,4) = pres  (m,n,k+1);

                 % Velocities
                 M(i_tel,5) = u_vel (m,n,k+1);
                 M(i_tel,6) = v_vel (m,n,k+1);
                 M(i_tel,7) = w_vel (m,n,k+1);

                 % water fraction
                 M(i_tel,8) = frac  (m,n,k+1);
             end
         end
     end
 end

 %% Write the Matrix
 if ~isempty(OPT.Filcsv)
     csvwrite(OPT.Filcsv,M);
 end

 %% Fill output argument with matrix
 if nargout >= 1
     varargout{1} = M;
 end

 %% File with hydrostatic pressure and air volume
 if ~isempty(OPT.Filcsv_hyd)
     clear M;
     i_tel = 0;
     for k = 0 : kmax + 2
         for m = OPT.Range(1,1): OPT.Factor: OPT.Range(2,1)
             for n = OPT.Range(1,2): OPT.Factor: OPT.Range(2,2)
                 if ~isnan(x_coor(m,n,1))
                     i_tel = i_tel + 1;
                     % x,y,z-coordinates
                     M(i_tel,1) = x_coor(m,n,1);
                     M(i_tel,2) = y_coor(m,n,1);
                     M(i_tel,3) = z_coor(m,n,k+1);
                     
                     % Hydrostatic pressure
                     M(i_tel,4) = pres  (m,n,k+1);
                     
                     % water fraction
                     M(i_tel,5) = frac  (m,n,k+1);
                 end
             end
         end
     end
     csvwrite(OPT.Filcsv_hyd,M);
 end
 
 %% File with velocities
 if ~isempty(OPT.Filcsv_vel)
     clear M;
     i_tel = 0;
     for k = 0 : kmax + 2
         for m = OPT.Range(1,1): OPT.Factor: OPT.Range(2,1)
             for n = OPT.Range(1,2): OPT.Factor: OPT.Range(2,2)
                 if ~isnan(x_coor(m,n,1))
                     i_tel = i_tel + 1;
                     % x,y,z-coordinates
                     M(i_tel,1) = x_coor(m,n,1);
                     M(i_tel,2) = y_coor(m,n,1);
                     M(i_tel,3) = z_coor(m,n,k+1);
                     
                     % Velocities
                     M(i_tel,4) = u_vel (m,n,k+1);
                     M(i_tel,5) = v_vel (m,n,k+1);
                     M(i_tel,6) = w_vel (m,n,k+1);
                 end
             end
         end
     end
     csvwrite(OPT.Filcsv_vel,M);
 end
 
