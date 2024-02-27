function dflowfm_pol2xyn(DirPol,obsNameStart)

% dflowfm_pol2xyn creates a Delft3D-FM observation file (.xyn) with observation points at each polygon support point
% the name of the observations points starts with the specified obsNameStart

%   --------------------------------------------------------------------
%   Copyright (C) 2016 Deltares
%       Wilbert Verbruggen
%
%       <Wilbert.Verbruggen@deltares.nl>;
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

%% reading
obs = landboundary('read',DirPol);

%% writing xyn file
fid  =  fopen([DirPol(1:end-3),'xyn'],'w+');
for oo = 1:size(obs,1)
   fprintf(fid,'%s \n',[num2str(obs(oo,1)),'  ',num2str(obs(oo,2)),' ''',obsNameStart,'_',num2str(oo,'%03i'),''' ']);
end
fclose(fid);