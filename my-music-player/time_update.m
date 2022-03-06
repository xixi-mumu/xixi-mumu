function time_update(hObject, eventdata, handles)

global play_flag
global next_flag
global h_audioplayer
if (play_flag==0)
    return;
end

time_m = getappdata(handles.figure1,'MusicTimeM');
time_s = getappdata(handles.figure1,'MusicTimeS');

now_samp = get(h_audioplayer,'CurrentSample');
tol_samp = get(h_audioplayer,'TotalSamples');

run_time = time_m * now_samp / tol_samp;

run_time_s = second_2_minute(run_time);

% update time of text
set(handles.MusicTimeText,'string',[run_time_s '/' time_s]);
set(handles.MusicTimeSlider,'value',run_time / time_m);





next_flag =0;
if (next_flag <= now_samp)
    next_flag = now_samp;
else

    % »»¸è
    now_index = getappdata(handles.figure1,'NowIndex');
    m_num     = getappdata(handles.figure1,'MusicNum');
    
    if(now_index == m_num)
        now_index = 0;
    else
        now_index = now_index + 1;
    end
    setappdata(handles.figure1,'NowIndex',now_index);
    
    switch_music(handles);
    
end













