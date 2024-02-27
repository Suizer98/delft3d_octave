function D = t_tide_read(fname,varargin)
%t_tide_read   load ascii 'output' file as generated by t_tide
%
% D = t_tide_read(filename)
%
%See also: tide_iho, t_tide, textscan

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl	
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: t_tide_read.m 11599 2014-12-30 12:53:06Z gerben.deboer.x $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tide/t_tide/t_tide_read.m $
% $Keywords: $

    OPT.units = '?';
    
    OPT = setproperty(OPT,varargin);

%% start
   fid     = fopen(fname,'r');
      
%% metadata

      tmp     = dir(fname);
      
      if length(tmp)==0
          error(['file not found "',fname,'"'])
      end
      D.name  = tmp.name;
      D.date  = tmp.date;
      D.bytes = tmp.bytes;

%% header
      
    for ii=1:16
        rec = fgetl(fid);

        ind = strfind(rec,'start time:');
        if any(ind)
        D.observationStart = datenum(strtrim(rec([ind+11:end])),'dd-mmm-yyyy');
        end
        ind = strfind(rec,'record length (days) =');
        if any(ind)
        D.observationEnd = str2num(strtrim(rec([ind+23:end]))); % days
        end
        
        D.header{ii} = rec;
        
    end
    
    D.observationEnd = D.observationStart + D.observationEnd;

    if strcmpi(strtok(D.header{16}),'tide')
        C = textscan(fid,'%s%f%f%f%f%f%f');
    else
        for ii=17:21
         D.header{ii} = fgetl(fid);   
        end
        C = textscan(fid,'%s%f%f%f%f%f%f%f%f%f%f');
    end
    fclose(fid);          
  
      %-------------
      %
      %    file name: fname
      %    date: 01-Dec-2010
      %    nobs = 26281,  ngood = 26281,  record length (days) = 182.51
      %    start time: 01-Jan-1998
      %    rayleigh criterion = 1.0
      %    Greenwich phase computed with nodal corrections applied to amplitude \n and phase relative to center time
      %    
      %    x0= 5.97, x trend= 0
      %    
      %    var(x)= 3169321519.5862   var(xp)= 3053240866.7394   var(xres)= 115904582.427
      %    percent var predicted/var original= 96.3 %
      %    
      %         tidal amplitude and phase with 95% CI estimates
      %    
      %    tide   freq       amp     amp_err    pha    pha_err     snr
      % MM   0.0015122    0.0000  000.000   000.00   000.00        0
      % ...  
      % M8   0.3220456    0.0000  000.000   000.00   000.00        0
      %-------------
   
%% parse data

    D.data.name  = char(C{1});
    %D.data.significance    = cellfun(@(x) strcmp(x(1),'*'),D.component_name);
    D.data.significance    = D.data.name(:,1)=='*';
    D.data.name(D.data.significance,1) = ' ';
    D.data.name  = cellstr(char(strtrim(cellstr(D.data.name))));

    D.data.frequency  = C{2};

    if length(C)==7 % scalar
        D.data.fmaj       = C{ 3};D.name.fmaj = 'sema'           ;D.units.fmaj = OPT.units;D.long_name.fmaj = 'major ellipse axis of tidal component';
        D.data.emaj       = C{ 4};D.name.emaj = 'sema_error'     ;D.units.emaj = OPT.units;D.long_name.emaj = 'estimate of error of major ellipse axis of tidal component';
        D.data.fmin       = [];
        D.data.emin       = [];     
        D.data.pha        = C{ 5};D.name.pha  = 'phase'          ;D.units.pha  = 'degrees';D.long_name.pha  = 'phase of tidal component';
        D.data.finc       = [];  
        D.data.einc       = [];
        D.data.epha       = C{ 6};D.name.epha = 'phase_error'    ;D.units.epha = 'degrees';D.long_name.epha = 'estimate of error of phase of tidal component';
        D.data.snr        = C{ 7};D.name.epha = 'snr'            ;D.units.epha = '1'      ;D.long_name.epha = 'signal to noise ratio';
    else % vbector
        D.data.fmaj       = C{ 3};D.name.fmaj = 'sema'           ;D.units.fmaj = OPT.units;D.long_name.fmaj = 'major ellipse axis of tidal component';
        D.data.emaj       = C{ 4};D.name.emaj = 'sema_error'     ;D.units.emaj = OPT.units;D.long_name.emaj = 'estimate of error of major ellipse axis of tidal component';
        D.data.fmin       = C{ 5};D.name.fmin = 'semi'           ;D.units.fmin = OPT.units;D.long_name.fmin = 'minor ellipse axis of tidal component';
        D.data.emin       = C{ 6};D.name.emin = 'semi_error'     ;D.units.emin = OPT.units;D.long_name.emin = 'estimate of error of minor ellipse axis of tidal component';   
        D.data.finc       = C{ 7};D.name.finc = 'inc'            ;D.units.finc = 'degree' ;D.long_name.finc = 'ellipse orientation';
        D.data.einc       = C{ 8};D.name.einc = 'inc_error'      ;D.units.einc = 'degree' ;D.long_name.einc = 'estimate of error of ellipse orientation';
        D.data.pha        = C{ 9};D.name.pha  = 'phase'          ;D.units.pha  = 'degrees';D.long_name.pha  = 'phase of tidal component';
        D.data.epha       = C{10};D.name.epha = 'phase_error'    ;D.units.epha = 'degrees';D.long_name.epha = 'estimate of error of phase of tidal component';
        D.data.snr        = C{11};D.name.epha = 'snr'            ;D.units.epha = '1'      ;D.long_name.epha = 'signal to noise ratio';
    end

      
