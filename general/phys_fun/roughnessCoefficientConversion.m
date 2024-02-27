function C_out = roughnessCoefficientConversion(C_in,waterdepth,formulation_in,formulation_out)
%ROUGHNESSCOEFFICIENTCONVERSION Transforms roughness coefficient as given by ones roughness formula 
%into the coefficient as given by another formula
%
%   Takes the Chezy coefficient/Manning coefficient/coefficient of Nikuradse 
%   (in the White-Colebrook rougness formula) as input and converts it into either
%   Chezy coefficient, Manning coefficient or coefficient of Nikuradse.  
%
%   Syntax:
%   C_out = roughnessCoefficientConversion(C_in,waterdepth,formulation_in,formulation_out)
%
%   Input:
%   C_in		= [mxn double] input roughness coefficient 
%   formulation_in	= [string] type of input roughness coefficient
%   formulation_out	= [string] type of output roughess coefficient
%   waterdepth		= [mxn double] water depth in [m]
%   formulation_in and formulation_out must be either 'chezy','manning' or 'white-colebrook'
%
%   Output:
%   C_out		= [mxn double] output roughness coefficient
%
%   Example
%   %Convert Manning coefficient into Chezy coefficient for water with a depth of 10m
%   Chezy = roughnessCoefficientConversion(0.022,10,'manning','chezy'); 
%   See also $seeAlso

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 ARCADIS
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Zwolle, The Netherlands
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
% Created: 09 11 2012
% Created with Matlab version: 2007b

%% Internal parameters

%Minimum waterdepth
waterdepth_min=0.05; %[m]

%% Input processing

%Check size input
if sum( size(C_in)~=size(waterdepth) )>0
  error('Dimension of C_in and waterdepth must be the same');
end %end if

%Check if input roughness is positive
if sum( C_in(:)<=0 )>0
  error('C_in must be strictly positive');
end %end if

% Apply minimum water depth
waterdepth=max(waterdepth,waterdepth_min); 

%% Convert input to Chezy

%Convert formulation to integer
iFormulation=find(strcmpi(formulation_in,{'chezy','manning','cole-whitebrook'}),1);

%Check input formulation
if isempty(iFormulation)
  error('Output roughness formulation must be chezy, manning or cole-whitebrook');
end %end if

%Perform conversion
switch(iFormulation)
  case 1 %chezy
    C_in=C_in;
  case 2 %manning
    C_in=local_manning(C_in,waterdepth);
  case 3 %Cole-Whitebrook
    C_in=local_CW(C_in,waterdepth); 
  otherwise
    error('Input roughness formulation must be chezy, manning or cole-whitebrook');
end %end switch

%% convert Chezy to output

%Convert formulation to interger
iFormulation=find(strcmpi(formulation_out,{'chezy','manning','cole-whitebrook'}),1);

%Check output formulation
if isempty(iFormulation)
  error('Output roughness formulation must be chezy, manning or cole-whitebrook');
end %end if


%Perform conversion
switch(iFormulation)
  case 1 %chezy
    C_out=C_in;
  case 2 %manning
    C_out=local_inv_manning(C_in,waterdepth); 
  case 3 %Cole-Whitebrook
    C_out=local_inv_CW(C_in,waterdepth); 
  otherwise
    error('Output roughness formulation must be chezy, manning or cole-whitebrook');
end % end switch


end %end function roughnessCoefficientConversion

function chezy=local_manning(manning,waterdepth)
%Convert Manning to Chezy

  chezy=waterdepth.^(1/6)./manning;

end %end function local_manning

function chezy=local_CW(nikuradse,waterdepth)
%Convert Nikuradse to Chezy

  chezy=18*log10(12*waterdepth./nikuradse);

end %end function local_CW

function manning=local_inv_manning(chezy,waterdepth)
%Convert Chezy to Manning

  manning=waterdepth.^(1/6)./chezy;

end %end function local_manning

function nikuradse=local_inv_CW(chezy,waterdepth)
%Convert Chezy to nikuradse

  nikuradse= 12*waterdepth./10.^(chezy/18);

end %end function local_CW

