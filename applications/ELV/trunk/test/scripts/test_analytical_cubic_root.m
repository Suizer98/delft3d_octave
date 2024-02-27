
nt=1000;
root_t=rand(nt,3);
t1=NaN(nt,1);
t2=NaN(nt,1);
t3=NaN(nt,1);
for kt=1:nt
p_test=poly(root_t(kt,:));

tic;
r_3=analytical_cubic_root_2(p_test(1),p_test(2),p_test(3),p_test(4));
t3(kt)=toc;
%
tic;
r_2=roots(p_test);
t2(kt)=toc;
%
tic;
r_1=analytical_cubic_root(p_test(1),p_test(2),p_test(3),p_test(4));
t1(kt)=toc;

if abs(r_1-r_3)>1e-8; warning('hmm...'); end

end

%%

figure
hold on
han1=plot(t1);
han2=plot(t2);
han3=plot(t3);
legend([han1,han2,han3],'anl','num','anl2')
