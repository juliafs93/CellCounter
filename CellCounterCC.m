function varargout = CellCounterCC(varargin)
% CELLCOUNTERCC MATLAB code for CellCounterCC.fig
%      CELLCOUNTERCC, by itself, creates a new CELLCOUNTERCC or raises the existing
%      singleton*.
%
%      H = CELLCOUNTERCC returns the handle to a new CELLCOUNTERCC or the handle to
%      the existing singleton*.
%
%      CELLCOUNTERCC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLCOUNTERCC.M with the given input arguments.
%
%      CELLCOUNTERCC('Property','Value',...) creates a new CELLCOUNTERCC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CellCounterCC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CellCounterCC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CellCounterCC

% Last Modified by GUIDE v2.5 26-Feb-2018 23:48:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CellCounterCC_OpeningFcn, ...
                   'gui_OutputFcn',  @CellCounterCC_OutputFcn, ...
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


% --- Executes just before CellCounterCC is made visible.
function CellCounterCC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CellCounterCC (see VARARGIN)
handles.Im = varargin{1};
handles.Channels = varargin{2};
handles.Slices = varargin{3};
handles.VoxelSize = varargin{4};
handles.default = varargin{5};
% Choose default command line output for CellCounterCC
handles.output = hObject;

% segment handles structure
guidata(hObject, handles);

handles.z = 1;
%handles.ST = 6.5;
%handles.FT = 2000;
handles.ST = handles.default.ST;
handles.FT = handles.default.FT;
handles.parameters = table();
handles.out = table();
% SET DEFAULT VALUES
%set(handles.thres, 'String', '0.2');
%set(handles.ws, 'String', '1');
%set(handles.rmv, 'String', '20');
set(handles.thres, 'String', num2str(handles.default.ThresLevel));
set(handles.ws, 'String', num2str(handles.default.WatershedParameter));
set(handles.rmv, 'String', num2str(handles.default.Remove));
set(handles.Zpos, 'String',['Z =  ',num2str(handles.z),' / ', num2str(handles.Slices)]);
set(handles.Zmin, 'String',num2str(handles.default.minZ));
set(handles.Zmax, 'String', num2str(handles.default.maxZ));

%disp(handles.f)
guidata(hObject, handles);
Plot1(handles)
%uiwait(msgbox('Click here to save when done'));
waitfor(handles.saveB, 'Value',1)
%set(hObject, 'waitstatus','waiting');


% --- Outputs from this function are returned to the command line.
function varargout = CellCounterCC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
guidata(hObject, handles);
varargout{1} = handles.out;
varargout{2} = handles.parameters;
%varargout{3} = handles.A;
%varargout{4} = handles.P;
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(hObject);
else
% The GUI is no longer waiting, just close it
delete(hObject);
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

z = get(hObject,'Value');
handles.z = floor(z*(handles.Slices-1))+1;
set(handles.Zpos, 'String',['Z =  ',num2str(handles.z),' / ', num2str(handles.Slices)]);
%disp(handles.f)
guidata(hObject, handles);
Plot1(handles)
try; Plot2(handles); end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in segment.
function segment_Callback(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = Segment(handles);
handles = ReplaceLabels(handles);
Plot2(handles)

 guidata(hObject, handles);
 
 
 % --- Executes on button press in update.
function update_Callback(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = ReplaceLabels(handles);
Plot2(handles)
 guidata(hObject, handles);



% --- Executes on button press in saveB.
function saveB_Callback(hObject, eventdata, handles)
% hObject    handle to saveB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%varargout = CellCounterCC_OutputFcn(hObject, eventdata, handles);



function thres_Callback(hObject, eventdata, handles)
% hObject    handle to thres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thres as text
%        str2double(get(hObject,'String')) returns contents of thres as a double


% --- Executes during object creation, after setting all properties.
function thres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rmv_Callback(hObject, eventdata, handles)
% hObject    handle to rmv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmv as text
%        str2double(get(hObject,'String')) returns contents of rmv as a double


% --- Executes during object creation, after setting all properties.
function rmv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ws_Callback(hObject, eventdata, handles)
% hObject    handle to ws (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ws as text
%        str2double(get(hObject,'String')) returns contents of ws as a double


% --- Executes during object creation, after setting all properties.
function ws_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ws (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ch1.
function ch1_Callback(hObject, eventdata, handles)
% hObject    handle to ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Plot1(handles)

% --- Executes on button press in ch2.
function ch2_Callback(hObject, eventdata, handles)
% hObject    handle to ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Plot1(handles)

% --- Executes on button press in ch3.
function ch3_Callback(hObject, eventdata, handles)
% hObject    handle to ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Plot1(handles)


function Zmin_Callback(hObject, eventdata, handles)
% hObject    handle to Zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zmin as text
%        str2double(get(hObject,'String')) returns contents of Zmin as a double


% --- Executes during object creation, after setting all properties.
function Zmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zmax_Callback(hObject, eventdata, handles)
% hObject    handle to Zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zmax as text
%        str2double(get(hObject,'String')) returns contents of Zmax as a double


% --- Executes during object creation, after setting all properties.
function Zmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in maxproj.
function maxproj_Callback(hObject, eventdata, handles)
% hObject    handle to maxproj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



    function Plot1(handles)
    axes(handles.axes1);
    z = handles.z;
    ChON = [~get(handles.ch1,'Value'),~get(handles.ch2,'Value'),~get(handles.ch3,'Value')];
    RGB(:,:,:) = handles.Im(:,:,z,:);
    RGB(:,:,:) = bsxfun(@times,RGB(:,:,:),reshape(ChON,1,1,[]));
    RGB = RGB./max(RGB(:)).*255;
    imshow(uint8(RGB));
    
    
    function[handles] = Segment(handles)
         minZ = str2num(get(handles.Zmin, 'String'));
          maxZ = str2num(get(handles.Zmax, 'String'));
          % select here channel to threshold
          CT = 1;
         toThreshold = handles.Im(:,:,minZ:maxZ,CT);
         toThreshold = imgaussfilt3(toThreshold,1);
         toThreshold = toThreshold./max(toThreshold(:));
          ThresLevel = str2num(get(handles.thres, 'String'));
        WatershedParameter = str2num(get(handles.ws, 'String'));
        Remove = str2num(get(handles.rmv, 'String'));
        parameters  = {Remove 2 WatershedParameter Remove ThresLevel 1};
        [TL ~] = ThresLabNBs_3D(toThreshold,parameters);
        %handles.out = table(CellsA, CellsP, SizeA, SizeP);
        handles.parameters = table(minZ, maxZ,ThresLevel,WatershedParameter,Remove);
        handles.TL = TL;

  % select here channel to measureF
          CF = 2;
         toF = handles.Im(:,:,minZ:maxZ,CF);
        RProps = regionprops('table',TL,toF,'PixelIdxList','Centroid','MeanIntensity','Area');
        RProps.Area = RProps.Area.*handles.VoxelSize;
        handles.RProps = RProps;

        hold(handles.axes3,'on')
        histogram(handles.axes3,log(RProps.Area), 20,'Normalization','probability');
        plot(handles.axes3,[handles.ST,handles.ST], [0,0.15],'-r')
        hold(handles.axes3,'off')
        hold(handles.axes4,'on')
        histogram(handles.axes4,RProps.MeanIntensity,20,'Normalization','probability');
        plot(handles.axes4,[handles.FT,handles.FT], [0,0.15],'-r')
        hold(handles.axes4,'off')
        handles.parameters.ST = handles.ST;
        handles.parameters.FT = handles.FT;
        RProps.PixelIdxList = [];
        handles.out = RProps;

        

    function[handles] = ReplaceLabels(handles)
        RProps = handles.RProps;
% replace colors in labelled image with high/low size and F
SmallHigh = find(log(RProps.Area) < handles.ST & RProps.MeanIntensity > handles.FT) ;
SmallLow = find(log(RProps.Area) < handles.ST & RProps.MeanIntensity < handles.FT) ;
BigHigh = find(log(RProps.Area) > handles.ST & RProps.MeanIntensity > handles.FT) ;
BigLow = find(log(RProps.Area) > handles.ST & RProps.MeanIntensity < handles.FT) ;
set(handles.SmallFbox, 'String', ['SmallF = ',num2str(length(SmallHigh))]);
set(handles.SmallnoFbox, 'String', ['SmallnoF = ',num2str(length(SmallLow))]);
set(handles.BigFbox, 'String', ['BigF = ',num2str(length(BigHigh))]);
set(handles.BignoFbox, 'String', ['BignoF = ',num2str(length(BigLow))]);
TL = handles.TL;
TLmod = TL;
for L = 1:length(SmallHigh)
    %TLmod(TL==SmallHigh(L)) = 1;
    TLmod(RProps.PixelIdxList{SmallHigh(L)}) = 1;
end
for L = 1:length(SmallLow)
    %TLmod(TL==SmallLow(L)) = 2;
    TLmod(RProps.PixelIdxList{SmallLow(L)}) = 2;
end
for L = 1:length(BigHigh)
    %TLmod(TL==BigHigh(L)) = 3;
    TLmod(RProps.PixelIdxList{BigHigh(L)}) = 3;
end
for L = 1:length(BigLow)
    %TLmod(TL==BigLow(L)) = 4;
    TLmod(RProps.PixelIdxList{BigLow(L)}) = 4;
end
handles.TLmod = TLmod; 


    function[handles] = Plot2(handles)
    z = handles.z;
    TL = handles.TLmod;
    %ROIbound = bwmorph(bwmorph(handles.A,'remove'),'thicken',1) | bwmorph(bwmorph(handles.P,'remove'),'thicken',1);
    RGB = label2rgb(TL(:,:,z), 'jet','k');
    %RGB(find(ones(size(RGB)).*ROIbound)) = 255;
    axes(handles.axes2);
    imshow(RGB);


%


% --- Executes on slider movement.
function STslider_Callback(hObject, eventdata, handles)
% hObject    handle to STslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
RProps = handles.RProps;
ST = get(hObject,'Value')*(max(log(RProps.Area))-min(log(RProps.Area)))+min(log(RProps.Area));
histogram(handles.axes3,log(RProps.Area), 20,'Normalization','probability');
hold(handles.axes3,'on')
plot(handles.axes3,[ST,ST], [0,0.15],'-r')
hold(handles.axes3,'off')
handles.ST = ST;
handles.parameters.ST = handles.ST;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function STslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to STslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function FTslider_Callback(hObject, eventdata, handles)
% hObject    handle to FTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
RProps = handles.RProps;
FT = get(hObject,'Value')*(max(RProps.MeanIntensity)-min(RProps.MeanIntensity))+min(RProps.MeanIntensity);
histogram(handles.axes4,RProps.MeanIntensity,20,'Normalization','probability');
hold(handles.axes4,'on')
plot(handles.axes4,[FT,FT], [0,0.15],'-r')
hold(handles.axes4,'off');
handles.FT = FT;
handles.parameters.FT = handles.FT;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function FTslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
