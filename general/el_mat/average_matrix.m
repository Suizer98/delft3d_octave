function reducedData = average_matrix(data,factor,varargin)
%average_matrix  Average values of a matrix per n cells, define by dimension
%
%   Example
%         data = peaks(100);
%         reducedData = average_matrix(data,[2 10]);
%         subplot(1,2,1)
%         pcolor(data)
%         subplot(1,2,2)
%         pcolor(reducedData)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       TDA
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 28 Jun 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: average_matrix.m 9545 2013-10-30 09:53:08Z tda.x $
% $Date: 2013-10-30 17:53:08 +0800 (Wed, 30 Oct 2013) $
% $Author: tda.x $
% $Revision: 9545 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/average_matrix.m $
% $Keywords: $

%%
OPT.nanThreshold = prod(factor); % sets cell value to NaN if the count of NaN s in cell is equal to por grater than specified number;
OPT = setproperty(OPT,varargin);

siz = size(data);
assert(OPT.nanThreshold<=prod(factor))
assert(OPT.nanThreshold>=1)
assert(isequal(size(siz),size(factor)))

sizReducedData = siz./factor;
assert(all(sizReducedData == round(sizReducedData)))

reducedData = nan(sizReducedData);

indFunStart = @(n,fact) (n-1)*fact + 1;
indFunEnd   = @(n,fact) n*fact;
indFun = @(n,fact) indFunStart(n,fact):indFunEnd(n,fact);
switch length(siz)
   case 2
        %% optimize for 2d array
        k = [1 cumprod(sizReducedData(1:end-1))];
        
        for ii = 1:numel(reducedData);
            ndx =ii;
            for nn = 2:-1:1,
                vi = rem(ndx-1, k(nn)) + 1;
                n(nn) = (ndx - vi)/k(nn) + 1;
                ndx = vi;
            end

            selection = data(...
                indFunStart(n(1),factor(1)):indFunEnd(n(1),factor(1)),...
                indFunStart(n(2),factor(2)):indFunEnd(n(2),factor(2)));
            
            isNaN = isnan(selection);
            if sum(isNaN(:)) >= OPT.nanThreshold
                reducedData(ii) = nan;
            else
                reducedData(ii) = sum(selection(~isNaN)) / sum(~isNaN(:));
            end
        end
    case 3
        %% optimize for 3d array
        k = [1 cumprod(sizReducedData(1:end-1))];
        
        for ii = 1:numel(reducedData);
            ndx =ii;
            for nn = 3:-1:1,
                vi = rem(ndx-1, k(nn)) + 1;
                n(nn) = (ndx - vi)/k(nn) + 1;
                ndx = vi;
            end

            selection = data(...
                indFunStart(n(1),factor(1)):indFunEnd(n(1),factor(1)),...
                indFunStart(n(2),factor(2)):indFunEnd(n(2),factor(2)),...
                indFunStart(n(3),factor(3)):indFunEnd(n(3),factor(3)));
            
            notNan = ~isnan(selection);
            if any(notNan(:))
                reducedData(ii) = sum(selection(notNan)) / sum(notNan(:));
            else
                reducedData(ii) = nan;
            end
        end
    otherwise
        %% for n dimensional arrays (slow)
        for ii = 1:numel(reducedData);
            [n{1:numel(siz)}] = ind2sub(sizReducedData,ii);
            indices = cellfun(indFun,n,num2cell(factor),'UniformOutput',false);
            
            selection = data(indices{:});
            notNan = ~isnan(selection);
            if any(notNan(:))
                reducedData(ii) = sum(selection(notNan)) / sum(notNan(:));
            else
                reducedData(ii) = nan;
            end
        end
end
