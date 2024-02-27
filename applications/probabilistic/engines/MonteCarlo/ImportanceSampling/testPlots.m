figure;

x = -3:.1:3;
y = -3:.1:3;

methods = {'none' 'factor' 'uniform' 'incvariance' 'exponential' 'normal'};
args = {{} {3} {-3 3} {3} {-3 3} {2 1}};

% draw random numbers
P1 = rand(1,1000);
P2 = rand(1,1000);

l = length(methods);
sx = ceil(sqrt(l));
sy = ceil(l/sx);

for i = 1:l
    subplot(sy,sx,i); hold on;

    % plot solution space
    pcolor(x,y,norm_pdf(x,0,1)'*norm_pdf(y,0,1)); shading interp;
    plot(x,-.1*x+2,'-k','LineWidth',2);

    % perform importance sampling    
    P_corr1 = ones(size(P1)); P1is = P1;
    if i > Inf; [P1is P_corr1] = feval(['prob_is_' methods{i}], P1, args{i}{:}); end;
    
    P_corr2 = ones(size(P2)); P2is = P2;
    if i > 1; [P2is P_corr2] = feval(['prob_is_' methods{i}], P2, args{i}{:}); end;
    
    P_corr = P_corr1.*P_corr2;

    u1 = norm_inv(P1is,0,1);
    u2 = norm_inv(P2is,0,1);

    % determine failures
    Z = 2-.1*u1-u2;

    scatter(u1(Z>=0),u2(Z>=0),10,'ok');
    scatter(u1(Z<0),u2(Z<0),10,'ok','filled');

    % set layout
    set(gca,'XLim',[min(x) max(x)],'YLim',[min(y) max(y)]);
    title({methods{i} sprintf('N_{fail} = %d ; P_f = %0.4f', sum(Z>0), sum((Z>0).*P_corr)/length(Z))});

    box on;
    grid on;
end