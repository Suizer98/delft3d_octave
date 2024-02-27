function DataProps=getXBDataProps

pth='c:\delft3d\w32\muppet\';

f=ReadTextFile([pth 'settings' filesep 'defaults' filesep 'xbout.def']);
for i=1:length(f)/3
    ii=(i-1)*3;
    DataProps(i).Name=f{ii+1};
    DataProps(i).FileName1=f{ii+2};
    DataProps(i).FileName2=f{ii+3};
%    tp=DataProps(i).FileName1(end-)
    DataProps(i).Type='global';
    if isempty(DataProps(i).FileName2)
        DataProps(i).NVal=1;
    else
        DataProps(i).NVal=2;
    end
end
