function audio_time_update(hObject, eventdata, handles)

global auplayer
time_m = getappdata(handles.figure1,'MusicTimeM');
time_s = getappdata(handles.figure1,'MusicTimeS');

now_samp = get(auplayer,'CurrentSample');
tol_samp = get(auplayer,'TotalSamples');

run_time = time_m * now_samp / tol_samp;
run_time_s = second_2_minute(run_time);

set(handles.MusicTimeText,'string',[run_time_s '/' time_s]);
set(handles.MusicTimeSlider,'value',run_time / time_m);
fprintf('\n [%7d %7d]',now_samp, tol_samp);

