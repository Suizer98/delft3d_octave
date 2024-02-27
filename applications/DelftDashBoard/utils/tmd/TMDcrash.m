function []=TMDcrash(n,m,n1,m1);
fprintf('You opened inconsistent model files:\n');
fprintf('Grid  size: %d x %d \n',n,m);
fprintf('Model size: %d x %d \n',n1,m1);
fprintf('Run TMD again. BYE....\n');
close all;
return;

