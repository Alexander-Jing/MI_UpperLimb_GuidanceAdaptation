%% 预处理数据传输
% 设置传输的参数
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);
