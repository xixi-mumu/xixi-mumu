function varargout = MyMusicPlayer(varargin)
% MYMUSICPLAYER MATLAB code for MyMusicPlayer.fig
%      MYMUSICPLAYER, by itself, creates a new MYMUSICPLAYER or raises the existing
%      singleton*.
%
%      H = MYMUSICPLAYER returns the handle to a new MYMUSICPLAYER or the handle to
%      the existing singleton*.
%
%      MYMUSICPLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYMUSICPLAYER.M with the given input arguments.
%
%      MYMUSICPLAYER('Property','Value',...) creates a new MYMUSICPLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MyMusicPlayer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      Stop.  All inputs are passed to MyMusicPlayer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MyMusicPlayer

% Last Modified by GUIDE v2.5 30-Jun-2021 23:14:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MyMusicPlayer_OpeningFcn, ...
                   'gui_OutputFcn',  @MyMusicPlayer_OutputFcn, ...
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


% --- Executes just before MyMusicPlayer is made visible.
function MyMusicPlayer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MyMusicPlayer (see VARARGIN)

% Choose default command line output for MyMusicPlayer
handles.output = hObject;

% handles.tmr = timer;
% set(handles.tmr, 'ExecutionMode','FixedRate');
% set(handles.tmr, 'Period', 0.5);
% set(handles.tmr, 'TimerFcn',{@time_update, handles});

% Update handles structure
guidata(hObject, handles);
movegui(hObject,'center');

global list_load_flag
% 列表有无
list_load_flag = 0;

global music_load_flag
% 当前有无音乐
music_load_flag = 0;

global stop_mode
stop_mode = 0;


global auplayer
auplayer = audioplayer(zeros(200,2),100);
set(auplayer, 'TimerFcn',{@audio_time_update, handles});
set(auplayer, 'StartFcn',{@audio_start_update, handles});
set(auplayer, 'StopFcn',{@audio_stop_update, handles});
set(auplayer, 'TimerPeriod', 0.5)





% ----------------- 保存参数 --------------------
now_index =  1; % 当前播放的是哪首歌 序号 1~x
m_list    = []; % 歌曲完成文件名,含路径
m_way     = []; % 歌曲路径
m_name    = []; % 歌曲名称
m_type    = []; % 歌曲类型 0:mp3 1:flac 2:wma
m_lrce    = []; % 歌词有无
m_lrcn    = []; % 歌词完整路径
sound_vol = 50; % 当前播放器音量 [0-100]

% 加载配置文件
if exist('music.mat','file')
    load('music.mat');
    if (isempty(now_index))
        now_index = 1;        
    else
        if (now_index < 1)
            now_index = 1;
        end
    end
    if (isempty(sound_vol))
        sound_vol = 50;
    else
        if (sound_vol < 0 || sound_vol > 100)
            sound_vol = 50;
        end
    end
end

setappdata(handles.figure1,'NowIndex', now_index);
setappdata(handles.figure1,'MusicList', m_list);
setappdata(handles.figure1,'MusicWay', m_way);
setappdata(handles.figure1,'MusicName', m_name);
setappdata(handles.figure1,'MusicType', m_type);
setappdata(handles.figure1,'MusicLrcE', m_lrce);
setappdata(handles.figure1,'MusicLrcN', m_lrcn);
setappdata(handles.figure1,'SoundVol', sound_vol);

% ----------------- 计算参数 ---------------------

m_num     = size(m_list,1); % 歌曲数目
setappdata(handles.figure1,'MusicNum',m_num);

audio_data_ori = 0; % 原始音频
audio_data_res = 0; % 调整音量
audio_fs       = 0; % 采样频率

if (m_num > 0)
    % 已有列表被加载
    if (now_index > m_num)
        now_index = 1;
        setappdata(handles.figure1,'NowIndex', now_index);
    end
    list_load_flag = 1;
    
    % 加载音乐
    load_music_of_now_index(handles);   
    
    % 列表赋值
    set(handles.MusicList,'string',m_name);
    set(handles.MusicList,'value',now_index);
    
    % 关闭提示
    set(handles.text3,'visible','off');
    
    % 初始时间 text
    time_s = getappdata(handles.figure1,'MusicTimeS');
    set(handles.MusicTimeText,'string',['00:00 / ' time_s]);
        
    % 初始音乐名称
    set(handles.Name,'string',m_name{now_index});
    
else
    % 全新打开
    list_load_flag = 0;
    set(handles.MusicList,'string','无音乐,请添加');
    set(handles.PlayType,'enable','off');
    set(handles.LastMusic,'enable','off');
    set(handles.StopGoon,'enable','off');
    set(handles.NextMusic,'enable','off');
    set(handles.Stop,'enable','off');
    set(handles.text3,'visible','on');
    
    setappdata(handles.figure1,'OriSoundData', audio_data_ori);
    setappdata(handles.figure1,'SoundFS', audio_fs);
    setappdata(handles.figure1,'ResSoundData', audio_data_res);
    
    time_m    = 0;         % 当前歌曲总时长 dec 秒
    time_s    = second_2_minute(time_m);  % 当前歌曲总时长 char
    music_samp = 0;
    setappdata(handles.figure1,'MusicTimeM',time_m);
    setappdata(handles.figure1,'MusicTimeS',time_s);
    setappdata(handles.figure1,'MusicSamp',music_samp);
    
    % 初始时间 text
    set(handles.MusicTimeText,'string','00:00 / 00:00');
    
end

% 初始时间 silder
set(handles.MusicTimeSlider,'value',0);

% 初始音量滑动条位置
set(handles.Sound,'value',sound_vol);

% 隐藏频谱图 暂时
set(handles.axes1,'visible','off');

% UIWAIT makes MyMusicPlayer wait for user response (see UIRESUME)
% uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = MyMusicPlayer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in PlayType.
function PlayType_Callback(hObject, eventdata, handles)
% hObject    handle to PlayType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(' ************ 此功能后面再加 **********');

% --- Executes on button press in LastMusic.
function LastMusic_Callback(hObject, eventdata, handles)
% hObject    handle to LastMusic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global list_load_flag
global music_load_flag
if (list_load_flag == 0)
    return;
end

if (music_load_flag == 0)
    return;
end

now_index = getappdata(handles.figure1,'NowIndex');
m_num = getappdata(handles.figure1,'MusicNum');

if (now_index == 0)
    now_index = m_num;
else
    now_index = now_index - 1;
end

setappdata(handles.figure1,'NowIndex',now_index);
switch_music(handles);
set(handles.StopGoon,'string','||');

% --- Executes on button press in NextMusic.
function NextMusic_Callback(hObject, eventdata, handles)
% hObject    handle to NextMusic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global list_load_flag
global music_load_flag
if (list_load_flag == 0)
    return;
end

if (music_load_flag == 0)
    return;
end

now_index = getappdata(handles.figure1,'NowIndex');
m_num = getappdata(handles.figure1,'MusicNum');
if (now_index == m_num)
    now_index = 0;
else
    now_index = now_index + 1;
end
setappdata(handles.figure1,'NowIndex',now_index);
switch_music(handles);
set(handles.StopGoon,'string','||');
 
 



% --- Executes on button press in StopGoon.
function StopGoon_Callback(hObject, eventdata, handles)
% hObject    handle to StopGoon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global list_load_flag
global music_load_flag
global auplayer
global stop_mode

if (list_load_flag == 0)
    return;
end

audio_status = get(auplayer,'running');
if strcmp(audio_status,'on')
    disp('switch status to off');
    stop_mode = 1;
    pause(auplayer);
    stop_mode = 0;
    set(handles.StopGoon,'string','|>');
else
    disp('switch status to on');
    if (music_load_flag == 0)
        switch_music(handles);
        set(handles.StopGoon,'string','||');
    else
        resume(auplayer);
        set(handles.StopGoon,'string','||');
    end       
end



% --- Executes on slider movement.
function Sound_Callback(hObject, eventdata, handles)
% hObject    handle to Sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sd_vol = get(handles.Sound,'value');
setappdata(handles.figure1,'SoundVol',sd_vol);

global list_load_flag
global music_load_flag
global auplayer
global stop_mode
if (list_load_flag == 0)
    return;
end


audio_status = get(auplayer,'running');
if strcmp(audio_status,'on')

    ori_music_data = getappdata(handles.figure1,'OriSoundData');
    
    fs   = getappdata(handles.figure1,'SoundFS');
    res_music_data = ori_music_data * sd_vol / 50;
    
    now_time = get(auplayer, 'CurrentSample') ;
    stop_mode = 1;
    stop(auplayer);
    stop_mode = 0;
    auplayer = audioplayer(res_music_data,fs);
    
    play(auplayer,now_time);
    
    set(handles.StopGoon,'string','||');
    
    setappdata(handles.figure1,'ResSoundData',res_music_data);
    
else
    ori_music_data = getappdata(handles.figure1,'OriSoundData');
    
    fs   = getappdata(handles.figure1,'SoundFS');

    res_music_data = ori_music_data * sd_vol / 50;
    
    now_time = get(auplayer, 'CurrentSample');
    stop_mode = 1;
    stop(auplayer);
    stop_mode = 0;
    set(handles.StopGoon,'string','||');

    auplayer = audioplayer(res_music_data,fs);
    play(auplayer,now_time);
 
    setappdata(handles.figure1,'ResSoundData',res_music_data);
    
end




    
   








% --- Executes during object creation, after setting all properties.
function Sound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in MusicList.
function MusicList_Callback(hObject, eventdata, handles)
% hObject    handle to MusicList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MusicList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MusicList

global list_load_flag
if (list_load_flag == 0)
    return;
end

index = get(handles.MusicList,'value');
now_index = getappdata(handles.figure1,'NowIndex');

if (index == now_index)
    return;
end

setappdata(handles.figure1,'NowIndex',index);
switch_music(handles);
set(handles.StopGoon,'string','||');


% --- Executes during object creation, after setting all properties.
function MusicList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MusicList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddMusic.
function AddMusic_Callback(hObject, eventdata, handles)
% hObject    handle to AddMusic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global list_load_flag
[filename,filepath] = uigetfile('*.mp3;*.flac;*.wma','MultiSelect','on');

m_list = getappdata(handles.figure1,'MusicList');
m_way  = getappdata(handles.figure1,'MusicWay');
m_name = getappdata(handles.figure1,'MusicName');
m_type = getappdata(handles.figure1,'MusicType');
m_lrce = getappdata(handles.figure1,'MusicLrcE');
m_lrcn = getappdata(handles.figure1,'MusicLrcN');
m_num  = getappdata(handles.figure1,'MusicNum');

if filepath ~= 0
    
    add_num  = size(filename,2);
    add_list = cell(1,add_num);
    add_way  = cell(1,add_num);
    add_name = cell(1,add_num);
    add_type = cell(1,add_num);
    add_lrce = cell(1,add_num);
    add_lrcn = cell(1,add_num);
    
    for i=1:add_num
        tmp = filename(i);
        tmp = tmp{1};
        tmp_length = length(tmp);
        if( strcmp(tmp(tmp_length-2:tmp_length) ,'mp3'))
            tmp_name = tmp(1:tmp_length-4);
            tmp_type = 0;
        elseif( strcmp(tmp(tmp_length-3:tmp_length) ,'flac'))
            tmp_name = tmp(1:tmp_length-5);
            tmp_type = 1;
        elseif( strcmp(tmp(tmp_length-3:tmp_length) ,'wma'))
            tmp_name = tmp(1:tmp_length-5);
            tmp_type = 2;
        end
        
        tmp_lrcn = [filepath tmp_name '.lrc'];
        tmp_lrce = exist([filepath tmp_name '.lrc'],'file');
        
        
        add_list{i} = [filepath tmp];
        add_way{i}  = filepath;
        add_name{i} = tmp_name;
        add_type{i} = tmp_type;
        add_lrce{i} = tmp_lrce;
        add_lrcn{i} = tmp_lrcn;
    end
    
    if (m_num > 0)
        for i=1:add_num
            n1  = add_name{i};
            for j=1:m_num
               n2 = m_name{j};
               if (strcmp(n1,n2)) 
                   if (add_type{i}>0 && m_type{j}==0)
                       % 新加歌曲品质较高
                       if (add_lrce{i}>0)
                           % 新加歌曲含有歌词
                           m_lrce{j} = add_lrce{i};
                           m_lrcn{j} = add_lrce{i};
                       else
                           % 新加歌曲不含歌词 
                       end
                       m_list{j} = add_list{i};
                       m_way{j}  = add_list{i};
                       % m_name                                              
                   else
                       if (add_lrce{i}>0 && m_lrce{j}==0)
                           % 新加歌曲含有歌词, 替换歌词
                           m_lrce{j} = add_lrce{i};
                           m_lrcn{j} = add_lrce{i}; 
                       end
                   end
                   break;
               else
                   % 添加的是新歌
                   if (j==m_num)
                       m_num = m_num + 1;
                       m_list = [m_list;add_list{i}];
                       m_way  = [m_way ;add_way{i} ];
                       m_name = [m_name; add_name{i}];
                       m_type = [m_type; add_type{i}];
                       m_lrce = [m_lrce; add_lrce{i}];
                       m_lrcn = [m_lrcn; add_lrcn{i}];
                   else
                       continue;
                   end
               end                                        
            end
        end
    else
        m_num = 1;        
        m_list = cell(1);
        m_way  = cell(1);
        m_name = cell(1);
        m_type = cell(1);
        m_lrce = cell(1);
        m_lrcn = cell(1);
        
        m_list{1} = add_list{1};
        m_way{1}  = add_way{1} ;
        m_name{1} = add_name{1};
        m_type{1} = add_type{1};
        m_lrce{1} = add_lrce{1};
        m_lrcn{1} = add_lrcn{1};
   
        for i=2:add_num
            n1  = add_name{i};
            for j=1:m_num
               n2 = m_name{j};
               if (strcmp(n1,n2)) 
                   if (add_type{i}>0 && m_type{j}==0)
                       % 新加歌曲品质较高
                       if (add_lrce{i}>0)
                           % 新加歌曲含有歌词
                           m_lrce{j} = add_lrce{i};
                           m_lrcn{j} = add_lrce{i};
                       else
                           % 新加歌曲不含歌词 
                       end
                       m_list{j} = add_list{i};
                       m_way{j}  = add_list{i};
                       % m_name                                              
                   else
                       if (add_lrce{i}>0 && m_lrce{j}==0)
                           % 新加歌曲含有歌词, 替换歌词
                           m_lrce{j} = add_lrce{i};
                           m_lrcn{j} = add_lrce{i}; 
                       end
                   end
                   break;
               else
                   % 添加的是新歌
                   if (j==m_num)
                       m_num = m_num + 1;
                       m_list = [m_list;add_list{i}];
                       m_way  = [m_way ;add_way{i} ];
                       m_name = [m_name; add_name(i)];
                       m_type = [m_type; add_type(i)];
                       m_lrce = [m_lrce; add_lrce(i)];
                       m_lrcn = [m_lrcn; add_lrcn(i)];
                   else
                       continue;
                   end
               end                                        
            end
        end
    end

    
    setappdata(handles.figure1,'MusicList', m_list);
    setappdata(handles.figure1,'MusicWay', m_way);
    setappdata(handles.figure1,'MusicName', m_name);
    setappdata(handles.figure1,'MusicType', m_type);
    setappdata(handles.figure1,'MusicLrcE', m_lrce);
    setappdata(handles.figure1,'MusicLrcN', m_lrcn);
    setappdata(handles.figure1,'MusicNum',m_num);

    set(handles.MusicList,'string',m_name);
    if (list_load_flag == 0)
        set(handles.PlayType,'enable','on');
        set(handles.LastMusic,'enable','on');
        set(handles.StopGoon,'enable','on');
        set(handles.NextMusic,'enable','on');
        set(handles.text3,'visible','off');
        list_load_flag = 1;
    end
else
    return;
end


% --- Executes on button press in Sort.
function Sort_Callback(hObject, eventdata, handles)
% hObject    handle to Sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(' ************ 此功能后面再加 **********');


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global list_load_flag
global music_load_flag
global auplayer
list_load_flag = 0;
music_load_flag = 0;

audio_status = get(auplayer,'running');
if strcmp(audio_status,'on')
    stop(auplayer);
end

now_index = getappdata(handles.figure1,'NowIndex');
m_list = getappdata(handles.figure1,'MusicList');
m_way  = getappdata(handles.figure1,'MusicWay');
m_name = getappdata(handles.figure1,'MusicName');
m_type = getappdata(handles.figure1,'MusicType');
m_lrce = getappdata(handles.figure1,'MusicLrcE');
m_lrcn = getappdata(handles.figure1,'MusicLrcN');
sound_vol = getappdata(handles.figure1,'SoundVol');

save('music.mat',...    
    'now_index',...
    'm_list',...
    'm_way',...
    'm_name',...
    'm_type',...
    'm_lrce',...
    'm_lrcn',...
    'sound_vol');

delete(hObject);





% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global auplayer

stop(auplayer);


% --- Executes on slider movement.
function MusicTimeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to MusicTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function MusicTimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MusicTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
