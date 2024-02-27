classdef nansparse
    %NANSPARSE  Sparse matrix padded with nans, instead of zeros.
    %
    %   Sparse matrices are efficient for matrices with many zeros, and few
    %   other values. Similarly, nansparse matrices are efficient for matrices
    %   with many nan enrties, and few other data values.
    %
    %   A lot of Matlab functions are overloaded to work with the
    %   nansparse. 
    %
    %   Example:
    %
    %     data            = rand(300,1000);
    %     data(data>0.10) = NaN;
    %     data(data<0.01) = 0;
    % 
    %     ns = nansparse(data);
    %     % Compare memory use
    %     whos ns data
    %     % Supported methods
    %     methods(ns)
    %     % Calculate fill percentage. Answer of ns is a sparse
    %     sum(sum(~isnan(ns  ))) / numel(ns  )
    %     sum(sum(~isnan(data))) / numel(data)
    %     % Use full to convert (part of) a nansparse to a double array
    %     full(ns(1:6,1:10))

    %   TODO:
    %     - Overload basic statistic functions as sum, mean, std etc

    %   See also: Sparse
    
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
    %       Thijs Damsma
    %
    %       tda@vanoord.com
    %
    %       Watermanweg 64
    %       3067 GG
    %       Rotterdam
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
    
    % This tool is part of OpenEarthTools.
    % OpenEarthTools is an online collaboration to share and manage data and
    % programming tools in an open source, version controlled environment.
    % Sign up to recieve regular updates of this function, and to contribute
    % your own tools.
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: 18 Nov 2010
    % Created with Matlab version: 7.11.0.584 (R2010b)
    
    % $Id: nansparse.m 3312 2010-11-19 10:19:12Z thijs@damsma.net $
    % $Date: 2010-11-19 18:19:12 +0800 (Fri, 19 Nov 2010) $
    % $Author: thijs@damsma.net $
    % $Revision: 3312 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/nan_fun/nansparse.m $
    % $Keywords: $
    
    properties(GetAccess = 'private', SetAccess = 'private')
        % define the properties of the class here, (like fields of a struct)
        data;
    end
    methods
        % methods, including the constructor are defined in this block
        function obj = nansparse(varargin)
            if nargin == 0
                error('cannot create instance of class nanspare without input')
            end
            % class constructor
            if nargin == 1
                if ~isa(varargin{1},'double')
                    error('single variable input must be a double array')
                end
                [i,j]   = find(~isnan(varargin{1}));
                s       = varargin{1}(sub2ind(size(varargin{1}),i,j));
                m       = size(varargin{1},1);
                n       = size(varargin{1},2);
                nzmax   = length(s);
            elseif ismember(nargin,[3 5 6]);
                i       = varargin{1};
                j       = varargin{2};
                s       = varargin{3};
                if nargin == 3
                    m       = max(i);
                    n       = max(j);
                else
                    m       = varargin{4};
                    n       = varargin{5};
                end
                
                if nargin ~= 6
                    nzmax   = length(s);
                end
            else
                error('wrong number of input arguments.')
            end
            nans        = isnan(s);
            i(nans)     = [];
            j(nans)     = [];
            s(nans)     = [];
            s(s==0)     = nan;
            obj.data    = sparse(i,j,s,m,n,nzmax);
        end
        function varargout = size(obj, varargin)
            [varargout{1:nargout}] = size(obj.data,varargin{:});
        end
        function obj = subsasgn(obj, S, value) %#ok<INUSD,MANU>
            error('assignment of data to a nansparse is not supported')
        end
        function obj = subsref(obj, S)
            if length(S)==1
                if strcmpi(S(1).type,'()')
                    obj.data = obj.data(S(1).subs{:});
                end
            end
        end
        function value = full(obj)
            value             = full(obj.data);
            nanvalues         = isnan(value);
            zerovalues        = value==0;
            value(nanvalues)  = 0;
            value(zerovalues) = NaN;
        end
        function display(obj)
            [i,j]           = find( obj.data);
            val             = nonzeros(obj.data);
            val(isnan(val)) = 0;
            leading_spaces  = floor(log10(max(i)))+3;
            trailing_spaces = floor(log10(max(j)))+3;
            
            fmt = sprintf('%% %ds,%% -%ds %%f\\n',leading_spaces,trailing_spaces);
            for k = 1:length(i)
                fprintf(1,fmt,...
                    sprintf('(%d',i(k)),...
                    sprintf('%d)',j(k)),...
                    val(k));
            end
         
            % much faster, but not exactly correct would be: 
            %  fprintf(1,'(% 4d,% -4d)  % 9.4f\n',[i,j,val]');
        end
        function obj = ctranspose(obj)
            obj.data = (obj.data)';
        end
        function obj = transpose(obj)
            obj.data = (obj.data).';
        end
        function value = numel(obj)
            value = numel(obj.data);
        end
        function value = end(obj,k,n)
            if n==1
                value = numel(obj);
            elseif n==2
                value = size(obj,k);
            end
        end
        function value = nonnan(obj)
            % number of nonnan elements
            value = nnz(obj.data);
        end
        function value = isnan(obj)
            value = obj.data==0;
        end
        function s = gt(obj, value)
            s = obj.data> value & obj.data~=0;
            if value< 0
                s(isnan(obj.data))=true;
            end
        end
        function s = lt(obj, value)
            s = obj.data< value & obj.data~=0;
            if value> 0
                s(isnan(obj.data))=true;
            end
        end
        function s = ge(obj, value)
            s = obj.data>=value & obj.data~=0;
            if value<=0
                s(isnan(obj.data))=true;
            end
        end
        function s = le(obj, value)
            s = obj.data<=value & obj.data~=0;
            if value>=0
                s(isnan(obj.data))=true;
            end
        end
    end
end
