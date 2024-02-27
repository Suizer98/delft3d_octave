function struct2=matchstruct(struct1,struct2,varargin)

names1=fieldnames(struct1);
names2=fieldnames(struct2);
sz1=size(names1,1);
sz2=size(names2,1);

for i=1:sz1

    if nargin==2
        struct2=setfield(struct2,names1{i},getfield(struct1,names1{i}));
    end
    
    if nargin==3
        k=varargin{1};
        struct2(k).(names1{i})=getfield(struct1,names1{i});
    end

    if nargin==4
        k=varargin{1};
        l=varargin{2};
        struct2(k,l).(names1{i})=getfield(struct1,names1{i});
    end

    if nargin==5
        k=varargin{1};
        l=varargin{2};
        m=varargin{3};
        struct2(k,l,m).(names1{i})=getfield(struct1,names1{i});
    end

end
