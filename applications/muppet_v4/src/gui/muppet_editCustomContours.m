function muppet_editCustomContours(varargin)

init=0;

handles=getHandles;

if isempty(varargin)
    % Called from main GUI (must be axis properties)
    init=1;
    opt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
    usedfor='axisproperty';
elseif isempty(varargin{1})
    % Called from plot options
    init=1;
    opt=gui_getUserData;
    usedfor='plotoption';
end

if init
    
    s.customcontours=opt.customcontours;
    s.cmin=opt.cmin;
    s.cmax=opt.cmax;
    cstep=opt.cstep;
    s.nrcontours=round((s.cmax-s.cmin)/cstep);

    s.selectedcontournumber=1;
    s.selectedcontour=s.customcontours(1);
    s=updateContourStrings(s);
    [s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'customcontours.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
    if ok
        switch usedfor
            case{'axisproperty'}
                handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.customcontours=s.customcontours;
                setHandles(handles);
            case{'plotoption'}
                opt.customcontours=s.customcontours;
                gui_setUserData(opt);
        end
    end
else
    switch lower(varargin{1})
        case{'selectcontour'}
            selectContour;            
        case{'editcontour'}
            editContour;
        case{'insertabove'}
            insertAbove;
        case{'insertbelow'}
            insertBelow;
        case{'delete'}
            deleteContour;
        case{'linear'}
            generateLinear;
        case{'logarithmic'}
            generateLogarithmic;
        case{'antilogarithmic'}
            generateAntiLogarithmic;            
    end
end

%%
function selectContour
s=gui_getUserData;
s.selectedcontour=s.customcontours(s.selectedcontournumber);
gui_setUserData(s);

%%
function editContour
s=gui_getUserData;
s.customcontours(s.selectedcontournumber)=s.selectedcontour;
s=updateContourStrings(s);
gui_setUserData(s);

%%
function insertAbove
s=gui_getUserData;
ic=s.selectedcontournumber;
s.customcontours=[s.customcontours(1:ic-1) s.customcontours(ic) s.customcontours(ic:end)];
s.selectedcontour=s.customcontours(s.selectedcontournumber);
s=updateContourStrings(s);
gui_setUserData(s);

%%
function insertBelow
s=gui_getUserData;
ic=s.selectedcontournumber;
s.customcontours=[s.customcontours(1:ic) s.customcontours(ic) s.customcontours(ic+1:end)];
s.selectedcontournumber=s.selectedcontournumber+1;
s.selectedcontour=s.customcontours(s.selectedcontournumber);
s=updateContourStrings(s);
gui_setUserData(s);

%%
function deleteContour
s=gui_getUserData;
if length(s.customcontours)>=2
    if s.selectedcontournumber<length(s.customcontours)
        s.customcontours=[s.customcontours(1:s.selectedcontournumber-1) s.customcontours(s.selectedcontournumber+1:end)];
    else
        s.customcontours=s.customcontours(1:s.selectedcontournumber-1);
    end
    if s.selectedcontournumber>length(s.customcontours)
        s.selectedcontournumber=length(s.customcontours);
    end
    s.selectedcontour=s.customcontours(s.selectedcontournumber);
    s=updateContourStrings(s);
end
gui_setUserData(s);

%%
function generateLinear
s=gui_getUserData;
s.customcontours=s.cmin:(s.cmax-s.cmin)/s.nrcontours:s.cmax;
s.selectedcontournumber=1;
s.selectedcontour=s.customcontours(s.selectedcontournumber);
s=updateContourStrings(s);
gui_setUserData(s);

%%
function generateLogarithmic

s=gui_getUserData;

cmin=s.cmin;
cmax=s.cmax;
noint=s.nrcontours;

if cmin<=0
    muppet_giveWarning('text','Minimum contour must be greater than zero!');
    return
end

if cmax<=0
    muppet_giveWarning('text','Maximum contour must be greater than zero!');
    return
end

s.customcontours=[];

if cmin>0 && cmax>0

    a=log10(cmin);
    b=log10(cmax);
    rat=(b-a)/noint;

    if rat<0.66
        r=floor(log10(cmin));
        val=10^r;
        ex=0;
        i=0;
        while ex==0
            %1
            if ex==0
                i=i+1;
                s.customcontours(i)=val;
                if s.customcontours(i)>=cmax
                    ex=1;
                end
            end
            %2
            if ex==0
                i=i+1;
                s.customcontours(i)=val*2;
                if s.customcontours(i)>=cmax
                    ex=1;
                end
            end
            %5
            if ex==0
                i=i+1;
                s.customcontours(i)=val*5;
                if s.customcontours(i)>=cmax
                    ex=1;
                end
            end
            val=val*10;
        end
    else
        r=round(log10(cmin));
        val=10^r;
        s.customcontours(1)=val;
        i=1;
        while val<cmax
            val=val*10;
            i=i+1;
            s.customcontours(i)=val;
        end
    end

end

s.selectedcontournumber=1;
s.selectedcontour=s.customcontours(s.selectedcontournumber);
s=updateContourStrings(s);

gui_setUserData(s);

%%
function generateAntiLogarithmic
s=gui_getUserData;
s.customcontours=s.cmin:(s.cmax-s.cmin)/s.nrcontours:s.cmax;
s.selectedcontournumber=1;
s.selectedcontour=s.customcontours(s.selectedcontournumber);
s=updateContourStrings(s);
gui_setUserData(s);

%%
function s=updateContourStrings(s)
s.contourstrings=[];
for ic=1:length(s.customcontours)
    s.contourstrings{ic}=num2str(s.customcontours(ic));
end
