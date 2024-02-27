function EPSG=readEPSGData(varargin)
if isempty(varargin)
    EPSG=load('EPSG.mat');
else
    EPSG=load(varargin{1});
end
if isfield(EPSG,'user_defined_data')
    % Merge user defined data
    sud=EPSG.user_defined_data;
    fnames1=fieldnames(EPSG);
    for i=1:length(fnames1)
        switch fnames1{i}
            case{'user_defined_data'}
            otherwise
                fnames2=fieldnames(EPSG.(fnames1{i}));
                for j=1:length(fnames2)
                    if ~isempty(sud.(fnames1{i}).(fnames2{j}))
                        nori=length(EPSG.(fnames1{i}).(fnames2{j}));
                        nnew=length(sud.(fnames1{i}).(fnames2{j}));
                        for k=1:nnew
                            if iscell(EPSG.(fnames1{i}).(fnames2{j}))
                                EPSG.(fnames1{i}).(fnames2{j}){nori+k}=sud.(fnames1{i}).(fnames2{j}){k};
                            else
                                EPSG.(fnames1{i}).(fnames2{j})(nori+k)=sud.(fnames1{i}).(fnames2{j})(k);
                            end
                        end
                    end
                end
        end
    end
end
