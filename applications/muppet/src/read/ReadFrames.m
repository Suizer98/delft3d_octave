function Frames=ReadFrames(pth)

txt=ReadTextFile([pth 'settings' filesep 'frames' filesep 'frames.def']);
 
k=1;

noframes=str2num(txt{k});
k=k+1;
 
for i=1:noframes
    Frames(i).Name=txt{k};
    k=k+1;
    Frames(i).Number=str2num(txt{k});
    k=k+1;
    for j=1:Frames(i).Number
        k=k+1;
        Frames(i).Frame(j).Position(1)=str2num(txt{k});
        k=k+1;
        Frames(i).Frame(j).Position(2)=str2num(txt{k});
        k=k+1;
        Frames(i).Frame(j).Position(3)=str2num(txt{k});
        k=k+1;
        Frames(i).Frame(j).Position(4)=str2num(txt{k});
        k=k+1;
    end
    Frames(i).TextNumber=str2num(txt{k});
    k=k+1;
    for j=1:Frames(i).TextNumber
        k=k+1;
        Frames(i).Text(j).Position(1)=str2num(txt{k});
        k=k+1;
        Frames(i).Text(j).Position(2)=str2num(txt{k});
        k=k+1;
        Frames(i).Text(j).HorizontalAlignment=txt{k};
        k=k+1;
    end
    Frames(i).NumberLogos=str2num(txt{k});
    k=k+1;
    for j=1:Frames(i).NumberLogos
        k=k+1;
        fname=txt{k};
        if isempty(fileparts(fname))
            Frames(i).Logo(j).File=[pth 'settings' filesep 'logos' filesep txt{k}];
        else
            Frames(i).Logo(j).File=fname;
        end
        k=k+1;
        Frames(i).Logo(j).Position(1)=str2num(txt{k});
        k=k+1;
        Frames(i).Logo(j).Position(2)=str2num(txt{k});
        k=k+1;
        Frames(i).Logo(j).Position(3)=str2num(txt{k});
        k=k+1;
    end
end
