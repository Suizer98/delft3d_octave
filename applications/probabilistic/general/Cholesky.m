function P = Cholesky(C)

% This function derives a matrix P for which P*P'= C 
% !!!!! C is a correlationationmatrix 

% input
%    - C: correlationmatrix
%
% % output
%    - P: matrix for which P*P'= C

K=length(C); 

[L,U] = lu(C);  % lower matrix L and upper matrix U, for which L*U=C
D=U.*eye(K);    % diagonal matrix D of U

% check if Cholesky-decomposition was succesful 
if any(C~=L*D*L')
   error('Cholesky decomposition unsuccesfull');
end

P=L*sqrt(D);     % matrix P for which P*P'=C


