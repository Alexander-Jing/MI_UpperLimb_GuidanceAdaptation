%% 初始化，关闭所有连接
pnet('closeall');
clc;
clear;
close all;
%% 在线实验参数设置部分，用于设置每一个被试的情况，依据被试情况进行修改
% 由于这部分是纯粹的伪在线模拟实验，所以这里不设置其余设备的连接，只设置server的连接

% 数据文件读取
subject_name_simu = 'Jyt_test_0901_online_simu';  % 被试姓名
subject_name = 'Jyt_test_0901_online';  % 被试姓名
sub_offline_collection_folder = 'Jyt_test_0901_offline_20240901_193737949_data';  % 被试的离线采集数据
subject_name_offline =  'Jyt_test_0901_offline';  % 离线收集数据时候的被试名称
foldername_Sessions = 'Jyt_test_0901_online_20240901_204911380_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
foldername_RawData = 'Online_EEGMI_RawData_Jyt_test_0901_online';  % 用于存储原始数据的文件夹

% MI脑电相关变量
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
channel_selection = 1;  % 判断是否要进行通道选择，初始值设置为0，保留所有数据，但是在后面服务器上可以开启选择
if channel_selection==0
    channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
    mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
    EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的
else
    channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  % 选择的通道，这里去掉了OZ，M1,M2，Fp1，Fp2这几个channel
    mu_channels = struct('C3',24-3, 'C4',22-3);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
    EI_channels = struct('F3', 29-3, 'Fz', 28-3, 'F4', 27-3);  % 用于计算EI指标的几个channels，需要确定下位置的
end

% 模拟实验存储的变量
MI_Acc = [];  % 用于存储一个trial里面的所有分类概率，在一个trial里面会存储，数据格式 MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)]; 一个trial结束之后 MI_Acc = [];
MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率，在一个trial里面会存储，数据格式 MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)]; 一个trial结束之后 MI_Acc_GlobalAvg = [];
resultsMI = [];  % 用于存储每一个trial里面的results，在一个trial里面存储，存储格式 resultMI_ = [resultMI; Trigger]; resultsMI = [resultsMI, resultMI_]; 一个trial结束之后 resultsMI = [];
TrialData_Processed = [];  % 用于存储训练中的实时数据，在一个trial里面会存储， 存储格式 TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]]; 一个trial结束之后 TrialData_Processed = [];

% 预先设定好的实验程序，trial_random = 2的时候启动
preSet_seq = [1, 2, 1, 2, 0, 0, 2, 2, 1, 1, 0, 0, ...
              2, 1, 1, 2, 0, 0, 1, 2, 2, 1, 0, 0, ...
              2, 2, 2, 1, 0, 0, 1, 2, 1, 1, 0, 0, ...
              2, 1, 2, 1, 0, 0, 2, 2, 1, 1, 0, 0, ...
              1, 1, 1, 2, 0, 0, 2, 2, 1, 2, 0, 0, ...
              2, 1, 1, 2, 0, 0, 2, 1, 1, 2, 0, 0, ...
              1, 2, 2, 2, 0, 0, 2, 1, 1, 1, 0, 0, ...
              2, 2, 1, 1, 0, 0, 1, 2, 2, 1, 0, 0, ...
              2, 1, 1, 2, 0, 0, 2, 1, 1, 2, 0, 0, ...
              1, 2, 2, 2, 0, 0, 2, 1, 1, 1, 0, 0,]; 
Trials = preSet_seq;

% 服务器通信设置
%ip = '172.18.22.21';
ip = '127.0.0.1';
port = 8880;  % 和后端服务器连接的两个参数

%% 准备初始的存储数据的文件夹
foldername = ['.\\', FunctionNowFilename([subject_name_simu, '_'], '_SimuData')]; % 指定文件夹路径和名称
if ~exist(foldername, 'dir')
   mkdir(foldername);
end
for session_idx=8:8
    % session级别的数据采集
    disp(["session: ", num2str(session_idx)]);
    session_rawdata = RawDataTrial(session_idx, subject_name, foldername_Sessions, foldername_RawData);
    for trial_idx=1:12
        % trial级别的数据采集
        trial_rawdata = session_rawdata(:, (trial_idx-1)*10*256+1:(trial_idx)*10*256);
        % 确定下总的trial_idx
        if session_idx > 1
            AllTrial_Session = 12*(session_idx-1) + trial_idx;  % 如果是session大于1的情况，需要计算下实际的AllTrial的数值
        else
            AllTrial_Session = trial_idx;
        end
        disp(["trial: ", num2str(AllTrial_Session)]);
        for window_idx=1:9
            % 采集每一个window的数据
            window_rawdata = trial_rawdata(:, 256*(window_idx-1)+1:256*(window_idx-1)+512);
            Trigger = window_rawdata(end,1);
            assert(Trigger==Trials(AllTrial_Session), "Trigger 和 Trials 排布必须是相同的");
            [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(window_rawdata, Trials(AllTrial_Session), sample_frequency, WindowLength, channels);
            % 发送得分以及一系列数据
            config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0 ;0;0;0;0 ];
            order = 1.0;
            resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name_simu, config_data, foldername);  % 传输数据给线上的模型，看分类情况
            % resultMI的数据结构是[预测的类别; 三个类别分别的softmax概率; 实际的类别]
            disp(['predict cls: ', num2str(resultMI(1,1))]);
            disp(['cls prob: ', num2str(resultMI(1+(1+Trigger),1))]);  % 注意这个对应的关系，这里应该是Trigger+2才能对应上概率
            disp(['probs: ', num2str(resultMI(2,1)), ', ', num2str(resultMI(3,1)), ',', num2str(resultMI(4,1))]);
            disp(['Trigger: ', num2str(Trigger)]);
            
            pause(1);  % 暂停1s
            % 收集全局的概率，用于显示
            MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)];
            MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
            resultMI_ = [resultMI; Trigger];
            resultsMI = [resultsMI, resultMI_];
            % 收集这次的数据，准备后面分析
            TriggerRepeat_ = repmat(Trigger,1,512);
            TrialData_Processed = [TrialData_Processed; [FilteredDataMI;TriggerRepeat_]];
        end
        % 一个trial结束之后的操作
        % 传输数据和更新模型
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name_simu, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        pause(5.0);
        SaveMIEngageTrials(subject_name_simu, foldername, config_data, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed);
        resultsMI = [];  % MI分类结果保存数值还原
        MI_Acc = [];  % 用于存储一个trial里面的所有分类概率
        MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率
        TrialData_Processed = [];
    end
end


%% 准备每一个session每一个trial的rawdata的函数
% 输入：session编号 session_idx，被试姓名 subject_name，数据存储文件夹foldername_Sessions，rawdata数据存储子文件夹foldername_RawData
% 输出：session_rawdata: 准备好的session的每一个trial的原始数据，数据格式33(32 channel + 1 trigger) * (10 * 256 * 12)
function session_rawdata = RawDataTrial(session_idx, subject_name, foldername_Sessions, foldername_RawData)
    load(fullfile(foldername_Sessions, foldername_RawData, ['Online_EEGMI_RawData_session_', num2str(session_idx), '_', subject_name, '.mat']));
    rawdata_session = TrialData;
    % 提取trigger
    trigger = rawdata_session(end, :);
    % 只提取MI相关的trigger的数据
    valid_columns = find(trigger == 0 | trigger == 1 | trigger == 2);
    % 提取数据
    session_rawdata = rawdata_session(:, valid_columns);
end

%% 存储在运动想象过程中的参与度指标
function SaveMIEngageTrials(subject_name, foldername, config_data, resultsMI, ...
    MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % 检验文件夹是否存在
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', ['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' ],'resultsMI',...
        'MI_Acc','MI_Acc_GlobalAvg','TrialData_Processed');  % 存储相关的数值
end
