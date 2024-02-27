function nanmean2_test
%nanmean2_test unit test for nanmean2, nanmin2, nanmax2
%
%See also: nanmean2, nanmin2, nanmax2

sz = 1; % test for higher dimensions

disp('-a---');a = repmat([  1 nan nan;   1 nan nan;   1 nan nan],sz);disp(a);
disp('-b---');b = repmat([  3   3   3; nan nan nan; nan nan nan],sz);disp(b);
disp('-c---');c = repmat([  5 nan nan; nan   5 nan; nan nan   5],sz);disp(c);

disp('-avg-');avg = nanmean2(a,b,c);disp(avg);
disp('-min-');min = nanmin2 (a,b,c);disp(min);
disp('-max-');max = nanmax2 (a,b,c);disp(max);

avg0 = repmat([  3   3   3;   1   5 nan;   1 nan   5],sz);
min0 = repmat([  1   3   3;   1   5 nan;   1 nan   5],sz);
max0 = repmat([  5   3   3;   1   5 nan;   1 nan   5],sz);

isequalwithequalnans(avg,avg0)
isequalwithequalnans(min,min0)
isequalwithequalnans(max,max0)

