%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: analytical_cubic_root.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/analytical_cubic_root.m $
%
%analytical_cubic_root returns the three roots of a cubic polynomial, provided they are real. The polynomial is ax^3+bx^2+cx+d=0.
%
%\texttt{root=analytical_cubic_root(a_coeff, b_coeff, c_coeff, d_coeff)}
%
%INPUT:
%   -\texttt{a_coeff} = a coefficient of the polynomial
%   -\texttt{b_coeff} = b coefficient of the polynomial
%   -\texttt{c_coeff} = c coefficient of the polynomial
%   -\texttt{d_coeff} = d coefficient of the polynomial
%
%OUTPUT:
%   -\texttt{root} = three roots
%
%HISTORY:
%

function root=analytical_cubic_root(a_coeff, b_coeff, c_coeff, d_coeff)

pp = -(b_coeff/a_coeff)^2/3 + (c_coeff/a_coeff);
qq = 2*(b_coeff/a_coeff)^3/27 - (b_coeff/a_coeff)/3 * (c_coeff/a_coeff) + (d_coeff/a_coeff);

%discriminant
Delta_discr=0.25*qq^2+pp^3/27;

if Delta_discr>0
	error('No solution of the backwater equation is found. Your CFL may be too large (check time step). You can also try again and again with the same input until automagically the problem is solved! :D')
end

theta_angle = atan2( sqrt(-Delta_discr), -0.5*qq  );

root=(2*sqrt(-pp/3)*cos(theta_angle/3+[0;2./3*3.141592653589793;4./3*3.141592653589793]))-(b_coeff/a_coeff)/3;


