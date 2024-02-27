function G = delft3d_io_dep(varargin)
%DELFT3D_IO_DEP   wrapper for WLDEP to deal with ambgiuous dummy rows. <<beta version!>>
%
%   G = DELFT3D_IO_DEP('read',filename)
%
%   G = DELFT3D_IO_DEP('read',filename,G,<keyword,value>)
%       where G is G = delft3d_io_grd(...)
%
%   G = DELFT3D_IO_DEP('read',filename,SIZE,<keyword,value>)
%       where SIZE is [mmax nmax] % note m first
%       reads depth of corner and center points and of center points
%       where the dummy rows are filled by mirroring.
%
%   G = DELFT3D_IO_DEP('read',filename,SIZE,<keyword,value>)
%       where the two keywords are mandatory, there is
%       no default value specified to avoid confusion:
%
% * location:    location of depth file data ('cen','cor')
%                Mandatory keyword.
% * dpsopt  :    interpolation method specified in mdf file ('dp','max','mean','min') to get center from corner depths
%                Mandatory keyword.
%
% When location is cen     , dpsopt   is not required.
% When dpsopt   is supplied, location is not required.
%
% * dummy   :    0/1 (defualt 1, i.e. dummy row col present in files). When 0 then
%                For corner data the last row/col is assumed dummy and absent,
%                for center dsta the 1st and last row/col are assumed dummy and absent.
% * nodatavalue : nodatavalue of data in dep file     (default -999)
% * missingvalue: nodatavalue of data in the G struct (default NaN)
%
%   DELFT3D_IO_DEP('write',filename,G     ,<keyword,value>)
%   with struct G, where the one keywords are mandatory, there
%   isno default value specified to avoid confusion:
%
%   DELFT3D_IO_DEP('write',filename,MATRIX,<keyword,value>)
%   with MATRIX defined at either centers of corners (no dummy rows/cols)
%
% * location:    location of depth file data ('cen','cor') to be written to file (mandatory)
% * nodatavalue: nodatavalue written to file (default -999)
% * mfilename:   optional keyword to add the mfilename from which
%                delft3d_io_dep.m is called to the meta info at the end of
%                the dep values (default is mfilename unknown)
% 
% Example:
%       mymatrix = peaks(5);
%       mydepfilename = 'mypeaks.dep';
%       delft3d_io_dep('write',mydepfilename,mymatrix,'location','cor','mfilename',mfilename);
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd,
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva,
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src,
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, wldep

%   delft3d_io_dep('write',FILENAME,MATRIX) where MATRIX is defined at the corner points.
%   or
%   delft3d_io_dep('write',FILENAME,STRUCT)
%   where STRUCT is a structure vector with either one of two fields
%   'depcor' or 'depcen', depeding on whether the data re defined at corner or center points.
%   - For depcor one dummy row /column  is  added.
%   - For depcen two dummy rows/columns are added.
%  When  both are present, depcen is taken.

%   --------------------------------------------------------------------
%   Copyright (C) 2005-7 Delft University of Technology
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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delft3d_io_dep.m 17313 2021-05-28 04:19:07Z chavarri $
% $Date: 2021-05-28 12:19:07 +0800 (Fri, 28 May 2021) $
% $Author: chavarri $
% $Revision: 17313 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_dep.m $

% 2009 aug 17 accounted for apparent swap by wldep

%% Input

if nargin ==1
    error(['At least 2 input arguments required: d3d_io_...(''read''/''write'',filename)']);
end

cmd   = varargin{1};
fname = varargin{2};

%% Read and calculate

if strcmpi(cmd,'read')
    
%% Keywords

    OPT.dummy        = 0;
    OPT.nodatavalue  = -999;
    OPT.missingvalue = NaN;
    OPT.location     = '   ';
    OPT.dpsopt       = '';    
    
    %% File info
    
    if isstruct(varargin{3})
        G           = varargin{3};
        SIZE        = [G.mmax G.nmax];
        tmp         = dir(fname);
        if length(tmp)==0
            error(['Depth file ''',fname,''' does not exist.'])
        end
        G.files.dep.name  = tmp.name ;
        G.files.dep.date  = tmp.date ;
        G.files.dep.bytes = tmp.bytes;
    else
        SIZE        = varargin{3};
        G           = dir(fname);
    end
    
    OPT = setproperty(OPT,varargin{4:end});
    
%     OPT.location     = pad(OPT.location,' ',3);
    G.location       = OPT.location;
    G.dpsopt         = OPT.dpsopt  ;
    
    %% Apply check and fills for inout matrix locations
    
    if strcmpi(OPT.location(1:3),'cor')
        if isempty(OPT.dpsopt)
            warning('keyword dpsopt required to determine depth at centers from corners: made cen.dep = []')
        end
    elseif strcmpi(G.location(1:3),'cen')
        if isempty(G.dpsopt)
            G.dpsopt = 'dp';
        end
    elseif isempty(strtrim(G.location))
       if isempty(G.dpsopt)
          error('either location or dpsopt should be suplied')
       end
    end
    
    if strcmpi(G.dpsopt,'dp')
        if isempty(strtrim(G.location))
            G.location = 'cen';
        elseif ~strcmpi(G.location(1:3),'cen')
            error('When dpsopt = dp, location should be cen');
        end
    elseif isempty(G.dpsopt)
       if isempty(strtrim(G.location))
          error('either location or dpsopt should be suplied')
       end
    else
        if isempty(strtrim(G.location))
            G.location = 'cor';
        elseif ~strcmpi(G.location(1:3),'cor')
             error('When dpsopt <> dp, location should be cor');
        end
    end
    
    %% Raw data
    
    %% Read bare number matrix without additional information
    %  Note SIZE is here [mmax nmax] % m first
    
    %  GJ de Boer, swapped 2010 mar 16
    %  for use with $Id: delft3d_io_dep.m 17313 2021-05-28 04:19:07Z chavarri $
    %  for use with $Id: delft3d_io_dep.m 17313 2021-05-28 04:19:07Z chavarri $
    
    if ~OPT.dummy
        D3Dmatrix                = wldep ('read',fname,[SIZE(1),SIZE(2)])';
    else
        if     strcmpi(G.location(1:3),'cor')
            matrix                   = wldep ('read',fname,[SIZE(1)-1,SIZE(2)-1])';
            D3Dmatrix                = addrowcol(matrix,[1   ],[1   ],OPT.missingvalue);
        elseif strcmpi(G.location(1:3),'cen')
            matrix                   = wldep ('read',fname,[SIZE(1)-2,SIZE(2)-2])';
            D3Dmatrix                = addrowcol(matrix,[-1 1],[-1 1],OPT.missingvalue);
        end
    end
    
    %% we swap so [n] is the first dimension
    %  we DON"T swap so [n] is the first dimension [changed GJ de Boer 2009 Apr 22]
    %  D3Dmatrix = D3Dmatrix';
    
    %% Aply mask
    D3Dmatrix(D3Dmatrix ==OPT.nodatavalue) = OPT.missingvalue;
    
    G.cen.dep_comment = 'positive: down';
    G.cor.dep_comment = 'positive: down';
    
    %% Depth at other grid locations
    
    %  we don't know where these data points are corners or centers.
    %  so it has to be specified
    
    if strcmpi(G.location(1:3),'cor')
        G.cor.dep = D3Dmatrix(1:end-1,1:end-1);
        if  strcmpi(G.dpsopt,'min')
            G.cen.dep = min(min(G.cor.dep(1:end-1,1:end-1),...
                                G.cor.dep(1:end-1,2:end  )),...
                            min(G.cor.dep(2:end  ,1:end-1),...
                                G.cor.dep(2:end  ,2:end  )));
        elseif  strcmpi(G.dpsopt,'mean')
            G.cen.dep = corner2center(G.cor.dep);
        elseif  strcmpi(G.dpsopt,'max')
            G.cen.dep = max(max(G.cor.dep(1:end-1,1:end-1),...
                                G.cor.dep(1:end-1,2:end  )),...
                            max(G.cor.dep(2:end  ,1:end-1),...
                                G.cor.dep(2:end  ,2:end  )));
          warning('flow kernel does not write max to center depths, but mean.')
        end
    elseif strcmpi(G.location(1:3),'cen')
        if  strcmpi(G.dpsopt,'dp') | isempty(G.dpsopt)
            G.cen.dep = D3Dmatrix(2:end-1,2:end-1);
            G.cor.dep = center2corner(G.cen.dep,'nearest');
            G.cor.dep_comment = {G.cor.dep_comment,'depths interpolated linearly from values at cell centers with nearest neightbour extrapolation near edges'};
        else
            error('when dpsopt~=''dp'' the depth need to be defined at the center points')
        end
    else
        error('location should eb ''cor'' or ''cen''')
    end
    
else strcmpi(cmd,'write');
    
    %% Keywords
    
    OPT.location    = '   ';
    OPT.nodatavalue = -999;
    OPT.name        = 'depth';
    OPT.unit        = '[m]';
    OPT.positive    = 'down';
    OPT.mfilename   = 'unknown mfilename';
    OPT.meta        = 0;
    OPT.dummy       = 1;
    OPT.format      = '%15.8f';
    
%     if numel(varargin)>3
    OPT = setproperty(OPT,varargin{4:end});
%     end
    
    tmp         = fileparts(fname);
        
    %% Get input data at corners or centers
    
    if ~isfield(OPT,'location')
        error('keyword ''location'' missing')
    end
    
    if ~isempty (OPT.location) && strcmp(OPT.location(1:3),'cen')
        
        if isstruct(varargin{3})
            G         = varargin{3};
        else
            G.cen.dep = varargin{3};
        end
        
        D3Dmatrix          = G.cen.dep;
        if OPT.dummy
            % NOTE : There was the transpose ' missing here...and this was
            % messing up the file writing - QUICKING was yielding : depth
            % does not fit grid
            D3Dmatrix          = addrowcol(D3Dmatrix,[-1 1],[-1 1],nan)';
            disp('Dummy values are added around the depth matrix')
        end
        position           = 'center';
        positiondummyvalue = 'first and last';
        
    elseif strcmp(OPT.location(1:3),'cor')
        
        if isstruct(varargin{3})
            G         = varargin{3};
        else
            G.cor.dep = varargin{3};
        end
        
        D3Dmatrix          = G.cor.dep;
        D3Dmatrix          = addrowcol(D3Dmatrix,1,1,nan)';
        position           = 'corner';
        positiondummyvalue = 'last';
        
    else
        
        error('No fields position definition cen or cor present in struct or in keywords')
        
    end
    
    D3Dmatrix(isnan(D3Dmatrix)) = OPT.nodatavalue;
    
    if isunix
        platform = 'unix';
    else
        platform = 'windows';
    end
    
    if ~OPT.meta % meta does not load in GUI
       wldep('write',fname,D3Dmatrix,'format','%15.14e');
    else
       metainfo = {['File type                       = Delft3d FLOW depth file (*.dep) (http://www.wldelft.nl/soft/d3d/intro/index.html)'],...
           ['variable                        = ',OPT.name],...
           ['nodatavalue                     = ',num2str(OPT.nodatavalue)],...
           ['position                        = ',position],...
           ['units                           = ',OPT.unit],...
           ['positive                        = ',OPT.positive],...
           ['dummy rows                      = ',positiondummyvalue],...
           ['dummy columns                   = ',positiondummyvalue],...
           ['size (incl. dummy rows/columns) = ',num2str(size(D3Dmatrix,1)),' ',num2str(size(D3Dmatrix,2))],...
           ['File written by                 = $Id: delft3d_io_dep.m 17313 2021-05-28 04:19:07Z chavarri $ $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_dep.m $ called from ', OPT.mfilename],...
           ['date time                       = ',datestr(now,31)],...
           ['matlab version                  = ',version],...
           ['platform                        = ',platform]};
       
       tmpfile1 = gettmpfilename(pwd);
       wldep('write',tmpfile1,D3Dmatrix);
       tmpfile2 = gettmpfilename(pwd);
       fid  = fopen(tmpfile2,'w');
       
       for ii=1:length(metainfo)
           fprintf(fid,'* ');
           fprintf(fid,char(metainfo{ii}));
           fprinteol(fid,platform);
       end
       fclose(fid);
       
       if isunix
           error('unix not implemented yet')
       else
           % put meta info
           doscommand = ['!copy ',tmpfile1,' + ',tmpfile2,' ',fname];
           eval(doscommand);
           delete(tmpfile1);
           delete(tmpfile2);
       end
    end
    
end

STRUC.DepFileName = varargin{2};
STRUC.iostat      = 1;
