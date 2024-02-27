function busy
% type 'busy' if you want to pretend on doing something important
string = 'processing to value';
h = waitbar(0,'1','Name','Converging calculation...',...
    'CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0)
steps = 10000;
step = 1000;
while 1
    step = step+1;
    % Check for Cancel button press
    if getappdata(h,'canceling')
        break
    end
    
    % Report current estimate in the waitbar's message field
    waitbar((step)/steps,h,sprintf('%s %5.1f%0.0f',string,step/10,rand*10000))
    if mod(round(step/30),3) == 1
        string = 'Inverting matrix';
     num2str(mod(magic(round(30*rand(1))),22))
    else   
        string = 'processing to value';
    end
    if round(step/20) == step/20
        if rand>0.6
            step = step+ round(500*(rand+rand+rand+rand));
            string = 'Combining results';
        end
        fprintf('fixed at %2.2f%%\n',100*rand)
    else
     fprintf('.')   
    end
    
    
    % Update the estimate
    if step > steps
        step = 1;
    end
    pause(0.03)
end
delete(h)       % DELETE the waitbar; don't try to CLOSE it.
clc