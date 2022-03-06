function load_music_of_now_index(handles)
global list_load_flag
global music_load_flag
music_load_flag = 0;
if (list_load_flag == 0)
    return;
end

index     = getappdata(handles.figure1,'NowIndex');
m_list    = getappdata(handles.figure1,'MusicList');
sound_vol = getappdata(handles.figure1,'SoundVol');

[ori_data,fs] = audioread(m_list{index});

setappdata(handles.figure1,'OriSoundData', ori_data);
res_data = sound_vol * ori_data / 50;

setappdata(handles.figure1,'SoundFS', fs);
setappdata(handles.figure1,'ResSoundData', res_data);

music_samp = size(ori_data,1);
time_m = music_samp / fs;
time_s = second_2_minute(time_m);

setappdata(handles.figure1,'MusicTimeM',time_m);
setappdata(handles.figure1,'MusicTimeS',time_s);
setappdata(handles.figure1,'MusicSamp',music_samp);

music_load_flag = 1;