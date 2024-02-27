function varargout = vs_get_constituent_index(NFSstruct,varargin)
%VS_GET_CONSTITUENT_INDEX   Read index information required to read constituents by name.
%
% INDEX = vs_get_constituent_index(NFSstruct)
%    returns a struct INDEX with a field per parameter (lower case)
%       'salinity'
%       'temperature'
%       'sediment_mud'
%       'turbulent_energy'
%       'energy_dissipation'
%    each with subfields
%       'index' index in dimenson dim
%       'dim'
%       'elementname'
%       'groupname'
%
% vs_get_constituent_index(NFSstruct)
%    Displays the above tree on the command line.
%
% INDEX = vs_get_constituent_index(NFSstruct,'parameter') returns only
%    the subffield for parameter
%
% STRUCT                            = vs_get_constituent_index(NFSstruct,'parameter');
%
% [index,dim                      ] = vs_get_constituent_index(NFSstruct,'parameter');
% [index,dim,elementname          ] = vs_get_constituent_index(NFSstruct,'parameter');
% [index,dim,groupname,elementname] = vs_get_constituent_index(NFSstruct,'parameter');
%
% [index                          ] = vs_get_constituent_index(NFSstruct,'parameter','index');
% [dim                            ] = vs_get_constituent_index(NFSstruct,'parameter','dim');
% [groupname                      ] = vs_get_constituent_index(NFSstruct,'parameter','groupname');
% [elementname                    ] = vs_get_constituent_index(NFSstruct,'parameter','elementname');
%
% Implemented are trihfile and trimfile, also ada/hda WAQ files
%
%See also: VS_USE

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2007 Delft University of Technology
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

% $Id: vs_get_constituent_index.m 11967 2015-06-08 21:07:10Z jagers $
% $Date: 2015-06-09 05:07:10 +0800 (Tue, 09 Jun 2015) $
% $Author: jagers $
% $Revision: 11967 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_get_constituent_index.m $
% 2009 sep 28: added implementation of WAQ ada/hda files [Yann Friocourt]

if ischar(NFSstruct)
    NFSstruct = vs_use(NFSstruct);
end

if (~(strcmp(NFSstruct.SubType,'Delft3D-waq-map') || ...
        strcmp(NFSstruct.SubType,'Delft3D-waq-history')))
    [m,n,k] = vs_mnk(NFSstruct,'quiet');
end

%   Salinity
%   Sediment Mud
%   Turbulent energy
%   Energy dissipation

returntype = [];
if nargin>1
    parameter = lower(varargin{1});
    if nargin>2
        returntype = varargin{2};
    end
else
    parameter = [];
end

%IND = struct([]);

if strcmp(NFSstruct.SubType,'Delft3D-trim')
    
    %Groupname:map-const        Dimensions:(1)
    %  No attributes
    %    LSTCI           INTEGER *  4                  [   -   ]        ( 1 )
    %        Number of constituents
    %    LTUR            INTEGER *  4                  [   -   ]        ( 1 )
    %        Number of turbulence quantities
    %    LSED            INTEGER *  4                  [   -   ]        ( 1 )
    %        Number of sediment constituents
    %
    %Groupname:map-series       Dimensions:(109)
    %  No attributes
    %    R1              REAL    *  4                  [   -   ]        ( 236 156 16 1 )
    %        Concentrations per layer in zeta point
    %    RTUR1           REAL    *  4                  [   -   ]        ( 236 156 17 2 )
    %        Turbulent quantity per layer in zeta point
    
    names                   = vs_let(NFSstruct,'map-const','NAMCON','quiet');
    names                   = shiftdim(names,1); % remove first dummy dimension
    groupname               = 'map-series';
    dim                     = 4; % for k=1 and k >1
    constituent_elementname = 'R1';
    turbulence_elementname  = 'RTUR1';
    
    %no_turbulent_quantities = vs_get_elm_size(NFSstruct,turbulence_elementname ,4)
    
    no_constituents         = vs_let(NFSstruct,'map-const','LSTCI','quiet');
    
    if vs_get_elm_size(NFSstruct,'LSED')
        no_sediment_constituents= vs_let(NFSstruct,'map-const','LSED','quiet');
    end
    no_turbulent_quantities = vs_let(NFSstruct,'map-const','LTUR' ,'quiet');
    
elseif strcmp(NFSstruct.SubType,'Delft3D-trih')
    
    %Groupname:his-const        Dimensions:(1)
    %  No attributes
    %    LSTCI           INTEGER *  4                  [   -   ]        ( 1 )
    %        Number of constituents
    %    LTUR            INTEGER *  4                  [   -   ]        ( 1 )
    %        Number of turbulence quantities
    %    NAMCON          CHARACTE* 20                  [   -   ]        ( 1 )
    %        Name of constituents / turbulent quantities
    %    LSED            INTEGER *  4                  [   -   ]        ( 1 )
    %        Number of sediment constituents
    %    LSEDBL          INTEGER *  4                  [   -   ]        ( 1 )
    %        Number of bedload sediment fractions
    %    NAMSED          CHARACTE* 20                  [   -   ]        ( 1 )
    %        Name of sediment fractio
    %
    %Groupname:his-series       Dimensions:(865)
    %  No attributes
    %    GRO             REAL    *  4                  [   -   ]        ( 1 )
    %        Concentrations per layer in station (zeta point)
    %    ZTUR            REAL    *  4                  [   -   ]        ( 1 )
    %        Turbulent quantity per layer in station (zeta point)
    
    names                   = vs_let         (NFSstruct,'his-const','NAMCON','quiet');
    
    groupname               = 'his-series';
    names                   = shiftdim(names,1); % remove first dummy dimension
    dim                     = 3; % for k=1 and k >1
    constituent_elementname = 'GRO';
    turbulence_elementname  = 'ZTUR';
    
    %no_constituents         = vs_get_elm_size(NFSstruct,constituent_elementname,4)
    %no_turbulent_quantities = vs_get_elm_size(NFSstruct,turbulence_elementname ,4)
    
    no_constituents         = vs_let(NFSstruct,'his-const','LSTCI','quiet');
    no_turbulent_quantities = vs_let(NFSstruct,'his-const','LTUR' ,'quiet');
    
elseif strcmp(NFSstruct.SubType,'Delft3D-com') & ~isempty(parameter)
    
    if strcmp(lower(parameter),'salinity')
        IND.(parameter).index                   = 1;
        IND.(parameter).dim                     = 3;
        IND.(parameter).groupname               = 'DWQTIM';
        IND.(parameter).elementname             = 'RSAL';
    elseif strcmp(lower(parameter),'temperature')
        IND.(parameter).index                   = 1;
        IND.(parameter).dim                     = 3;
        IND.(parameter).groupname               = 'DWQTIM';
        IND.(parameter).elementname             = 'RTEM';
    else
        error(['Parameter not implemented yet/not found in file: ',parameter])
    end
    
elseif strcmp(NFSstruct.SubType,'Delft3D-com') & isempty(parameter)
    
    parameter = 'salinity';
    IND.(parameter).index                   = 1;
    IND.(parameter).dim                     = 3;
    IND.(parameter).groupname               = 'DWQTIM';
    IND.(parameter).elementname             = 'RSAL';
    
    parameter = 'temperature';
    IND.(parameter).index                   = 1;
    IND.(parameter).dim                     = 3;
    IND.(parameter).groupname               = 'DWQTIM';
    IND.(parameter).elementname             = 'RTEM';
    
    parameter = [];
    
elseif (strcmp(NFSstruct.SubType,'Delft3D-waq-map') || ...
        strcmp(NFSstruct.SubType,'Delft3D-waq-history'))
    
    names                   = vs_let(NFSstruct,'DELWAQ_PARAMS','SUBST_NAMES','quiet');
    names                   = shiftdim(names,1); % remove first dummy dimension
    names                   = cellstr(names);
    groupname               = 'DELWAQ_RESULTS';
    dim                     = 2; % for k=1 and k >1
    
    %no_constituents         = vs_get_elm_size(NFSstruct,constituent_elementname,4)
    %no_turbulent_quantities = vs_get_elm_size(NFSstruct,turbulence_elementname ,4)
    
    no_constituents         = vs_let(NFSstruct,'DELWAQ_PARAMS','SIZES',{1},'quiet');
    
    for i = 1:no_constituents
        parameter = names{i};
        IND.(parameter).index                   = 1;
        IND.(parameter).dim                     = 2;
        IND.(parameter).groupname               = 'DELWAQ_RESULTS';
        IND.(parameter).elementname             = ['SUBST_' sprintf('%03d', i)];
    end
    
    parameter = [];
    
else
    
    error('Invalid NEFIS file for this action.');
    
end


if strcmp(NFSstruct.SubType,'Delft3D-trim') | ...
        strcmp(NFSstruct.SubType,'Delft3D-trih')
    names                     = squeeze(names);
    if ~isempty(names)
        constituents              = names(1:no_constituents,:);
        for in =1:size(constituents,1)
            name                   = lower(mkvar(deblank(constituents(in,:))));
            IND.(name).index       = in;
            IND.(name).dim         = dim;
            IND.(name).groupname   = groupname;
            IND.(name).elementname = constituent_elementname;
        end
    else
        IND = struct([]);
    end
    
    if k >1
        turbulent_quantities     = names(no_constituents+1:end,:);
        for in =1:size(turbulent_quantities,1)
            name                   = lower(mkvar(deblank(turbulent_quantities(in,:))));
            IND.(name).index       = in;
            IND.(name).dim         = dim;
            IND.(name).groupname   = groupname;
            IND.(name).elementname = turbulence_elementname;
        end
    end
end

if exist('IND','var')
    fldnames = fieldnames(IND);
else
    IND = struct([]);
end

if    nargout==0
    if ~exist('IND')
        disp('No constituents found.')
    else
        for i=1:length(fldnames)
            name = fldnames{i};
            disp(['   ',name,':'])
            disp(['      index      : ',num2str(IND.(name).index       )]);
            disp(['      dim        : ',num2str(IND.(name).dim         )]);
            disp(['      groupname  : ',        IND.(name).groupname    ]);
            disp(['      elementname: ',        IND.(name).elementname  ]);
        end
    end
else
    if ~ isempty(parameter) & ...
            ~any(strcmp(fldnames,parameter))
        disp(['Parameter not implemented yet/not found in file: ',parameter])
        IND.(parameter).index       = [];
        IND.(parameter).dim         = [];
        IND.(parameter).groupname   = [];
        IND.(parameter).elementname = [];
    end
    if     nargout==1 & isempty(parameter)
        varargout = {IND};
    elseif nargout==1
        if isempty(returntype)
            varargout = {IND.(parameter)};
        elseif strcmp(returntype,'index')
            varargout = {IND.(parameter).index};
        elseif strcmp(returntype,'dim')
            varargout = {IND.(parameter).dim};
        elseif strcmp(returntype,'groupname')
            varargout = {IND.(parameter).groupname};
        elseif strcmp(returntype,'elementname')
            varargout = {IND.(parameter).elementname};
        end
    elseif nargout==2  & ~isempty(parameter)
        varargout = {IND.(parameter).index,...
            IND.(parameter).dim};
    elseif nargout==4  & ~isempty(parameter)
        varargout = {IND.(parameter).index,...
            IND.(parameter).dim,...
            IND.(parameter).elementname};
    elseif nargout==4  & ~isempty(parameter)
        varargout = {IND.(parameter).index,...
            IND.(parameter).dim,...
            IND.(parameter).groupname,...
            IND.(parameter).elementname};
    else
        error('invalid argument combination')
    end
end
