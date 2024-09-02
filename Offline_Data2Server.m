%% 鍦ㄧ嚎瀹為獙鍙傛暟璁剧疆閮ㄥ垎锛岀敤浜庤缃瘡涓?涓璇曠殑鎯呭喌锛屼緷鎹璇曟儏鍐佃繘琛屼慨鏀?

% 杩愬姩鎯宠薄鍩烘湰鍙傛暟璁剧疆
subject_name = 'Jyt_test_0901_offline';  % 琚瘯濮撳悕
TrialNum = 30*4;  % 璁剧疆閲囬泦鐨勬暟閲?
%TrialNum = 3*3;
MotorClasses = 3;  % 杩愬姩鎯宠薄鐨勭绫荤殑鏁伴噺鐨勮缃紝娉ㄦ剰杩欓噷鏄妸绌烘兂idle鐘舵?佷篃瑕佹斁杩涘幓鐨勶紝娉ㄦ剰杩欓噷鐨勪换鍔℃槸[0,1,2]锛屽拰readme.txt閲岄潰鐨勫搴?
% 褰撳墠璁剧疆鐨勪换鍔?
% Idle 0   -> SceneIdle 
% MI1 1   -> SceneMI_Drinking 
% MI2 2   -> Scene_Milk 
% 鐢辨璁剧疆浠诲姟鐢ㄧ殑瀛楀吀
task_keys = {0, 1, 2};
task_values = {'SceneIdle', 'SceneMI_Drinking', 'Scene_Milk'};
task_dict = containers.Map(task_keys, task_values);

% 鑴戠數璁惧鐨勬暟鎹噰闆?
sample_frequency = 256; 
WindowLength = 512;  % 姣忎釜绐楀彛鐨勯暱搴?
channel_selection=1;
if channel_selection==0 % 判断是否要进行通道选择，目前设置为0，保留所有数据，但是在后面服务器上可以开启选择
    channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
    mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
    EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的
else
    channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  % 选择的通道，这里去掉了OZ，M1,M2，Fp1，Fp2这几个channel
    mu_channels = struct('C3',24-3, 'C4',22-3);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
    EI_channels = struct('F3', 29-3, 'Fz', 28-3, 'F4', 27-3);  % 用于计算EI指标的几个channels，需要确定下位置的
end
weight_mu = 0.6;  % 鐢ㄤ簬璁＄畻ERD/ERS鎸囨爣鍜孍I鎸囨爣鐨勫姞鏉冨拰
seconds_per_trial = 5;

% 閫氫俊璁剧疆
ip = '127.0.0.1';
port = 8880;  % 鍜屽悗绔湇鍔″櫒杩炴帴鐨勪袱涓弬鏁?
%ip = '172.18.22.21';
%port = 8880;

% 浼犺緭鏁版嵁鐨勬枃浠跺す浣嶇疆璁剧疆
foldername = 'Jyt_test_0901_offline_20240901_193737949_data';
windows_per_session = 90;
classes = MotorClasses;
%% 璇诲彇寰呬紶杈撶殑鍘熷鏁版嵁
TrialData = load([foldername, '\\', 'Offline_EEGMI_RawData_Jyt_test_0901_offline', '\\', 'Offline_EEGMI_RawData_Jyt_test_0901_offline20240901_201236541.mat' ],'TrialData');

% 鏁版嵁棰勫鐞?
% 鍒掔獥鍙傛暟璁剧疆
rawdata = TrialData.TrialData;
sample_frequency = 256; 
WindowLength = 512;  % 姣忎釜绐楀彛鐨勯暱搴?
SlideWindowLength = 256;  % 婊戠獥闂撮殧
[DataX, DataY, windows_per_session] = Offline_DataPreprocess_Hanning_GuidanceAdaption(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername, seconds_per_trial);

%% 璇诲彇寰呬紶杈撶殑鏁版嵁
%DataX = load([foldername, '\\', 'Offline_EEGMI_Jyt_test_0513_offline', '\\', 'Offline_EEG_data_Jyt_test_0513_offline20240513_173441993.mat' ],'DataX');
%DataX = DataX.DataX;
%% 棰勫鐞嗘暟鎹紶杈?
% 璁剧疆浼犺緭鐨勫弬鏁?
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);
