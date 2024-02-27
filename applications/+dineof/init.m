function [T0,E0] = init(cmd,initfile)
%init initialises DINEOF setings
%
%  T = dineof.init() returns struct T with default field values
% [T,E] = dineof.init() also returns struct E with explanations
%
%See also: DINEOF

%   --------------------------------------------------------------------
%   Copyright (C) 2011-2012 Deltares 4 Rijkswaterstaat: Resmon project
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

% $Id: init.m 8856 2013-06-25 14:29:34Z boer_g $
% $Date: 2013-06-25 22:29:34 +0800 (Tue, 25 Jun 2013) $
% $Author: boer_g $
% $Revision: 8856 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/+dineof/init.m $
% $Keywords: $
%% initialize %  defaults

%  whether field is char or num
%  order corresponds to order in init file
%  empty type ('' or []) corresponds to type (char or num) in init file

   T0.data             = '';
   T0.mask             = '';
   T0.time             = '';
   T0.alpha            = 0;
   T0.numit            = 50;
   T0.nev              = 1;
   T0.neini            = 1;
   T0.ncv              = 10;
   T0.tol              = 1.0e-8;
   T0.nitemax          = 300;
   T0.toliter          = 1.0e-3;
   T0.rec              = 1;
   T0.eof              = 1;
   T0.norm             = 0;
   T0.Output           = ['''./'''];
   T0.clouds           = [];
   T0.results          = '';
   T0.EOF_U            = ['']; % v 4
   T0.EOF_V            = '';   % v 4
   T0.EOF_Sigma        = '';   % v 4
   T0.seed             = 243435;
   T0.number_cv_points = [];
   T0.cloud_size       = 1;
   T0.cloud_mask       = [];

   E0.data             = {'Name of file+variable of gappy data to fill by DINEOF. For several matrices, separate names with commas ',...
                          ' Example:  ',...
                          '         data = [''seacoos2005.avhrr'',''seacoos2005.chl''].'};
   E0.mask             = {'Name of file+variable of land-sea mask of gappy data. Several masks separated by commas:',...
                          'Example : ',...
                          '          mask = [''seacoos2005.avhrr.mask'',''seacoos2005.chl.mask''].'};
   E0.time             = {'Name of file+variable of time variable in files.'};
   E0.alpha            = {'Parameter for smoothing, alpha=0 uses integers: time=1:nt.'};
   E0.numit            = {'Parameter for number of iterations.'};
   E0.nev              = {'Parameter for setting the numerical variables for the computation of the required',...
                          'singular values and associated modes. Set it to the maximum number of modes you want to compute.'};
   E0.neini            = {'Parameter for the minimum  number of modes you want to compute.'};
   E0.ncv              = {'Parameter for the maximal size for the Krylov subspace ',...
                          '(Do not change it as soon as ncv > nev+5) ',...
                          'ncv must also be smaller than the temporal size of your matrix.'};
   E0.tol              = {'Parameter for the treshold for Lanczos convergence ',...
                          'By default 1.e-8 is quite reasonable.'};
   E0.nitemax          = {'Parameter for defining the maximum number of iteration allowed ',...
                          'for the stabilisation of eofs obtained by the cycle ',...
                          '((eof decomposition <-> truncated reconstruction and replacement of missing data)).' ,...
                          'An automatic criteria is defined by the following parameter ''itstop'' to go faster.'};
   E0.toliter          = {'Parameter for precision criteria defining the threshold of automatic ',...
                          'stopping of dineof iterations, once the ratio ',...
                          '(rms of successive missing data reconstruction)/stdv(existing data) becomes lower than ''toliter''.'};
   E0.rec              = {'Parameter for complete reconstruction of the matrix ',...
                          'rec=1 will reconstruct all points; rec=0 only missing points.'};
   E0.eof              = {'Parameter for writing the left and right modes of the',...
                          'input matrix. Disabled by default. To activate, set to 1.'};
   E0.norm             = {'Parameter for activating the normalisation of the input matrix',...
                          'for multivariate case. Disabled by default. To activate, set to 1.'};
   E0.Output           = {'Name of folder for saving output. Left and Right EOFs will be written here.'};
   E0.clouds           = {'Name of file+variable of cloud variable. Remove or comment-out this keyword',...
                          'if the cross-validation points are to be chosen internally.'};
   E0.results          = {'Name of file+variable of the filled data.'};
   E0.EOF_U            = ['eof.nc#U'];   % v 4
   E0.EOF_V            =  'eof.nc#V';    % v 4
   E0.EOF_Sigma        =  'eof.nc#Sigma';% v 4

   E0.seed             = {'Parameter for seed to initialize the random number generator.'};
   E0.number_cv_points = {'Parameter for number of cross-validation points.'};
   E0.cloud_size       = {'Parameter for cloud surface size in pixels.'};
   E0.cloud_mask       = {'Name of file+variable of cloud mask.'};
