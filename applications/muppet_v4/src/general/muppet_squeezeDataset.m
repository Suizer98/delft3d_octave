function d=muppet_squeezeDataset(d)

% Squeeze data
fldnames=fieldnames(d);
for ii=1:length(fldnames)
    if isnumeric(d.(fldnames{ii}))
        d.(fldnames{ii})=squeeze(d.(fldnames{ii}));
    end
end
