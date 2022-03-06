function audio_stop_update(hObject, eventdata, handles)
global stop_mode
if (stop_mode == 1)
    % ÔÝÍ£×´Ì¬
    return;
end
    
% ×Ô¶¯ÇÐ¸è
now_index = getappdata(handles.figure1,'NowIndex');
m_num     = getappdata(handles.figure1,'MusicNum');
    
if(now_index == m_num)
    now_index = 0;
else
    now_index = now_index + 1;
end
setappdata(handles.figure1,'NowIndex',now_index);
switch_music(handles);
disp('auto switch music at end of music');
    