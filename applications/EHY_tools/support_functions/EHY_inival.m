function out = EHY_inival(dimensions,inival)

%% Initialises n-dimensional array with inival
total           = prod(dimensions);
out   (1:total) = inival;
if length(dimensions==1)
    out             = reshape(out,[dimensions 1]);
else
    out             = reshape(out,dimensions);
end
