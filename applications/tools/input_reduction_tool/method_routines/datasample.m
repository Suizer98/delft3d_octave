function [y,i] = datasample(x,k,varargin)

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the research project titled "Development
% of Coastal Erosion Control Technology (or CoMIDAS)" funded by the Korean
% Ministry of Oceans and Fisheries and the Deltares strategic research program
% Coastal and Offshore Engineering. This financial support is highly appreciated.

nargs = nargin;

% Process the stream argument, if present.
defaultStream = isnumeric(x) || ~isa(x,'RandStream'); % simple test first for speed
if ~defaultStream
    % shift right to drop s from the argument list
    nargs = nargs - 1;
    s = x;
    x = k;
    if nargs > 1
        k = varargin{1};
        varargin(1) = [];
    end
end

if nargs < 2
    error(message('stats:datasample:TooFewInputs'));
elseif ~(isscalar(k) && isnumeric(k) && (k==round(k)) && (k >= 0))
    error(message('stats:datasample:InvalidK'));
end

% Pull out the DIM arg if present, or determine which dimension to use.
if nargs > 2 && ~ischar(varargin{1})
    dim = varargin{1};
    varargin(1) = [];
    nargs = nargs - 1;
else
    dim = find(size(x)~=1, 1); % first non-singleton dimension
    if isempty(dim), dim = 1; end
end
n = size(x,dim);

replace = true;
wgts = [];
if nargs > 2 % avoid parsing args if there are none
    pnames = {'replace' 'weights'};
    dflts =  { replace      wgts };
    [replace,wgts] = parseArgs(pnames,dflts,varargin{:});

    if ~isempty(wgts)
        if ~isvector(wgts) || length(wgts) ~= n
            error(message('stats:datasample:InputSizeMismatch'));
        else
            checkSupportedNumeric('Weights',wgts,true);
            wgts = double(wgts);
            sumw = sum(wgts);
            if ~(sumw > 0) || ~all(wgts>=0) % catches NaNs
                error(message('stats:datasample:InvalidWeights'));
            end
        end
    end
    if ~isscalar(replace) || ~islogical(replace)
        error(message('stats:datasample:InvalidReplace'));
    end
end

% Sample with replacement
if replace
    if n == 0
        if k == 0
            i = zeros(0,1);
        else
            error(message('stats:datasample:EmptyData'));
        end
        
    elseif isempty(wgts) % unweighted sample
        if defaultStream
            i = randi(n,1,k);
        else
            i = randi(s,n,1,k);
        end
        
    else % weighted sample
        p = wgts(:)' / sumw;
        edges = min([0 cumsum(p)],1); % protect against accumulated round-off
        edges(end) = 1; % get the upper edge exact
        if defaultStream
            [~, i] = histc(rand(1,k),edges);
        else
            [~, i] = histc(rand(s,1,k),edges);
        end
    end
    
    % Sample without replacement
else
    if k > n
        error(message('stats:datasample:SampleTooLarge'));
        
    elseif isempty(wgts) % unweighted sample
        if defaultStream
            i = randperm(n,k);
        else
            i = randperm(s,n,k);
        end
        
    else % weighted sample
        if sum(wgts>0) < k
            error(message('stats:datasample:TooFewPosWeights'));
        end
        if defaultStream
            i = wswor(wgts,k);
        else
            i = wswor(s,wgts,k);
        end
    end
end

% Use the index vector to sample from the data.
if ismatrix(x) % including vectors and including dataset or table
    if dim == 1
        y = x(i,:);
    elseif dim == 2
        y = x(:,i);
    else
        reps = [ones(1,dim-1) k];
        y = repmat(x,reps);
    end
else % N-D
    subs = repmat({':'},1,max(ndims(x),dim));
    subs{dim} = i;
    y = x(subs{:});
end
