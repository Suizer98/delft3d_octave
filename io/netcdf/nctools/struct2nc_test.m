function varargout = STRUCT2NC_TEST
%STRUCT2NC_TEST   test for struct2nc & nc2struct
%
% Note that char arrays should not contain 0 characters.
%
% Tests: * 1D and 2D numeric and char arrays
%        * Special doubles: NaN, Inf, -Inf
%        * Special chars  : ' ' and 0
%   
%
%See also: STRUCT2NC, NC2STRUCT

% TO DO: swap fieldnames and attributenames in meta-struct

clear all
close all

n = 20;

   D1.datenum               = datenum(1970,1,linspace(1,3,n))';
   D1.eta                   = sin(2*pi*D1.datenum./.5);

   D1.some_numbers          = [1997 1998 1999; 0 -Inf Inf];
   D1.some_numbersT         = [1997 1998 1999; 0 -Inf Inf]';

   D1.nan                   = nan;

   D1.char                  = repmat('a b ',[10]);
   D1.char(10,50)           = 'z'; % this inserts 0 characters between index 400 and 500, which have to be treated separately by struct2nc()         
   D1.cellstr               = cellstr(D1.char);

   M1.terms_for_use         = 'These data can be used freely for research purposes provided that the following source is acknowledged: OET.';
   M1.disclaimer            = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';

%% current implementation
   M1.units.datenum         = 'time';
   M1.units.eta             = 'meter';
   M1.standard_name.datenum = 'days since 0000-0-0 00:00:00 +00:00';
   M1.standard_name.eta     = 'sea_surface_height';
   
%% preferred implementation (swap level of attributes and variables in struct)

  %M1.datenum.units         = 'time';
  %M1.datenum.standard_name = 'days since 0000-0-0 00:00:00 +00:00';
  %M1.eta.units             = 'sea_surface_height';
  %M1.eta.standard_name     = 'meter';

   struct2nc('struct2nc.nc',D1,M1);
   D2 = nc2struct('struct2nc.nc');
   
         %isequal(cellstr(D1.char)   ,cellstr(D2.char   ))
         %isequal(       (D1.cellstr),       (D2.cellstr))
         %isequal(cellstr(D1.cellstr),cellstr(D2.cellstr))
      
% and now without 0 characters

   D1.char   (D1.char   ==0)=' ';
   struct2nc('struct2nc.nc',D1,M1);
   D2 = nc2struct('struct2nc.nc');

         %isequal(cellstr(D1.char)   ,cellstr(D2.char   ))
         %isequal(       (D1.cellstr),       (D2.cellstr))
         %isequal(cellstr(D1.cellstr),cellstr(D2.cellstr))
         
% check field

   fldnames = {'datenum','eta','some_numbers','some_numbersT','char'};
   
   D1.char = cellstr(D1.char);
   D2.char = cellstr(D2.char);
   
   for ifld=1:length(fldnames)
      fldname = fldnames{ifld};
      val(ifld) = isequal(D1.(fldname),D2.(fldname));
   end
   
   val(6) = isnan(D2.nan);

varargout = {all(val)};