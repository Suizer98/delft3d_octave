
Seed=10;
rng('default');
rng(Seed);

% test function 2
%     u1   = randn(1000,1);                                    
%     u2   = randn(1000,1); 
%     u1 = 78064.4+11709.7* u1;
%     u2 = 0.0104+0.00156*u2;


% test function 4
%      u1   = randn(1000,1);                                    
%      u2   = randn(1000,1);
% xfor_plot = linspace(-6, 6,1000);
% yfor_plot = linspace(-6, 6,1000);

% test function 5
    u1   = randn(1000,1);                                    
    u2   = randn(1000,1); 
xfor_plot = linspace(-6, 6,1000);
yfor_plot = linspace(-6, 6,1000);
  
 % test function 6
%      u1   = randn(1000,1);                                    
%      u2   = randn(1000,1);
% xfor_plot = linspace(-6, 6,1000);
% yfor_plot = linspace(-6, 6,1000);
     
 % test function 7
%     u1 = 10+3* u1;
%     u2 = 10+3* u2;
%  xfor_plot = linspace(-28, 28,1000);
%  yfor_plot = linspace(-28, 28,1000);

%  %test function 8
%      u1   = randn(1000,1);                                    
%      u2   = randn(1000,1);
% xfor_plot = linspace(-6, 6,1000);
% yfor_plot = linspace(-6, 6,1000);


[mesh_x, mesh_y] = meshgrid(xfor_plot,yfor_plot);

for i=1:size(mesh_x,1)  
%test function 2    
%true_val_for_plot(:,i) = mesh_x(:,i).*mesh_y(:,i)-146.14;

%test function 4
%true_val_for_plot(:,i) = 0.1*( mesh_x(:,i)-mesh_y(:,i)).^2-(1/sqrt(2))*( mesh_x(:,i)+mesh_y(:,i))+2.5;


%test function 5
true_val_for_plot(:,i) = -0.5*( mesh_x(:,i)-mesh_y(:,i)).^2-(1/sqrt(2))*( mesh_x(:,i)+mesh_y(:,i))+3;

%test function 6
%true_val_for_plot(:,i) = 2-mesh_y(:,i)-0.1*(mesh_x(:,i)).^2+ 0.06*(mesh_x(:,i)).^3;

%test function 7
%true_val_for_plot(:,i) = 2.5-0.2357*(mesh_x(:,i)-mesh_y(:,i))+0.00463*(mesh_x(:,i)+mesh_y(:,i)-20).^4;

%test function 8
%true_val_for_plot(:,i) = 3-mesh_y(:,i)+(4*mesh_x(:,i)).^4;
end

f2= figure(2)

surf(xfor_plot,yfor_plot,-true_val_for_plot ,'EdgeColor','None');
xlabel('u1')
ylabel('u2')


grid on
axis square
set(f2,'paperpositionmode','auto','Visible','on');
% test function 5
%clim([-max(max(true_val_for_plot)) max(max(true_val_for_plot))])

% test function 2
%colormap(b2r(min(min(true_val_for_plot)),-min(min(true_val_for_plot)))) 

% test function 4
%colormap(b2r(min(min(true_val_for_plot)),-min(min(true_val_for_plot)))) 

% test function 5
%colormap(b2r(-max(max(true_val_for_plot)),max(max(true_val_for_plot)))) 

% test function 7
% colormap(b2r(min(min(true_val_for_plot)),-min(min(true_val_for_plot)))) 

% test function 8
 %colormap(b2r(min(min(true_val_for_plot)),-min(min(true_val_for_plot)))) 


colorbar
view(2)
title('Plot test function 5')

print -dpng polyfitn_true_test_function5

