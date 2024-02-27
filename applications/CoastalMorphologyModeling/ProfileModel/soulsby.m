function [tauc]=soulsby(taum,tauw)
tauc=0;taucold=1000;iter=0;
while abs(taucold-tauc)>1e-6;
    taucold=tauc;
    tauc=taum/(1+1.2*(tauw/(tauc+tauw))^3.2);
    iter=iter+1;
end