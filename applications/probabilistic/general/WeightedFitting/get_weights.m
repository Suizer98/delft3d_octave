
function w=get_weights(z)
% GET THE WEIGHTS FROM THE Z VALUE

%z = linspace(-5,5,100);

w =1+round(10*exp((-z.^2)/max(abs(z))));

%w2 = 1/(sqrt(2*pi))*exp((-z.^2)./2);
plot(z,w,'k*')
ylim ([0, max(w)+min(w)])
%hold on
%plot(z,w2,'r--')

xlabel ('Z value')
ylabel('weight')
title('Z-value dependent weights')