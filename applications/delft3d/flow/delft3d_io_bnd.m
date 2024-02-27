function varargout = delft3d_io_bnd(cmd,varargin),
%DELFT3D_IO_BND   read/write open boundaries (*.bnd) <<beta version!>>
%
%  D = delft3d_io_bnd('read' ,filename);
%
%  D = delft3d_io_bnd('read' ,filename,<G>);
%
% where G = delft3d_io_grd() also returns mn, x and y
% of each boundary segment. Useful for interpolating boundary
% conditions from 2D maps (nesting).
%
%       delft3d_io_bnd('write',filename,D);
%
% writes boundary struct to *.bnd file format. The data structure 
% fields that are actually required for writing are returned when 
% calling delft3d_io_bnd() without arguments.
%
% Example:
%  LBD = nc2struct('http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc','include',{'x','y'})
%  GRD = delft3d_io_grd('read','wadden4.grd');
%  BND = delft3d_io_bnd('read','wadden2005.bnd',GRD);
%  pcolorcorcen(GRD.cor.x,GRD.cor.y,nan.*GRD.cen.x,[.5 .5 .5])
%  axis equal
%  tickmap('xy')
%  hold on
%  plot(BND.x',BND.y','k.-')
%  axis(axis)
%  plot(LBD.x,LBD.y)
%
% See also: delft3d, d3d_attrib, delft3d_io_grd, delft3d_io_bch, bct_io, bct2bca, pol2bca

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

% $Id: delft3d_io_bnd.m 16344 2020-04-29 07:16:33Z kaaij $
% $Date: 2020-04-29 15:16:33 +0800 (Wed, 29 Apr 2020) $
% $Author: kaaij $
% $Revision: 16344 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_bnd.m $

% 2008 Nov 28: * corrected test for 3d-profile (missing dash) [Yann Friocourt]
%
% 2008 Jul 11: * made it work when Labels have length < 11 [Anton de Fockert]
%              * removed useless threeD keyword [Anton de Fockert]

if nargin ==0
    bnd.DATA.name         = '--Unnamed--234567890]';
    bnd.DATA.bndtype      = '{Z} | C | N | Q | T | R';
    bnd.DATA.datatype     = '{A} | H | Q | T';
    bnd.DATA.mn           = [0 0 0 0];
    bnd.DATA.alfa         = nan;
    bnd.DATA.vert_profile = '[ {Uniform} | Logarithmic | 3D profile]';
    bnd.DATA.labelA       = '--Unnamed--2';
    bnd.DATA.labelB 	     = '--Unnamed--2';
    varargout = {bnd};
    return
elseif nargin ==1
    error(['At least 2 input arguments required: delft3d_io_bnd(''read''/''write'',filename)'])
end

switch lower(cmd),
    case 'read',
        S=Local_read(varargin{:});
        if nargout==1
           varargout = {S};
        elseif nargout >1
            error('too much output paramters: 0 or 1')
        end
        if S.iostat<0,
            error(['Error opening file: ',varargin{1}])
        end;
    case 'write',
        iostat=Local_write(varargin{:});
        if nargout==1
            varargout = {iostat};
        elseif nargout >1
            error('too much output paramters: 0 or 1')
        end
        if iostat<0,
            error(['Error opening file: ',varargin{1}])
        end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function S=Local_read(varargin),

S.filename = varargin{1};

%if nargin==2 | nargin==4
%   threeD    = varargin{2};
%else
%   threeD    = 0;
%end

mmax = Inf;
nmax = Inf;
G    = [];
if nargin==2
    G    = varargin{2};
    mmax = G.mmax;
    nmax = G.nmax;
end

fid          = fopen(S.filename,'r');
if fid==-1
    S.iostat   = fid;
else
    S.iostat   = -1;
    i            = 0;
    
    while ~feof(fid)
        
        i = i + 1;
        
        S.DATA(i).name         = strtrim(fscanf(fid,'%20c',1));
        S.DATA(i).bndtype      = fscanf(fid,'%1s' ,1);
        S.DATA(i).datatype     = fscanf(fid,'%1s' ,1);
        S.DATA(i).mn           = fscanf(fid,'%i'  ,4);
        
        % turns the endpoint-description along gridlines into vectors
        
        [S.DATA(i).m,...
            S.DATA(i).n]=meshgrid(S.DATA(i).mn(1):S.DATA(i).mn(3),...
            S.DATA(i).mn(2):S.DATA(i).mn(4));
        
        if S.DATA(i).mn(1)==mmax+1
           S.DATA(i).mn(1)= mmax;
        end
        if S.DATA(i).mn(2)==nmax+1
           S.DATA(i).mn(2)= nmax;
        end
        if S.DATA(i).mn(3)==mmax+1
           S.DATA(i).mn(3)= mmax;
        end
        if S.DATA(i).mn(4)==nmax+1
           S.DATA(i).mn(4)= nmax;
        end
        
        S.DATA(i).alfa         = fscanf(fid,'%f'  ,1);
        
        rec = fgetl(fid);
        
        %if threeD
        %
        % TK: here it gets complicated!!! We don't now from de bnd file if
        % a simulation is 3D so if vert profile is included in the bnd file
        % lets use the number of strings in rec as indication:
        threeD = false;
        astr0  = false;
        if ~isempty(rec)
            index =  d3d2dflowfm_decomposestr(strtrim(rec));
            if isempty(index)
                threeD =true;
            elseif(length(index)) == 3
                astro = true;
            elseif(length(index)) == 4
                threeD = true;
                astro  = true;
            end
        end
  
        if strcmpi('C',S.DATA(i).bndtype) | ...
           strcmpi('Q',S.DATA(i).bndtype) | ...
           strcmpi('T',S.DATA(i).bndtype) | ...
           strcmpi('R',S.DATA(i).bndtype)
            
           % TK 
           if threeD
               [S.DATA(i).vert_profile,rec] = strtok(rec); %,fscanf(fid,'%20c',1);
               %
               if strcmpi(S.DATA(i).vert_profile,'3D')
                   
                   [dummy,rec] = strtok(rec); %,fscanf(fid,'%20c',1);
                   
                   S.DATA(i).vert_profile = '3d-profile';
                   
               end
               
               if ~(strcmpi(S.DATA(i).vert_profile,'uniform')     | ...
                       strcmpi(S.DATA(i).vert_profile,'Logarithmic') | ...
                       strcmpi(S.DATA(i).vert_profile,'3d-profile'))
                   
                   error(['Not a valid profile: ''',S.DATA(i).vert_profile])
                   
               end
               
           end
           
        end
        %end
        
        if strcmp('A',S.DATA(i).datatype)
            
            % tk
            if astro
                [S.DATA(i).labelA,rec]  = strtok(rec); %[letter,fscanf(fid,'%11c',1)];
                [S.DATA(i).labelB,rec]  = strtok(rec); %[letter,fscanf(fid,'%11c',1)];
            end
            
        else
        end
        
        try % for conversion to unstruc use labelA as pli number and labelB as sequence number inside that pli
            
            [S.DATA(i).pli_name,rec]  = strtok(rec);
             S.DATA(i).pli_nr         = str2num(strtok(rec));
            
        catch
        end
        
    end
    
    S.iostat   = 1;
    S.NTables  = i;
    
    %% (m,n) coordinates as used for D3D matrices with dummy rows and columns
    
    for i=1:S.NTables
        S.m(i,:) = [S.DATA(i).mn(1) S.DATA(i).mn(3)];
        S.n(i,:) = [S.DATA(i).mn(2) S.DATA(i).mn(4)];
    end
    
    if ~isempty(G)
        S.x = nan(size(S.m));
        S.y = nan(size(S.m));
        
        for i=1:S.NTables
            for j=1:2
                S.x(i,j) = G.cend.x(S.n(i,j),S.m(i,j));
                S.y(i,j) = G.cend.y(S.n(i,j),S.m(i,j));
            end
        end
    end
    
    
    %% (m,n) coordinates as used for matrices without dummy rows
    %  boundaries defined at faces (so each segment is spanned between two corners)
    
    fclose(fid);
    iostat=1;
    
end

% ------------------------------------

function iostat=Local_write(filename,S),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

for i=1:length(S.DATA)
    
    fprintfstringpad(fid,20,S.DATA(i).name,' ');
    
    fprintf(fid,'%1c',' ');
    % fprintf automatically adds one space between all printed variables
    % within one call
    fprintf(fid,'%1c %1c %5i %5i %5i %5i %f',...
        S.DATA(i).bndtype ,...
        S.DATA(i).datatype,...
        S.DATA(i).mn(1)   ,...
        S.DATA(i).mn(2)   ,...
        S.DATA(i).mn(3)   ,...
        S.DATA(i).mn(4)   ,...
        S.DATA(i).alfa    );
    
%     if S.DATA(i).threeD
        if strcmp('C',S.DATA(i).bndtype) | ...
                strcmp('Q',S.DATA(i).bndtype) | ...
                strcmp('T',S.DATA(i).bndtype) | ...
                strcmp('R',S.DATA(i).bndtype)
            
            if ~isfield(S.DATA(i),'vert_profile')
                % DEFAULT
                vert_profile = 'Uniform';
                %vert_profile = 'Logarithmic';
            else
                vert_profile = S.DATA(i).vert_profile;
            end
            fprintf(fid,'%1c',' ');
            fprintfstringpad(fid,20,vert_profile,' ');
            
        end
%     end
    
    if strcmp('A',S.DATA(i).datatype)
        % print only labels for *.bca file if present
        if isfield(S.DATA(i),'labelA')
            fprintf(fid,'%12s %12s',...
                S.DATA(i).labelA,...
                S.DATA(i).labelB);
        end
    end
    
    if     strcmp(lower(OS(1)),'u')
        fprintf(fid,'\n');
    elseif strcmp(lower(OS(1)),'w')
        fprintf(fid,'\r\n');
    end
    
end;
fclose(fid);
iostat=1;