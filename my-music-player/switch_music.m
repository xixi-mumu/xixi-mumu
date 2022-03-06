function switch_music(handles)
global list_load_flag
global music_load_flag
global auplayer
if (list_load_flag == 0 || music_load_flag == 0)
    return;
end

load_music_of_now_index(handles);

now_index = getappdata(handles.figure1,'NowIndex');
m_name    = getappdata(handles.figure1,'MusicName');

set(handles.MusicList,'value',now_index);
time_s = getappdata(handles.figure1,'MusicTimeS');
set(handles.MusicTimeText,'string',['00:00 / ' time_s]);
set(handles.Name,'string',m_name{now_index});


music_data = getappdata(handles.figure1,'ResSoundData');
fs         = getappdata(handles.figure1,'SoundFS');

audio_status = get(auplayer,'running');

if strcmp(audio_status,'on')
    disp('switch status ...');
end

auplayer = audioplayer(music_data,fs);

play(auplayer);
set(handles.MusicTimeText,'string',['00:00 / ' time_s]);
set(handles.MusicTimeSlider,'value',0);
    











