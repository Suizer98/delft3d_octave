function varargout = EditCustomContours(varargin)
% EDITCUSTOMCONTOURS M-file for EditCustomContours.fig
%      EDITCUSTOMCONTOURS, by itself, creates a new EDITCUSTOMCONTOURS or raises the existing
%      singleton*.
%
%      H = EDITCUSTOMCONTOURS returns the handle to a new EDITCUSTOMCONTOURS or the handle to
%      the existing singleton*.
%
%      EDITCUSTOMCONTOURS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITCUSTOMCONTOURS.M with the given input arguments.
%
%      EDITCUSTOMCONTOURS('Property','Value',...) creates a new EDITCUSTOMCONTOURS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditCustomContours_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditCustomContours_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help EditCustomContours

% Last Modified by GUIDE v2.5 04-Jul-2006 16:19:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditCustomContours_OpeningFcn, ...
                   'gui_OutputFcn',  @EditCustomContours_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EditCustomContours is made visible.
function EditCustomContours_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditCustomContours (see VARARGIN)

% Choose default command line output for EditCustomContours
handles.output = hObject;

handles.OriginalContours=varargin{2};

handles.CMin=varargin{4};
handles.CMax=varargin{6};
handles.CStep=varargin{8};

PutInCentre(hObject);
 
handles.Contours=handles.OriginalContours;

handles.NoContours=size(handles.Contours,2);

for i=1:handles.NoContours
    str{i}=num2str(handles.Contours(i));
end
set(handles.SelectContour,'String',str);

set(handles.EditValue,'String',str{1});

no=round((handles.CMax-handles.CMin)/handles.CStep);

set(handles.EditMinimum,'String',num2str(handles.CMin));
set(handles.EditMaximum,'String',num2str(handles.CMax));
set(handles.EditNoIntervals,'String',num2str(no));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditCustomContours wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditCustomContours_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

close(handles.figure1)

% --- Executes on selection change in SelectContour.
function SelectContour_Callback(hObject, eventdata, handles)
% hObject    handle to SelectContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectContour contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectContour

k=get(handles.SelectContour,'Value');

str=get(handles.SelectContour,'String');

set(handles.EditValue,'String',str{k});

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectContour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=handles.Contours(1:handles.NoContours);

guidata(hObject, handles);
 
uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=handles.OriginalContours;
 
guidata(hObject, handles);
 
uiresume;


function EditValue_Callback(hObject, eventdata, handles)
% hObject    handle to EditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditValue as text
%        str2double(get(hObject,'String')) returns contents of EditValue as a double



% --- Executes during object creation, after setting all properties.
function EditValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in PushInsertAbove.
function PushInsertAbove_Callback(hObject, eventdata, handles)
% hObject    handle to PushInsertAbove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sz=size(get(handles.EditValue,'String'),2);

if sz>0

    k=get(handles.SelectContour,'Value');

    for j=handles.NoContours+1:-1:k+1;
        handles.Contours(j)=handles.Contours(j-1);
    end
    newcont=k;

    handles.Contours(k)=str2num(get(handles.EditValue,'String'));
    
    handles.NoContours=handles.NoContours+1;

    for i=1:handles.NoContours
        str{i}=num2str(handles.Contours(i));
    end

    set(handles.SelectContour,'String',str);
    set(handles.SelectContour,'Value',newcont);
    
    str=get(handles.SelectContour,'String');

    set(handles.EditValue,'String',num2str(str{newcont}) );
end

guidata(hObject, handles);

% --- Executes on button press in PushInsertBelow.
function PushInsertBelow_Callback(hObject, eventdata, handles)
% hObject    handle to PushInsertBelow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sz=size(get(handles.EditValue,'String'),2);

if sz>0

    k=get(handles.SelectContour,'Value');

    for j=handles.NoContours+1:-1:k+1;
        handles.Contours(j)=handles.Contours(j-1);
    end
    
    if handles.NoContours==0
        newcont=1;
        handles.Contours(1)=str2num(get(handles.EditValue,'String'));
    else
        newcont=k+1;
        handles.Contours(k+1)=str2num(get(handles.EditValue,'String'));
    end
    
    handles.Contours(k+1)=str2num(get(handles.EditValue,'String'));
    
    handles.NoContours=handles.NoContours+1;

    for i=1:handles.NoContours
        str{i}=num2str(handles.Contours(i));
    end

    set(handles.SelectContour,'String',str);
    set(handles.SelectContour,'Value',newcont);
    
    str=get(handles.SelectContour,'String');

    set(handles.EditValue,'String',num2str(str{newcont}) );
end

guidata(hObject, handles);

% --- Executes on button press in PushDelete.
function PushDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.NoContours>0

    k=get(handles.SelectContour,'Value');

    if k==handles.NoContours
        if k==1
            newcont=1;
        else
            newcont=k-1;
        end
    else
        for j=k:handles.NoContours-1
            handles.Contours(j)=handles.Contours(j+1);
        end
        newcont=k;
    end
    
    handles.NoContours=handles.NoContours-1;

    if handles.NoContours>0
        for i=1:handles.NoContours
            str{i}=num2str(handles.Contours(i));
        end
    else
        str{1}='';
    end
    set(handles.SelectContour,'String',str);
    set(handles.SelectContour,'Value',newcont);
    
    str=get(handles.SelectContour,'String');

    set(handles.EditValue,'String',num2str(str{newcont}) );
end

guidata(hObject, handles);

% --- Executes on button press in PushChange.
function PushChange_Callback(hObject, eventdata, handles)
% hObject    handle to PushChange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sz=size(get(handles.EditValue,'String'),2);

if sz>0

    k=get(handles.SelectContour,'Value');

    str=get(handles.EditValue,'String');

    handles.Contours(k)=str2num(str);

    clear str;
    
    if handles.NoContours==0
        handles.NoContours=1;
        handles.Contours(1)=str2num(get(handles.EditValue,'String'));
    end

    for i=1:handles.NoContours
        str{i}=num2str(handles.Contours(i));
    end
    set(handles.SelectContour,'String',str);

end

guidata(hObject, handles);




function EditMinimum_Callback(hObject, eventdata, handles)
% hObject    handle to EditMinimum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMinimum as text
%        str2double(get(hObject,'String')) returns contents of EditMinimum as a double


% --- Executes during object creation, after setting all properties.
function EditMinimum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMinimum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditMaximum_Callback(hObject, eventdata, handles)
% hObject    handle to EditMaximum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMaximum as text
%        str2double(get(hObject,'String')) returns contents of EditMaximum as a double


% --- Executes during object creation, after setting all properties.
function EditMaximum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMaximum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditNoIntervals_Callback(hObject, eventdata, handles)
% hObject    handle to EditNoIntervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditNoIntervals as text
%        str2double(get(hObject,'String')) returns contents of EditNoIntervals as a double


% --- Executes during object creation, after setting all properties.
function EditNoIntervals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNoIntervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in PushLinear.
function PushLinear_Callback(hObject, eventdata, handles)
% hObject    handle to PushLinear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmin=str2num(get(handles.EditMinimum,'String'));
cmax=str2num(get(handles.EditMaximum,'String'));
noint=str2num(get(handles.EditNoIntervals,'String'));

handles.Contours=cmin:(cmax-cmin)/noint:cmax;
    
handles.NoContours=noint+1;

for i=1:handles.NoContours
    str{i}=num2str(handles.Contours(i));
end
set(handles.SelectContour,'String',str);
set(handles.SelectContour,'Value',1);
    
str=get(handles.SelectContour,'String');

set(handles.EditValue,'String',num2str(str{1}) );

guidata(hObject, handles);

% --- Executes on button press in PushLogarithmic.
function PushLogarithmic_Callback(hObject, eventdata, handles)
% hObject    handle to PushLogarithmic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmin=str2num(get(handles.EditMinimum,'String'));
cmax=str2num(get(handles.EditMaximum,'String'));
noint=str2num(get(handles.EditNoIntervals,'String'));

if cmin>0 & cmax>0

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
                handles.Contours(i)=val;
                if handles.Contours(i)>=cmax
                    ex=1;
                end
            end
            %2
            if ex==0
                i=i+1;
                handles.Contours(i)=val*2;
                if handles.Contours(i)>=cmax
                    ex=1;
                end
            end
            %5
            if ex==0
                i=i+1;
                handles.Contours(i)=val*5;
                if handles.Contours(i)>=cmax
                    ex=1;
                end
            end
            val=val*10;
        end
    else
        r=round(log10(cmin));
        val=10^r;
        handles.Contours(1)=val;
        i=1;
        while val<cmax
            val=val*10;
            i=i+1;
            handles.Contours(i)=val;
        end
    end

    handles.NoContours=i;

    for i=1:handles.NoContours
        str{i}=num2str(handles.Contours(i));
    end
    set(handles.SelectContour,'String',str);
    set(handles.SelectContour,'Value',1);

    str=get(handles.SelectContour,'String');

    set(handles.EditValue,'String',num2str(str{1}) );

end

guidata(hObject, handles);



% --- Executes on button press in PushAntiLogarithmic.
function PushAntiLogarithmic_Callback(hObject, eventdata, handles)
% hObject    handle to PushAntiLogarithmic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


