%% 在线实验参数设置部分，用于设置每�?个被试的情况，依据被试情况进行修�?

% 运动想象基本参数设置
subject_name = 'Jyt_test_0901_offline';  % 被试姓名
TrialNum = 30*4;  % 设置采集的数�?
%TrialNum = 3*3;
MotorClasses = 3;  % 运动想象的种类的数量的设置，注意这里是把空想idle状�?�也要放进去的，注意这里的任务是[0,1,2]，和readme.txt里面的对�?
% 当前设置的任�?
% Idle 0   -> SceneIdle 
% MI1 1   -> SceneMI_Drinking 
% MI2 2   -> Scene_Milk 
% 由此设置任务用的字典
task_keys = {0, 1, 2};
task_values = {'SceneIdle', 'SceneMI_Drinking', 'Scene_Milk'};
task_dict = containers.Map(task_keys, task_values);

% 脑电设备的数据采�?
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长�?
channel_selection=1;
if channel_selection==0 % �ж��Ƿ�Ҫ����ͨ��ѡ��Ŀǰ����Ϊ0�������������ݣ������ں���������Ͽ��Կ���ѡ��
    channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
    mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
    EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
else
    channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  % ѡ���ͨ��������ȥ����OZ��M1,M2��Fp1��Fp2�⼸��channel
    mu_channels = struct('C3',24-3, 'C4',22-3);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
    EI_channels = struct('F3', 29-3, 'Fz', 28-3, 'F4', 27-3);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
end
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和
seconds_per_trial = 5;

% 通信设置
ip = '127.0.0.1';
port = 8880;  % 和后端服务器连接的两个参�?
%ip = '172.18.22.21';
%port = 8880;

% 传输数据的文件夹位置设置
foldername = 'Jyt_test_0901_offline_20240901_193737949_data';
windows_per_session = 90;
classes = MotorClasses;
%% 读取待传输的原始数据
TrialData = load([foldername, '\\', 'Offline_EEGMI_RawData_Jyt_test_0901_offline', '\\', 'Offline_EEGMI_RawData_Jyt_test_0901_offline20240901_201236541.mat' ],'TrialData');

% 数据预处�?
% 划窗参数设置
rawdata = TrialData.TrialData;
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长�?
SlideWindowLength = 256;  % 滑窗间隔
[DataX, DataY, windows_per_session] = Offline_DataPreprocess_Hanning_GuidanceAdaption(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername, seconds_per_trial);

%% 读取待传输的数据
%DataX = load([foldername, '\\', 'Offline_EEGMI_Jyt_test_0513_offline', '\\', 'Offline_EEG_data_Jyt_test_0513_offline20240513_173441993.mat' ],'DataX');
%DataX = DataX.DataX;
%% 预处理数据传�?
% 设置传输的参�?
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);
