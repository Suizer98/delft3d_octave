function [u_rot,v_rot] = nesthd_rotate_vector(u,v,angle)

% rotate_vector :rotates a vector (also works on matrices)

%
% Rotates a vector
%

u_rot  = cos(angle)*u - sin(angle)*v;
v_rot  = sin(angle)*u + cos(angle)*v;
