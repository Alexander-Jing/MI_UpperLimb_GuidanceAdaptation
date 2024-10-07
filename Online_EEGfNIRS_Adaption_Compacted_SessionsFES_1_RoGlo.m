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
%system('E:\UpperLimb_AO_NewModel_MI_1\unity_test.exe&');

%system('E:\UpperLimb_AO_NewModel_MI_ReachGrasp_2\unity_test.exe&');
%system('D:\workspace\UpperLimb_AO_NewModel_MI\unity_test.exe&');

system('D:\workspace\UpperLimb_AO_NewModel_MI_ReachGrasp_2\unity_test.exe&');

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
subject_name = 'Nkc_online';  % 被试姓名
sub_offline_collection_folder = 'Nkc_offline_20241007_161904206_data';  % 被试的离线采集数据
subject_name_offline =  'Nkc_offline';  % 离线收集数据时候的被试名称
% session 大于1时候要改动的部分
% 注意，由于设备问题，建议在session_idx为4之前重启下matlab，防止出现后面的中断
session_idx = 10;  % session index数量，如果是1的话，会自动生成相关排布
foldername_Sessions = 'Nkc_online_20241007_170347400_data';  % 当session大于1的时候，需要手工修正foldername_Sessions

fNIRS_Use = 1;  % 是否使用fNIRs设备，设置为1是使用，否则就不用
MotorClass = 2; % 运动想象动作数量，注意这里是纯设计的运动想象动作的数量，不包括空想idle状态
%MotorClassMI = 2;  % 如果是单运动想象任务的话，那就直接指定任务就好了
original_seq = [1,1, 1,2, 0,0, 2,1, 2,2, 0,0];  % 原始序列数组
%original_seq = [1, 2, 0];  % 原始序列数组
training_seqs = 9;  % 训练轮数
trial_random = 2;  % 用于判断是否进行随机训练顺序的参数 false 0， true 1， 若设置成2的话选择固定的预先设置好的实验顺序
% 预先设定好的实验程序，trial_random = 2的时候启动
preSet_seq = [1, 2, 1, 2, 0, 0, 2, 2, 1, 1, 0, 0, ...
              2, 1, 1, 2, 0, 0, 1, 2, 2, 1, 0, 0, ...
              2, 2, 2, 1, 0, 0, 1, 2, 1, 1, 0, 0, ...
              2, 1, 2, 1, 0, 0, 2, 2, 1, 1, 0, 0, ...
              1, 1, 1, 2, 0, 0, 2, 2, 1, 2, 0, 0, ...
              2, 1, 1, 2, 0, 0, 2, 1, 1, 2, 0, 0, ...
              1, 2, 2, 2, 0, 0, 2, 1, 1, 1, 0, 0, ...
              2, 2, 1, 1, 0, 0, 1, 2, 2, 1, 0, 0, ...
              1, 2, 2, 2, 0, 0, 2, 1, 1, 1, 0, 0, ...
              2, 2, 1, 1, 0, 0, 1, 2, 2, 1, 0, 0, ...
              2, 1, 1, 2, 0, 0, 2, 1, 1, 2, 0, 0,
              ]; 
TrialNum = length(original_seq)*training_seqs;  % 每一个类别的trial的数量
if trial_random == 2
    TrialNum = length(preSet_seq);  % 如果是trial_random为2的时候，修改数值为length(preSet_seq)
end
TrialNum_session = 12;  % 一个session里面的trial数量

% 运动想象时间节点设定
MI_preFeedBack = 12;  % 运动想象提供视觉电刺激反馈的时间节点
MI_AOTime = 5;  % AO+FES的时间长度
RestTimeLenBaseline = 2;  % 休息时间（运动想象）
RestTimeLen = RestTimeLenBaseline;  % 初始化休息时间（运动想象）
Idle_preBreak = 12;  % 静息态提供休息的时间点
RestTimeLen_idleBasline = 5;  % 初始化休息时间（静息态）
MI_AOTime_Moving = 3;  % 初始化机械臂当前MI反馈的时长
MI_AOTime_Preparing = 2;  % 初始化机械臂准备下一个MI的反馈的时长

% 其余指标和参数
MI_AO_Len = 200;  % 动画实际有多少帧

% 运动想象任务调整设置
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
EEG_Cap = 1;  % 判断使用的脑电帽子设备，0为原来的老帽子(Jyt-20240824-GraelEEG.xml)，1为新的帽子(Jyt-20240918-GraelEEG.xml)
channel_selection=1; % 判断是否要进行通道选择，目前设置为0，保留所有数据，但是在后面服务器上可以开启选择
if EEG_Cap==0  % 选择老的帽子(Jyt-20240824-GraelEEG.xml)
    if channel_selection==0
        channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
        mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
        EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的
    else
        channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  % 选择的通道，这里去掉了OZ，M1,M2，Fp1，Fp2这几个channel
        mu_channels = struct('C3',24-3, 'C4',22-3);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
        EI_channels = struct('F3', 29-3, 'Fz', 28-3, 'F4', 27-3);  % 用于计算EI指标的几个channels，需要确定下位置的
    end 
elseif EEG_Cap==1  % 选择新的帽子(Jyt-20240918-GraelEEG.xml)
    if channel_selection==0
        channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
        mu_channels = struct('C3',17, 'C4',15);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
        EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 29, 'F3', 28, 'Fz', 27, 'F4', 26, 'F8', 25);  % 用于计算EI指标的几个channels，需要确定下位置的
    else
        channels = [1, 3,4,5,6,7,8, 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30];  % 选择的通道，这里去掉了OZ，M1,M2，Fp1，Fp2这几个channel
        mu_channels = struct('C3',17-3, 'C4',15-3);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
        EI_channels = struct('F3', 28-3, 'Fz', 27-3, 'F4', 26-3);  % 用于计算EI指标的几个channels，需要确定下位置的
    end 
end

Train_Thre = 0.5;  % 用于衡量后续是keep还是adjust的阈值
Train_Thre_Global_FeasibleInit = [0, 0.36, 0.36;
                                  0, 0.41, 0.41;
                                  0, 1,    2;];  % 初始数值，用于可行部分轨迹的生成，这部分需要根据实际的被试表现来说明
traj_Feasible = generate_traj_feasible(Train_Thre_Global_FeasibleInit, TrialNum);  % 用于生成阈值的轨迹的函数
Train_Thre_Global = Train_Thre_Global_FeasibleInit(1,1);  % 全局阈值Train_Thre_Global，用于并且调整的针对全局均值的可行-最优策略的阈值设定

% 服务器通信设置
%ip = '172.18.22.21';
ip = '127.0.0.1';
port = 8880;  % 和后端服务器连接的两个参数

% 机械臂通信设置
RobotControl = tcpip('localhost', 5288, 'NetworkRole','client');
fopen(RobotControl);
% 气动手套通信设置
GloveControl = tcpip("192.168.2.30", 8003, 'NetworkRole','client');
fopen(GloveControl);  % 气动手套初始化，先放松
sendbuf_glo = uint8(1:2);
sendbuf_glo(1,1) = hex2dec('ff') ;
sendbuf_glo(1,2) = hex2dec('ff') ;
fwrite(GloveControl, sendbuf_glo);


% 电刺激强度设置
StimAmplitude_1 = 7;  % MI1 肩关节的电刺激幅值测试（mA）
StimAmplitude_2 = 6;  % MI2 手部分的幅值设置（mA）

% %% 设置电刺激连接
% 设置连接
%system('F:\MI_engagement\fes\fes\x64\Debug\fes.exe&');
%system('F:\CASIA\MI_engagement\fes\fes\x64\Debug\fes.exe&');
system('D:\workspace\fes\x64\Release\fes.exe&');
pause(1);
StimControl = tcpip('localhost', 8888, 'NetworkRole', 'client','Timeout',1000);
StimControl.InputBuffersize = 1000;
StimControl.OutputBuffersize = 1000;

% 设置电刺激相关参数
fopen(StimControl);
tStim = [3,14,2]; % [t_up,t_flat,t_down] * 100ms
StimCommand_1 = uint8([0,StimAmplitude_1,tStim,1]); % left calf
StimCommand_2 = uint8([0,StimAmplitude_2,tStim,2]); % left thigh

% 设置近红外
if fNIRS_Use==1
    oxy = actxserver('oxysoft.oxyapplication');  % 连接近红外
    disp(['Connected to Oxy Version: ', oxy.strVersion]);
end

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
% 原始数据存储
TrialData = [];  % 用于原始数据的采集，1个session结束之后会存储，数据格式 data = [data;TriggerRepeat]; TrialData = [TrialData,data];

% trial里面的数值存储，以下变量是trial以内的数据存储
% 关于精度/分类概率部分的指标存储
MI_Acc = [];  % 用于存储一个trial里面的所有分类概率，在一个trial里面会存储，数据格式 MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)]; 一个trial结束之后 MI_Acc = [];
MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率，在一个trial里面会存储，数据格式 MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)]; 一个trial结束之后 MI_Acc_GlobalAvg = [];
resultsMI_voting = [];  % 用于存储投票的结果，在一个trial里面会存储，数据格式 resultsMI_voting = [resultsMI_voting, resultMI(2:end,1)]; 一个trial结束之后 resultsMI_voting = [];

% 关于训练时刻的数据的存储
TrialData_Processed = [];  % 用于存储训练中的实时数据，在一个trial里面会存储， 存储格式 TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]]; 一个trial结束之后 TrialData_Processed = [];
% 用于一些可以分析的指标的存储
mu_powers = [];  % 用于存储每一个trial里面的每一个window的mu频带的能量数值，在一个trial里面存储，存储格式mu_power_MI = [mu_power_MI; Trigger]; mu_powers = [mu_powers, mu_power_MI]; 一个trial结束之后 mu_powers = []; 
mu_suppressions = [];  % 用于存储每一个trial里面的mu_suppression，在一个trial里面存储，存储格式mu_suppression = [mu_suppression; Trigger]; mu_suppressions = [mu_suppressions, mu_suppression]; 一个trial结束之后 mu_suppressions = [];
mu_suppressions_normalized = [];  % 用于存储每一个trial里面的mu_suppressions_normalized，该变量暂时不用
EI_indices = [];  % 用于存储每一个trial里面的每一个window的EI分数值，在一个trial里面存储，存储格式 EI_index = [EI_index; Trigger]; EI_indices = [EI_indices, EI_index]; 一个trial结束之后 EI_indices = [];
EI_index_scores = [];  % 用于存储EI_index_Caculation(EI_index, EI_channels)计算出来的EI_index_score数值，存储格式 EI_index_score = [EI_index_score; Trigger]; EI_index_scores = [EI_index_scores, EI_index_score]; 一个trial结束之后 EI_index_scores = [];
EI_index_scores_normalized = [];  % 用于存储归一化的EI_index_scores数值，该变量暂时不用
resultsMI = [];  % 用于存储每一个trial里面的results，在一个trial里面存储，存储格式 resultMI_ = [resultMI; Trigger]; resultsMI = [resultsMI, resultMI_]; 一个trial结束之后 resultsMI = [];

% 关于训练时刻的操作和flag的处理
Train_Thre_Global_Flag = 0;  % 用于判断是否达到阈值的flag，达到置1，否则置0，在一个trial结束之后置0
Flag_FesOptim = 0;  % 用于判断是选择可行还是最优的flag，在每一个trial之前设定

% trial之间的数据存储，以下变量是和Session有关的，将在一个session结束之后进行存储
if session_idx==1
    Train_Thre_FesOpt = [];  % 用于存储规划的阈值的数组，存储方式 Train_Thre_FesOpt = [Train_Thre_FesOpt, [Train_Thre_Global_Optim; Flag_FesOptim; Trigger]]; 由TaskAdjustUpgraded_FeasibleOptimal_1函数进行更新
    MI_Acc_Trials = [];  % 用于存储全部训练中的所有trial的分类概率，MI_Acc_Trials = [MI_Acc_Trials; [MI_Acc; Trigger]]
    MI_Acc_GlobalAvg_Trials = [];  % 用于存储全部训练中的所有trial里面的全局的平均分类概率，MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials; [MI_Acc_GlobalAvg(end); Trigger]]
    RestTimeLens = [];  % 用于存储休息时间长度
    Train_Performance = [];  % 用于存储每一个trial的训练表现， 存储方式 Train_Performance = [Train_Performance, [MI_Acc_GlobalAvg(end); Train_Thre_Global; Trigger]];
    Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;1]];
    Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;2]];  % 初始化Train_Thre_FesOpt，一开始都是选择可行
    muSups_trial = [];  % 用于存储一个trial的mu衰减，存储方式 muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial_Session)]];
    scores_trial = [];  % 用于存储每一个trial的平均分数值，存储方式 scores_trial = [scores_trial, average_score];
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
            
            % 对于阈值的判定
            % 先计算可行的阈值
            Trigger_num_ = count_trigger(Trials, AllTrial_Session);  % 这里用于计算在AllTrial对应的Trigger之前已经出现了多少次，从而计算轨迹
            Train_Thre_Global_Fes = traj_Feasible{Trigger+1}(Trigger_num_+1);  % 计算可行的阈值
            % 读取这一类别上一次的判断是可行还是最优
            Trial_tasks = Train_Thre_FesOpt(3,:);
            Train_Thre_FesOpt_ = Train_Thre_FesOpt(:, Trial_tasks==Trials(AllTrial_Session));
            Flag_FesOptim = Train_Thre_FesOpt_(2, end);  % 提取上一次的类别的对应的可行/最优的flag判断
            Train_Thre_Global_Optim = Train_Thre_FesOpt_(1, end);  % 提取上一次的类别的对应的最优的数值，如果对应的判断是选择最优的话
            % 根据TaskAdjustUpgraded_FeasibleOptimal来判定是选择可行还是最优
            if Flag_FesOptim == 0
                Train_Thre_Global = Train_Thre_Global_Fes;  % 选择可行 
                disp(['根据上一轮情况，这一轮选择可行']);
            else
                Train_Thre_Global = Train_Thre_Global_Optim;  % 选择最优
                if Train_Thre_Global < Train_Thre_Global_Fes
                    Train_Thre_Global = Train_Thre_Global_Fes;  % 如果出现小于可行解的现象，那就使用可行解
                end
                disp(['根据上一轮情况，这一轮选择最优']);
            end
        end
        if fNIRS_Use==1
            % 近红外打标签
            oxy.WriteEvent('P', 'Prepare');
            disp('近红外标签 P');
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
        % resultMI的数据结构是[预测的类别; 三个类别分别的softmax概率; 实际的类别]
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(1+(1+Trigger),1))]);  % 注意这个对应的关系，这里应该是Trigger+2才能对应上概率
        disp(['probs: ', num2str(resultMI(2,1)), ', ', num2str(resultMI(3,1)), ',', num2str(resultMI(4,1))]);
        disp(['Trigger: ', num2str(Trigger)]);
        
        % 收集全局的概率，用于显示
        MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)];  
        MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
        resultsMI_voting = [resultsMI_voting, resultMI(2:end,1)];
        
        % 当达到全局阈值的时候，flag置1
        if Timer == MI_preFeedBack
            if fNIRS_Use==1
                % 近红外数据记录
                FnirsLabelTask(Trials, AllTrial_Session, oxy);
            end

            if Flag_FesOptim == 1
                % 最优模式下满足最优值或者投票数值都可以触发反馈
                resultsMI_voting_ = mean(resultsMI_voting, 2);
                [clspro_, cls_] = max(resultsMI_voting_);
                if cls_ == (Trigger+1)  % 如果最大值对应的是trigger+1，那么就是投票结果显示分类正确
                    Train_Thre_Global_Flag = 1;
                    disp(['投票达到条件 MI_Acc_GlobalAvg：', num2str(clspro_)]);
                end
                % 阈值达到最优解
                if MI_Acc_GlobalAvg(end) > Train_Thre_Global
                    Train_Thre_Global_Flag = 1;
                    disp(['阈值达到最优情况下条件 MI_Acc_GlobalAvg：', num2str(MI_Acc_GlobalAvg(end)), ', Train_Thre_Global: ',num2str(Train_Thre_Global)]);
                end
            elseif Flag_FesOptim == 0
                % 可行模式下，满足可行值或者投票值都可以触发反馈
                resultsMI_voting_ = mean(resultsMI_voting, 2);
                [clspro_, cls_] = max(resultsMI_voting_);
                if cls_ == (Trigger+1)  % 如果最大值对应的是trigger+1，那么就是投票结果显示分类正确
                    Train_Thre_Global_Flag = 1;
                    disp(['投票达到条件 MI_Acc_GlobalAvg：', num2str(clspro_)]);
                end
                % 阈值达到可行解
                if MI_Acc_GlobalAvg(end) > Train_Thre_Global
                    Train_Thre_Global_Flag = 1;
                    disp(['阈值达到可行情况下条件 MI_Acc_GlobalAvg：', num2str(MI_Acc_GlobalAvg(end)), ', Train_Thre_Global: ',num2str(Train_Thre_Global)]);
                end
            end
        end
        
        % 根据概率显示动画，用于给与实时反馈
        sendbuf(1,1) = hex2dec(mat2unity);
        sendbuf(1,2) = hex2dec('01');
        sendbuf(1,3) = hex2dec('00');
        sendbuf(1,4) = hex2dec('00');
        if Trigger==2
            MI_AO_Len = 150;
        else
            MI_AO_Len = 200;
        end

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
        disp(['cls prob: ', num2str(resultMI(1+(1+Trigger),1))]); % 注意这个对应的关系，这里应该是Trigger+2才能对应上概率
        disp(['probs: ', num2str(resultMI(2,1)), ', ', num2str(resultMI(3,1)), ',', num2str(resultMI(4,1))]);
        disp(['Trigger: ', num2str(Trigger)]);
        
        % 收集全局的概率，用于显示
        MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)];
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
        
        if fNIRS_Use==1
            if Timer==Idle_preBreak
                % 近红外数据记录
                FnirsLabelTask(Trials, AllTrial_Session, oxy);
            end
        end
   end
   %% 运动想象给与反馈阶段（想对/时间范围内没有想对）,同时更新模型
   if Timer == MI_preFeedBack && Trials(AllTrial_Session) > 0
       Trigger = 8;
       if Train_Thre_Global_Flag==1  % 如果想对了，达到阈值
           if Trials(AllTrial_Session) > 0  % 运动想象任务
                % 播放动作的AO动画（Idle, MI1, MI2）
                mat2unity = ['0', num2str(Trials(AllTrial_Session) + 3)];
                sendbuf(1,1) = hex2dec(mat2unity);
                sendbuf(1,2) = hex2dec('04') ;  % 0x04: 4倍速播放, 0x02: 2倍速播放, 0x01: 1倍速播放, 指定播放帧 
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
       % 确定机械臂的辅助
       [MI_AOTime_Moving, MI_AOTime_Preparing, MovingCommand, PreparingCommand, MovingCommand_glo, PreparingCommand_glo] = RobotCommand(Train_Thre_Global_Flag, Trials(AllTrial_Session), Trials(AllTrial_Session+1));
       % 当前的机械臂助力，直接在MI结束之后进行助力
       textSend = MovingCommand;
       fwrite(RobotControl, textSend);
       % 当前的气动手的助力
       if strcmp(MovingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(MovingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['任务完成: ', num2str(Train_Thre_Global_Flag)]);
       disp(['当前任务机械臂移动时间：', num2str(MI_AOTime_Moving), '; ', '当前指令： ', MovingCommand, ', ', MovingCommand_glo]);
       disp(['下一任务机械臂准备时间：', num2str(MI_AOTime_Preparing), '; ', '下一任务指令： ', PreparingCommand, ', ', PreparingCommand_glo]);

       % 传输数据和更新模型
       config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
       order = 2.0;  % 传输数据和训练的命令
       Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        
       % 重置下flag，不管上面的识别情况如何都是要置0的
       Train_Thre_Global_Flag = 0;
   end
   
   % 机械臂在提供结束当前任务的助力之后，会运行到下一动作的助力部分
   % 当前是MI任务的时候，结束助力之后，会运行到下一个动作的准备部分，MI_preFeedBack+MI_AOTime_Moving是直接启动运行到下一个MI任务的位置的时间点
   if Timer == MI_preFeedBack+MI_AOTime_Moving && Trials(AllTrial_Session) > 0
       % 为下一任务的机械臂助力提前做好准备
       textSend = PreparingCommand;
       fwrite(RobotControl, textSend);
       % 当前的气动手的助力
       if strcmp(PreparingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(PreparingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['当前任务: ', num2str(Trials(AllTrial_Session)), "下一任务: ", num2str(Trials(AllTrial_Session+1)), "机械臂为下一任务启动"]);
   end

   %% 休息阶段，确定下一个动作
    % 空想只给5s就休息
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
        RestTimeLen_ = [RestTimeLen_idle; Trials(AllTrial_Session)];  % 静息态休息5s
        RestTimeLens = [RestTimeLens, RestTimeLen_];

        % 确定机械臂的辅助
       [MI_AOTime_Moving, MI_AOTime_Preparing, MovingCommand, PreparingCommand, MovingCommand_glo, PreparingCommand_glo] = RobotCommand(Train_Thre_Global_Flag, Trials(AllTrial_Session), Trials(AllTrial_Session+1));
       % 当前的机械臂助力，在静息态的时候，这部分直接就是不动的
       textSend = MovingCommand;
       fwrite(RobotControl, textSend);
       % 当前的气动手的助力
       if strcmp(MovingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(MovingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['当前任务机械臂移动时间：', num2str(MI_AOTime_Moving), '; ', '当前指令： ', MovingCommand, ', ', MovingCommand_glo]);
       disp(['下一任务机械臂准备时间：', num2str(MI_AOTime_Preparing), '; ', '下一任务指令： ', PreparingCommand, ', ', PreparingCommand_glo]);
    end
    
    % 机械臂在提供结束当前任务的助力之后，会运行到下一动作的助力部分
    % 在静息态的时候，直接准备运行到下一个MI任务的位置，MI_preFeedBack+MI_AOTime_Moving是直接启动运行到下一个MI任务的位置的时间点
    if Timer == Idle_preBreak+MI_AOTime_Moving && Trials(AllTrial_Session)==0
       % 为下一任务的机械臂助力提前做好准备
       textSend = PreparingCommand;
       fwrite(RobotControl, textSend);
       % 当前的气动手的助力
       if strcmp(PreparingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(PreparingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['当前任务: ', num2str(Trials(AllTrial_Session)), "下一任务: ", num2str(Trials(AllTrial_Session+1)), "机械臂为下一任务启动"]);
    end
    

    % 运动想象之后，AO和文字结束了之后让人休息
    if Trials(AllTrial_Session)>0 && Timer == (MI_preFeedBack+MI_AOTime_Moving+MI_AOTime_Preparing)   %开始休息
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
        Train_Performance = [Train_Performance, [MI_Acc_GlobalAvg(end); Train_Thre_Global; Trials(AllTrial_Session)]];
        
        % 阈值调整部分还需要修改
        [Flag_FesOptim, Train_Thre_Global_Optim, RestTimeLen, Train_Thre_FesOpt] = TaskAdjustUpgraded_FeasibleOptimal_1(scores_trial, Train_Performance, Train_Thre_FesOpt, Trials, AllTrial_Session, RestTimeLenBaseline, min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial_Session)];  % MI任务会动态调整休息的时间
        RestTimeLens = [RestTimeLens, RestTimeLen_];

        if fNIRS_Use==1
            % 近红外数据记录
            oxy.WriteEvent('M', 'Moving');
            disp('近红外标签 M');
        end
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
    % 空想任务想象12s，到第12s之后开始休息，到第17s就结束任务
    if Timer == Idle_preBreak+MI_AOTime_Moving+MI_AOTime_Preparing && Trials(AllTrial_Session)==0  %结束休息，准备下一个
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
        EI_index_scores_normalized = [];
        MI_Acc = [];  % 用于存储一个trial里面的所有分类概率
        MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率
        TrialData_Processed = [];
        resultsMI_voting = [];
        
        RestTimeLen = RestTimeLenBaseline;  % 休息时间还原
        disp(['Trial: ', num2str(AllTrial_Session), ', Task: ', num2str(Trials(AllTrial_Session))]);  % 显示相关数据
        if fNIRS_Use==1
            % 近红外数据记录
            oxy.WriteEvent('R', 'Resting');
            disp('近红外标签 R');
        end
    end
    % 想对了之后，AO之后，休息3s之后，结束休息，准备下一个
    if Trials(AllTrial_Session)>0 && Timer == (MI_preFeedBack+MI_AOTime_Moving+MI_AOTime_Preparing + RestTimeLen)  %结束休息
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
        EI_index_scores_normalized = [];
        MI_Acc = [];  % 用于存储一个trial里面的所有分类概率
        MI_Acc_GlobalAvg = [];  % 用于存储一个trial里面的全局的平均分类概率
        TrialData_Processed = [];
        resultsMI_voting = [];
        
        % 其余设置还原
        RestTimeLen = RestTimeLenBaseline;  % 休息时间还原
        disp(['Trial: ', num2str(AllTrial_Session), ', Task: ', num2str(Trials(AllTrial_Session))]);  % 显示相关数据
        if fNIRS_Use==1
            % 近红外数据记录
            oxy.WriteEvent('R', 'Resting');
            disp('近红外标签 R');
        end
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
%% 存储轨迹追踪与调整的相关指标，这部分在一个session结束之后才会存储，防止一个session里面中断导致的多存储
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

%% 弹窗提示相关操作
% 创建消息内容
message = ['当前是session: ', num2str(session_idx), ', 注意重启单片机和重新连接机械臂'];
% 显示弹窗
h = msgbox(message, 'Session Alert');

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
    channels_ = [EI_channels.F3, EI_channels.Fz, EI_channels.F4];
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

%% 控制机械臂和气动手的函数，用于控制实际动作执行部分的机械臂和气动手部分的工作
% 输入部分为: Train_Thre_Global_Flag 当前的MI执行完成情况，
% Trials(AllTrial_Session)，Trials(AllTrial_Session+1)
% 当前以及后续的运动任务，用于操作机械臂移动的位置
% 输出部分为：MI_AOTime_Moving 准备下一步动作的时间，MI_AOTime_Preparing 下一步动作完成之后，准备休息的时间
% MovingCommand 机械臂完成动作之后移动的命令 PreparingCommand 机械臂准备下一步动作的指令
% MovingCommand_glo 气动手完成动作之后移动的命令 PreparingCommand_glo 气动手准备下一步动作的指令
function [MI_AOTime_Moving, MI_AOTime_Preparing, MovingCommand, PreparingCommand, MovingCommand_glo, PreparingCommand_glo] = RobotCommand(Train_Thre_Global_Flag, Task_now, Task_next)
    % 考虑第一种情况，也就是MI的时候，通过当前的MI结果以及后续的实际情况来进行研究
    if Task_now > 0
        % 没有想对的情况下，直接进入后续的准备中
        if Train_Thre_Global_Flag==0
            MI_AOTime_Moving=2;  % 隔着2s之后就进行准备后面MI的机械臂移动
            MI_AOTime_Preparing=3;  % 准备后面MI的机械臂移动3s之后就直接进入休息，这样的话整个AO+FES+Robot的时间还是5s
            MovingCommand='Y0';  % 此时Y0不移动机械臂
            MovingCommand_glo='G3';  % 此时气动手放松状态
            % 准备后面MI的机械臂移动
            if Task_next==0 || Task_next==1
                PreparingCommand='Y3';
                PreparingCommand_glo='G3';  % 此时气动手放松状态
            end
            if Task_next==2
                PreparingCommand='Y4';
                PreparingCommand_glo='G3';  % 此时气动手放松状态
            end
        end
        if Train_Thre_Global_Flag==1
            % 此时由于已经想对，需要进行
            if Task_now==1
                MI_AOTime_Moving=4;  % 当前需要根据实际的想象任务移动机械臂，隔着4s之后就进行准备后面MI的机械臂移动
                MovingCommand='Y1';
                MovingCommand_glo='G3';  % 此时气动手放松状态
            end
            if Task_now==2
                MI_AOTime_Moving=8;  % 当前需要根据实际的想象任务移动机械臂，隔着8s之后就进行准备后面MI的机械臂移动
                MovingCommand='Y2';
                MovingCommand_glo='G2';  % 此时气动手握拳
            end
            MI_AOTime_Preparing=3;  % 准备后面MI的机械臂移动3s之后就直接进入休息，这样的话整个AO+FES+Robot的时间是MI_AOTime_Moving+MI_AOTime_Preparing
            if Task_next==0 || Task_next==1
                PreparingCommand='Y3';
                PreparingCommand_glo='G3';  % 此时气动手放松状态
            end
            if Task_next==2
                PreparingCommand='Y4';
                PreparingCommand_glo='G3';  % 此时气动手放松状态
            end
        end
    end
    if Task_now == 0
        % 当想象运动是静息态的时候
        MI_AOTime_Moving=1;
        MI_AOTime_Preparing=4;  % 这里时间稍微多调一点
        MovingCommand='Y0';
        MovingCommand_glo='G3';  % 此时气动手放松状态
        % 还是根据后面的任务来调整实际的位置
        if Task_next==0 || Task_next==1
            PreparingCommand='Y3';
            PreparingCommand_glo='G3';  % 此时气动手放松状态
        end
        if Task_next==2
            PreparingCommand='Y4';
            PreparingCommand_glo='G3';  % 此时气动手放松状态
        end
    end
end

%% 近红外发送任务标签
% 仅仅适用于近红外在任务期间的状态
% 输入任务总体集合RandomTrial, 第几个任务AllTrial, 近红外连接oxy
function FnirsLabelTask(RandomTrial, AllTrial, oxy)
    task = RandomTrial(AllTrial);
    task_oxy = 'P';
    name_oxy = 'Prepare';

    if task==0
        task_oxy = 'I';
        name_oxy = "Idle";
    elseif task==1
        task_oxy = 'S';
        name_oxy = 'Shoulder';
    elseif task==2
        task_oxy = 'H';
        name_oxy = 'Hand';
    end

    disp(['Oxy 发送：', task_oxy, ', 任务： ', name_oxy]);
    oxy.WriteEvent(task_oxy, name_oxy);
end