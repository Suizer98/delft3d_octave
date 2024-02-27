function OK = seawifs_datenum_test
%SEAWIFS_DATENUM_TEST   unit test for seawifs_datenum
%
%See also: seawifs_datenum

MTestCategory.Unit;

str = '1998128121603';
num = ceil(now*24*60)./24/60; % on minutes

answ = seawifs_datenum(seawifs_datenum(num));
OK(1) = abs(num - answ) < 1e-6; % floats are never exactly identical
assert(OK(1),['answ should be input (' num2str(num) '), but was ' num2str(answ) ' instead.', char(10), 'Difference was: ' num2str(abs(num - answ),'%e')]);

OK(2) = strcmpi(str,seawifs_datenum(seawifs_datenum(str)));
assert(OK(2),'String should be returned');

OK = all(OK);

%% EOF