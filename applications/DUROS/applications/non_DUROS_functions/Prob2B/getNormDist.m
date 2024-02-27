function X = getNormDist(P, mu, sigma)
%GETNORMDIST    routine to derive X using a normal distribution

%%
if sigma ~= 0
    X = norminv(P, mu, sigma);
else
    X = mu;
end