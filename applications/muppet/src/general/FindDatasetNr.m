function datasetnr=FindDatasetNr(string,data)
 
same=0;
 
noset=length(data);

datasetnr=0;

for i=1:noset
    same=strcmp(lower(string),lower(data(i).Name));
    if same==1
        datasetnr=i;
    end
end

if datasetnr==0
   % warn='Dataset not found!'
    disp(['Dataset not found : ' string]);
  end
