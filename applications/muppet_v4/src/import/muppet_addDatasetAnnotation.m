function dataset=muppet_addDatasetAnnotation(opt,dataset)

switch lower(opt)

    case{'read'}
        
        % Do as much as possible here and not in import function
        dataset.adjustname=0;
        [pathstr,name,ext]=fileparts(dataset.filename);
        dataset.name=name;

        fid=fopen(dataset.filename);
        
        k=0;
        while 1
            tx0=fgets(fid);
            if and(ischar(tx0), size(tx0>0))
                v0=strread(tx0,'%q');
                if ~strcmp(v0{1}(1),'#')
                    k=k+1;
                    if ~isnan(str2double(v0{1})) && ~isempty(str2double(v0{1}))
                        dataset.x(k)=str2double(v0{1});
                        dataset.y(k)=str2double(v0{2});
                        dataset.z(k)=0;
                        dataset.text{k}=v0{3};
                    else
                        dataset.x(k)=str2double(v0{2});
                        dataset.y(k)=str2double(v0{3});
                        dataset.z(k)=0;
                        dataset.text{k}=v0{1};
                    end
                    if size(v0,1)>=4
                        dataset.rotation(k)=str2double(v0{4});
                    else
                        dataset.rotation(k)=0;
                    end
                    if size(v0,1)>=5
                        dataset.curvature(k)=str2double(v0{5});
                    else
                        dataset.curvature(k)=0;
                    end
                end
            else
                break
            end
        end
        
        fclose(fid);
                
        dataset.type = 'textannotation';
        dataset.tc='c';
        
    case{'import'}
        
        if ~isempty(dataset.annotationtext)
            % annotationtext read from mup file
            dataset.alltextselected=0;
            dataset.selectedtextnumber=strmatch(dataset.annotationtext,dataset.text,'exact');
        end
        
        if dataset.alltextselected==0
            if ~isempty(dataset.selectedtextnumber)
                it=dataset.selectedtextnumber;
                d=dataset;
                dataset.x=[];
                dataset.y=[];
                dataset.rotation=[];
                dataset.curvature=[];
                dataset.text=[];
                dataset.x=d.x(it);
                dataset.y=d.y(it);
                dataset.rotation=d.rotation(it);
                dataset.curvature=d.curvature(it);
                dataset.text{1}=d.text{it};
                dataset.annotationtext=d.text{it};
            end
        end
        
end
