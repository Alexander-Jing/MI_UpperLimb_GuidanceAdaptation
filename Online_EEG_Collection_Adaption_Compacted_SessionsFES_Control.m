%% 初始化，关闭所有连接
pnet('closeall');
clc;
clear;
close all;
%% 启动Unity程序，并初始化
% 程序说明：发送命令共5字节
%           Byte1：画面/动作切换
%           Byte2：控制画面是否运动
%           Byte3：画面文字显示（离线训练实验无文字提示）
%           Byte4：动作类型
%           Byte5：预留
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');       % Unity动画exe文件地址
%system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
%system('E:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_AO\build_test\unity_test.exe&');
%system('E:\UpperLimb_Animation\unity_test.exe&');
%system('E:\MI_AO_Animation\UpperLimb_Animation\unity_test.exe&');

%system('E:\MI_AO_Animation\UpperLimb_Animation_modified\unity_test.exe&');

%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_Animation\unity_test.exe&');
%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_Animation_modified_DoubleThreshold\unity_test.exe&');

%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_AO_NewModel\unity_test.exe&');
system('E:\UpperLimb_AO_NewModel_MI_1\unity_test.exe&');
%system('D:\workspace\UpperLimb_AO_NewModel_MI\unity_test.exe&');

pause(3)
UnityControl = tcpip('localhost', 8881, 'NetworkRole', 'client');          % 新的端口改为8881
fopen(UnityControl);
pause(1)
sendbuf = uint8(1:5);
sendbuf(1,1) = hex2dec('00') ;
sendbuf(1,2) = hex2dec('00') ;
sendbuf(1,3) = hex2dec('00') ;
sendbuf(1,4) = hex2dec('00') ;
sendbuf(1,5) = hex2dec('00') ;
fwrite(UnityControl,sendbuf);
pause(3)

%% 设置脑电采集参数
init = 0;
freq = 256;
startStop = 1;
con = pnet('tcpconnect','127.0.0.1',4455);                                 % 建立一个连接
status = CheckNetStreamingVersion(con);                                    % 判断版本信息，正确返回状态值为1
[~, basicInfo] = ClientGetBasicMessage(con);                               % 获取设备基本信息basicInfo包含 size,eegChan,sampleRate,dataSize
[~, infoList] = ClientGetChannelMessage(con,basicInfo.eegChan);            % 获取通道信息

%% 在线实验参数设置部分，用于设置每一个被试的情况，依据被试情况进行修改

% 运动想象基本参数设置
subject_name = 'Jyt_test_0708_online_control';  % 被试姓名
sub_offline_collection_folder = 'Jyt_test_0606_offline_20240606_193249561_data';  % 被试的离线采集数据
subject_name_offline =  'Jyt_test_0606_offline';  % 离线收集数据时候的被试名称
% session 大于1时候要改动的部分
foldername_Sessions = 'Jyt_test_0708_online_20240708_215529779_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
session_idx = 2;  % session index数量，如果是1的话，会自动生成相关排布

MotorClass = 2; % 运动想象动作数量，注意这里是纯设计的运动想象动作的数量，不包括空想idle状态
%MotorClassMI = 2;  % 如果是单运动想象任务的话，那就直接指定任务就好了
original_seq = [1,1, 1,2, 0,0, 2,1, 2,2, 0,0];  % 原始序列数组
%original_seq = [1, 2, 0];  % 原始序列数组
training_seqs = 9;  % 训练轮数
trial_random = 2;  % 用于判断是否进行随机训练顺序的参数 false 0， true 1， 若设置成2的话选择固定的预先设置好的实验顺序
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
TrialNum = length(original_seq)*training_seqs;  % 每一个类别的trial的数量
if trial_random == 2
    TrialNum = length(preSet_seq);  % 如果是trial_random为2的时候，修改数值为length(preSet_seq)
end
TrialNum_session = 12;  % 一个session里面的trial数量

% 运动想象时间节点设定
MI_preFeedBack = 9;  % 运动想象提供视觉电刺激反馈的时间节点
MI_AOTime = 5;  % AO+FES的时间长度
RestTimeLenBaseline = 2;  % 休息时间（运动想象）
RestTimeLen = RestTimeLenBaseline;  % 初始化休息时间（运动想象）
Idle_preBreak = 9;  % 静息态提供休息的时间点
RestTimeLen_idleBasline = 5;  % 初始化休息时间（静息态）

% 其余指标和参数
MI_AO_Len = 200;  % 动画实际有多少帧

% 运动想象任务调整设置
score_init = 1.0;  % 这是在之前离线时候计算的mu衰减和EI指标的均值
MaxMITime = 35; % 在线运动想象最大允许时间 
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
channel_selection=0;  % 判断是否要进行通道选择，目前设置为0，保留所有数据，但是在后面服务器上可以开启选择
if channel_selection==0
    channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
    mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
    EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的
else
    channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  % 选择的通道，这里去掉了OZ，M1,M2，Fp1，Fp2这几个channel
    mu_channels = struct('C3',24-3, 'C4',22-3);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
    EI_channels = struct('F3', 29-3, 'Fz', 28-3, 'F4', 27-3);  % 用于计算EI指标的几个channels，需要确定下位置的
end
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和
MI_MUSup_thre = 0;  % 用于MI时候的阈值初始化
MI_MUSup_thre_weight_baseline = 0.714;  % 用于计算MI时候的mu衰减的阈值权重初始化数值，这个权重一般是和分类的概率相关的，也会随着相关数据进行调整
MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;  % 用于计算MI时候的mu衰减的阈值权重数值，这个权重一般是和分类的概率相关的，也会随着相关数据进行调整

Train_Thre = 0.5;  % 用于衡量后续是keep还是adjust的阈值
Train_Thre_Global_FeasibleInit = [0, 0.45, 0.45;
                                  0, 0.50, 0.50;
                                  0, 1,    2;];  % 初始数值，用于可行部分轨迹的生成
traj_Feasible = generate_traj_feasible(Train_Thre_Global_FeasibleInit, TrialNum);  % 用于生成阈值的轨迹的函数
Train_Thre_Global = Train_Thre_Global_FeasibleInit(1,1);  % 用于并且调整的针对全局均值的可行-最优策略的阈值设定

% 通信设置
ip = '172.18.22.21';
%ip = '127.0.0.1';
port = 8880;  % 和后端服务器连接的两个参数

% 电刺激强度设置
StimAmplitude_1 = 9;
StimAmplitude_2 = 9;  % 幅值设置（mA）

% %% 设置电刺激连接
% 设置连接
%system('F:\MI_engagement\fes\fes\x64\Debug\fes.exe&');
system('F:\CASIA\MI_engagement\fes\fes\x64\Debug\fes.exe&');
pause(1);
StimControl = tcpip('localhost', 8888, 'NetworkRole', 'client','Timeout',1000);
StimControl.InputBuffersize = 1000;
StimControl.OutputBuffersize = 1000;

% 设置电刺激相关参数
fopen(StimControl);
tStim = [3,14,2]; % [t_up,t_flat,t_down] * 100ms
StimCommand_1 = uint8([0,StimAmplitude_1,tStim,1]); % left calf
StimCommand_2 = uint8([0,StimAmplitude_2,tStim,2]); % left thigh

%% 准备初始的存储数据的文件夹
if session_idx==1
    foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % 指定文件夹路径和名称
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
else
    foldername=foldername_Sessions;
end
% 读取之前的离线采集的数据
foldername_Scores = [sub_offline_collection_folder, '\\Offline_EEGMI_Scores_', subject_name_offline]; % 指定之前存储的离线文件夹路径和名称
mean_std_EI_score = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_EI_score');
mean_std_muSup = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_muSup');
quartile_caculation_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_mu');
min_max_value_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_mu');
quartile_caculation_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_EI');
min_max_value_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_EI');
min_max_value_EI = min_max_value_EI.min_max_value_EI;  % 设置下max和min数值

%% 运动想象内容安排
Trials = [];  % 初始化训练的数组
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

for seq_id = 1:training_seqs
    
    temp_array = original_seq;  % 复制原始数组
    if trial_random==1
        non_zero_indices = find(temp_array);  % 找到非零元素的索引
        random_permutation = randperm(length(non_zero_indices));  % 生成非零元素的随机排列
        temp_array(non_zero_indices) = temp_array(non_zero_indices(random_permutation));  % 将原始数组中的非零元素重新排列
    end
    
    Trials = [Trials, temp_array];  % 将重新排列的数组添加到结果数组
end    

if trial_random==2
    Trials = preSet_seq;  % 直接使用预先设定好的数值
end

%% 开始实验，离线采集
Timer = 0;
TrialData = [];  % 用于原始数据的采集

% trial里面的数值存储，一下变量是trial以内的数据存储
% 关于精度/分类概率部分的指标存储
MI_Acc = [];  % 用于存储一个trial里面的所有分类概率
MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率
% 关于训练时刻的数据的存储
TrialData_Processed = [];  % 用于存储训练中的实时数据，TrialData_Processed = [TrialData_Processed; [[Data_preprocessed;Trigger],[Data_preprocessed;Trigger],...[Data_preprocessed;Trigger]]]
% 用于一些可以分析的指标的存储
mu_powers = [];  % 用于存储每一个trial里面的每一个window的mu频带的能量数值
mu_suppressions = [];  % 用于存储每一个trial里面的mu_suppression
mu_suppressions_normalized = [];  % 用于存储每一个trial里面的mu_suppressions_normalized
EI_indices = [];  % 用于存储每一个trial里面的每一个window的EI分数值
EI_index_scores = [];  % 用于存储EI_index_Caculation(EI_index, EI_channels)计算出来的EI_index_score数值
EI_index_scores_normalized = [];  % 用于存储归一化的EI_index_scores数值
resultsMI = [];  % 用于存储每一个trial里面的results
resultsMI_voting = [];  % 用于判断一个trial是否相对的voting程序
% 关于训练时刻的操作和flag的处理
Train_Flag = 0;  % 用于判断是keep还是adjust的flag
Train_Thre_Global_Flag = 0;  % 用于判断是否达到阈值的flag
Flag_FesOptim = 0;  % 用于判断是选择可行还是最优的flag 
Train_Thre_FesOpt = [];  % 用于存储规划的阈值的数组，存储方法 Train_Thre_FesOpt = [Train_Thre_FesOpt, [Train_Thre_Global_Optim; Flag_FesOptim; Trigger]];
Online_FES_ExamingNum = 5;  % 在线的时候每隔多久检查判断是否需要进行FES辅助
Online_FES_flag = 0;  % 用于设置是否进行实时FES刺激的相关控制flag

% trial之间的数据存储，以下变量是和Session有关的
if session_idx==1
    MI_Acc_Trials = [];  % 用于存储全部训练中的所有trial的分类概率，MI_Acc_Trials = [MI_Acc_Trials; [MI_Acc; Trigger]]
    MI_Acc_GlobalAvg_Trials = [];  % 用于存储全部训练中的所有trial里面的全局的平均分类概率，MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials; [MI_Acc_GlobalAvg; Trigger]]
    RestTimeLens = [];  % 用于存储休息时间长度
    Train_Performance = [];  % 用于存储每一个trial的训练表现， Train_Performance = [Train_Performance, [max(MI_Acc_GlobalAvg); Train_Thre_Global; Trigger]];
    Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;1]];
    Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;2]];  % 初始化Train_Thre_FesOpt，一开始都是选择可行
    muSups_trial = [];  % 用于存储一个trial的mu衰减
    scores_trial = [];  % 用于存储每一个trial的平均分数值
elseif session_idx > 1
    % 从之前的文件中导引出变量
    foldername_trajectory = [foldername_Sessions, '\\Online_EEGMI_trajectory_', subject_name]; % 指定文件夹路径和名称
    load([foldername_trajectory, '\\', ['Online_EEGMI_trajectory_', subject_name], '.mat'], 'scores_trial','traj_Feasible',...
    'RestTimeLens','muSups_trial', 'MI_Acc_Trials', 'MI_Acc_GlobalAvg_Trials', 'Train_Performance','Train_Thre_FesOpt');
end

while(AllTrial <= TrialNum_session)
    %% 提示专注阶段
    if Timer==0  %提示专注 cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
        if session_idx > 1
            AllTrial_Session = 12*(session_idx-1) + AllTrial;  % 如果是session大于1的情况，需要计算下实际的AllTrial的数值
        else
            AllTrial_Session = AllTrial;
        end
        if mod(AllTrial,12)==0
            %RestTimeLen_idle = 60*3;
            RestTimeLen_idle = RestTimeLen_idleBasline;
            disp(["12个trial了，休息3分钟"]);
        else
            RestTimeLen_idle = RestTimeLen_idleBasline;
        end
        if AllTrial > TrialNum_session
            break;
        end
    end
    
    %% 运动想象阶段
    % 开始想象前的准备
    if Timer==2
        if Trials(AllTrial_Session)==0  % 空想任务
            Trigger = 0;
            sendbuf(1,1) = hex2dec('03') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            sendbuf(1,8) = hex2dec('00');
            fwrite(UnityControl,sendbuf);
            % 第2s的时候，取512的Trigger==6的窗口，数据处理并且进行分析
            rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
            rawdata = rawdata(2:end,:);
            % 这里仅仅提取在MI之前的频带能量
            [preMIData_processed, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
            mu_power_ = [mu_power_; 6];
            mu_powers = [mu_powers, mu_power_];  % 添加相关的mu节律能量
            TriggerRepeat_ = repmat(6,1,512);
            TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]];
        end
        if Trials(AllTrial_Session)> 0  % 运动想象任务
            Trigger = Trials(AllTrial_Session);  % 播放动作的AO动画（Idle, MI1, MI2）
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            sendbuf(1,8) = hex2dec('00');
            fwrite(UnityControl,sendbuf);  
        
            % 第2s的时候，取512的Trigger==6的窗口，数据处理并且进行分析
            rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
            rawdata = rawdata(2:end,:);
            % 这里仅仅提取在MI之前的频带能量
            [preMIData_processed, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
            mu_power_ = [mu_power_; 6];
            mu_powers = [mu_powers, mu_power_];  % 添加相关的mu节律能量
            TriggerRepeat_ = repmat(6,1,512);
            TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]];
            
        end
    end

    if Timer == 2 && Trials(AllTrial_Session)> 0 && Timer <= MI_preFeedBack  % 开始的时候将动画置零帧的时候
       sendbuf(1,2) = hex2dec('01') ;
       sendbuf(1,3) = hex2dec('00') ;
       sendbuf(1,5) = uint8(0);
       fwrite(UnityControl,sendbuf);
    end
    
    % 开始动态想象
    % 画面变动
    if ((Timer-2) >1) && Trials(AllTrial_Session)> 0 && Timer <= MI_preFeedBack
        disp(['开始训练']);
        Trigger = Trials(AllTrial_Session);
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial_Session), sample_frequency, WindowLength, channels);
        % 计算两个指标
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        % 发送得分以及一系列数据
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0 ;0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % 传输数据给线上的模型，看分类情况
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(1+Trigger,1))]);
        
        % 收集全局的概率，用于显示
        MI_Acc = [MI_Acc, resultMI(1+Trigger,1)];
        MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
        resultsMI_voting = [resultsMI_voting, resultMI(2:end,1)];
        
        % 当达到全局阈值的时候，flag置1
        if Timer == MI_preFeedBack
            resultsMI_voting_ = mean(resultsMI_voting, 2);
            [clspro_, cls_] = max(resultsMI_voting_);
            if cls_ == (Trigger+1)  % 如果最大值对应的是trigger+1，那么就是投票结果显示分类正确
                Train_Thre_Global_Flag = 1;
                disp(['投票达到条件 MI_Acc_GlobalAvg：', num2str(clspro_)]);
            end
        end
        
        % 根据概率显示动画，用于给与实时反馈
        sendbuf(1,1) = hex2dec(mat2unity);
        sendbuf(1,2) = hex2dec('01');
        sendbuf(1,3) = hex2dec('00');
        sendbuf(1,4) = hex2dec('00');
        if size(MI_Acc_GlobalAvg,2) > 1
            % 将均值归一化到全局的阈值Train_Thre_Global范围内
            VisualFB_Rate_0 = MI_Acc_GlobalAvg(end-1)/Train_Thre_Global;
            VisualFB_Rate_1 = MI_Acc_GlobalAvg(end)/Train_Thre_Global;
            VisualFB_Rate_0 = max(0, min(1, VisualFB_Rate_0));  % 将 VisualFB_Rate_0 约束在 0 到 1 之间
            VisualFB_Rate_1 = max(0, min(1, VisualFB_Rate_1));  % 将 VisualFB_Rate_1 约束在 0 到 1 之间
            % 计算要展示的帧率
            VisualFB_0 = VisualFB_Rate_0 * MI_AO_Len;
            VisualFB_1 = VisualFB_Rate_1 * MI_AO_Len;
            disp(['feedback last:', num2str(VisualFB_0)]);
            disp(['feedback now:', num2str(VisualFB_1)]);
            % 通过插帧的方法动画播放
            if VisualFB_0 <= VisualFB_1
                Visual_list = VisualFB_0:1:VisualFB_1;
            else
                Visual_list = VisualFB_0:-1:VisualFB_1;
            end

            for i = 1:length(Visual_list)
                sendbuf(1,5) = uint8(Visual_list(i));
                fwrite(UnityControl,sendbuf);
            end
        else
            VisualFB_Rate_1 = MI_Acc_GlobalAvg(end)/Train_Thre_Global;
            VisualFB_Rate_1 = max(0, min(1, VisualFB_Rate_1));  % 将 VisualFB_Rate_1 约束在 0 到 1 之间
            VisualFB_1 = VisualFB_Rate_1 * MI_AO_Len;
            disp(['feedback now:', num2str(VisualFB_1)]);
            sendbuf(1,5) = uint8(VisualFB_1);
            fwrite(UnityControl,sendbuf);
        end
        
        % 收集这次的数据，准备后面分析
        TriggerRepeat_ = repmat(Trigger,1,512);
        TrialData_Processed = [TrialData_Processed; [FilteredDataMI;TriggerRepeat_]];
        
%         % 对于EI指标的归一化操作
%         EI_index_score_normalized = EI_normalization(EI_index_score, min_max_value_EI.min_max_value_EI);
%         mu_suppression_normalized = mu_normalization(mu_suppression, min_max_value_mu.min_max_value_mu, Trigger+1);

        % 存储这一系列指标的数值
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % 这里添加上Trigger的相关数值，方便存储
        mu_suppression = [mu_suppression; Trigger]; % 这里添加上Trigger的相关数值，方便存储
        EI_index_score = [EI_index_score; Trigger];
%         EI_index_score_normalized = [EI_index_score_normalized; Trigger];
        resultMI_ = [resultMI; Trigger];
%         mu_suppression_normalized = [mu_suppression_normalized; Trigger];

        
        resultsMI = [resultsMI, resultMI_];
        EI_index_scores = [EI_index_scores, EI_index_score];
%         EI_index_scores_normalized = [EI_index_scores_normalized, EI_index_score_normalized];
        EI_indices = [EI_indices, EI_index];  % 添加相关的EI指标数值  
        mu_powers = [mu_powers, mu_power_MI];  % 添加相关的mu节律能量
        mu_suppressions = [mu_suppressions, mu_suppression];  % 添加相关的mu衰减情况，用于后续的分析
%         mu_suppressions_normalized = [mu_suppressions_normalized, mu_suppression_normalized]; 
    end
    
   %% 静息态训练阶段
   if ((Timer-2) >1) && (Timer <=Idle_preBreak) && Trials(AllTrial_Session)==0
        Trigger = Trials(AllTrial_Session);
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial_Session), sample_frequency, WindowLength, channels);
        % 计算两个指标
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        % 发送得分以及一系列数据
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % 传输数据给线上的模型，看分类情况
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(1+Trigger,1))]);
        
        % 收集全局的概率，用于显示
        MI_Acc = [MI_Acc, resultMI(2,1)];
        MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
        resultsMI_voting = [resultsMI_voting, resultMI(2:end,1)];
        
        % 收集这次的数据，准备后面分析
        TriggerRepeat_ = repmat(Trigger,1,512);
        TrialData_Processed = [TrialData_Processed; [FilteredDataMI;TriggerRepeat_]];
        
%         % 对于EI指标的归一化操作
%         EI_index_score_normalized = EI_normalization(EI_index_score, min_max_value_EI.min_max_value_EI);
%         mu_suppression_normalized = mu_normalization(mu_suppression, min_max_value_mu.min_max_value_mu, Trigger+1);

        % 存储这一系列指标的数值
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % 这里添加上Trigger的相关数值，方便存储
        %mu_suppression = [mu_suppression; Trigger]; % 这里添加上Trigger的相关数值，方便存储
        EI_index_score = [EI_index_score; Trigger];
%         EI_index_score_normalized = [EI_index_score_normalized; Trigger];
        resultMI_ = [resultMI; Trigger];
%         mu_suppression_normalized = [mu_suppression_normalized; Trigger];

        
        resultsMI = [resultsMI, resultMI_];
        EI_index_scores = [EI_index_scores, EI_index_score];
%         EI_index_scores_normalized = [EI_index_scores_normalized, EI_index_score_normalized];
        EI_indices = [EI_indices, EI_index];  % 添加相关的EI指标数值  
        mu_powers = [mu_powers, mu_power_MI];  % 添加相关的mu节律能量
        mu_suppressions = [mu_suppressions, mu_suppression];  % 添加相关的mu衰减情况，用于后续的分析
%         mu_suppressions_normalized = [mu_suppressions_normalized, mu_suppression_normalized]; 

   end
   %% 运动想象给与反馈阶段（想对/时间范围内没有想对）,同时更新模型
   if Timer == MI_preFeedBack && Trials(AllTrial_Session) > 0
       Trigger = 8;
       if Train_Thre_Global_Flag==1  % 如果想对了，达到阈值
           if Trials(AllTrial_Session) > 0  % 运动想象任务
                % 播放动作的AO动画（Idle, MI1, MI2）
                mat2unity = ['0', num2str(Trials(AllTrial_Session) + 3)];
                sendbuf(1,1) = hex2dec(mat2unity);
                sendbuf(1,2) = hex2dec('04') ;
                sendbuf(1,3) = hex2dec('01') ;  % 给与反馈，显示文字
                sendbuf(1,4) = hex2dec('00') ;
                sendbuf(1,8) = hex2dec('00') ;
                fwrite(UnityControl,sendbuf);  
            end
            
            % 进行电刺激
            if Trials(AllTrial_Session) == 1
                StimCommand = StimCommand_1;
                fwrite(StimControl,StimCommand);
            end
            if Trials(AllTrial_Session) == 2
                StimCommand = StimCommand_2;
                fwrite(StimControl,StimCommand);
            end
            disp(['MI达到阈值电刺激']);
       else  % 如果没有想对
            if Trials(AllTrial_Session) > 0  % 运动想象任务
                % 播放动作的AO动画（Idle, MI1, MI2）
                mat2unity = ['0', num2str(Trials(AllTrial_Session) + 3)];
                sendbuf(1,1) = hex2dec(mat2unity);
                sendbuf(1,2) = hex2dec('00') ;
                sendbuf(1,3) = hex2dec('02') ;  % 给与反馈，显示文字
                sendbuf(1,4) = hex2dec('00') ;
                sendbuf(1,8) = hex2dec('00') ;
                fwrite(UnityControl,sendbuf);  
            end
       end

        % 传输数据和更新模型
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        % 重置下flag
        Train_Thre_Global_Flag = 0;
   end

   %% 休息阶段，确定下一个动作
    % 空想只给2s就休息
    if Timer==Idle_preBreak && Trials(AllTrial_Session)==0  %开始休息
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 更新算法
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        % 进入确定下一个任务
        average_score = mean(EI_index_scores(1, :));  % 这里换成EI指标，后续可能还会换
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        max_MuSup = max(mu_suppressions(1,:));  % 计算最大的Mu衰减比上阈值，衡量任务完成情况
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial_Session)]];  % 存储好完成情况
        %visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial_Session)]];  % 存储相关视觉反馈情况
        MI_Acc_Trials = [MI_Acc_Trials, [MI_Acc; repmat(Trials(AllTrial_Session),1,length(MI_Acc));]];  % 存储精度
        MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials, [MI_Acc_GlobalAvg(end); Trials(AllTrial_Session)]];

        % 静息态的数据采集不做阈值调整
        RestTimeLen_ = [2; Trials(AllTrial_Session)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    % 运动想象之后，AO和文字结束了之后让人休息
    if Trials(AllTrial_Session)>0 && Timer == (MI_preFeedBack + MI_AOTime)  %开始休息
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 进入确定下一个任务
        average_score = mean(EI_index_scores(1, :));  % 这里换成EI指标，后续可能还会换
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        max_MuSup = max(mu_suppressions(1,:));  % 计算最大的Mu衰减比上阈值，衡量任务完成情况
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial_Session)]];  % 存储好完成情况
        %visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial_Session)]];  % 存储相关视觉反馈情况
        MI_Acc_Trials = [MI_Acc_Trials, [MI_Acc; repmat(Trials(AllTrial_Session),1,length(MI_Acc));]];  % 存储精度
        MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials, [MI_Acc_GlobalAvg(end); Trials(AllTrial_Session)]];
        Train_Performance = [Train_Performance, [max(MI_Acc_GlobalAvg); Train_Thre_Global; Trials(AllTrial_Session)]];
        
        % 阈值调整部分还需要修改
        [Flag_FesOptim, Train_Thre_Global_Optim, RestTimeLen, Train_Thre_FesOpt] = TaskAdjustUpgraded_FeasibleOptimal(scores_trial, Train_Performance, Train_Thre_FesOpt, Trials, AllTrial_Session, RestTimeLenBaseline, min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial_Session)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    %% 时钟更新
    % 生成标签
    TriggerRepeat = repmat(Trigger,1,256);  % 生成标签
    % 脑电信号采集
    tic
    pause(1);
    [~, data] = ClientGetDataPacket(con,basicInfo,infoList,startStop,init); % Obtain EEG data, 需要在ClientGetDataPacket设置要不要移除基线
    toc
    data = [data;TriggerRepeat];
    TrialData = [TrialData,data];
    Timer = Timer + 1;
    disp(['时间：', num2str(Timer)]);
    
    %% 最后的各个数值复位
    % 空想任务想象18s，到第18s之后开始休息，到第20s就结束任务
    if Timer == Idle_preBreak+RestTimeLen_idle && Trials(AllTrial_Session)==0  %结束休息，准备下一个
        % 存储相关的EI指标和mu节律能量的数据
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed, resultsMI_voting);
        %计时器清0
        Timer = 0;  % 计时器清0
        % 每一个trial的数值还原
        scores = [];  % 分数值还原
        EI_indices = [];  % EI分数值还原
        mu_powers = [];  % mu频带的能量数值还原
        resultsMI = [];  % MI分类结果保存数值还原
        EI_index_scores = [];  % EI指标保存数值还原
        mu_suppressions = [];  % mu衰减保存数值还原
        mu_suppressions_normalized = [];
        visual_feedbacks = [];
        MI_MUSup_thre1s_normalized = [];
        EI_index_scores_normalized = [];
        MI_Acc = [];  % 用于存储一个trial里面的所有分类概率
        MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率
        TrialData_Processed = [];
        resultsMI_voting = [];
        
        RestTimeLen = RestTimeLenBaseline;  % 休息时间还原
        disp(['Trial: ', num2str(AllTrial_Session), ', Task: ', num2str(Trials(AllTrial_Session))]);  % 显示相关数据
    end
    % 想对了之后，AO之后，休息3s之后，结束休息，准备下一个
    if Trials(AllTrial_Session)>0 && Timer == (MI_preFeedBack + MI_AOTime + RestTimeLen)  %结束休息
        % 存储相关的EI指标和mu节律能量的数据
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed, resultsMI_voting);
        % 计时器清0
        Timer = 0;  % 计时器清0
        % 每一个trial的数值还原
        scores = [];  % 分数值还原
        EI_indices = [];  % EI分数值还原
        mu_powers = [];  % mu频带的能量数值还原
        resultsMI = [];  % MI分类结果保存数值还原
        EI_index_scores = [];  % EI指标保存数值还原
        mu_suppressions = [];  % mu衰减保存数值还原
        mu_suppressions_normalized = [];
        visual_feedbacks = [];
        MI_MUSup_thre1s_normalized = [];
        EI_index_scores_normalized = [];
        MI_Acc = [];  % 用于存储一个trial里面的所有分类概率
        MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率
        TrialData_Processed = [];
        resultsMI_voting = [];
        
        % 其余设置还原
        RestTimeLen = RestTimeLenBaseline;  % 休息时间还原
        disp(['Trial: ', num2str(AllTrial_Session), ', Task: ', num2str(Trials(AllTrial_Session))]);  % 显示相关数据
    end
end
%% 存储原始数据
close all
TrialData = TrialData(2:end,:);  %去掉矩阵第一行
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % 将连接关闭
% 存储原始数据
if session_idx==1
    foldername_rawdata = [foldername, '\\Online_EEGMI_RawData_', subject_name]; % 指定文件夹路径和名称
    if ~exist(foldername_rawdata, 'dir')
       mkdir(foldername_rawdata);
    end
    save([foldername_rawdata, '\\', ['Online_EEGMI_RawData_', 'session_', num2str(session_idx), '_', subject_name], '.mat' ],'TrialData','Trials','ChanLabel');
else
    foldername_rawdata = [foldername_Sessions, '\\Online_EEGMI_RawData_', subject_name]; % 指定文件夹路径和名称
    save([foldername_rawdata, '\\', ['Online_EEGMI_RawData_', 'session_', num2str(session_idx), '_', subject_name], '.mat' ],'TrialData','Trials','ChanLabel');
end
%% 存储轨迹追踪与调整的相关指标
if session_idx==1
    foldername_trajectory = [foldername, '\\Online_EEGMI_trajectory_', subject_name]; % 指定文件夹路径和名称
    if ~exist(foldername_trajectory, 'dir')
       mkdir(foldername_trajectory);
    end
    save([foldername_trajectory, '\\', ['Online_EEGMI_trajectory_', subject_name], '.mat'],'scores_trial','traj_Feasible',...
        'RestTimeLens','muSups_trial', 'MI_Acc_Trials', 'MI_Acc_GlobalAvg_Trials', 'Train_Performance','Train_Thre_FesOpt');
elseif session_idx > 1  % 如果session大于1的话，可以进行覆盖存储
    save([foldername_trajectory, '\\', ['Online_EEGMI_trajectory_', subject_name], '.mat'],'scores_trial','traj_Feasible',...
        'RestTimeLens','muSups_trial', 'MI_Acc_Trials', 'MI_Acc_GlobalAvg_Trials', 'Train_Performance','Train_Thre_FesOpt','-append');
end


%% 存储在运动想象过程中的参与度指标
function SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
    MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed, resultsMI_voting)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % 检验文件夹是否存在
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', ['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' ],'EI_indices','mu_powers','mu_suppressions', 'EI_index_scores','resultsMI',...
        'MI_Acc','MI_Acc_GlobalAvg','TrialData_Processed', 'resultsMI_voting');  % 存储相关的数值
end
%% 计算相关mu频带衰减指标，这里需要修改
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % 计算两个脑电位置的相关的指标 
    mu_suppresion = - ERD_C3;  % 取负值，这样的话数值越大越正ERD效应越好
end

%% 计算相关的EI指标的函数
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
    EI_index_score = mean(EI_index(channels_, 1));
end

%% 生成可行部分的轨迹函数
% Trials里面判断当前类别已经出现过多少次的函数，用于精细的轨迹生成
function count = count_trigger(Trials, AllTrial)
    % 提取 Trigger
    Trigger = Trials(AllTrial);
    
    % 计算 Trigger 在 Trials(1:AllTrial-1) 中的数量
    count = sum(Trials(1:AllTrial-1) == Trigger);
end

function traj = generate_traj_feasible(Probs_Feasible, TrialNum)
    % 获取类别的数量
    n = size(Probs_Feasible, 2);

    % 初始化一个空的 cell 数组来存储每个类别的轨迹
    traj = cell(1, n);

    % 对于每一个类别
    for i = 1:n
        % 提取起始点和重点的数值
        Prob_lower1 = Probs_Feasible(1, i);
        Prob_lower2 = Probs_Feasible(2, i);

        % 初始化一个空的数组来存储轨迹
        traj{i} = zeros(TrialNum, 1);
        
        % 计算轨迹
        for x = 1:TrialNum
            traj{i}(x) = Prob_lower1 + (Prob_lower2 - Prob_lower1) * (1 - exp(-3 * x / TrialNum));
        end
    end
end
%% 归一化显示的函数，主要用于归一化的函数显示
function mu_normalized = mu_normalization(mu_data, min_max_value_mu, Trigger)
    % 提取最大和最小数值
    data_max = min_max_value_mu(1, Trigger);
    data_min = min_max_value_mu(2, Trigger);
    % 归一化相关的数据，使得其在0到1的范围内
    mu_normalized = (mu_data - data_min)/(data_max - data_min);
end
function EI_normalized = EI_normalization(EI_data, min_max_value_EI)
    % 提取最大和最小数值
    data_max = max(min_max_value_EI(1,:));
    data_min = min(min_max_value_EI(2,:));
    % 归一化相关的数据，使得其在0到1的范围内
    EI_normalized = (EI_data - data_min)/(data_max - data_min);
end