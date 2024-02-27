function varargout = swan_io_table(varargin)
%SWAN_IO_TABLE            read SWAN ASCII output table
%
%   TAB = swan_io_table(INP.table(i))
%
%   TAB = swan_io_table(fname)
%   TAB = swan_io_table(fname,fieldcolumnnames)
%   TAB = swan_io_table(fname,fieldcolumnnames,mxyc)
%
% where INP.table is returned by INP = swan_io_input('INPUT.swn')
%    for multidimensional INP.table loads all tables. It also
%    reshapes 2D point sets, and reshapes NONSTATionary table data.
% where fname is the table file name (e.g. *.crv or *.dat)
% where fieldcolumnnames is a cell array or white space delimited char 
%    with the field names for each column. By default these are
%    the small case SHORT names as used in the SWAN input file syntax.
%    Use SWAN_INPUT to get these. Use SWAN_QUANTITY to
%    get info regarding these. All fieldnames are turned into upper case.
%    If no fieldnames specified, a bulk raw output matrix is returned.
% where mxyc is a 2-element vector with the number of 
%    SWAN !nodes! , (mxc+1) i.e. 1 more than the number of 
%    SWAN !meshes! mxc as given in the SWAN input file.
%    Use swan_input to get these (in case of COMPGRID).
%    If not specified, or empty, 1D bulk vectors are returned
%    that you have to reshape yourselves.
% if field TIME is present, the columns are reshaped into 2D 
%    matrices [points x time] and TIME is converted to matlab datenum.
%    If field TIME is absent, but INP.table(i) is passed, any TIME
%    vector is reconstructed ans use likewise.
%
% Example: load and plot nonstationary transects:
%
%       pcolorcorcen(tab.TIME,tab.XP,tab.HS)
%       datetick('x')
%       tickmap('y')
%
% Example to load following SWAN table:
%
%    ----------------------------------------------------
%    TABLE 'COMPGRID' HEADER   'tst.crv'  XP YP DEP HSIGN 
%    ----------------------------------------------------
%
% Example to load SWAN table without loading input file
%
%    TAB = swan_io_table('tst.crv','XP YP DEP HSIGN');
%
% Example to load SWAN table automatically using INPUT file-info:
%
%    INP = swan_io_input('INPUT')
%    TAB = swan_io_table(INP.table) % also takes xexc into account.
%
%    % is same as (below does not apply nodavalue for x,y from input grid)
%
%    for itab=1:length(INP.table)
%       TAB(itab) = swan_io_table(INP.table(itab).fname ,...
%                                 INP.table(itab).parameter.names,...
%                                [INP.table(itab).mxc+1  ...
%                                 INP.table(itab).myc+1]);
%    end
%
%
% See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_GRD, SWAN_IO_BOT

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2010 Delft University of Technology
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

% $Id: swan_io_table.m 11780 2015-03-05 09:30:47Z gerben.deboer.x $
% $Date: 2015-03-05 17:30:47 +0800 (Thu, 05 Mar 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11780 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_io_table.m $

% 2009 Jun 04: use new matlab code-cells syntax to divide code into 'chapters'
% 2009 mar 12: added option to read based on solely table 
%              struct as read by SWAN_IO_INPU. Removed 
%              default parameter name list, only split into 
%              fields when parameter names are specified, changed 
%              order of input into (...,fieldcolumnnames,<mxyc>). [Gerben de Boer]
% 2009 mar 19: added loading of fname incl. path (as added to table struct in SWAN_IO_INPUT)
% 2010 sep 28: apply default nodatavalues
% TO DO: use user-defined overruling of nodatavalues

%% Input

   INP.table.mmax = [];
   INP.table.nmax = [];
   
   if isstruct(varargin{1})
      INP.table = varargin{1};
      
   %% Recursively call SWAN_IO_TABLE for multiple tables

      if length(INP.table(:)) > 1
         disp(['swan_io_table: Loading multiple tables.'])
         for itab=1:length(INP.table)      
            TAB(itab) = swan_io_table(INP.table(itab));  
            disp(['loaded table ',num2str(itab),': ',INP.table(itab).sname])
         end
         TAB = reshape(TAB,size(INP.table)); % for 2D TAB arrays
         varargout = {TAB};
         return
         
   %% Proceed SWAN_IO_TABLE for single table

      else
         if ~(INP.table.mxc==0 | INP.table.myc==0)
         INP.table.mmax = INP.table.mxc + 1;
         INP.table.nmax = INP.table.myc + 1;
         else
         INP.table.mmax = [];
         INP.table.nmax = [];
         end
      end
      
   elseif ischar(varargin{1})

      INP.table.fullfilename = varargin{1};

   %% column names

      if nargin>1
   
          % REMOVED DELFTD_WAVE DEFAULT:
          %  Define default (Delft3D) Column parameter names
          % -------------------------
          % 
          % INP.table.parameter.nfields     = ones(18,1);
          % INP.table.parameter.nfields( 5) = 2;
          % INP.table.parameter.nfields( 6) = 2;
          % INP.table.parameter.nfields(17) = 2;
          % 
          %                                             %  parameter
          %                                             %     columns
          %                                             %          dimensions (vector vs. scalar)
          %                                             % --------------------------------
          % INP.table.parameter.names  = {'HS     ',... %  1  1    1
          %                               'DIR    ',... %  2  2    1
          %                               'TM01   ',... %  3  3    1
          %                               'DEP    ',... %  4  4    1
          %                               'VEL    ',... %  5  5- 6 2
          %                               'TRA    ',... %  6  7- 8 2
          %                               'DSPR   ',... %  7  9    1
          %                               'DISS   ',... %  8 10    1
          %                               'LEAK   ',... %  9 11    1
          %                               'QB     ',... % 10 12    1
          %                               'XP     ',... % 11 13    1
          %                               'YP     ',... % 12 14    1
          %                               'DIST   ',... % 13 15    1
          %                               'UBOT   ',... % 14 16    1
          %                               'STEEP  ',... % 15 17    1
          %                               'WLEN   ',... % 16 18    1
          %                               'FOR    ',... % 17 19-20 2
          %                               'RTP    ',... % 18 21    1
          %                               'PDIR   '};   % 19 22    1

          %                               'WIND   ',... %  x  x    2          
         INP.table.parameter.names  = upper(varargin{2});
         if ~iscell(INP.table.parameter.names)
            INP.table.parameter.names = strtokens2cell(strtrim(INP.table.parameter.names));
         end
         INP.table.parameter.nfields = ones(length(INP.table.parameter.names),1);
         
      end

%% reshape size

      if nargin>2
         if ~isempty(varargin{3})
            INP.table.mmax = varargin{3}(1);
            INP.table.nmax = varargin{3}(2);
         end
      end
      if nargin>3
         error('syntax: dep = swan_TABLE(filename,<mxyc,fieldnames>)')
      end
      
   end
   
%% for all vectors define 2 columns

   if nargin>1 | isstruct(varargin{1})
      
      for ifield=1:length(INP.table.parameter.nfields)
         
         fldname = char(strtrim(INP.table.parameter.names{ifield}));
         
         if length(fldname) > 5
            fldname = fldname(1:5);
         end
         
         fldname = strtrim(fldname);
         
         if strcmp(upper(fldname),'VEL')   | ...
            strcmp(upper(fldname),'TRA')   | ...
            strcmp(upper(fldname),'WIND' ) | ...
            strcmp(upper(fldname),'FOR')
   
             INP.table.parameter.nfields(ifield) = 2;  
   
         end
         
      end % for ifield=1:length(shape.nfields)
      
   end % nargin>1 | isstruct(varargin{1})   
   
%% Load full raw matrix

   dat = load(INP.table.fullfilename); %load(TAB.fname);
   
%%  split into scalar/vector columns and give names (only possible when INP is supplied ...)

if isfield(INP.table,'parameter')

   %% load table with default nodatavalues

   D = swan_quantity;
   
   quantitynames = fieldnames(D);

   for ifield=1:length(INP.table.parameter.nfields)

      ndata   = INP.table.parameter.nfields(ifield); % 1 or 2
      fldname_long = char(strtrim(INP.table.parameter.names{ifield}));
      
      % find match with minimal short names, but return fldname_long to user
      for i=1:length(quantitynames)
         if strmatch(quantitynames{i},fldname_long)
             fldname = quantitynames{i};
             break
         end
      end

      %  determine nodatavalue that differs per parameter
      
      if     strcmp(fldname,'XP') & isfield(INP.table,'xexc')
         nodatavalue = INP.table.xexc;
      elseif strcmp(fldname,'YP') & isfield(INP.table,'yexc')
         nodatavalue = INP.table.yexc;
      else      
         nodatavalue = D.(fldname).OVEXCV;
      end
      
      % ['ifield:',num2str(ifield),' ndata:',num2str(ndata),' fldname:',fldname]

      for idata = 1:INP.table.parameter.nfields(ifield)

      %  extract data block one parameters per blokc

         columns = sum(INP.table.parameter.nfields(1:ifield-1)) + idata;
         data    = dat(:,columns);
         
      %  apply nodatavalue

         data(data==nodatavalue)=nan; % apply default nodatavalues

      %  reshape 1D column to proper 2D matrix (if mxc,myc provided)
         
         if ~isempty(INP.table.mmax) & ...
            ~isempty(INP.table.nmax)
            nt = prod(size(data))/INP.table.mmax/INP.table.nmax;
            TAB.(fldname_long)(:,:,idata) = reshape(data,[nt INP.table.mmax INP.table.nmax]);
         else
            TAB.(fldname_long)(:,idata  ) = data;
         end
      end

   end
   
   %% reconstruct TIME, only if full INP was passed
   
   if ~isfield(TAB,'TIME')
       if isfield(INP.table,'tbegtbl') & isfield(INP.table,'points')
           nxy = length(INP.table.points.xp);
           nt = length(TAB.(fldname_long))./nxy;
           TAB.TIME = INP.table.tbegtbl + [0:(nt-1)]*INP.table.delttbl;
           TAB.TIME = make1D(repmat(TAB.TIME,[nxy 1]));
           [Y,MO,D,H,MI,S]=datevec(TAB.TIME);
           TAB.TIME = Y.*10000+MO.*100 + D+H./100+MI./1000+S./1000000;
       end
   end   
   
   %% turn TIME into seperater dimension
   
   if isfield(TAB,'TIME')
       
        nt  = length(unique(TAB.TIME));
        nxy = length(TAB.TIME)/nt;
        varnames = fieldnames(TAB);
        for ivar=1:length(varnames)
            varname = varnames{ivar};
            ncol = size(TAB.(varname),2);
            TAB.(varname) = reshape(TAB.(varname),[nxy nt ncol]);   
        end
        TAB.TIME = time2datenum(TAB.TIME(1,:));
        if isfield(TAB,'XP');TAB.XP = TAB.XP(:,1);end
        if isfield(TAB,'YP');TAB.YP = TAB.YP(:,1);end
       
   end
   
   varargout = {TAB};

else

   varargout = {dat};

end % if isfield(INP.table,'parameter')

%% EOF
