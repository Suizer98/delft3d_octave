np=1e6;

v=rand(np,1);
t=NaN(np,1);
for kp=1:np
    tic
    mean(v(1:kp));
    t(kp)=toc;
end

%%

figure
hold on
plot(t)
