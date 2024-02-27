function [ZI EI]  = meris_interp2seg(xMeris, yMeris, dataMeris, gridStruct, method, eMeris)
%MERIS_INTERP2SEG Interpolates MERIS data to the center of the segment
%
%     [ZI EI]  = MERIS_INTERP2SEG(XMERIS,YMERIS, DATAMERIS,GRIDSTRUCT)
%     XMERIS and YMERIS is the position in the X and Y direccion of DATAMERIS
%
%     GRIDSTRUCT is a structure comming from  GRIDSTRUCT = DELWAQ_XYSEGMENT(LGAFILE)
%
%     [ZI EI]  = MERIS_INTERP2SEG(..., METHOD,...) allows selection of the technique 
%      used to interpolate the data, where METHOD is one of the following; 
%           'natural'     Natural neighbor interpolation
%           'linear'      Linear interpolation (default)
%           'nearest'     Nearest neighbor interpolation
%
%                         Block Methods:
%           'mean'        Mean of the data inside segment
%           'wemean'      Weigthed mean of the data inside segment
%                         Weigth factor: variance of the error (E)
%           'wdmean'      Weigthed mean of the data inside segment
%                         Weigth factor: distance with respect to the 
%                         center of the segment (D)
%           'wedmean'     Weigthed mean of the data inside segment
%                         Weigth factor: D and E
%
%                         Esemble Methods: For all block methods a ensemble
%                         of data may be used. Example:
%           'Ewemean'     Ensemble weigthed mean of the data inside segment
%
%                         Logarithm data: For all methods logarithm of data
%                         may be used. Example:
%          'log10-wemean' Weigthed mean of the log10(data) inside segment 
%          'log-Ewemean'  Ensemble weigthed mean of the natural logarithm 
%                         of data inside segment
%
%     [ZI EI]  = MERIS_INTERP2SEG(..., EMERIS) The standar deviation of the error 
%
%   See also: DELWAQ, DELWAQ_XYSEGMENT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com

% Number of ensemble members
ne = 50;
type = 'value';

if nargin < 5
   method  = 'linear';
end

% Variance of the error
eMeris = eMeris.^2;
if nargin<6
   eMeris = ones(size(dataMeris));
end    
dataMeris = double(dataMeris);
eMeris = double(eMeris);

% In case gridStruct is a lga file
if ischar(gridStruct) && exist(gridStruct,'file')
   gridStruct = delwaq_xysegment(gridStruct);
end

% Only valid points
inot = isnan(xMeris) | isnan(yMeris) | isnan(dataMeris) | isnan(eMeris);
xMeris(inot) = nan;
yMeris(inot) = nan;
dataMeris(inot) = nan;
eMeris(inot) = nan;

iseg  = naninterp(gridStruct.X,gridStruct.Y,gridStruct.Index(:,:,1),xMeris,yMeris,'nearest');
iseg = round(iseg);
useg = unique(iseg(~isnan(iseg)));
useg(useg<=0) = [];

ZI = nan(gridStruct.NoSegPerLayer,1);
EI = nan(gridStruct.NoSegPerLayer,1);
zi = nan(length(useg),1);
ei = nan(length(useg),1);

im = find(ismember(method,'-'));
if ~isempty(im)
   if ~isempty(strmatch('log',method(1:im-1),'exact')) && isempty(strmatch('E',method(im+1),'exact'));
      dataMeris(dataMeris<=0) = nan;
      dataMeris = log(dataMeris);
   elseif ~isempty(strmatch('log10',method(1:im-1),'exact')) && isempty(strmatch('E',method(im+1),'exact'));
      dataMeris(dataMeris<=0) = nan;
      dataMeris = log10(dataMeris);
   elseif ~isempty(strmatch('log',method(1:im-1),'exact')) && ~isempty(strmatch('E',method(im+1),'exact'));
      dataMeris(dataMeris<=0) = nan;
      type = 'log';
   elseif ~isempty(strmatch('log10',method(1:im-1),'exact')) && ~isempty(strmatch('E',method(im+1),'exact'));
      dataMeris(dataMeris<=0) = nan;
      type = 'log10';
   end
   method = method(im+1:end);
end

block_methods = {'mean' 'wemean' 'wdmean' 'wedmean' 'Emean' 'Ewemean' 'Ewdmean' 'Ewedmean'};

if length(useg)>5
    
    switch method
        case block_methods
            for i = 1:length(useg)
                kseg = useg(i);
                ipix  = find(iseg==kseg);
                x = xMeris(ipix);
                y = yMeris(ipix);
                z = dataMeris(ipix);
                e = eMeris(ipix);
                xi = gridStruct.cen.x(kseg);
                yi = gridStruct.cen.y(kseg);
                inot = isnan(z) | isinf(z) | isnan(x) | isnan(y);
                x(inot) = [];
                y(inot) = [];
                z(inot) = [];
                e(inot) = [];

                % Distance
                d = sqrt((x-xi).^2 + (y-yi).^2);

                if any(z)

                    if strcmp(method,'mean')
                       zi(i) = nanmean(z);
                       ei(i) = nanmean(e);
                    elseif strcmp(method,'wemean')
                       [zi(i) ei(i)] = wmean(z,e);
                    elseif strcmp(method,'wdmean')
                       [zi(i) ei(i)] = wmean(z,d);
                    elseif strcmp(method,'wedmean')
                       [zi(i) ei(i)] = wmean(z,e,d);
                    elseif strcmp(method,'Emean')
                       [z e] = ensemble(z,e,ne,type);
                       zi(i) = nanmean(z);
                       ei(i) = nanmean(e);
                    elseif strcmp(method,'Ewemean')
                       [z e] = ensemble(z,e,ne,type);
                       [zi(i) ei(i)] = wmean(z,e);
                    elseif strcmp(method,'Ewdmean')
                       z = ensemble(z,e,ne,type);
                       [zi(i) ei(i)] = wmean(z,d);
                    elseif strcmp(method,'Ewedmean')
                       [z e] = ensemble(z,e,ne,type);
                       [zi(i) ei(i)] = wmean(z,e,d);

                    end
                end %any(z)
            end %i

        otherwise
            zi  = naninterp(xMeris,yMeris,dataMeris,gridStruct.cen.x(useg),gridStruct.cen.y(useg),method);
    end
end
ZI(useg) = zi;
EI(useg) = ei;


% -------------------------------------------------------------------------
% Weigth mean
% -------------------------------------------------------------------------
function [zi ei] = wmean(z,varargin)

w = weight(varargin{:});
zi = sum(z.*w)/sum(w);
ei = std((z - zi).*w);

% -------------------------------------------------------------------------
% Weigth
% -------------------------------------------------------------------------
function w = weight(varargin)

w = zeros(length(varargin{1}),nargin);
for i = 1:nargin
    w(:,i) = (max(varargin{i})-varargin{i})./ (max(varargin{i})- min(varargin{i}));    
    % w(:,i) =  1./varargin{i}); % Uncoment for 1/var
end
w = nanmean(w,2);

% -------------------------------------------------------------------------
% Ensemble
% -------------------------------------------------------------------------
function [xe qe] = ensemble(x,q,ne,type)

x = x(:);
q = sqrt(q(:));
ns = length(x);
X = repmat(x,1,ne);
W = repmat(q,1,ne).*randn(ns,ne);

Xe = X + W;

Xe(Xe<=0) = nan;
inan = find(isnan(Xe));

if any(any(isnan(Xe)))
   Xe(inan) = X(inan);
end

if strcmp(type,'log')
   Xe = log(Xe);
elseif strcmp(type,'log10')
   Xe = log10(Xe);
end

xe = nanmean(Xe,2);
E = bsxfun(@minus,Xe,xe);
P = (1./(ne-1))* (E*E');
qe = sqrt(diag(P));
