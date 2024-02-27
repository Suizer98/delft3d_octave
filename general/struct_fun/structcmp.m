function OK = structcmp(s1, s2, seps)
%STRUCTCMP compare structures with tolerenace
%
%    structcmp(s1, s2, seps)
%
% compare structures, allowing for different field
% sets and values within a tolerance of seps.
%
% STRUCTCMP does not pay attention to the order of fields
% 
%
%See also: struct_fun, isequal, isequalwithnans

OK = true;

if nargin == 2
  seps = 1e-4;
end

if length(s1) ~= length(s2)
  fprintf(2, 'lengths of structure arrays differ\n');
  OK = false;
end

if length(s1) > length(s2)
  t = s1; s1 = s2; s2 = t;
end

f1 = fieldnames(s1);
f2 = fieldnames(s2);

if length(f1) ~= length(f2)
  fprintf(2, 'field sets differ\n');
  f1
  f2
  OK = false;
end

if length(f1) > length(f2)
  t = s1; s1 = s2; s2 = t;
  t = f1; f1 = f2; f2 = t;
end

b = 1;
for i = 1:length(s1)
  for j = 1 : length(f1)

    fname = f1{j};

    if isfield(s1, fname) & isfield(s2, fname)

      eval(sprintf('[m1,n1] = size(s1(i).%s);', fname));
      eval(sprintf('[m2,n2] = size(s2(i).%s);', fname));
      m1 = min(m1, m2);
      n1 = min(n1, n2);

      eval(sprintf('t = max(max(abs(s1(i).%s(m1,n1) - s2(i).%s(m1,n1))));', ...
                   fname, fname));
      if t > seps
        fprintf(2, 'fields %s differ by more than %g\n', fname, seps);
        [i,j]
        t
        [m1,n1]
        [m2,n2]
        b = 0;
       OK = false;
      end
    end
  end
end

if b == 1
  fprintf(1, 'matching fields and subarrays are within %g\n', seps);
end

