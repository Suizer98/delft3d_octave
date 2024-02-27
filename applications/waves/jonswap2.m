function varargout = jonswap2(f,varargin)
%jonswap2  1D or 2D jonswap spectrum
%
% jon = jonswap2(f,'Hm0',Hm0,'Tp',Tp,<keyword,value>) 
%
% returns discretized 1D JONSWAP spectrum in [m2/Hz] at frequencies f, 
% with energy Hm0 and peak period Tp. For other, non-required keywords, 
% call jonswap2(), e.g.
% [jon,<factor_normalize>] = jonswap2(f,..,'gamma',gamma,'normalize',1)
%
% jon = jonswap2(f,'Hm0',Hm0,'Tp',Tp,'directions',d,'ms',ms,'pdir,pdir,'<keyword,value>) 
%
% returns discretized 2D JONSWAP spectrum in [m2/Hz/deg] at frequencies f 
% and directions d, with peak direction pdir and directional spreading ms. 
% ms can be a scalar or a vector with same length as frequencies f.
%
% Example: 1D spectrum
%
%    for n=[10 30 100 300]
%        frq = linspace(0.03,.3,n);
%        jn1 = jonswap2(frq,'Hm0',1,'Tp',10);
%        plot(frq,jn1,'-','displayname',num2str(n),'linewidth',n/200);
%        hold on
%    end
%    legend show
%    xlabel('frequency [Hz]');ylabel('Energy [m2/Hz]')
%
% Example: 2D spectrum
%
%    frq = linspace(0.03,.3,30);
%    deg  = [0 30 55 75 90:10:180 195 215 240 270]; % linspace(0,360,24);
%    jn2 = jonswap2(frq,'Hm0',1,'Tp',10,'pdir',135,'directions',deg,'ms',6);
%    subplot(1,2,1);pcolorcorcen(frq,deg,jn2,[.5 .5 .5]);ylim([0 360])
%    title(4*sqrt(trapz(frq,trapz(deg,jn2))))
%    xlabel('frequency [Hz]');ylabel('Direction [deg]');
%    subplot(1,2,2);pcolor_spectral(frq, deg, jn2);
%    colorbarwithhtext('Energy [m2/Hz/deg]','horiz')
%
%See also: swan, directional_spreading, waves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Van Oord; TU Delft
%       Gerben J de Boer <gerben.deboer@vanoord.com>; <g.j.deboer@tudelft.nl>
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

% $Id: jonswap2.m 15207 2019-03-07 12:50:11Z matthijs.benit.x $
% $Date: 2019-03-07 20:50:11 +0800 (Thu, 07 Mar 2019) $
% $Author: matthijs.benit.x $
% $Revision: 15207 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/jonswap2.m $
% $Keywords: $

% https://code.google.com/p/wafo/source/browse/trunk/wafo25/spec/jonswap.m?r=130
% http://www.maths.lth.se/matstat/wafo/documentation/wafodoc/wafo/spec/jonswap.html
% https://ltth1979.wordpress.com/2012/05/20/jonswap-source-matlab/
% SWAN: swanser.ftn: SUBROUTINE SSHAPE: M. Yamaguchi: Approximate expressions for integral properties
%                    of the JONSWAP spectrum; Proc. JSCE, No. 345/II-1, pp. 149-152, 1984.

OPT.Tp        = [];
OPT.Hm0       = [];
OPT.g         = 9.81;
OPT.gamma     = 3.3;
OPT.method    = 'Yamaguchi'; % 'Goda'
OPT.normalize = 1;
OPT.sa        = 0.07;
OPT.sb        = 0.09;

OPT.pdir       = [];
OPT.ms         = [];
OPT.directions = [];

if nargin==0
    varargout = {OPT};
    return
end
OPT = setproperty(OPT,varargin);

%% checks

if isempty(OPT.Hm0);error('Hm0 required');end
if isempty(OPT.Tp );error('Tp  required');end

%% Pierson-Moskowitz

    if strcmpi(OPT.method,'Yamaguchi') || strcmpi(OPT.method,'Swan')
       alpha = 1/(0.06533*OPT.gamma.^0.8015 + 0.13467)./16; % Yamaguchi (1984), used in SWAN
    elseif strcmpi(OPT.method,'Goda')
      alpha = 1/(0.23+0.03*OPT.gamma-0.185*(1.9+OPT.gamma)^-1)./16; % Goda
    else
        error(['METHOD UNKNOWN: ',OPT.method])
    end

    pm    = alpha*OPT.Hm0^2*OPT.Tp^-4*f.^-5.*exp(-1.25*(OPT.Tp*f).^-4);

%% apply JONSWAP shape

    jon   = pm.*OPT.gamma.^exp(-0.5*(OPT.Tp*f-1).^2./sigma(f,1./OPT.Tp,OPT.sa,OPT.sb).^2);
    
    jon(isnan(jon))=0;

%% Optionally correct total energy of user-discretized spectrum to match Hm0, as above methods are only an approximation

    if OPT.normalize
        corr = OPT.Hm0.^2./(16*trapz(f,jon)+eps);
        jon  = jon.*corr;
    end

%% 2D 

    if isscalar(OPT.ms)
        OPT.ms = repmat(OPT.ms,size(f));
    end
        
    if     sum([isscalar(OPT.pdir) any(OPT.ms) any(OPT.directions)])==0
    elseif sum([isscalar(OPT.pdir) any(OPT.ms) any(OPT.directions)])==3
        
        jon2 = repmat(jon,[length(OPT.directions) 1]);
        for iff=1:length(f)
            cdir = directional_spreading(OPT.directions,OPT.pdir,OPT.ms(iff),'quiet',1);
            jon2(:,iff) = cdir(:).*jon2(:,iff);
        end

        if OPT.normalize
            corr = OPT.Hm0.^2./(16*trapz(f,trapz(OPT.directions,jon2))+eps);
            jon2  = jon2.*corr;
        end        
        
        jon = jon2;
    else            
        error('for 2D spectrum specify (i) directions, (ii) ms , (iii) pdir for a 2D spectrum, or leave all [] for 1D spectrum')
    end
    
%%

varargout = {jon,corr};

function s = sigma(f,fpeak,sa,sb)

s = repmat(sa, size(f));
s(f > fpeak) = sb;

