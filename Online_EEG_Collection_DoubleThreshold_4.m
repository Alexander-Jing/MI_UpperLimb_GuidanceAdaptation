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

system('E:\MI_AO_Animation\UpperLimb_Animation_modified_DoubleThreshold\unity_test.exe&');

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
subject_name = 'Jyt_test_0310_online';  % 被试姓名
sub_offline_collection_folder = 'Jyt_test_0310_offline_20240310_195952653_data';  % 被试的离线采集数据
subject_name_offline =  'Jyt_test_0310_offline';  % 离线收集数据时候的被试名称
session_idx = 1;  % session index数量，如果是1的话，会自动生成相关排布
DiffLevels = [1,2];  % 对于上面的运动想象的难度排布，越靠后越难，其中的1,2对应的是运动想象的类型，和unity对应
MajorPoportion = 0.6;  % 每一个session里面不同类型运动想象总数所占的比值
%TrialNum = 40;  % 每一个session里面的trial的数量
TrialNum = 20;  % 每一个session里面的trial的数量
MotorClass = 2; % 运动想象动作数量，注意这里是纯设计的运动想象动作的数量，不包括空想idle状态
MotorClassMI = 2;  % 如果是单运动想象任务的话，那就直接指定任务就好了


% 运动想象任务调整设置
score_init = 1.0;  % 这是在之前离线时候计算的mu衰减和EI指标的均值
MaxMITime = 35; % 在线运动想象最大允许时间 
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和
MI_MUSup_thre = 0;  % 用于MI时候的阈值初始化
MI_MUSup_thre_weight_baseline = 0.714;  % 用于计算MI时候的mu衰减的阈值权重初始化数值，这个权重一般是和分类的概率相关的，也会随着相关数据进行调整
MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;  % 用于计算MI时候的mu衰减的阈值权重数值，这个权重一般是和分类的概率相关的，也会随着相关数据进行调整

% 通信设置
ip = '172.18.22.21';
port = 8888;  % 和后端服务器连接的两个参数

% 电刺激强度设置
StimAmplitude_1 = 7;
StimAmplitude_2 = 9;  % 幅值设置（mA）

%% 设置电刺激连接
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
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % 指定文件夹路径和名称
if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% 生成mu衰减的追踪轨迹
% 读取之前的离线采集的数据
foldername_Scores = [sub_offline_collection_folder, '\\Offline_EEGMI_Scores_', subject_name_offline]; % 指定之前存储的离线文件夹路径和名称
mean_std_EI_score = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_EI_score');
mean_std_muSup = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_muSup');
quartile_caculation_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_mu');
min_max_value_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_mu');
quartile_caculation_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_EI');
min_max_value_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_EI');

% 生成现在的轨迹
%traj = generate_traj(mean_std_muSup.mean_std_muSup, TrialNum);
traj = generate_traj_quartile(quartile_caculation_mu.quartile_caculation_mu, TrialNum);

%% 运动想象内容安排
TrialIndex = randperm(TrialNum);                                           % 根据采集的数量生成随机顺序的数组
%All_data = [];
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

randomindex = [];   
if MotorClass > 1                                                       % 初始化trials的集合
    for i= 1:(MotorClass)                                                    % 注意，这里只生成运动想象的任务，后面会依据实际情况加入相关的静息状态
        index_i = ones(TrialNum/MotorClass,1)*i;                             % size TrialNum/MotorClasses*1，各种任务
        randomindex = [randomindex; index_i];                                  % 各个任务整合，最终size TrialNum*1
    end

    RandomTrial = randomindex(TrialIndex);                                     % 随机生成各个Trial对应的任务
else
    Trials = repmat(MotorClassMI, TrialNum);   % 如果是单任务的话，我们直接设置任务
end

%% 开始实验，离线采集
Timer = 0;
TrialData = [];
scores = [];  % 用于存储每一个trial里面的每一个window的分数值
EI_indices = [];  % 用于存储每一个trial里面的每一个window的EI分数值
EI_index_scores = [];  % 用于存储EI_index_Caculation(EI_index, EI_channels)计算出来的EI_index_score数值
EI_index_scores_normalized = [];  % 用于存储归一化的EI_index_scores数值
mu_powers = [];  % 用于存储每一个trial里面的每一个window的mu频带的能量数值
mu_suppressions = [];  % 用于存储每一个trial里面的mu_suppression
mu_suppressions_normalized = [];  % 用于存储每一个trial里面的mu_suppressions_normalized
resultsMI = [];  % 用于存储每一个trial里面的results
FES_flags = [];  % 用于存储每一个trial里面的FES电刺激情况，如果施加电刺激，则为1
visual_feedbacks = [];  % 用于存储每一个trial里面的visual_feedback视觉反馈的数值
MI_MUSup_thre1s_normalized = [];  % 用于存储每一个trial的第二阈值

scores_trial = [];  % 用于存储每一个trial的平均分数值
muSups_trial = [];  % 用于存储每一个trial的任务完成数值，当前的任务完成指标设置为trial里面的最大的resultMI*MuSup比上MI_MUSup_thre  max(resultMI*MuSup)/MI_MUSup_thre
MI_MUSup_thre_weights = []; % 用于存储每一个trial的权重
MI_MUSup_thres = [];  % 用于存储每一个trial的阈值
MI_MUSup_thres_normalized = [];  % 用于存储每一个trial的第一阈值
RestTimeLens = [];  % 用于存储每一个trial的休息时间
visual_feedbacks_trial = [];  % 用于存储每一个trial的visual_feedback视觉反馈的平均数值

Online_FES_ExamingNum = 5;  % 在线的时候每隔多久检查判断是否需要进行FES辅助
Online_FES_flag = 0;  % 用于设置是否进行实时FES刺激的相关控制flag
clsFlag = 0; % 用于判断阈值0是否达到的flag
clsFlag1 = 0; % 用于判断阈值1是否达到的flag
clsTime = 100;  % 初始化分类正确的时间
clsControl = 0;  % 用于相对之后判断是否休息的flag
RestTimeLenBaseline = 7 + session_idx;  % 休息时间随着session的数量增加
RestTimeLen = RestTimeLenBaseline;  % 初始化休息时间
if MotorClass > 1
    Trials = RandomTrial;
end

while(AllTrial <= TrialNum)
    %% 提示专注阶段
    if Timer==0  %提示专注 cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
        if AllTrial > TrialNum
            break;
        end
    end
    
    %% 运动想象阶段
    if Timer==2
        if Trials(AllTrial)==0  % 空想任务
            Trigger = 0;
            sendbuf(1,1) = hex2dec('03') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        if Trials(AllTrial)> 0  % 运动想象任务
            Trigger = Trials(AllTrial);  % 播放动作的AO动画（Idle, MI1, MI2）
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % 第2s的时候，取512的Trigger==6的窗口，数据处理并且进行分析
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        % 这里仅仅提取在MI之前的频带能量
        [~, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; 6];
        mu_powers = [mu_powers, mu_power_];  % 添加相关的mu节律能量

        % 确定这一轮的阈值
        if Trials(AllTrial)> 0
            %Trigger = Trials(AllTrial);
            Trigger_num_ = count_trigger(Trials, AllTrial);  % 这里用于计算在AllTrial对应的Trigger之前已经出现了多少次，从而计算轨迹
            MI_MUSup_thre = traj{Trigger+1}(Trigger_num_+1);  % 计算阈值
            
            
            % 确定加权之后的阈值，用于保存
            MI_MUSup_thre = MI_MUSup_thre;
            MI_MUSup_thre_weights = [MI_MUSup_thre_weights, [MI_MUSup_thre_weight;Trigger]];
            MI_MUSup_thres = [MI_MUSup_thres, [MI_MUSup_thre;Trigger]];

            % 归一化相关的数值，用于实时显示和判断情况
            MI_MUSup_thre_normalized = mu_normalization(MI_MUSup_thre, min_max_value_mu.min_max_value_mu, Trigger+1);
            MI_MUSup_thre_normalized = MI_MUSup_thre_weight * MI_MUSup_thre_normalized;
            disp(['Trial: ', num2str(AllTrial), ' Cls: ', num2str(Trials(AllTrial))]);
            disp(['Mu Threshold：', num2str(MI_MUSup_thre)]);
            disp(['Threshold Normalized Weighted: ', num2str(MI_MUSup_thre_normalized)]);
            MI_MUSup_thres_normalized = [MI_MUSup_thres_normalized, [MI_MUSup_thre_normalized;Trigger]];
            MI_MUSup_thre1_normalized = MI_MUSup_thre_normalized;  % 确定阈值2
            MI_MUSup_thre1s_normalized = [MI_MUSup_thre1s_normalized, [MI_MUSup_thre1_normalized; Trigger]];

            % threshold 数据传输设置以及显示
            sendbuf(1,6) = uint8((MI_MUSup_thre_normalized*100));
            sendbuf(1,7) = uint8((MI_MUSup_thre1_normalized*100));
            fwrite(UnityControl,sendbuf);  
            % 初始化显示下视觉反馈数值
            sendbuf(1,5) = uint8((0.01*100.0));
            fwrite(UnityControl,sendbuf);
        end
        
        % 添加电刺激，电刺激的时间为2s
        if Trigger == 1
            StimCommand = StimCommand_1;
            fwrite(StimControl,StimCommand);
            disp(['MI之前辅助电刺激']);
        end
        if Trigger == 2
            StimCommand = StimCommand_2;
            fwrite(StimControl,StimCommand);
            disp(['MI之前辅助电刺激']);
        end
        
    end
    
    % 第5s开始取512的Trigger~=6的MI的窗口，数据处理并且进行分析
    if Timer > 4 && Trials(AllTrial)> 0 && clsFlag == 0 && clsControl == 0
        Trigger = Trials(AllTrial);
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
        % 计算两个指标
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % 计算得分
        scores = [scores, score];  % 保存得分

        % 发送得分以及一系列数据
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % 传输数据给线上的模型，看分类情况
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(2,1))]);
        
        
        % 得分数据归一化处理，同时保持在0-1之间，用于实时显示和比较
        mu_suppression_normalized = mu_normalization(mu_suppression, min_max_value_mu.min_max_value_mu, Trigger+1);
        visual_feedback = resultMI(2,1) * mu_suppression_normalized;
        
        if visual_feedback < 0.01
            visual_feedback = 0.01;
        elseif visual_feedback > 1
            visual_feedback = 1.0;
        end
        disp(['Mu Online：', num2str(mu_suppression)]);
        disp(['Mu normalized Weighted: ', num2str(visual_feedback)]);
        
        % 对于EI指标的归一化操作
        EI_index_score_normalized = EI_normalization(EI_index_score, min_max_value_EI.min_max_value_EI);
        
        % 存储这一系列指标的数值
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % 这里添加上Trigger的相关数值，方便存储
        mu_suppression = [mu_suppression; Trigger]; % 这里添加上Trigger的相关数值，方便存储
        EI_index_score = [EI_index_score; Trigger];
        EI_index_score_normalized = [EI_index_score_normalized; Trigger];
        resultMI_ = [resultMI; Trigger];
        mu_suppression_normalized = [mu_suppression_normalized; Trigger];

        
        resultsMI = [resultsMI, resultMI_];
        EI_index_scores = [EI_index_scores, EI_index_score];
        EI_index_scores_normalized = [EI_index_scores_normalized, EI_index_score_normalized];
        EI_indices = [EI_indices, EI_index];  % 添加相关的EI指标数值  
        mu_powers = [mu_powers, mu_power_MI];  % 添加相关的mu节律能量
        mu_suppressions = [mu_suppressions, mu_suppression];  % 添加相关的mu衰减情况，用于后续的分析
        mu_suppressions_normalized = [mu_suppressions_normalized, mu_suppression_normalized];
        visual_feedbacks = [visual_feedbacks, [visual_feedback; Trigger]];
        
        % 计算阈值2
        MI_MUSup_thre1_normalized = Online_Threshold1Adjust_DoubleThreshold_2(visual_feedbacks(1,:), MI_MUSup_thre1_normalized, MI_MUSup_thre_normalized, "Game");
        MI_MUSup_thre1s_normalized = [MI_MUSup_thre1s_normalized, [MI_MUSup_thre1_normalized; Trigger]];
        
        % 实时的视觉反馈分数
        sendbuf(1,5) = uint8((visual_feedback*100.0));
        sendbuf(1,7) = uint8((MI_MUSup_thre1_normalized*100));
        fwrite(UnityControl,sendbuf);


        % 判断是否达成要求
        if visual_feedback >= MI_MUSup_thre_normalized
            clsFlag1 = 1;
            % 进行电刺激
            if Trials(AllTrial) == 1
                StimCommand = StimCommand_1;
                fwrite(StimControl,StimCommand);
            end
            if Trials(AllTrial) == 2
                StimCommand = StimCommand_2;
                fwrite(StimControl,StimCommand);
            end
            disp(['MI达到阈值0电刺激']);
        end

        if visual_feedback >= MI_MUSup_thre1_normalized
            clsFlag = 1;  % 识别正确，置1
            disp(['MI达到阈值1电刺激']);
        else
            clsFlag = 0;
        end
        
%         if resultMI == Trials(AllTrial)
%             clsFlag = 1;  % 识别正确，置1
%         else
%             clsFlag = 0;
%         end  

        % 在想象的同时加入电刺激，如果想象的时候出现一定的困难，那就加入电刺激
        Online_FES_flag = Threshold_FESAdjust_DoubleThreshold_1(resultsMI, mu_suppressions_normalized, Online_FES_ExamingNum);
        
        if Online_FES_flag == 1
            % 进行电刺激
            if Trigger == 1
                StimCommand = StimCommand_1;
                fwrite(StimControl,StimCommand);
            end
            if Trigger == 2
                StimCommand = StimCommand_2;
                fwrite(StimControl,StimCommand);
            end
            disp(['MI在线辅助电刺激']);
            Online_FES_flag = 0;  % 电刺激结束之后重新置0
        end
        FES_flags = [FES_flags, [Online_FES_flag; Trigger]];  % 存储一下电刺激相关的数值
    end
    
   %% 运动想象给与反馈阶段（想对/时间范围内没有想对）,同时更新模型
   % 想对了开始播放动作 
   if (clsFlag == 1 && clsFlag1==1) && clsControl == 0
       Trigger = 7; 
       clsTime = Timer;  % 这是分类正确的时间
        if Trials(AllTrial) > 0  % 运动想象任务
            % 播放动作的AO动画（Idle, MI1, MI2）
            mat2unity = ['0', num2str(Trials(AllTrial) + 3)];
            sendbuf(1,1) = hex2dec(mat2unity);
            sendbuf(1,2) = hex2dec('01') ;
            sendbuf(1,3) = hex2dec('01') ;  % 给与反馈，显示文字
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        
        % 进行电刺激
        if Trials(AllTrial) == 1
            StimCommand = StimCommand_1;
            fwrite(StimControl,StimCommand);
        end
        if Trials(AllTrial) == 2
            StimCommand = StimCommand_2;
            fwrite(StimControl,StimCommand);
        end
        disp(['MI达到阈值电刺激']);

        % 传输数据和更新模型
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        % 重置下3个flag
        clsControl = 1;
        clsFlag = 0;
        clsFlag1 = 0;
   end
    
    % 想错了开始休息和提醒
    if (clsFlag == 0 || clsFlag1==0) && Timer == (MaxMITime) && clsControl == 0
        Trigger = 7;
        if Trials(AllTrial) > 0  % 运动想象任务
            % 播放动作的AO动画（Idle, MI1, MI2）
            mat2unity = ['0', num2str(Trials(AllTrial) + 3)];
            sendbuf(1,1) = hex2dec(mat2unity);
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('02') ;  % 给与反馈，显示文字
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % 传输数据和更新模型
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        clsControl = 2;
    end
    
   %% 休息阶段，确定下一个动作
    % 空想只给5s就休息
    if Timer==7 && Trials(AllTrial)==0 && clsControl == 0 %开始休息
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 更新算法
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 2.0;  % 传输数据和训练的命令
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 发送指令，让服务器更新数据，[0,0,0,0]单纯是用于凑下数据，防止应为空集影响传输
        % 进入确定下一个任务
        average_score = mean(EI_index_scores(1, :));  % 这里换成EI指标，后续可能还会换
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        max_MuSup = max(mu_suppressions(1,:))/MI_MUSup_thre;  % 计算最大的Mu衰减比上阈值，衡量任务完成情况
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % 存储好完成情况
        visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % 存储相关视觉反馈情况

        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline,TrialNum);
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_1(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum, min_max_value_EI.min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    % 运动想象想对了之后，AO结束了之后让人休息
    if Trials(AllTrial)>0 && Timer == (clsTime + 8) && clsControl == 1  %开始休息
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 进入确定下一个任务
        average_score = mean(EI_index_scores(1, :));  % 这里换成EI指标，后续可能还会换
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        max_MuSup = max(mu_suppressions(1,:))/MI_MUSup_thre;  % 计算最大的Mu衰减比上阈值，衡量任务完成情况
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % 存储好完成情况
        visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % 存储相关视觉反馈情况
        
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline,TrialNum);
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_1(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum, min_max_value_EI.min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    % 运动想象没有想对，提醒结束了之后让人休息
    if Trials(AllTrial)>0 && (clsFlag==0 || clsFlag1==0) && Timer == (MaxMITime + 8) && clsControl == 2
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % 进入确定下一个任务
        average_score = mean(EI_index_scores(1, :));  % 这里换成EI指标，后续可能还会换
        scores_trial = [scores_trial, average_score];  % 存储好平均的分数
        max_MuSup = max(mu_suppressions(1,:))/MI_MUSup_thre;  % 计算最大的Mu衰减比上阈值，衡量任务完成情况
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % 存储好完成情况
        visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % 存储相关视觉反馈情况
        
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_1(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum, min_max_value_EI.min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
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
    
    %% 最后的各个数值复位
    % 空想任务想象5s，到第7s之后开始休息，到第10s就结束任务
    if Timer == 10 && Trials(AllTrial)==0 && clsControl == 0 %结束休息，准备下一个
        % 存储相关的EI指标和mu节律能量的数据
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized, ...
            visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized);
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
        
        RestTimeLen = RestTimeLenBaseline;  % 休息时间还原
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % 显示相关数据
    end
    % 想对了之后，AO之后，休息3s之后，结束休息，准备下一个
    if Trials(AllTrial)>0 && Timer == (clsTime + 8 + RestTimeLen) && clsControl == 1  %结束休息
        % 存储相关的EI指标和mu节律能量的数据
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized, ...
            visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized);
        % 计时器清0
        Timer = 0;  % 计时器清0
        % cls的两个flag清0
        clsFlag = 0;  % 分类flag清0
        clsFlag1 = 0;  % 分类clsFlag1清0
        clsControl = 0;
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
        
        % 其余设置还原
        RestTimeLen = RestTimeLenBaseline;  % 休息时间还原
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % 显示相关数据
    end
    % 运动想象没有想对，提醒之后，休息3s之后，结束休息，准备下一个
    if Trials(AllTrial)>0 && (clsFlag == 0 || clsFlag1==0) && Timer == (MaxMITime + 8 + RestTimeLen) && clsControl == 2
        % 存储相关的EI指标和mu节律能量的数据
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized, ...
            visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized);
        % 计时器清0
        Timer = 0;  % 计时器清0
        % clsflag清0
        clsFlag = 0;  % 分类flag清0
        clsFlag1 = 0;  % 分类clsFlag1清0
        clsControl = 0;
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
        
        % 其余设置还原
        RestTimeLen = RestTimeLenBaseline;  % 休息时间还原
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % 显示相关数据
    end
end
%% 存储原始数据
close all
TrialData = TrialData(2:end,:);  %去掉矩阵第一行
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % 将连接关闭
% 存储原始数据
foldername_rawdata = [foldername, '\\Online_EEGMI_RawData_', subject_name]; % 指定文件夹路径和名称
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_RawData_',num2str(session_idx), '_', subject_name], '.mat' )],'TrialData','Trials','ChanLabel');

%% 存储轨迹追踪与调整的相关指标
foldername_rawdata = [foldername, '\\Online_EEGMI_trajectory_', subject_name]; % 指定文件夹路径和名称
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_trajectory_',num2str(session_idx), '_', subject_name], '.mat' )],'scores_trial','traj','MI_MUSup_thre_weights',...
    'MI_MUSup_thres','RestTimeLens','muSups_trial','scores_trial','MI_MUSup_thres_normalized', 'visual_feedbacks_trial');


%% 存储在运动想象过程中的参与度指标
function SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized,...
    visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % 检验文件夹是否存在
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', FunctionNowFilename(['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' )],'EI_indices','mu_powers','mu_suppressions', 'EI_index_scores','resultsMI','FES_flags','mu_suppressions_normalized', 'visual_feedbacks',...
        'MI_MUSup_thre1s_normalized', 'EI_index_scores_normalized');  % 存储相关的数值
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

%% 生成轨迹的函数
function traj = generate_traj(mean_std_muSup, TrialNum)
    % 获取类别的数量
    n = size(mean_std_muSup, 2);

    % 初始化一个空的 cell 数组来存储每个类别的轨迹
    traj = cell(1, n);

    % 对于每一个类别
    for i = 1:n
        % 提取 mean 和 std
        mean_val = mean_std_muSup(1, i);
        std_val = mean_std_muSup(2, i);

        % 初始化一个空的数组来存储轨迹
        traj{i} = zeros(TrialNum, 1);

        % 计算轨迹
        for x = 1:TrialNum
            traj{i}(x) = mean_val + (std_val) * (1 - exp(-3 * x / TrialNum));
        end
    end
end

function traj = generate_traj_quartile(quartiles, TrialNum)
    % 获取类别的数量
    n = size(quartiles, 2);

    % 初始化一个空的 cell 数组来存储每个类别的轨迹
    traj = cell(1, n);

    % 对于每一个类别
    for i = 1:n
        % 提取0.25, 0.5, 0.75的分位点
        mu_supQ1 = quartiles(1, i);
        mu_supQ2 = quartiles(2, i);
        mu_supQ3 = quartiles(3, i);

        % 初始化一个空的数组来存储轨迹
        traj{i} = zeros(TrialNum, 1);
        
        % 如果两个分位数有小于0的问题，强行修正过来，强行设置相关数值，后续可修改
        if mu_supQ2 < 0.0
            mu_supQ2 = 0.5;
        end
        if mu_supQ3 < 0.0
            mu_supQ3 = 2.0;
        end
        
        % 计算轨迹
        for x = 1:TrialNum
            traj{i}(x) = mu_supQ2 + (mu_supQ3 - mu_supQ2) * (1 - exp(-3 * x / TrialNum));
        end
    end
end

% Trials里面判断当前类别已经出现过多少次的函数，用于精细的轨迹生成
function count = count_trigger(Trials, AllTrial)
    % 提取 Trigger
    Trigger = Trials(AllTrial);
    
    % 计算 Trigger 在 Trials(1:AllTrial-1) 中的数量
    count = sum(Trials(1:AllTrial-1) == Trigger);
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