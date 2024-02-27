function [t,val]=sfincs_read_boundary_conditions(filename)

s=load(filename);
t=s(:,1);
val=s(:,2:end);
