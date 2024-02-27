function dataset=muppet_setDatasetVaryingOrConstant(dataset,timestep)

%if dataset.size(1)==0 || (dataset.size(1)>1 && (timestep==0 || length(timestep)>1))
if dataset.size(1)==0 || (dataset.size(1)>1 && length(timestep)>1)
    dataset.tc='c';
else
    dataset.tc='t';
    dataset.availabletimes=dataset.times;
%    dataset.availablemorphtimes=data.morphtimes;
end
