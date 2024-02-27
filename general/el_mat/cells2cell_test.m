function OK = cell2cellstr_test(IN)
%cell2cellstr_test  test for cell2cellstr
%
%See also: cell2cellstr

a = {{'a'},{'b','c'},{'d','e','f'}};

b = cells2cell(a);

OK = strcmpi(char(b)','abcdef');
