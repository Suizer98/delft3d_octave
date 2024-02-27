function D2 = structsubs(D,ind)
%STRUCTSUBS  make subset from all struct or class fields (as in database table-query)
%
% D2 = structsubs(D,ind) takes subset ind from
% all field of struct D (array and cell field)
% for cases when you use a struct as a flat database
% where all fields have the exact same length.
% ind can be a boolean array or an index array.
% 
% Example 1: like an SQL WHERE query
% T.a = [1     2    3       4    5    6       7    8    9]
% T.b = {'a' ,'b' ,'c',    'a' ,'b' ,'c'    ,'a' ,'b' ,'c'}
% T.c = {'NY','NY','NY',   'SF','SF','SF',   'LA','LA','LA'}
% ind = strmatchb('NY',T.c) & T.a <3
% T2 = structsubs(T,ind) % where T2 = struct('a',{[1 2]},'b', {{'a','b'}},'c',{{'NY','NY'}})
%
% mask = find(strmatchb('NY',T.c) & T.a <3)
% T2b = structsubs(T,mask) % where T2 = struct('a',{[1 2]},'b', {{'a','b'}},'c',{{'NY','NY'}})
%
%See also: strmatchb, strfindb, csv2struct, xls2struct, nc2struct, struct_fun, postgresql, class

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Sep 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: structsubs.m 13432 2017-07-01 07:23:58Z gerben.deboer.x $
% $Date: 2017-07-01 15:23:58 +0800 (Sat, 01 Jul 2017) $
% $Author: gerben.deboer.x $
% $Revision: 13432 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/structsubs.m $
% $Keywords: $

flds = fieldnames(D);
    
for ifld=1:length(flds)
fld = flds{ifld};       
   lengths(ifld) = length(D.(fld));
end

if ~all(diff(lengths)==0)
   error([mfilename, ' requires all struct field to have the exact same length.'])
end   

D2   = D; % needed for classes: output should be class too
for ifld=1:length(flds)
    fld = flds{ifld};
    if iscell(D.(fld))
        D2.(fld) = {D.(fld){ind}};
		% preserve orientation (only needed for cell)
        if iscolumn(D.(fld))
            D2.(fld) = D2.(fld)';
        end        
    else % isnumeric(D.(fld))
        D2.(fld) = D.(fld)(ind);
    end
end