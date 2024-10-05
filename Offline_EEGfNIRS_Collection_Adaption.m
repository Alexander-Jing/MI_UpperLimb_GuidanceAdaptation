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
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');      % Unity动画exe文件地址
%system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
%system('E:\UpperLimb_Animation\unity_test.exe&');
%system('E:\UpperLimb_Animation\unity_test.exe&');
%system('E:\MI_AO_Animation\UpperLimb_Animation\unity_test.exe&');
%system('E:\MI_AO_Animation\UpperLimb_Animation_modified\unity_test.exe&');
%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_Animation\unity_test.exe&');

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

%% 离线实验参数设置部分，用于设置每一个被试的情况，依据被试情况进行修改

% 运动想象基本参数设置
subject_name = 'Thy_compare_offline';  % 被试姓名
TrialNum = 30*4;  % 设置采集的数量
Trial_setSession = 1;  % 设置是否需要对于采集的TrialNum个trial分session处理，每一个session含有TrialNum/session个样本，1设置为是，0设置为否
Trial_Session = 4;  % 如果上面设置为1，需要对于session数量进行设定

%TrialNum = 3;  % 设置采集的数量
%Trial_setSession = 0;  % 设置是否需要对于采集的TrialNum个trial分session处理，每一个session含有TrialNum/session个样本，1设置为是，0设置为否
%Trial_Session = 1;  % 如果上面设置为1，需要对于session数量进行设定

%TrialNum = 3*10;
MotorClasses = 3;  % 运动想象的种类的数量的设置，注意这里是把空想idle状态也要放进去的，注意这里的任务是[0,1,2]，和readme.txt里面的对应
% 当前设置的任务
% Idle 0   -> SceneIdle 
% MI1 1   -> SceneMI_Drinking 
% MI2 2   -> Scene_Milk 
% 由此设置任务用的字典
task_keys = {0, 1, 2};
task_values = {'SceneIdle', 'SceneMI_Drinking', 'Scene_Milk'};
task_dict = containers.Map(task_keys, task_values);
RestTimeLenBaseline = 5;  % 休息时长确定
seconds_per_trial  = 5;  % 每一个trial的时间长度，根据实际情况设置

% 脑电设备的数据采集
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
weight_mu = 0.6;  % 用于计算ERD/ERS指标和EI指标的加权和

% 通信设置
%ip = '172.18.22.21';
ip = '127.0.0.1';
port = 8880;  % 和后端服务器连接的两个参数

% 电刺激强度设置
Fes_flag = 0;  % 是否开启Fes辅助，1是开启，0是关闭
StimAmplitude_1 = 5;
StimAmplitude_2 = 5;  % 幅值设置（mA）

% 设置近红外连接参数
oxy = actxserver('oxysoft.oxyapplication');  % 连接近红外
disp(['Connected to Oxy Version: ', oxy.strVersion]);

% 难度计算与划分设置
%task_weights = [3,5,2];

%% 设置电刺激连接
%设置连接
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

%% 运动想象内容安排
Trigger = 0;                                                               % 初始化Trigger，用于后续的数据存储
AllTrial = 0;

if Trial_setSession==0
    TrialIndex = randperm(TrialNum);                                           % 根据采集的数量生成随机顺序的数组
    %All_data = [];
    randomindex = [];                                                          % 初始化trials的集合
    for i= 0:(MotorClasses-1)
        index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1，各种任务
        randomindex = [randomindex; index_i];                                  % 各个任务整合，最终size TrialNum*1
    end
    RandomTrial = randomindex(TrialIndex);                                     % 随机生成各个Trial对应的任务

elseif Trial_setSession==1
    RandomTrial = [];
    TrialIndex = [];
    % 如果开启以session形式进行数据收集的话，每一个session设置TrialNum/Trial_Session个trial
    trials_perSession = TrialNum/Trial_Session;  % 一个session里面的trial数量
    % 一个session里面的排布
    for session_idx = 1:Trial_Session
        TrialIndex_session = randperm(trials_perSession);                          % 根据采集的数量生成随机顺序的数组
        randomindex_session = [];                                                  % 初始化trials的集合
        for i= 0:(MotorClasses-1)
            index_i = ones(trials_perSession/MotorClasses,1)*i;                    % size trials_perSession/MotorClasses*1，各种任务
            randomindex_session = [randomindex_session; index_i];                  % 各个任务整合，最终size trials_perSession*1
        end
        RandomTrial = [RandomTrial; randomindex_session(TrialIndex_session)];      % 随机生成每一个session里面各个Trial对应的任务，并且进行合并
        TrialIndex = [TrialIndex; TrialIndex_session];                             % 收集所有的trialIndex用于后续的存储
    end
end
%% 实验数据采集存储设置
% 设置相关参数
classes = MotorClasses;
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % 指定文件夹路径和名称

if ~exist(foldername, 'dir')
   mkdir(foldername);
end
% 设置存储score的数组
scores = [];  % 用于存储每一个trial里面的每一个window的分数值
EI_indices = [];  % 用于存储每一个trial里面的每一个window的EI分数值,存储方式 EI_indices = [EI_indices, EI_index]; 一个trial里面存储4个window的数值
EI_index_scores = [];  % 用于存储EI_index_Caculation(EI_index, EI_channels)计算出来的EI_index_score数值，存储方式 EI_index_score = [EI_index_score; Trigger]; EI_index_scores = [EI_index_scores, EI_index_score];  一个trial里面存储4个window的数值
mu_powers = [];  % 用于存储每一个trial里面的每一个window的mu频带的能量数值， 存储方式 mu_powers = [mu_powers, mu_power_MI];  一个trial里面存储5个window的数值
scores_task = [];  % 用于存储score和task，存储方式 scores_task = [scores_task, scores_task_]; 一个trial里面存储4个window的数值
mu_suppressions = [];  % 用于存储MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels)计算出来的mu_suppression，存储方式mu_suppression = [mu_suppression; Trigger]; mu_suppressions = [mu_suppressions, mu_suppression]; 一个trial里面存储4个window的数值

%% 开始实验，离线采集
Timer = 0;
TrialData = [];
while(AllTrial <= TrialNum)
    if Timer==0  %提示专注 cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
        % 确定下休息时间的长度，中间隔了30个trial（6分钟）最好休息下，休息一定时间
        % 如果Trial_setSession = 1;也就是设置了Session的话，那么一个Session正好是30个trial，同样也是30个trial的时候休息下
        if mod(AllTrial,30)==0 && AllTrial<TrialNum
            RestTimeLenBaseline = 60*3;
            disp(["30个trial了，休息3分钟"])
        else
            RestTimeLenBaseline = 5;
        end
        if AllTrial > TrialNum
            break;
        end
    end
    
    if Timer==2
        Trigger = RandomTrial(AllTrial);  % 播放动作的AO动画（Idle, MI1, MI2）
        mat2unity = ['0', num2str(Trigger + 3)];
        sendbuf(1,1) = hex2dec(mat2unity) ;
        if Trigger==1
            % MI 1使用肩关节的动画播放
            sendbuf(1,2) = hex2dec('04') ;  % 0x04: 4倍速播放, 0x02: 2倍速播放, 0x01: 1倍速播放, 指定播放帧
        elseif Trigger==2
            % MI 2手部使用特别设置的02号2倍速动画来设置，这一部分不会出现举起杯子的部分，仅仅是抓握
            sendbuf(1,2) = hex2dec('02') ;  % 0x04: 4倍速播放, 0x02: 2倍速播放, 0x01: 1倍速播放, 指定播放帧
        end
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        % 这里仅仅提取在MI之前的频带能量
        [~, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; 6];
        mu_powers = [mu_powers, mu_power_];  % 添加相关的mu节律能量
        
        % 添加电刺激，电刺激的时间为2s
        if Fes_flag == 1  % 是否选择电刺激
            Trigger = RandomTrial(AllTrial);
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

        % 近红外打标签
        oxy.WriteEvent('P', 'Prepare');
        disp('近红外标签 P');
    end

    % 第4s开始取512的Trigger~=6的MI的窗口，数据处理并且进行分析
    if Timer > (2+1) && Timer <= (2+5) && RandomTrial(AllTrial)> 0
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trigger, sample_frequency, WindowLength, channels);
        % mu_suppression = (mu_power_MI(mu_channel,1) - mu_power_(mu_channel,1))/mu_power_(mu_channel,1);  % 计算miu频带衰减情况
        % 计算两个指标
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % 计算得分
        scores = [scores, score];  % 保存得分
        scores_task_ = [score; Trigger];
        scores_task = [scores_task, scores_task_];  % 保存分数-任务对，用于后续的分析任务难度用的
        
        % 存储这几个指标的数值
        EI_index_score = [EI_index_score; Trigger];
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  
        mu_suppression = [mu_suppression; Trigger]; % 这里添加上Trigger的相关数值，方便存储

        EI_index_scores = [EI_index_scores, EI_index_score];  % 添加相关的EI_index_scores数值，注意这个是计算了几个channels通道的平均数值，下面那个EI_indices是存储了所有数值
        EI_indices = [EI_indices, EI_index];  % 添加相关的EI指标数值，用于后续的分析  
        mu_powers = [mu_powers, mu_power_MI];  % 添加相关的mu节律能量，用于后续的分析
        mu_suppressions = [mu_suppressions, mu_suppression];  % 添加相关的mu衰减情况，用于后续的分析
    end
    
    if Timer==7 && RandomTrial(AllTrial)> 0  %开始休息
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);
        
        % 近红外打标签，确定之前的数据的标签
        FnirsLabelTask(RandomTrial, AllTrial, oxy);
    end
    
    % 第4s开始取512的Trigger~=6的Rest的窗口，数据处理并且进行分析
    if Timer > (2+1) && Timer <= (2+5) && RandomTrial(AllTrial)==0
        rawdata = TrialData(:,end-512+1:end);  % 取前一个512的窗口
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trigger, sample_frequency, WindowLength, channels);
        % mu_suppression = (mu_power_MI(mu_channel,1) - mu_power_(mu_channel,1))/mu_power_(mu_channel,1);  % 计算miu频带衰减情况
        % 计算两个指标
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % 计算得分
        scores = [scores, score];  % 保存得分
        scores_task_ = [score; Trigger];
        scores_task = [scores_task, scores_task_];  % 保存分数-任务对，用于后续的分析任务难度用的
        
        % 存储这几个指标的数值
        EI_index_score = [EI_index_score; Trigger];
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  
        mu_suppression = [mu_suppression; Trigger]; % 这里添加上Trigger的相关数值，方便存储

        EI_index_scores = [EI_index_scores, EI_index_score];  % 添加相关的EI_index_scores数值，注意这个是计算了几个channels通道的平均数值，下面那个EI_indices是存储了所有数值
        EI_indices = [EI_indices, EI_index];  % 添加相关的EI指标数值，用于后续的分析  
        mu_powers = [mu_powers, mu_power_MI];  % 添加相关的mu节律能量，用于后续的分析
        mu_suppressions = [mu_suppressions, mu_suppression];  % 添加相关的mu衰减情况，用于后续的分析

    end
    
    if Timer==7 && RandomTrial(AllTrial)==0  %开始休息
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  

        % 近红外打标签，确定之前的数据的标签
        FnirsLabelTask(RandomTrial, AllTrial, oxy);
    end
    
    % 在长时间的休息中，给点电刺激，作为休息的开始
    if mod(AllTrial,30)==0 && Timer==7+5
        StimCommand = StimCommand_1;
        fwrite(StimControl,StimCommand);
        disp(['休息时间，MI辅助电刺激，此时已经休息5s']);
    end    
    
    % 在长时间的休息中，给点电刺激，作为休息的开始
    if mod(AllTrial,30)==0 && Timer==7+15
        StimCommand = StimCommand_2;
        fwrite(StimControl,StimCommand);
        disp(['休息时间，MI辅助电刺激，此时已经休息15s']);
    end 

    % 在长时间的休息中，给点电刺激，作为休息的结束
    if mod(AllTrial,30)==0 && Timer==7+180-20
        StimCommand = StimCommand_1;
        fwrite(StimControl,StimCommand);
        disp(['休息时间，MI辅助电刺激，此时距离休息结束还有20s']);
    end

    % 在长时间的休息中，给点电刺激，作为休息的结束
    if mod(AllTrial,30)==0 && Timer==7+180-15
        StimCommand = StimCommand_2;
        fwrite(StimControl,StimCommand);
        disp(['休息时间，MI辅助电刺激，此时距离休息结束还有15s']);
    end

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
    
    if Timer == (7 + RestTimeLenBaseline) && RandomTrial(AllTrial)> 0
        Timer = 0;  % 计时器清0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % 显示相关数据
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % 计算得分

        % 近红外打标签，确定之前的数据的标签
        oxy.WriteEvent('R', 'Rest');
    end
    
    if Timer == (7 + RestTimeLenBaseline) && RandomTrial(AllTrial)==0
        Timer = 0;  % 计时器清0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % 显示相关数据
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % 计算得分
        
        % 近红外打标签，确定之前的数据的标签
        oxy.WriteEvent('R', 'Rest');
    end
    
end
%% 存储原始数据
close all
TrialData = TrialData(2:end,:);  %去掉矩阵第一行
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % 将连接关闭
% 存储原始数据
foldername_rawdata = [foldername, '\\Offline_EEGMI_RawData_', subject_name]; % 指定文件夹路径和名称
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Offline_EEGMI_RawData_', subject_name], '.mat' )],'TrialData','TrialIndex','ChanLabel');

%% 数据预处理
% 划窗参数设置
rawdata = TrialData;
sample_frequency = 256; 
WindowLength = 512;  % 每个窗口的长度
SlideWindowLength = 256;  % 滑窗间隔
[DataX, DataY, windows_per_session] = Offline_DataPreprocess_Hanning_GuidanceAdaption(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername, seconds_per_trial);

%% 每一种任务对应的各项指标的平均分数以及4分位数确定，并且存储相关指标
foldername_Scores = [foldername, '\\Offline_EEGMI_Scores_', subject_name]; % 指定文件夹路径和名称
if ~exist(foldername_Scores, 'dir')
   mkdir(foldername_Scores);
end
% 计算各个变量指标的均值和方差  
mean_std_muSup = compute_mean_std(mu_suppressions, 'mu_suppressions');  
mean_std_EI_score = compute_mean_std(EI_index_scores, 'EI_index_scores');
% 计算四分位数
[quartile_caculation_mu, min_max_value_mu] = Offline_Bootstrapping_quartile(mu_suppressions, 'mu_suppressions', 1000);
[quartile_caculation_EI, min_max_value_EI] = Offline_Bootstrapping_quartile(EI_index_scores, 'EI_index_scores', 1000);

% 存储相关数据
save([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name], '.mat' ],'scores_task','EI_indices','mu_powers', ...
    'mu_suppressions','EI_index_scores', 'mean_std_EI_score','mean_std_muSup','quartile_caculation_mu',"min_max_value_mu","quartile_caculation_EI","min_max_value_EI"); 

%% 预处理数据传输
% 设置传输的参数
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);

%% 关闭电刺激
StimCommand(1,1) = 100;
fwrite(StimControl,StimCommand);
system('taskkill /F /IM fes.exe');
close all;

%% 获取平均参与度分数的函数
function mean_std_scores = compute_mean_std(scores_task, scores_name)
    % 获取scores和triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % 获取所有不同的triggers
    unique_triggers = unique(triggers);

    % 初始化输出
    mean_scores = zeros(size(unique_triggers));
    std_scores = zeros(size(unique_triggers));

    % 对于每一个trigger，计算对应的score的均值
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
        std_scores(i) = std(scores(triggers == trigger));
    end
    mean_std_scores = [mean_scores; std_scores];

    % 输出结果
    disp(['每一个Trigger的平均', scores_name, '分数是：']);
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' 的平均分数是 ' num2str(mean_scores(i))]);
        disp(['Trigger ' num2str(unique_triggers(i)) ' 的标准差是 ' num2str(std_scores(i))]);
    end
end
%% 计算相关mu频带衰减指标
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % 计算两个脑电位置的相关的指标 
    mu_suppresion =  - ERD_C3;  % 归一化到[0,1]的区间里面
end
    
    %% 计算相关的EI指标的函数
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.F3, EI_channels.Fz, EI_channels.F4];
    EI_index_score = mean(EI_index(channels_, 1));

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