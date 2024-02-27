function handles = ddb_TropicalCyclone_select_tropical_cyclone_basins(handles)
% ddb_TropicalCyclone_select_tropical_cyclone_basins  Finds & plots TC basin polygons
%
%   This Matlab function opens and plots (or removes plotted) TC basin
%   polygons.  The user has, within the TC Toolbox, selected to display or
%   not to display the TC basin polygons, and if to display them, whether
%   all of the basins or that nearest to (i.e., enclosing) the model
%   domain.
%
%   Syntax:
%   handles = ddb_TropicalCyclone_select_tropical_cyclone_basins(handles)
%
%   Input:
%   handles  = handles data structure
%
%   Output:
%   handles  = handles data structure, updated with current TC basin
%   name(s) and TC basin polygon file name(s)
%
%   Example
%   handles = ddb_TropicalCyclone_select_tropical_cyclone_basins(handles)
%
%   See also:
%   ddb_initializeTropicalCyclone.m,
%   ddb_TropicalCycloneToolbox_setParameters.m
%
%  Revision History:
%  20 Dec 2011  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%  09 Jan 2012  Added subfunc. find_tc_polygon to determine in which
%               polygon the present Delft3D grid lies; added code to the
%               innermost IF block to call find_tc_polygon for the case in
%               which the 'nearest' polygon option is chosen.  (RSL)
%  10 Jan 2012  Updated help content; replaced subfunc. find_tc_polygon
%               with the updated code (from tst_find_tc_polygon.m);
%               modified initialization of bname, bfname, hpatch; moved the
%               call to find_tc_polygon to outside the inner IF block;
%               added 'poly_dir' to the calling parameter list of
%               find_tc_polygon.  (RSL)
%  11 Jan 2012  Removed plotting code (except for TC basin polygons) from
%               subfunc. find_tc_polygon; added indices to the .gridX,
%               .gridY input parameters in the call to find_tc_polygon;
%               added code to set the TC basin polygons on or off; changed
%               find_tc_polygon output 'bname' to a character string; added
%               local parameter 'babbrev' to store the newly added output
%               of find_tc_polygon (basin name abbreviation(s)); added
%               listing and output of 'babbrev' to find_tc_polygon;
%               upgraded one of the IF statements to check whether a
%               different view option was selected prior to the 'show'
%               option being selected; added an IF block to change the
%               basin name string if the display was disabled only if the
%               basin name string is not empty; removed debug print code.  (RSL)
%  13 Jan 2012  Added a check in subfunc. find_tc_polygon for whether the
%               X, Y coordinate arrays are empty, and if so, issues a
%               warning message and immediately returns.  (RSL)
%  19 Jan 2012  Upgraded subfunc. find_tc_polygon to provide better
%               coloring of the basin polygons.  (RSL)
%  28 Jan 2013  Updated subfunc. find_tc_polygon to add support for names,
%               abbreviations & colors for the recently added TC basins
%               (Indian Ocean, Southern Hemisphere).  (RSL)
%
%*******************************************************************************

%  Extract the pertinent handles parameters.
inp = handles.toolbox.tropicalcyclone;

%  Check whether the basins are to be displayed.
if (inp.showTCBasins == 1)
    %  Show basins.
    bname = '';    % Basin name(s) (e.g., 'Atlantic')
    bfname = {};   % Basin polygon file name list
    babbrev = {};  % Basin name(s) 2-character abbreviation (e.g., 'at')
    hpatch = [];   % Basin polygon patch handle list
    nhold = '';    % Holder of basin name string
    
    %  Check whether basins have been plotted.
    if (~isempty(inp.TCBasinHandles))
        %  There have been plotted TC bason polygons, so check whether the
        %  user chose to view a different option, all vs. nearest.
        if (~isequal(inp.whichTCBasinOption, inp.oldwhichTCBasinOption) || ...
            (length(inp.TCBasinFileName) > 1 && inp.whichTCBasinOption == 0) || ...
            (length(inp.TCBasinFileName) == 1 && inp.whichTCBasinOption == 1))
            %  The user changed which basin(s) to view, so get the new
            %  polygon(s) & name(s).
            %  First, remove any existing polygons from the plot, and clear
            %  the handles vector.
            for i = 1:length(handles.toolbox.tropicalcyclone.TCBasinHandles)
                %  Set the current TC basin polygon handle visibility to 'off'.
                if (ishandle(handles.toolbox.tropicalcyclone.TCBasinHandles(i)))
                    delete(handles.toolbox.tropicalcyclone.TCBasinHandles(i));
                end
            end
            
            %  Clear the handles list; reinitialize the local TC output
            %  parameters.
            handles.toolbox.tropicalcyclone.TCBasinHandles = [];
            bname = '';
            bfname = {};
            babbrev = {};
            hpatch = [];
            handles.toolbox.tropicalcyclone.oldTCBasinName = handles.toolbox.tropicalcyclone.TCBasinName;
            
            %  Plot the polygon(s) & retrieve polygon info.
            [bname,bfname,babbrev,hpatch] = find_tc_polygon(inp.tcBasinsDir,inp.whichTCBasinOption, ...
                handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
            
            %  Store the info if the user did not cancel.
            if (~isempty(bname))
                handles.toolbox.tropicalcyclone.oldTCBasinName = handles.toolbox.tropicalcyclone.TCBasinName;
                handles.toolbox.tropicalcyclone.TCBasinName = bname;
                handles.toolbox.tropicalcyclone.TCBasinFileName = bfname;
                handles.toolbox.tropicalcyclone.TCBasinNameAbbrev = babbrev;
                handles.toolbox.tropicalcyclone.TCBasinHandles = hpatch;
            end
        else
            %  This is the same which option, so loop over them.
            %  First, restore the basin name string.
            nhold = handles.toolbox.tropicalcyclone.TCBasinName;
            handles.toolbox.tropicalcyclone.TCBasinName = handles.toolbox.tropicalcyclone.oldTCBasinName;
            handles.toolbox.tropicalcyclone.oldTCBasinName = nhold;
            %  Loop over TC basin polygons....
            for i = 1:length(inp.TCBasinHandles)
                %  Set the current TC basin polygon handle visibility to 'on'.
                if (ishandle(inp.TCBasinHandles(i)))
                    set(handles.toolbox.tropicalcyclone.TCBasinHandles(i),'Visible','on');
                end
            end
        end
    else
        %  This should be the 1st time through, unless the user canceled previously.
        %  Plot the basin(s), and get basin, polygon file name info.
        [bname,bfname,babbrev,hpatch] = find_tc_polygon(inp.tcBasinsDir,inp.whichTCBasinOption, ...
            handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
        
        %  Store the info if the user did not cancel.
        if (~isempty(bname))
            handles.toolbox.tropicalcyclone.oldTCBasinName = handles.toolbox.tropicalcyclone.TCBasinName;
            handles.toolbox.tropicalcyclone.TCBasinName = bname;
            handles.toolbox.tropicalcyclone.TCBasinFileName = bfname;
            handles.toolbox.tropicalcyclone.TCBasinNameAbbrev = babbrev;
            handles.toolbox.tropicalcyclone.TCBasinHandles = hpatch;
        end
    end
else
    %  Turn basins off.
    %  Check whether any TC basin polygons have been plotted.
    if (~isempty(inp.TCBasinHandles))
        %  Plotting has been done, so store the previous name string and
        %  reset the current one (only if the current one is not empty).
        if (~isempty(inp.TCBasinName))
            handles.toolbox.tropicalcyclone.oldTCBasinName = handles.toolbox.tropicalcyclone.TCBasinName;
            handles.toolbox.tropicalcyclone.TCBasinName = '';
        end
        
        %  There have been plotted TC bason polygons, so loop over them.
        for i = 1:length(handles.toolbox.tropicalcyclone.TCBasinHandles)
            %  Set the current TC basin polygon handle visibility to 'off'.
            if (ishandle(handles.toolbox.tropicalcyclone.TCBasinHandles(i)))
                set(handles.toolbox.tropicalcyclone.TCBasinHandles(i),'Visible','off');
            end
        end
    end
end

%  Update the "old" which option.
handles.toolbox.tropicalcyclone.oldwhichTCBasinOption = handles.toolbox.tropicalcyclone.whichTCBasinOption;

%  Update the handles structure.
setHandles(handles);

return;

%*******************************************************************************
function [bname,bfname,babbrev,hpatch] = find_tc_polygon(poly_dir,itype,x,y)
%  FIND_TC_POLYGON Function to determine in which polygon a point lies
%
%  find_tc_polygon.m
%
%  This Matlab function determines in which polygon, from a list of known
%  polygon .xy files, a point lies.  The point is the mean of the given X
%  and Y coordinate matrices.  The return value is the name (a 2-character
%  string) of the polygon.  The polygons reside in a known location, and
%  delineate tropical cyclone basins.  The vertices of the polygons are
%  stored in ASCII text "XY" files which contain 2 columns, longitude and
%  latitude, respectively.  In each XY file, the last vertex equals the
%  first to form a closed polygon.
%
%  Syntax: [bname,bfname,babbrev,hpatch] = find_tc_polygon(poly_dir,itype,handles.Model.Input.gridX,handles.Model.Input.gridY)
%  where:  bname is the returned basin name string,
%          bfname is the returned file name of the polygon file,
%          babbrev is the returned list of 2-character basin name(s),
%          hpatch is a vector of handles to each polygon patch object,
%          poly_dir is the directory in which the polygon files reside,
%          itype is an integer flag indicating whether to select the
%          nearest (itype == 0) or all (itype == 1) of the TC basins,
%          handles.Model.Input.gridX is a matrix of X grid coordinates, and
%          handles.Model.Input.gridY is a matrix of Y grid coordinates
%
%  Calls: nanmean.m
%
%  Called by: 
%
%  Revision History:
%  13 Dec 2011  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%  09 Jan 2012  Several upgrades were applied: the 'basins' and
%               'basin_abbr' variables were ordered alphabetically;
%               'basin_color' was added to plot each basin polygon in a
%               different color; the basin polygon plot command was changed
%               to a 'patch' command with other paremeters to provide
%               improved appearance; an IF block was added to the FOR loop
%               to use the identified basin name and corresponding color
%               within the plot legend; modified the questdlg() call to use
%               the basin label; added output of basin polygon file name,
%               bfname; updated help content.  (RSL)
%  10 Jan 2012  Added output of vector of polygon patch handles, hpatch;
%               updated help content; added input of 'itype' to designate
%               the type of TC basin selection (=0 for nearest, or 1 for
%               all); added IF blocks to provide support for 'itype' so
%               that if itype==1, all of the polygons are extracted &
%               plotted; updated the help content; added input of
%               'poly_dir' in the input parameter list, and modified the
%               def. of 'poly_file' to include 'poly_dir'.  (RSL)
%  11 Jan 2012  Removed plotting code except for the polygon patch; changed
%               bname assignments to use basins{} vice basins_abbr{};
%               changed output bname to a character string, and added code
%               to built that string for the case of all basins; added
%               output of 'babbrev' to contain the 2-character basin name
%               strings & reused the 'bname' code that used basins{}.
%               (RSL)
%  13 Jan 2012  Added an IF block to check whether the input X, Y
%               coordinate arrays are empty, and if so, issues a warning
%               message and immediately returns.  (RSL)
%  19 Jan 2012  Renamed basin_color to basin_edge_color; added def. of
%               basin_color using vectors of RGB values; changed the
%               'patch' commands to use these modified/new parameters.
%               (RSL)
%  28 Jan 2013  Updated the basin-specific parameters (basin*) to include
%               the recently added basins (Indian Ocean, Southern
%               Hemisphere) & colors for them.  (RSL)
%
%*******************************************************************************

%  Initialize the output value.
bname = '';   % Basin name string
bfname = {};  % Basin polygon file name
babbrev = {};  % Basin name abbreviation
hpatch = [];   % Handles to polygon patch(es)

%  Check whether valid coordinates were passed.
if (isempty(x) || isempty(y))
    ddb_giveWarning('Warning',['No grid coordinates were provided; has a grid been loaded or generated?  Function: ' mfilename '.m']);
    return;
end

%  Find the mean position from the (assumed 2-D) coordinate matrices.
xav = nanmean(nanmean(x));
yav = nanmean(nanmean(y));

%  Define the basin names and abbreviations.
basins = {'Atlantic','Central Pacific','East Pacific','Indian Ocean','Southern Hemisphere','West Pacific'};
basins_abbr = {'at','cp','ep','io','sh','wp'};
%  Colors for the polygon edges:
basin_edge_color = ['r','y','g','m','c','b'];
%  Colors for the basin polygons (experimentally derived; had to use GIMP
%  to determine the RGB values of patches drawn using the above colors with
%  different values of 'edgealpha').
basin_color = [255/255,179/255,179/255;...
    255/255,255/255,191/255;...
    191/255,255/255,143/255;...
    217/255,27/255,224/255;...
    27/255,224/255,181/255;...
    128/255,128/255,255/255];
nb = size(basins,2);  % Number of basins.
llabel = 'Unknown';  % Init. the basin name for the user prompt

%  Currently, the directory in which the polygon files reside is
%  hard-wired.  Ultimately, this should be stored in a .xml file or some
%  similar means of storage.  
poly_file = dir([poly_dir filesep '*.xy']);

%  Obtain the number of files found.
nf = size(poly_file,1);

%  Check whether files were found.
if (nf < 1)
    %  None were found, so return to the caller after issuing a warning.
    warning('The polygon files were not found.');
    return;
end

%  Make the current figure active.
figure(gcf);

%  Loop over polygon file names....
for i = 1:nf
    %  Load the polygon vertex coordinates.
    xy = load(poly_file(i).name);
        
    %  Check which mode, all basins (1) or nearest (0):
    if (itype == 0)
    
        %  Create a list of indices for all points in/on the polygon.
        isin = find(inpolygon(xav,yav,xy(:,1),xy(:,2)));
        %  Nearest, so we want that which encloses the domain.
        %  Check whether the mean lat/lon lies in/on the polygon.
        if (~isempty(isin))
            %  The point lies in/on the polygon, so determine which polygon was
            %  used.
            %  Check whether the present basin name matches the polygon
            %  file name.
            if (~isempty(regexp(poly_file(i).name, strrep(lower(basins{i}),' ', '_'), 'match')))
                babbrev{1} = basins_abbr{i};  % Basin abbreviation
                bname = char(basins{i});  % Basin name
                llabel = basins{i};      % Basin name
                bfname{1} = char(poly_file(i).name);  % Polygon file name
                %  Label the TC basin polygon plot.
                hbp = patch(xy(:,1),xy(:,2),basin_color(i,:),'edgecolor',basin_edge_color(i));
                hpatch = hbp;
                %  Drop out of the loop.
                break;
            end
        end
    else
        %  Itype == 1; all basins are to be plotted & stored.
        hpatch(i) = patch(xy(:,1),xy(:,2),basin_color(i,:),'edgecolor',basin_edge_color(i));
        babbrev{i} = basins_abbr{i};  % Basin abbreviation
        if (i == 1)
            bname = char(basins{i});
        else
            bname = [bname ', ' char(basins{i})];  % Basin name
        end
        bfname{i} = poly_file(i).name;  % Polygon file name
    end
end

%  Perform the verification only for 'nearest' option (itype == 0).
if (itype == 0)
    %  Verify that the correct TC basin has been determined.
    resp = questdlg(['Is ' llabel ' the correct TC basin?'],'VERIFICATION','Yes','No','Cancel','Yes');
    
    %  Check the user response.
    if (isempty(resp) || strcmp(resp, 'Cancel'))
        %  User canceled or hit Escape or clicked the 'X' button to close the
        %  window; issue a status message and return to the calling routine
        %  with an empty string.
        warning('User canceled TC basin verification.');
        bname = {};
        bfname = {};
        babbrev = {};
        
        %  Remove plotted entities.
        if (ishandle(hbp))
            delete(hbp);
            hpatch = []; % Remove from the handle vector
        end
        return;
    elseif (strcmp(resp,'No'))
        %  The TC basin is incorrect, so do prompt for the basin.
        resp = listdlg('ListString',basins,'SelectionMode','single','ListSize',[160,70], ...
            'Name','TC Basins','PromptString','Select the tropical cyclone basin:');
        if (isempty(resp))
            %  User canceled or hit Escape or clicked the 'X' button to close the
            %  window; issue a status message and return to the calling routine
            %  with an empty string.
            warning('User canceled TC basin verification.');
            bname = {};
            bfname = {};
            babbrev = {};
            
            %  Remove plotted entities.
            if (ishandle(hbp))
                delete(hbp);
                hpatch = []; % Remove from the handle vector
            end
            return;
        else
            %  User made a selection, so use it.  Issue a status message to
            %  that regard.
            disp(['User chose the ' char(basins(resp)) ' TC basin (' char(basins_abbr(resp)) ').']);
            %  Check whether this basin differs from the one that is plotted.
            if (~strcmp(bname,basins_abbr(resp)))
                babbrev{1} = basins_abbr{resp};
                bname = char(basins{resp});
                bfname{1} = poly_file(resp).name;
                clear xy;
                if (ishandle(hbp))
                    delete(hbp);
                end
                xy = load(poly_file(resp).name);
                hbp = patch(xy(:,1),xy(:,2),basin_color(resp,:),'edgecolor',basin_edge_color(resp));
                hpatch = hbp;
            end  % if(~strcmp...
        end  % if (isempty(...
    end  % if (isempty...
end  % if (itype...

return;
