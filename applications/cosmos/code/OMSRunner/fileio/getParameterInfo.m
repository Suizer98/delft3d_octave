function out=getParameterInfo(hm,par,varargin)

out=[];

npar=length(hm.parameters.parameter);

% Make cell array of all available parameters
for i=1:npar
    names{i}=hm.parameters.parameter(i).parameter.shortname;
end

% Find required parameter number
ipar=strmatch(lower(par),lower(names),'exact');

s=hm.parameters.parameter(ipar).parameter;

if length(varargin)==1   
    out=s.(varargin{1});
else
    k=0;
    for i=1:2:length(varargin)-1
        k=k+1;
        ptype2{k}=varargin{i};
        pname{k}=varargin{i+1};
    end

    par=varargin{end};

    nrp=k;

    ptype1=ptype2;
    
    name1=ptype1{1};

    switch nrp

        case 1
            
            for j=1:length(s.(name1))
                nm{j}=s.(name1)(j).(name1).type;
            end
            ii=strmatch(lower(pname{1}),lower(nm),'exact');
            
            if ~isempty(ii)           
                out=s.(name1)(ii).(name1).(par);
            end
            
        case 2
            name2=ptype1{2};

            nm=[];
            for j=1:length(s.(name1))
                nm{j}=s.(name1)(j).(name1).type;
            end
            ii=strmatch(lower(pname{1}),lower(nm),'exact');

            if ~isempty(ii)
                
                nm=[];
                for j=1:length(s.(name1)(ii).(name1).(name2))
                    nm{j}=s.(name1)(ii).(name1).(name2)(j).(name2).type;
                end
                jj=strmatch(lower(pname{2}),lower(nm),'exact');                
                out=s.(name1)(ii).(name1).(name2)(jj).(name2).(par);
            end
            
    end
end
