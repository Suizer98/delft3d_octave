function EHY_snake
%% input
width = 20;
height = 10;
dt0 = 0.25;
dtMax = 0.05;

%% initiate
figSnake = figure('units','centimeters','position',[10 5 width height],'KeyPressFcn',@my_callback);
highScoreFile = [tempdir 'EHY_snake_highSchore.mat'];
if exist(highScoreFile)
    load(highScoreFile); % load variable 'highScore'
else
    highScore = 0;
end
hold on
snk = [0.25*width 0.5*height; 0.25*width-1 0.5*height; 0.25*width-2 0.5*height];
frt = [0.75*width 0.5*height];

hSnk = plot(snk(:,1),snk(:,2),'b','linewidth',8);
hFrt = scatter(frt(1,1),frt(1,2),'x','linewidth',2);

axis([0 width 0 height])
set(gca,'xtick',[],'ytick',[])
box on

move=[1 0];
key='';
%% loop
loop = 1;
while loop
    
    % dt (linearly increases with score)
    dt = (dt0-dtMax)/(3-(width*height))*length(snk)+dt0;
    pause(dt)
    
    % (high) score
    score = length(snk)-3;
    if score > highScore
        highScore = score;
        save(highScoreFile,'highScore');
    end
    
    loop = EHY_snake_figOpen(figSnake); % check if figure is still open
    if loop==0; return; end
    title(['Score :' sprintf('%3.0f',score) '  |  High score :' sprintf('%3.0f',highScore)])
    
    % key
    if strcmp(key,'rightarrow') && all(move~=[-1 0])
        move=[1 0];
    elseif strcmp(key,'leftarrow') && all(move~=[1 0])
        move=[-1 0];
    elseif strcmp(key,'uparrow') && all(move~=[0 -1])
        move=[0 1];
    elseif strcmp(key,'downarrow') && all(move~=[0 1])
        move=[0 -1];
    end
    
    % snake
    delete(hSnk);
    snk=[snk(1,:)+move; snk];
    
    % fruit
    if snk(1,1)==frt(1) && snk(1,2)==frt(2)
        delete(hFrt);
        frt=snk(1,:);
        while ismember(frt,snk,'rows')
            frt=round(ceil([rand*(width-2) rand*(height-2)]));
        end
        hFrt = scatter(frt(1,1),frt(1,2),'x','linewidth',4);
    else
        snk(end,:)=[];
    end
    hSnk = plot(snk(:,1),snk(:,2),'b','linewidth',12);
    
    % boundary
    if snk(1,1)<1 || snk(1,1)> width-1 || snk(1,2)<1 || snk(1,2)>height-1 || ...
            ismember(snk(1,:),snk(2:end,:),'rows')
        text(0.25*width,0.5*height,'GAME OVER','fontsize',30)
        previousKey=key;
        text(0.25*width,0.25*height,'Play again? Press any key','fontsize',10)
        while loop
            pause(0.1)
            if ~strcmp(key,previousKey)
                close(figSnake);
                EHY_snake
            end
            loop = EHY_snake_figOpen(figSnake); % check if figure is still open
        end
    end
    
end

    function key = my_callback(~,event) % callback function for movement
        assignin('caller','key',event.Key);
    end

    function loop = EHY_snake_figOpen(figSnake)
        loop = 1;
        if ~ishandle(figSnake)
            disp('<strong>EHY_snake closed by user</strong>')
            loop = 0;
        end
    end

end
