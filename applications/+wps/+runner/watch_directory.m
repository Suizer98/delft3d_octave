%WATCH_DIRECTORY watch directory for file changes
%
% When the file system supports it, this function will listen to the
% dirname directory for new, modified and deleted files. This is done using the
% java nio api, which is only supported in java 1.7 and up, os it will not
% work for all matlab versions. Once an event is generated the function
% returns the event and possibly other events at the same time, the function then
% stops watching the directory. 
%
% syntax:
% [events] = watch_directory(dirname, duration)
%
% input:
% dirname = a directory (absolute path) which is watched
% duration = how long should we wait for events to occur
%
% output:
% events = a structure in the format {'kind': 'EVENT_TYPE', 'context':
% 'filename'}
%
% example:
% watch_directory(fullfile(pwd, '.'), 1000)
%
% See also: fullfile, ls

function [events] = watch_directory(dirname, duration)

    % Import java classes that we need
    import java.nio.file.*
    import java.nio.file.StandardWatchEventKinds.*
    
    % Filesystem is OS specific
    filesystem = FileSystems.getDefault();
    
    % hack to get path (expects 2 arguments, due to java ellipsis)
    dir = filesystem.getPath(dirname, {''});

    % Java does not know about the current dir in matlab, so we always want
    % an absolute path
    if ~dir.isAbsolute() 
        warning(['Dirname should be absolute.']);
        warning(['Got: ', dirname, ' which refers to', char(dir.toAbsolutePath())]);
        return
    end
    % Start a watchservice, which can be used for listening
    watcher = filesystem.newWatchService();
    % subscribe to these events
    eventkinds = [...
            java.nio.file.StandardWatchEventKinds.ENTRY_CREATE,  ...
            java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY,  ...
            java.nio.file.StandardWatchEventKinds.ENTRY_DELETE,  ...
            ];
    % start watching
    % there is no unregister method, seems that closing the watcher clears
    % the watch, double check with sysinternals or lsof on linux.
    key = dir.register(watcher, eventkinds);
    
    % blocks, add poll with a timeout and timeunits if required
    keyframe = watcher.poll(duration, java.util.concurrent.TimeUnit.MILLISECONDS);
    % put them in a matlab struct, can this be done easier???
    events = struct('kind',[], 'context',[]);
    % get the array of events
    if isempty(keyframe)
        return
    end
    javaevents = keyframe.pollEvents();
    % loop manually
    for i=1:javaevents.size
        % java is 0 based
        event = javaevents.get(i-1);
        % and matlab is 1 based, explicitly convert to char 
        events(i) = struct('kind', char(event.kind), 'context', char(event.context));
    end
    % stop listening otherwise the computer slows down (MS virus checker goes
    % crazy)
    watcher.close();
    % events is returned

end
