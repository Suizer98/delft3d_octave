function examplePlots()

close all;

a   = 4;
f   = [1 1e-9];
P1  = 0:.01:1;

%% factor

P   = 1-(1-P1)/a;

u1  = norm_inv(P1,0,1);
u   = norm_inv(P, 0,1);

[v1 p1] = cdf2pdf(P1,u1);
[v p]   = cdf2pdf(P1,u);

corr = 1/a;

plot_example(u1,u,v1,v,P1,P1,p1,p,corr);

%% uniform

Pb = exp(-f);
ub = norm_inv(Pb,0,1);

u1 = norm_inv(P1,0,1);
u  = ub(1)+P1*diff(ub);

[v1 p1] = cdf2pdf(P1,u1);
[v p]   = cdf2pdf(P1,u);

corr = diff(ub)*norm_pdf(v,0,1);

plot_example(u1,u,v1,v,P1,P1,p1,p,corr);

%% inc variance

u1 = norm_inv(P1,0,1);
u  = a*u1;

[v1 p1] = cdf2pdf(P1,u1);
[v p]   = cdf2pdf(P1,u);

corr    = a*exp(-0.5*(v.^2-v1.^2));

plot_example(u1,u,v1,v,P1,P1,p1,p,corr);

%% exponential

Pb = exp(-f);
ub = norm_inv(Pb,0,1);

u1 = norm_inv(P1,0,1);
%u  = ub(1) + P1*diff(ub);
u  = P1*diff(ub);

P  = exp_cdf(u,1);

[v1 p1] = cdf2pdf(P1,u1);
[v p]   = cdf2pdf(P,u);

corr = norm_pdf(v,0,1)./exp(-v);

plot_example(u1,u,v1,v,P1,P,p1,p,corr);

%% normal

Pb = exp(-f);
ub = norm_inv(Pb,0,1);
s  = mean(ub);
m  = diff(ub)/2;

u1 = norm_inv(P1,0,1);
u  = norm_inv(P1,m,s);

[v1 p1] = cdf2pdf(P1,u1);
[v p]   = cdf2pdf(P1,u);

corr = norm_pdf(v,0,1)./norm_pdf(v,m,s);

plot_example(u1,u,v1,v,P1,P1,p1,p,corr);

end

function plot_example(u1,u,v1,v,P1,P,p1,p,corr)

    figure;

    subplot(1,2,1); hold on;

    plot(u1,P1,'xr');
    plot(u, P, 'xb');

    title('cdf');
    
    subplot(1,2,2); hold on;

    plot(v1,p1,'xr');
    plot(v, p, 'xb');

    plot(v, p.*corr,'xg');

    title('pdf');
end