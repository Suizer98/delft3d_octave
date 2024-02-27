function varargout = bca2bct(varargin);
%BCA2BCT          performs tidal prediction to generate *.bct from *.bca <<beta version!>>
%
%       bca2bct(<keyword,value>);
%   BCT=bca2bct(<keyword,value>);
%
% generates a Delft3D FLOW *.bct file (time series boundary condition)
% from a *.bca file (astronomic components boundary conditions).
% using the *.bnd file (boundary definition file) and using T_TIDE prediction.
% Thw following <keyword,value> pairs are required.
%
%    *  'bcafile', 'bndfile' and 'bctfile' are file names (including directory).
%
%    *  'period' is a time array in matlab datenumbers
%       E.g. a 10-minute ( 10 minutes is 1 day / 24 hours /6) time series:
%       period = datenum(1999,5,1,3,0,0):1/24/6:datenum(1999,10,1,2,0,0);
%
%    *  'refdate' is a matlab datenumber or the string as
%       defined in the *.mdf file: "yyyy-mm-dd"
%       or "yyyymmdd".
%
% The following <keyword,value> pairs are implemented (not case sensitive):
%
%    * 'latitude'    [] default (same effect as none in t_tide)
%
%    NOTE THAT ANY LATITUDE IS REQUIRED FOR T_PREDIC TO INCLUDE NODAL FACTORS AT ALL
%
%    OPT = bct2bca() returns struct with default <keyword,value> pairs
%
% Note: t_tide does not generally return an A0 component, determine A0 yourselves.
%
% See also:  BCT2BCA, DELFT3D_NAME2T_TIDE, T_TIDE_NAME2DELFT3D,
%            BCT_IO, DELFT3D_IO_BCA, DELFT3D_IO_BND,
%            T_TIDE (http://www.eos.ubc.ca/~rich/)

% Requires the following m-functions:
% - bct_io
% - delft3d_io_bca
% - delft3d_io_bnd
% - t_tidename2freq
% - t_predic and associated stuff

% 2008 jul 11: * changed name of t_tide output (to prevent error due to ':' in current column name)

%   --------------------------------------------------------------------
%   Copyright (C) 2006-8 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: bca2bct.m 12970 2016-11-03 13:21:53Z gerben.deboer.x $
% $Date: 2016-11-03 21:21:53 +0800 (Thu, 03 Nov 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12970 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/bca2bct.m $

%% Defaults

OPT.bcafile     = '';
OPT.bctfile     = '';
OPT.bndfile     = '';
OPT.period      = [];
OPT.refdate     = [];
OPT.latitude    = []; % optional

%% Return defaults

if nargin==0
    varargout = {OPT};
    return
end

%% Input

OPT = setproperty(OPT,varargin{:});

%% Check input

if isempty(OPT.latitude);warning('No latitude passed, performing simple harmonic analysis, not tidal analysis!');end
if isempty(OPT.period  );errror('No period passed.' );end
if isempty(OPT.refdate );errror('No refdate passed.');end

%% Load (ancillary) data

BND = delft3d_io_bnd('read',OPT.bndfile);
disp(['Boundary definition file read: ',OPT.bndfile]);

BCA = delft3d_io_bca('read',OPT.bcafile,BND);
%[BCA,BND] = delft3d_io_bca('read',bcafile,BND;
disp(['Astronomic boundary data file read: ',OPT.bcafile]);

%% Date / time

if ischar(OPT.refdate)
    if length(OPT.refdate)==8
        %% "yyyymmdd"
        %  --------------------
        ReferenceTime       = str2num(OPT.refdate);
        OPT.refdate = datenum(str2num(OPT.refdate(1: 4)),...
            str2num(OPT.refdate(5: 6)),...
            str2num(OPT.refdate(7: 8)));
    else
        %% "yyyy-mm-dd"
        %  --------------------
        ReferenceTime       = str2num([OPT.refdate(1: 4);...
            OPT.refdate(6: 7);...
            OPT.refdate(9:10)]);
        OPT.refdate =  datenum(str2num(OPT.refdate(1: 4)),...
            str2num(OPT.refdate(6: 7)),...
            str2num(OPT.refdate(9:10)));
    end
else
    %% datenumber
    %  --------------------
    [Y,M,D,HR,MI,SC] = datevec(OPT.refdate);
    ReferenceTime  = str2num([num2str(Y,'%0.4d'),...
        num2str(M,'%0.2d'),...
        num2str(D,'%0.2d')]);
end

minutes_wrt_refdate = (OPT.period - OPT.refdate).*(24*60);

%% Fill BCT

BCT.FileName = OPT.bctfile;
BCT.NTables  = BND.NTables;

for ibnd=1:length(BND.DATA)
    
    %% Only for astronomical boundaries
    %  delft3d_io_bca already checked that the
    %  required tables exist
    
    if lower(BND.DATA(1).datatype)=='a'
        
        BCT.Table(ibnd).Name              = ['t_predic @ latitude ',num2str(OPT.latitude),' from bca file: ',OPT.bcafile];
        BCT.Table(ibnd).Contents          = 'uniform';
        BCT.Table(ibnd).Location          = BND.DATA(ibnd).name;
        BCT.Table(ibnd).TimeFunction      = 'non-equidistant';
        BCT.Table(ibnd).ReferenceTime     =  ReferenceTime;
        BCT.Table(ibnd).TimeUnit          = 'minutes';
        BCT.Table(ibnd).Interpolation     = 'linear';
        
        BCT.Table(ibnd).Data(:,1)         = minutes_wrt_refdate;
        
        BCT.Table(ibnd).Parameter(1).Name = 'Time starting at ITDATE = 0.0';
        BCT.Table(ibnd).Parameter(1).Unit = '[   min  ]';
        
        BCT.Table(ibnd).Parameter(2).Name = 'water elevation (z)  end A';
        BCT.Table(ibnd).Parameter(2).Unit = '[   m    ]';
        
        BCT.Table(ibnd).Parameter(3).Name = 'water elevation (z)  end B';
        BCT.Table(ibnd).Parameter(3).Unit = '[   m    ]';
        
        for isize=1:2
            
            %% Although delft3d_io_bca above cannot handle a different number
            %% of components per boundary yet (ncomponents),
            %% bca2bct can already (ncomp).
            %% Should be same for the two boundary end points though.

             %% TO DO handle case where 2 sides use same data node
            
            if isize == 1
                id = (ibnd*isize)+(ibnd-1);              
            elseif isize == 2
                id = (ibnd*isize);
            end
            
            if     isize==1
                % ncomp   = length(BCA.DATA(ibnd,isize).amp);
                ncomp   = length(BCA.DATA(1,id).amp);
            elseif isize==2
                % if ~(ncomp == length(BCA.DATA(ibnd,isize).amp));
                if ~(ncomp == length(BCA.DATA(1,id).amp));                   
                    error(['Number of components should be equal for two end points for boundary: ',BCT.Table(ibnd).Name ])
                end
            end
            
            %% Tidal prediction parameters
            %             H.names = BCA.DATA(ibnd,isize).names;

            H.names = BCA.DATA(1,id).names;           
            H.names = delft3d_name2t_tide(H.names);
            
            %% t_predic wants frequecies in cycles /hour
            
            [H.freq,...
                H.names,...
                H.tindex]   = t_tide_name2freq(cellstr(H.names),'unit' ,'cyc/hr');
            
            H.freq      = H.freq(:);
            H.names     = pad(char(H.names),4,' ');
            
            %% Tidal amp/phase
            
            %  tidecon is a matrix with
            %  column 1 amplitude
            %  column 2 amplitude error
            %  column 3 phase
            %  column 4 phase error
            
            %  the 2nd and 4th are set to eps, because when they are zero,
            %  t_predic shows a lot of the following warnings:
            
            %   Warning: Divide by zero.
            %   (Type "warning off MATLAB:divideByZero" to suppress this warning.)
            %   > In ...\t_tide\t_predic.m at line 92
            %     In ...\bca2bct.m at line 133
            %     In ...\bca2bct_example.m at line 9
            
            tidecon = zeros([ncomp 4]) + eps;
            
            for icomp=1:ncomp
%                 tidecon(icomp,1) = BCA.DATA(ibnd,isize).amp(icomp);
%                 tidecon(icomp,3) = BCA.DATA(ibnd,isize).phi(icomp);
                tidecon(icomp,1) = BCA.DATA(1,id).amp(icomp);
                tidecon(icomp,3) = BCA.DATA(1,id).phi(icomp);
            end
            
            % Results from t_tide:
            %
            %    tidestruc =
            %           name: [35x4 char]
            %           freq: [35x1 double]
            %        tidecon: [35x4 double]
            
            if isempty(OPT.latitude)
                hpredic = t_predic(OPT.period,H.names,H.freq,tidecon);
            else
                hpredic = t_predic(OPT.period,H.names,H.freq,tidecon,'latitude',OPT.latitude);
            end
            
            BCT.Table(ibnd).Data(:,isize+1) = hpredic;
            
        end
        
        disp(['Processed boundary ',num2str(ibnd),' of ',num2str(BND.NTables)])
        %pause
        
    end % if lower(BND.DATA(1).datatype)=='a'
    
end

%% Write the BCT file with the time series

bct_io('write',OPT.bctfile,BCT)

if nargout==1
    varargout = {BCT};
end

% BCT = bct_io('read','dummy.bct')
% ----------------------------------------------------------------
% BCT
%
%       Check: 'OK'
%    FileName: 'TMP_cas.bct'
%     NTables: 75
%       Table: [1x75 struct]
%
% BCT.Table(1)
%
%             Name: 'T-serie BCT north_001            for run: cas'
%         Contents: 'uniform'
%         Location: 'north_001'
%     TimeFunction: 'non-equidistant'
%    ReferenceTime: 19990506
%         TimeUnit: 'minutes'
%    Interpolation: 'linear'
%        Parameter: [1x3 struct]
%             Data: [3432x3 double]
%
% ----------------------------------------------------------------
