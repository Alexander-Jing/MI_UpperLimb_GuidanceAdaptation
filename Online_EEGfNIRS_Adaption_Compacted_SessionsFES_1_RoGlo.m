%% ��ʼ�����ر���������
pnet('closeall');
clc;
clear;
close all;
%% ����Unity���򣬲���ʼ��
% ����˵�����������5�ֽ�
%           Byte1������/�����л�
%           Byte2�����ƻ����Ƿ��˶�
%           Byte3������������ʾ������ѵ��ʵ����������ʾ��
%           Byte4����������
%           Byte5��Ԥ��
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');       % Unity����exe�ļ���ַ
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
UnityControl = tcpip('localhost', 8881, 'NetworkRole', 'client');          % �µĶ˿ڸ�Ϊ8881
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

%% �����Ե�ɼ�����
init = 0;
freq = 256;
startStop = 1;
con = pnet('tcpconnect','127.0.0.1',4455);                                 % ����һ������
status = CheckNetStreamingVersion(con);                                    % �жϰ汾��Ϣ����ȷ����״ֵ̬Ϊ1
[~, basicInfo] = ClientGetBasicMessage(con);                               % ��ȡ�豸������ϢbasicInfo���� size,eegChan,sampleRate,dataSize
[~, infoList] = ClientGetChannelMessage(con,basicInfo.eegChan);            % ��ȡͨ����Ϣ

%% ����ʵ��������ò��֣���������ÿһ�����Ե���������ݱ�����������޸�

% �˶����������������
subject_name = 'Nkc_online';  % ��������
sub_offline_collection_folder = 'Nkc_offline_20241007_161904206_data';  % ���Ե����߲ɼ�����
subject_name_offline =  'Nkc_offline';  % �����ռ�����ʱ��ı�������
% session ����1ʱ��Ҫ�Ķ��Ĳ���
% ע�⣬�����豸���⣬������session_idxΪ4֮ǰ������matlab����ֹ���ֺ�����ж�
session_idx = 10;  % session index�����������1�Ļ������Զ���������Ų�
foldername_Sessions = 'Nkc_online_20241007_170347400_data';  % ��session����1��ʱ����Ҫ�ֹ�����foldername_Sessions

fNIRS_Use = 1;  % �Ƿ�ʹ��fNIRs�豸������Ϊ1��ʹ�ã�����Ͳ���
MotorClass = 2; % �˶�������������ע�������Ǵ���Ƶ��˶�������������������������idle״̬
%MotorClassMI = 2;  % ����ǵ��˶���������Ļ����Ǿ�ֱ��ָ������ͺ���
original_seq = [1,1, 1,2, 0,0, 2,1, 2,2, 0,0];  % ԭʼ��������
%original_seq = [1, 2, 0];  % ԭʼ��������
training_seqs = 9;  % ѵ������
trial_random = 2;  % �����ж��Ƿ�������ѵ��˳��Ĳ��� false 0�� true 1�� �����ó�2�Ļ�ѡ��̶���Ԥ�����úõ�ʵ��˳��
% Ԥ���趨�õ�ʵ�����trial_random = 2��ʱ������
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
TrialNum = length(original_seq)*training_seqs;  % ÿһ������trial������
if trial_random == 2
    TrialNum = length(preSet_seq);  % �����trial_randomΪ2��ʱ���޸���ֵΪlength(preSet_seq)
end
TrialNum_session = 12;  % һ��session�����trial����

% �˶�����ʱ��ڵ��趨
MI_preFeedBack = 12;  % �˶������ṩ�Ӿ���̼�������ʱ��ڵ�
MI_AOTime = 5;  % AO+FES��ʱ�䳤��
RestTimeLenBaseline = 2;  % ��Ϣʱ�䣨�˶�����
RestTimeLen = RestTimeLenBaseline;  % ��ʼ����Ϣʱ�䣨�˶�����
Idle_preBreak = 12;  % ��Ϣ̬�ṩ��Ϣ��ʱ���
RestTimeLen_idleBasline = 5;  % ��ʼ����Ϣʱ�䣨��Ϣ̬��
MI_AOTime_Moving = 3;  % ��ʼ����е�۵�ǰMI������ʱ��
MI_AOTime_Preparing = 2;  % ��ʼ����е��׼����һ��MI�ķ�����ʱ��

% ����ָ��Ͳ���
MI_AO_Len = 200;  % ����ʵ���ж���֡

% �˶����������������
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
EEG_Cap = 1;  % �ж�ʹ�õ��Ե�ñ���豸��0Ϊԭ������ñ��(Jyt-20240824-GraelEEG.xml)��1Ϊ�µ�ñ��(Jyt-20240918-GraelEEG.xml)
channel_selection=1; % �ж��Ƿ�Ҫ����ͨ��ѡ��Ŀǰ����Ϊ0�������������ݣ������ں���������Ͽ��Կ���ѡ��
if EEG_Cap==0  % ѡ���ϵ�ñ��(Jyt-20240824-GraelEEG.xml)
    if channel_selection==0
        channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
        mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
        EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
    else
        channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  % ѡ���ͨ��������ȥ����OZ��M1,M2��Fp1��Fp2�⼸��channel
        mu_channels = struct('C3',24-3, 'C4',22-3);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
        EI_channels = struct('F3', 29-3, 'Fz', 28-3, 'F4', 27-3);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
    end 
elseif EEG_Cap==1  % ѡ���µ�ñ��(Jyt-20240918-GraelEEG.xml)
    if channel_selection==0
        channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
        mu_channels = struct('C3',17, 'C4',15);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
        EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 29, 'F3', 28, 'Fz', 27, 'F4', 26, 'F8', 25);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
    else
        channels = [1, 3,4,5,6,7,8, 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30];  % ѡ���ͨ��������ȥ����OZ��M1,M2��Fp1��Fp2�⼸��channel
        mu_channels = struct('C3',17-3, 'C4',15-3);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
        EI_channels = struct('F3', 28-3, 'Fz', 27-3, 'F4', 26-3);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
    end 
end

Train_Thre = 0.5;  % ���ں���������keep����adjust����ֵ
Train_Thre_Global_FeasibleInit = [0, 0.36, 0.36;
                                  0, 0.41, 0.41;
                                  0, 1,    2;];  % ��ʼ��ֵ�����ڿ��в��ֹ켣�����ɣ��ⲿ����Ҫ����ʵ�ʵı��Ա�����˵��
traj_Feasible = generate_traj_feasible(Train_Thre_Global_FeasibleInit, TrialNum);  % ����������ֵ�Ĺ켣�ĺ���
Train_Thre_Global = Train_Thre_Global_FeasibleInit(1,1);  % ȫ����ֵTrain_Thre_Global�����ڲ��ҵ��������ȫ�־�ֵ�Ŀ���-���Ų��Ե���ֵ�趨

% ������ͨ������
%ip = '172.18.22.21';
ip = '127.0.0.1';
port = 8880;  % �ͺ�˷��������ӵ���������

% ��е��ͨ������
RobotControl = tcpip('localhost', 5288, 'NetworkRole','client');
fopen(RobotControl);
% ��������ͨ������
GloveControl = tcpip("192.168.2.30", 8003, 'NetworkRole','client');
fopen(GloveControl);  % �������׳�ʼ�����ȷ���
sendbuf_glo = uint8(1:2);
sendbuf_glo(1,1) = hex2dec('ff') ;
sendbuf_glo(1,2) = hex2dec('ff') ;
fwrite(GloveControl, sendbuf_glo);


% ��̼�ǿ������
StimAmplitude_1 = 7;  % MI1 ��ؽڵĵ�̼���ֵ���ԣ�mA��
StimAmplitude_2 = 6;  % MI2 �ֲ��ֵķ�ֵ���ã�mA��

% %% ���õ�̼�����
% ��������
%system('F:\MI_engagement\fes\fes\x64\Debug\fes.exe&');
%system('F:\CASIA\MI_engagement\fes\fes\x64\Debug\fes.exe&');
system('D:\workspace\fes\x64\Release\fes.exe&');
pause(1);
StimControl = tcpip('localhost', 8888, 'NetworkRole', 'client','Timeout',1000);
StimControl.InputBuffersize = 1000;
StimControl.OutputBuffersize = 1000;

% ���õ�̼���ز���
fopen(StimControl);
tStim = [3,14,2]; % [t_up,t_flat,t_down] * 100ms
StimCommand_1 = uint8([0,StimAmplitude_1,tStim,1]); % left calf
StimCommand_2 = uint8([0,StimAmplitude_2,tStim,2]); % left thigh

% ���ý�����
if fNIRS_Use==1
    oxy = actxserver('oxysoft.oxyapplication');  % ���ӽ�����
    disp(['Connected to Oxy Version: ', oxy.strVersion]);
end

%% ׼����ʼ�Ĵ洢���ݵ��ļ���
if session_idx==1
    foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % ָ���ļ���·��������
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
else
    foldername=foldername_Sessions;
end
% ��ȡ֮ǰ�����߲ɼ�������
foldername_Scores = [sub_offline_collection_folder, '\\Offline_EEGMI_Scores_', subject_name_offline]; % ָ��֮ǰ�洢�������ļ���·��������
mean_std_EI_score = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_EI_score');
mean_std_muSup = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_muSup');
quartile_caculation_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_mu');
min_max_value_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_mu');
quartile_caculation_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_EI');
min_max_value_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_EI');
min_max_value_EI = min_max_value_EI.min_max_value_EI;  % ������max��min��ֵ

%% �˶��������ݰ���
Trials = [];  % ��ʼ��ѵ��������
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

for seq_id = 1:training_seqs
    
    temp_array = original_seq;  % ����ԭʼ����
    if trial_random==1
        non_zero_indices = find(temp_array);  % �ҵ�����Ԫ�ص�����
        random_permutation = randperm(length(non_zero_indices));  % ���ɷ���Ԫ�ص��������
        temp_array(non_zero_indices) = temp_array(non_zero_indices(random_permutation));  % ��ԭʼ�����еķ���Ԫ����������
    end
    
    Trials = [Trials, temp_array];  % ���������е�������ӵ��������
end    

if trial_random==2
    Trials = preSet_seq;  % ֱ��ʹ��Ԥ���趨�õ���ֵ
end

%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
% ԭʼ���ݴ洢
TrialData = [];  % ����ԭʼ���ݵĲɼ���1��session����֮���洢�����ݸ�ʽ data = [data;TriggerRepeat]; TrialData = [TrialData,data];

% trial�������ֵ�洢�����±�����trial���ڵ����ݴ洢
% ���ھ���/������ʲ��ֵ�ָ��洢
MI_Acc = [];  % ���ڴ洢һ��trial��������з�����ʣ���һ��trial�����洢�����ݸ�ʽ MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)]; һ��trial����֮�� MI_Acc = [];
MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ��������ʣ���һ��trial�����洢�����ݸ�ʽ MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)]; һ��trial����֮�� MI_Acc_GlobalAvg = [];
resultsMI_voting = [];  % ���ڴ洢ͶƱ�Ľ������һ��trial�����洢�����ݸ�ʽ resultsMI_voting = [resultsMI_voting, resultMI(2:end,1)]; һ��trial����֮�� resultsMI_voting = [];

% ����ѵ��ʱ�̵����ݵĴ洢
TrialData_Processed = [];  % ���ڴ洢ѵ���е�ʵʱ���ݣ���һ��trial�����洢�� �洢��ʽ TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]]; һ��trial����֮�� TrialData_Processed = [];
% ����һЩ���Է�����ָ��Ĵ洢
mu_powers = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��muƵ����������ֵ����һ��trial����洢���洢��ʽmu_power_MI = [mu_power_MI; Trigger]; mu_powers = [mu_powers, mu_power_MI]; һ��trial����֮�� mu_powers = []; 
mu_suppressions = [];  % ���ڴ洢ÿһ��trial�����mu_suppression����һ��trial����洢���洢��ʽmu_suppression = [mu_suppression; Trigger]; mu_suppressions = [mu_suppressions, mu_suppression]; һ��trial����֮�� mu_suppressions = [];
mu_suppressions_normalized = [];  % ���ڴ洢ÿһ��trial�����mu_suppressions_normalized���ñ�����ʱ����
EI_indices = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��EI����ֵ����һ��trial����洢���洢��ʽ EI_index = [EI_index; Trigger]; EI_indices = [EI_indices, EI_index]; һ��trial����֮�� EI_indices = [];
EI_index_scores = [];  % ���ڴ洢EI_index_Caculation(EI_index, EI_channels)���������EI_index_score��ֵ���洢��ʽ EI_index_score = [EI_index_score; Trigger]; EI_index_scores = [EI_index_scores, EI_index_score]; һ��trial����֮�� EI_index_scores = [];
EI_index_scores_normalized = [];  % ���ڴ洢��һ����EI_index_scores��ֵ���ñ�����ʱ����
resultsMI = [];  % ���ڴ洢ÿһ��trial�����results����һ��trial����洢���洢��ʽ resultMI_ = [resultMI; Trigger]; resultsMI = [resultsMI, resultMI_]; һ��trial����֮�� resultsMI = [];

% ����ѵ��ʱ�̵Ĳ�����flag�Ĵ���
Train_Thre_Global_Flag = 0;  % �����ж��Ƿ�ﵽ��ֵ��flag���ﵽ��1��������0����һ��trial����֮����0
Flag_FesOptim = 0;  % �����ж���ѡ����л������ŵ�flag����ÿһ��trial֮ǰ�趨

% trial֮������ݴ洢�����±����Ǻ�Session�йصģ�����һ��session����֮����д洢
if session_idx==1
    Train_Thre_FesOpt = [];  % ���ڴ洢�滮����ֵ�����飬�洢��ʽ Train_Thre_FesOpt = [Train_Thre_FesOpt, [Train_Thre_Global_Optim; Flag_FesOptim; Trigger]]; ��TaskAdjustUpgraded_FeasibleOptimal_1�������и���
    MI_Acc_Trials = [];  % ���ڴ洢ȫ��ѵ���е�����trial�ķ�����ʣ�MI_Acc_Trials = [MI_Acc_Trials; [MI_Acc; Trigger]]
    MI_Acc_GlobalAvg_Trials = [];  % ���ڴ洢ȫ��ѵ���е�����trial�����ȫ�ֵ�ƽ��������ʣ�MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials; [MI_Acc_GlobalAvg(end); Trigger]]
    RestTimeLens = [];  % ���ڴ洢��Ϣʱ�䳤��
    Train_Performance = [];  % ���ڴ洢ÿһ��trial��ѵ�����֣� �洢��ʽ Train_Performance = [Train_Performance, [MI_Acc_GlobalAvg(end); Train_Thre_Global; Trigger]];
    Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;1]];
    Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;2]];  % ��ʼ��Train_Thre_FesOpt��һ��ʼ����ѡ�����
    muSups_trial = [];  % ���ڴ洢һ��trial��mu˥�����洢��ʽ muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial_Session)]];
    scores_trial = [];  % ���ڴ洢ÿһ��trial��ƽ������ֵ���洢��ʽ scores_trial = [scores_trial, average_score];
elseif session_idx > 1
    % ��֮ǰ���ļ��е���������
    foldername_trajectory = [foldername_Sessions, '\\Online_EEGMI_trajectory_', subject_name]; % ָ���ļ���·��������
    load([foldername_trajectory, '\\', ['Online_EEGMI_trajectory_', subject_name], '.mat'], 'scores_trial','traj_Feasible',...
    'RestTimeLens','muSups_trial', 'MI_Acc_Trials', 'MI_Acc_GlobalAvg_Trials', 'Train_Performance','Train_Thre_FesOpt');
end

while(AllTrial <= TrialNum_session)
    %% ��ʾרע�׶�
    if Timer==0  %��ʾרע cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
        if session_idx > 1
            AllTrial_Session = 12*(session_idx-1) + AllTrial;  % �����session����1���������Ҫ������ʵ�ʵ�AllTrial����ֵ
        else
            AllTrial_Session = AllTrial;
        end
        if mod(AllTrial,12)==0
            %RestTimeLen_idle = 60*3;
            RestTimeLen_idle = RestTimeLen_idleBasline;
            disp(["12��trial�ˣ���Ϣ3����"]);
        else
            RestTimeLen_idle = RestTimeLen_idleBasline;
        end
        if AllTrial > TrialNum_session
            break;
        end
    end
    
    %% �˶�����׶�
    % ��ʼ����ǰ��׼��
    if Timer==2
        if Trials(AllTrial_Session)==0  % ��������
            Trigger = 0;
            sendbuf(1,1) = hex2dec('03') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            sendbuf(1,8) = hex2dec('00');
            fwrite(UnityControl,sendbuf);
            % ��2s��ʱ��ȡ512��Trigger==6�Ĵ��ڣ����ݴ����ҽ��з���
            rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
            rawdata = rawdata(2:end,:);
            % ���������ȡ��MI֮ǰ��Ƶ������
            [preMIData_processed, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
            mu_power_ = [mu_power_; 6];
            mu_powers = [mu_powers, mu_power_];  % �����ص�mu��������
            TriggerRepeat_ = repmat(6,1,512);
            TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]];
        end
        if Trials(AllTrial_Session)> 0  % �˶���������
            Trigger = Trials(AllTrial_Session);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            sendbuf(1,8) = hex2dec('00');
            fwrite(UnityControl,sendbuf);  
        
            % ��2s��ʱ��ȡ512��Trigger==6�Ĵ��ڣ����ݴ����ҽ��з���
            rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
            rawdata = rawdata(2:end,:);
            % ���������ȡ��MI֮ǰ��Ƶ������
            [preMIData_processed, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
            mu_power_ = [mu_power_; 6];
            mu_powers = [mu_powers, mu_power_];  % �����ص�mu��������
            TriggerRepeat_ = repmat(6,1,512);
            TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]];
            
            % ������ֵ���ж�
            % �ȼ�����е���ֵ
            Trigger_num_ = count_trigger(Trials, AllTrial_Session);  % �������ڼ�����AllTrial��Ӧ��Trigger֮ǰ�Ѿ������˶��ٴΣ��Ӷ�����켣
            Train_Thre_Global_Fes = traj_Feasible{Trigger+1}(Trigger_num_+1);  % ������е���ֵ
            % ��ȡ��һ�����һ�ε��ж��ǿ��л�������
            Trial_tasks = Train_Thre_FesOpt(3,:);
            Train_Thre_FesOpt_ = Train_Thre_FesOpt(:, Trial_tasks==Trials(AllTrial_Session));
            Flag_FesOptim = Train_Thre_FesOpt_(2, end);  % ��ȡ��һ�ε����Ķ�Ӧ�Ŀ���/���ŵ�flag�ж�
            Train_Thre_Global_Optim = Train_Thre_FesOpt_(1, end);  % ��ȡ��һ�ε����Ķ�Ӧ�����ŵ���ֵ�������Ӧ���ж���ѡ�����ŵĻ�
            % ����TaskAdjustUpgraded_FeasibleOptimal���ж���ѡ����л�������
            if Flag_FesOptim == 0
                Train_Thre_Global = Train_Thre_Global_Fes;  % ѡ����� 
                disp(['������һ���������һ��ѡ�����']);
            else
                Train_Thre_Global = Train_Thre_Global_Optim;  % ѡ������
                if Train_Thre_Global < Train_Thre_Global_Fes
                    Train_Thre_Global = Train_Thre_Global_Fes;  % �������С�ڿ��н�������Ǿ�ʹ�ÿ��н�
                end
                disp(['������һ���������һ��ѡ������']);
            end
        end
        if fNIRS_Use==1
            % ��������ǩ
            oxy.WriteEvent('P', 'Prepare');
            disp('�������ǩ P');
        end
    end

    if Timer == 2 && Trials(AllTrial_Session)> 0 && Timer <= MI_preFeedBack  % ��ʼ��ʱ�򽫶�������֡��ʱ��
       sendbuf(1,2) = hex2dec('01') ;
       sendbuf(1,3) = hex2dec('00') ;
       sendbuf(1,5) = uint8(0);
       fwrite(UnityControl,sendbuf);
    end
    
    % ��ʼ��̬����
    % ����䶯
    if ((Timer-2) >1) && Trials(AllTrial_Session)> 0 && Timer <= MI_preFeedBack
        disp(['��ʼѵ��']);
        Trigger = Trials(AllTrial_Session);
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial_Session), sample_frequency, WindowLength, channels);
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        % ���͵÷��Լ�һϵ������
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0 ;0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
        % resultMI�����ݽṹ��[Ԥ������; �������ֱ��softmax����; ʵ�ʵ����]
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(1+(1+Trigger),1))]);  % ע�������Ӧ�Ĺ�ϵ������Ӧ����Trigger+2���ܶ�Ӧ�ϸ���
        disp(['probs: ', num2str(resultMI(2,1)), ', ', num2str(resultMI(3,1)), ',', num2str(resultMI(4,1))]);
        disp(['Trigger: ', num2str(Trigger)]);
        
        % �ռ�ȫ�ֵĸ��ʣ�������ʾ
        MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)];  
        MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
        resultsMI_voting = [resultsMI_voting, resultMI(2:end,1)];
        
        % ���ﵽȫ����ֵ��ʱ��flag��1
        if Timer == MI_preFeedBack
            if fNIRS_Use==1
                % ���������ݼ�¼
                FnirsLabelTask(Trials, AllTrial_Session, oxy);
            end

            if Flag_FesOptim == 1
                % ����ģʽ����������ֵ����ͶƱ��ֵ�����Դ�������
                resultsMI_voting_ = mean(resultsMI_voting, 2);
                [clspro_, cls_] = max(resultsMI_voting_);
                if cls_ == (Trigger+1)  % ������ֵ��Ӧ����trigger+1����ô����ͶƱ�����ʾ������ȷ
                    Train_Thre_Global_Flag = 1;
                    disp(['ͶƱ�ﵽ���� MI_Acc_GlobalAvg��', num2str(clspro_)]);
                end
                % ��ֵ�ﵽ���Ž�
                if MI_Acc_GlobalAvg(end) > Train_Thre_Global
                    Train_Thre_Global_Flag = 1;
                    disp(['��ֵ�ﵽ������������� MI_Acc_GlobalAvg��', num2str(MI_Acc_GlobalAvg(end)), ', Train_Thre_Global: ',num2str(Train_Thre_Global)]);
                end
            elseif Flag_FesOptim == 0
                % ����ģʽ�£��������ֵ����ͶƱֵ�����Դ�������
                resultsMI_voting_ = mean(resultsMI_voting, 2);
                [clspro_, cls_] = max(resultsMI_voting_);
                if cls_ == (Trigger+1)  % ������ֵ��Ӧ����trigger+1����ô����ͶƱ�����ʾ������ȷ
                    Train_Thre_Global_Flag = 1;
                    disp(['ͶƱ�ﵽ���� MI_Acc_GlobalAvg��', num2str(clspro_)]);
                end
                % ��ֵ�ﵽ���н�
                if MI_Acc_GlobalAvg(end) > Train_Thre_Global
                    Train_Thre_Global_Flag = 1;
                    disp(['��ֵ�ﵽ������������� MI_Acc_GlobalAvg��', num2str(MI_Acc_GlobalAvg(end)), ', Train_Thre_Global: ',num2str(Train_Thre_Global)]);
                end
            end
        end
        
        % ���ݸ�����ʾ���������ڸ���ʵʱ����
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
            % ����ֵ��һ����ȫ�ֵ���ֵTrain_Thre_Global��Χ��
            VisualFB_Rate_0 = MI_Acc_GlobalAvg(end-1)/Train_Thre_Global;
            VisualFB_Rate_1 = MI_Acc_GlobalAvg(end)/Train_Thre_Global;
            VisualFB_Rate_0 = max(0, min(1, VisualFB_Rate_0));  % �� VisualFB_Rate_0 Լ���� 0 �� 1 ֮��
            VisualFB_Rate_1 = max(0, min(1, VisualFB_Rate_1));  % �� VisualFB_Rate_1 Լ���� 0 �� 1 ֮��
            % ����Ҫչʾ��֡��
            VisualFB_0 = VisualFB_Rate_0 * MI_AO_Len;
            VisualFB_1 = VisualFB_Rate_1 * MI_AO_Len;
            disp(['feedback last:', num2str(VisualFB_0)]);
            disp(['feedback now:', num2str(VisualFB_1)]);
            % ͨ����֡�ķ�����������
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
            VisualFB_Rate_1 = max(0, min(1, VisualFB_Rate_1));  % �� VisualFB_Rate_1 Լ���� 0 �� 1 ֮��
            VisualFB_1 = VisualFB_Rate_1 * MI_AO_Len;
            disp(['feedback now:', num2str(VisualFB_1)]);
            sendbuf(1,5) = uint8(VisualFB_1);
            fwrite(UnityControl,sendbuf);
        end
        
        % �ռ���ε����ݣ�׼���������
        TriggerRepeat_ = repmat(Trigger,1,512);
        TrialData_Processed = [TrialData_Processed; [FilteredDataMI;TriggerRepeat_]];
        
%         % ����EIָ��Ĺ�һ������
%         EI_index_score_normalized = EI_normalization(EI_index_score, min_max_value_EI.min_max_value_EI);
%         mu_suppression_normalized = mu_normalization(mu_suppression, min_max_value_mu.min_max_value_mu, Trigger+1);

        % �洢��һϵ��ָ�����ֵ
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % ���������Trigger�������ֵ������洢
        mu_suppression = [mu_suppression; Trigger]; % ���������Trigger�������ֵ������洢
        EI_index_score = [EI_index_score; Trigger];
%         EI_index_score_normalized = [EI_index_score_normalized; Trigger];
        resultMI_ = [resultMI; Trigger];
%         mu_suppression_normalized = [mu_suppression_normalized; Trigger];

        
        resultsMI = [resultsMI, resultMI_];
        EI_index_scores = [EI_index_scores, EI_index_score];
%         EI_index_scores_normalized = [EI_index_scores_normalized, EI_index_score_normalized];
        EI_indices = [EI_indices, EI_index];  % �����ص�EIָ����ֵ  
        mu_powers = [mu_powers, mu_power_MI];  % �����ص�mu��������
        mu_suppressions = [mu_suppressions, mu_suppression];  % �����ص�mu˥����������ں����ķ���
%         mu_suppressions_normalized = [mu_suppressions_normalized, mu_suppression_normalized]; 
    
    end
    
   %% ��Ϣ̬ѵ���׶�
   if ((Timer-2) >1) && (Timer <=Idle_preBreak) && Trials(AllTrial_Session)==0
        Trigger = Trials(AllTrial_Session);
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial_Session), sample_frequency, WindowLength, channels);
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        % ���͵÷��Լ�һϵ������
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(1+(1+Trigger),1))]); % ע�������Ӧ�Ĺ�ϵ������Ӧ����Trigger+2���ܶ�Ӧ�ϸ���
        disp(['probs: ', num2str(resultMI(2,1)), ', ', num2str(resultMI(3,1)), ',', num2str(resultMI(4,1))]);
        disp(['Trigger: ', num2str(Trigger)]);
        
        % �ռ�ȫ�ֵĸ��ʣ�������ʾ
        MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)];
        MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
        resultsMI_voting = [resultsMI_voting, resultMI(2:end,1)];
        % �ռ���ε����ݣ�׼���������
        TriggerRepeat_ = repmat(Trigger,1,512);
        TrialData_Processed = [TrialData_Processed; [FilteredDataMI;TriggerRepeat_]];
        
%         % ����EIָ��Ĺ�һ������
%         EI_index_score_normalized = EI_normalization(EI_index_score, min_max_value_EI.min_max_value_EI);
%         mu_suppression_normalized = mu_normalization(mu_suppression, min_max_value_mu.min_max_value_mu, Trigger+1);

        % �洢��һϵ��ָ�����ֵ
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % ���������Trigger�������ֵ������洢
        %mu_suppression = [mu_suppression; Trigger]; % ���������Trigger�������ֵ������洢
        EI_index_score = [EI_index_score; Trigger];
%         EI_index_score_normalized = [EI_index_score_normalized; Trigger];
        resultMI_ = [resultMI; Trigger];
%         mu_suppression_normalized = [mu_suppression_normalized; Trigger];

        
        resultsMI = [resultsMI, resultMI_];
        EI_index_scores = [EI_index_scores, EI_index_score];
%         EI_index_scores_normalized = [EI_index_scores_normalized, EI_index_score_normalized];
        EI_indices = [EI_indices, EI_index];  % �����ص�EIָ����ֵ  
        mu_powers = [mu_powers, mu_power_MI];  % �����ص�mu��������
        mu_suppressions = [mu_suppressions, mu_suppression];  % �����ص�mu˥����������ں����ķ���
%         mu_suppressions_normalized = [mu_suppressions_normalized, mu_suppression_normalized]; 
        
        if fNIRS_Use==1
            if Timer==Idle_preBreak
                % ���������ݼ�¼
                FnirsLabelTask(Trials, AllTrial_Session, oxy);
            end
        end
   end
   %% �˶�������뷴���׶Σ����/ʱ�䷶Χ��û����ԣ�,ͬʱ����ģ��
   if Timer == MI_preFeedBack && Trials(AllTrial_Session) > 0
       Trigger = 8;
       if Train_Thre_Global_Flag==1  % �������ˣ��ﵽ��ֵ
           if Trials(AllTrial_Session) > 0  % �˶���������
                % ���Ŷ�����AO������Idle, MI1, MI2��
                mat2unity = ['0', num2str(Trials(AllTrial_Session) + 3)];
                sendbuf(1,1) = hex2dec(mat2unity);
                sendbuf(1,2) = hex2dec('04') ;  % 0x04: 4���ٲ���, 0x02: 2���ٲ���, 0x01: 1���ٲ���, ָ������֡ 
                sendbuf(1,3) = hex2dec('01') ;  % ���뷴������ʾ����
                sendbuf(1,4) = hex2dec('00') ;
                sendbuf(1,8) = hex2dec('00') ;
                fwrite(UnityControl,sendbuf);  
            end
            
            % ���е�̼�
            if Trials(AllTrial_Session) == 1
                StimCommand = StimCommand_1;
                fwrite(StimControl,StimCommand);
            end
            if Trials(AllTrial_Session) == 2
                StimCommand = StimCommand_2;
                fwrite(StimControl,StimCommand);
            end
            disp(['MI�ﵽ��ֵ��̼�']);
       else  % ���û�����
            if Trials(AllTrial_Session) > 0  % �˶���������
                % ���Ŷ�����AO������Idle, MI1, MI2��
                mat2unity = ['0', num2str(Trials(AllTrial_Session) + 3)];
                sendbuf(1,1) = hex2dec(mat2unity);
                sendbuf(1,2) = hex2dec('00') ;
                sendbuf(1,3) = hex2dec('02') ;  % ���뷴������ʾ����
                sendbuf(1,4) = hex2dec('00') ;
                sendbuf(1,8) = hex2dec('00') ;
                fwrite(UnityControl,sendbuf);  
            end
       end
       % ȷ����е�۵ĸ���
       [MI_AOTime_Moving, MI_AOTime_Preparing, MovingCommand, PreparingCommand, MovingCommand_glo, PreparingCommand_glo] = RobotCommand(Train_Thre_Global_Flag, Trials(AllTrial_Session), Trials(AllTrial_Session+1));
       % ��ǰ�Ļ�е��������ֱ����MI����֮���������
       textSend = MovingCommand;
       fwrite(RobotControl, textSend);
       % ��ǰ�������ֵ�����
       if strcmp(MovingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(MovingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['�������: ', num2str(Train_Thre_Global_Flag)]);
       disp(['��ǰ�����е���ƶ�ʱ�䣺', num2str(MI_AOTime_Moving), '; ', '��ǰָ� ', MovingCommand, ', ', MovingCommand_glo]);
       disp(['��һ�����е��׼��ʱ�䣺', num2str(MI_AOTime_Preparing), '; ', '��һ����ָ� ', PreparingCommand, ', ', PreparingCommand_glo]);

       % �������ݺ͸���ģ��
       config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
       order = 2.0;  % �������ݺ�ѵ��������
       Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        
       % ������flag�����������ʶ�������ζ���Ҫ��0��
       Train_Thre_Global_Flag = 0;
   end
   
   % ��е�����ṩ������ǰ���������֮�󣬻����е���һ��������������
   % ��ǰ��MI�����ʱ�򣬽�������֮�󣬻����е���һ��������׼�����֣�MI_preFeedBack+MI_AOTime_Moving��ֱ���������е���һ��MI�����λ�õ�ʱ���
   if Timer == MI_preFeedBack+MI_AOTime_Moving && Trials(AllTrial_Session) > 0
       % Ϊ��һ����Ļ�е��������ǰ����׼��
       textSend = PreparingCommand;
       fwrite(RobotControl, textSend);
       % ��ǰ�������ֵ�����
       if strcmp(PreparingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(PreparingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['��ǰ����: ', num2str(Trials(AllTrial_Session)), "��һ����: ", num2str(Trials(AllTrial_Session+1)), "��е��Ϊ��һ��������"]);
   end

   %% ��Ϣ�׶Σ�ȷ����һ������
    % ����ֻ��5s����Ϣ
    if Timer==Idle_preBreak && Trials(AllTrial_Session)==0  %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % �����㷨
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ����ȷ����һ������
        average_score = mean(EI_index_scores(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        max_MuSup = max(mu_suppressions(1,:));  % ��������Mu˥��������ֵ����������������
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial_Session)]];  % �洢��������
        %visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial_Session)]];  % �洢����Ӿ��������
        MI_Acc_Trials = [MI_Acc_Trials, [MI_Acc; repmat(Trials(AllTrial_Session),1,length(MI_Acc));]];  % �洢����
        MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials, [MI_Acc_GlobalAvg(end); Trials(AllTrial_Session)]];

        % ��Ϣ̬�����ݲɼ�������ֵ����
        RestTimeLen_ = [RestTimeLen_idle; Trials(AllTrial_Session)];  % ��Ϣ̬��Ϣ5s
        RestTimeLens = [RestTimeLens, RestTimeLen_];

        % ȷ����е�۵ĸ���
       [MI_AOTime_Moving, MI_AOTime_Preparing, MovingCommand, PreparingCommand, MovingCommand_glo, PreparingCommand_glo] = RobotCommand(Train_Thre_Global_Flag, Trials(AllTrial_Session), Trials(AllTrial_Session+1));
       % ��ǰ�Ļ�е���������ھ�Ϣ̬��ʱ���ⲿ��ֱ�Ӿ��ǲ�����
       textSend = MovingCommand;
       fwrite(RobotControl, textSend);
       % ��ǰ�������ֵ�����
       if strcmp(MovingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(MovingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['��ǰ�����е���ƶ�ʱ�䣺', num2str(MI_AOTime_Moving), '; ', '��ǰָ� ', MovingCommand, ', ', MovingCommand_glo]);
       disp(['��һ�����е��׼��ʱ�䣺', num2str(MI_AOTime_Preparing), '; ', '��һ����ָ� ', PreparingCommand, ', ', PreparingCommand_glo]);
    end
    
    % ��е�����ṩ������ǰ���������֮�󣬻����е���һ��������������
    % �ھ�Ϣ̬��ʱ��ֱ��׼�����е���һ��MI�����λ�ã�MI_preFeedBack+MI_AOTime_Moving��ֱ���������е���һ��MI�����λ�õ�ʱ���
    if Timer == Idle_preBreak+MI_AOTime_Moving && Trials(AllTrial_Session)==0
       % Ϊ��һ����Ļ�е��������ǰ����׼��
       textSend = PreparingCommand;
       fwrite(RobotControl, textSend);
       % ��ǰ�������ֵ�����
       if strcmp(PreparingCommand_glo, 'G3')
            sendbuf_glo(1,1) = hex2dec('ff') ;
            sendbuf_glo(1,2) = hex2dec('ff') ;
       elseif strcmp(PreparingCommand_glo, 'G2')
            sendbuf_glo(1,1) = hex2dec('bf') ;
            sendbuf_glo(1,2) = hex2dec('bf') ;
       end
       fwrite(GloveControl, sendbuf_glo);
       disp(['��ǰ����: ', num2str(Trials(AllTrial_Session)), "��һ����: ", num2str(Trials(AllTrial_Session+1)), "��е��Ϊ��һ��������"]);
    end
    

    % �˶�����֮��AO�����ֽ�����֮��������Ϣ
    if Trials(AllTrial_Session)>0 && Timer == (MI_preFeedBack+MI_AOTime_Moving+MI_AOTime_Preparing)   %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % ����ȷ����һ������
        average_score = mean(EI_index_scores(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        max_MuSup = max(mu_suppressions(1,:));  % ��������Mu˥��������ֵ����������������
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial_Session)]];  % �洢��������
        %visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial_Session)]];  % �洢����Ӿ��������
        MI_Acc_Trials = [MI_Acc_Trials, [MI_Acc; repmat(Trials(AllTrial_Session),1,length(MI_Acc));]];  % �洢����
        MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials, [MI_Acc_GlobalAvg(end); Trials(AllTrial_Session)]];
        Train_Performance = [Train_Performance, [MI_Acc_GlobalAvg(end); Train_Thre_Global; Trials(AllTrial_Session)]];
        
        % ��ֵ�������ֻ���Ҫ�޸�
        [Flag_FesOptim, Train_Thre_Global_Optim, RestTimeLen, Train_Thre_FesOpt] = TaskAdjustUpgraded_FeasibleOptimal_1(scores_trial, Train_Performance, Train_Thre_FesOpt, Trials, AllTrial_Session, RestTimeLenBaseline, min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial_Session)];  % MI����ᶯ̬������Ϣ��ʱ��
        RestTimeLens = [RestTimeLens, RestTimeLen_];

        if fNIRS_Use==1
            % ���������ݼ�¼
            oxy.WriteEvent('M', 'Moving');
            disp('�������ǩ M');
        end
    end
    
    %% ʱ�Ӹ���
    % ���ɱ�ǩ
    TriggerRepeat = repmat(Trigger,1,256);  % ���ɱ�ǩ
    % �Ե��źŲɼ�
    tic
    pause(1);
    [~, data] = ClientGetDataPacket(con,basicInfo,infoList,startStop,init); % Obtain EEG data, ��Ҫ��ClientGetDataPacket����Ҫ��Ҫ�Ƴ�����
    toc
    data = [data;TriggerRepeat];
    TrialData = [TrialData,data];
    Timer = Timer + 1;
    disp(['ʱ�䣺', num2str(Timer)]);
    
    %% ���ĸ�����ֵ��λ
    % ������������12s������12s֮��ʼ��Ϣ������17s�ͽ�������
    if Timer == Idle_preBreak+MI_AOTime_Moving+MI_AOTime_Preparing && Trials(AllTrial_Session)==0  %������Ϣ��׼����һ��
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed, resultsMI_voting);
        %��ʱ����0
        Timer = 0;  % ��ʱ����0
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        resultsMI = [];  % MI������������ֵ��ԭ
        EI_index_scores = [];  % EIָ�걣����ֵ��ԭ
        mu_suppressions = [];  % mu˥��������ֵ��ԭ
        mu_suppressions_normalized = [];
        visual_feedbacks = [];
        EI_index_scores_normalized = [];
        MI_Acc = [];  % ���ڴ洢һ��trial��������з������
        MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ���������
        TrialData_Processed = [];
        resultsMI_voting = [];
        
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial_Session), ', Task: ', num2str(Trials(AllTrial_Session))]);  % ��ʾ�������
        if fNIRS_Use==1
            % ���������ݼ�¼
            oxy.WriteEvent('R', 'Resting');
            disp('�������ǩ R');
        end
    end
    % �����֮��AO֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Trials(AllTrial_Session)>0 && Timer == (MI_preFeedBack+MI_AOTime_Moving+MI_AOTime_Preparing + RestTimeLen)  %������Ϣ
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed, resultsMI_voting);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        resultsMI = [];  % MI������������ֵ��ԭ
        EI_index_scores = [];  % EIָ�걣����ֵ��ԭ
        mu_suppressions = [];  % mu˥��������ֵ��ԭ
        mu_suppressions_normalized = [];
        visual_feedbacks = [];
        EI_index_scores_normalized = [];
        MI_Acc = [];  % ���ڴ洢һ��trial��������з������
        MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ���������
        TrialData_Processed = [];
        resultsMI_voting = [];
        
        % �������û�ԭ
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial_Session), ', Task: ', num2str(Trials(AllTrial_Session))]);  % ��ʾ�������
        if fNIRS_Use==1
            % ���������ݼ�¼
            oxy.WriteEvent('R', 'Resting');
            disp('�������ǩ R');
        end
    end
end
%% �洢ԭʼ����
close all
TrialData = TrialData(2:end,:);  %ȥ�������һ��
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % �����ӹر�
% �洢ԭʼ����
if session_idx==1
    foldername_rawdata = [foldername, '\\Online_EEGMI_RawData_', subject_name]; % ָ���ļ���·��������
    if ~exist(foldername_rawdata, 'dir')
       mkdir(foldername_rawdata);
    end
    save([foldername_rawdata, '\\', ['Online_EEGMI_RawData_', 'session_', num2str(session_idx), '_', subject_name], '.mat' ],'TrialData','Trials','ChanLabel');
else
    foldername_rawdata = [foldername_Sessions, '\\Online_EEGMI_RawData_', subject_name]; % ָ���ļ���·��������
    save([foldername_rawdata, '\\', ['Online_EEGMI_RawData_', 'session_', num2str(session_idx), '_', subject_name], '.mat' ],'TrialData','Trials','ChanLabel');
end
%% �洢�켣׷������������ָ�꣬�ⲿ����һ��session����֮��Ż�洢����ֹһ��session�����жϵ��µĶ�洢
if session_idx==1
    foldername_trajectory = [foldername, '\\Online_EEGMI_trajectory_', subject_name]; % ָ���ļ���·��������
    if ~exist(foldername_trajectory, 'dir')
       mkdir(foldername_trajectory);
    end
    save([foldername_trajectory, '\\', ['Online_EEGMI_trajectory_', subject_name], '.mat'],'scores_trial','traj_Feasible',...
        'RestTimeLens','muSups_trial', 'MI_Acc_Trials', 'MI_Acc_GlobalAvg_Trials', 'Train_Performance','Train_Thre_FesOpt');
elseif session_idx > 1  % ���session����1�Ļ������Խ��и��Ǵ洢
    save([foldername_trajectory, '\\', ['Online_EEGMI_trajectory_', subject_name], '.mat'],'scores_trial','traj_Feasible',...
        'RestTimeLens','muSups_trial', 'MI_Acc_Trials', 'MI_Acc_GlobalAvg_Trials', 'Train_Performance','Train_Thre_FesOpt','-append');
end

%% ������ʾ��ز���
% ������Ϣ����
message = ['��ǰ��session: ', num2str(session_idx), ', ע��������Ƭ�����������ӻ�е��'];
% ��ʾ����
h = msgbox(message, 'Session Alert');

%% �洢���˶���������еĲ����ָ��
function SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
    MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed, resultsMI_voting)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % �����ļ����Ƿ����
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', ['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' ],'EI_indices','mu_powers','mu_suppressions', 'EI_index_scores','resultsMI',...
        'MI_Acc','MI_Acc_GlobalAvg','TrialData_Processed', 'resultsMI_voting');  % �洢��ص���ֵ
end
%% �������muƵ��˥��ָ�꣬������Ҫ�޸�
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % ���������Ե�λ�õ���ص�ָ�� 
    mu_suppresion = - ERD_C3;  % ȡ��ֵ�������Ļ���ֵԽ��Խ��ERDЧӦԽ��
end

%% ������ص�EIָ��ĺ���
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.F3, EI_channels.Fz, EI_channels.F4];
    EI_index_score = mean(EI_index(channels_, 1));
end

%% ���ɿ��в��ֵĹ켣����
% Trials�����жϵ�ǰ����Ѿ����ֹ����ٴεĺ��������ھ�ϸ�Ĺ켣����
function count = count_trigger(Trials, AllTrial)
    % ��ȡ Trigger
    Trigger = Trials(AllTrial);
    
    % ���� Trigger �� Trials(1:AllTrial-1) �е�����
    count = sum(Trials(1:AllTrial-1) == Trigger);
end

function traj = generate_traj_feasible(Probs_Feasible, TrialNum)
    % ��ȡ��������
    n = size(Probs_Feasible, 2);

    % ��ʼ��һ���յ� cell �������洢ÿ�����Ĺ켣
    traj = cell(1, n);

    % ����ÿһ�����
    for i = 1:n
        % ��ȡ��ʼ����ص����ֵ
        Prob_lower1 = Probs_Feasible(1, i);
        Prob_lower2 = Probs_Feasible(2, i);

        % ��ʼ��һ���յ��������洢�켣
        traj{i} = zeros(TrialNum, 1);
        
        % ����켣
        for x = 1:TrialNum
            traj{i}(x) = Prob_lower1 + (Prob_lower2 - Prob_lower1) * (1 - exp(-3 * x / TrialNum));
        end
    end
end
%% ��һ����ʾ�ĺ�������Ҫ���ڹ�һ���ĺ�����ʾ
function mu_normalized = mu_normalization(mu_data, min_max_value_mu, Trigger)
    % ��ȡ������С��ֵ
    data_max = min_max_value_mu(1, Trigger);
    data_min = min_max_value_mu(2, Trigger);
    % ��һ����ص����ݣ�ʹ������0��1�ķ�Χ��
    mu_normalized = (mu_data - data_min)/(data_max - data_min);
end
function EI_normalized = EI_normalization(EI_data, min_max_value_EI)
    % ��ȡ������С��ֵ
    data_max = max(min_max_value_EI(1,:));
    data_min = min(min_max_value_EI(2,:));
    % ��һ����ص����ݣ�ʹ������0��1�ķ�Χ��
    EI_normalized = (EI_data - data_min)/(data_max - data_min);
end

%% ���ƻ�е�ۺ������ֵĺ��������ڿ���ʵ�ʶ���ִ�в��ֵĻ�е�ۺ������ֲ��ֵĹ���
% ���벿��Ϊ: Train_Thre_Global_Flag ��ǰ��MIִ����������
% Trials(AllTrial_Session)��Trials(AllTrial_Session+1)
% ��ǰ�Լ��������˶��������ڲ�����е���ƶ���λ��
% �������Ϊ��MI_AOTime_Moving ׼����һ��������ʱ�䣬MI_AOTime_Preparing ��һ���������֮��׼����Ϣ��ʱ��
% MovingCommand ��е����ɶ���֮���ƶ������� PreparingCommand ��е��׼����һ��������ָ��
% MovingCommand_glo ��������ɶ���֮���ƶ������� PreparingCommand_glo ������׼����һ��������ָ��
function [MI_AOTime_Moving, MI_AOTime_Preparing, MovingCommand, PreparingCommand, MovingCommand_glo, PreparingCommand_glo] = RobotCommand(Train_Thre_Global_Flag, Task_now, Task_next)
    % ���ǵ�һ�������Ҳ����MI��ʱ��ͨ����ǰ��MI����Լ�������ʵ������������о�
    if Task_now > 0
        % û����Ե�����£�ֱ�ӽ��������׼����
        if Train_Thre_Global_Flag==0
            MI_AOTime_Moving=2;  % ����2s֮��ͽ���׼������MI�Ļ�е���ƶ�
            MI_AOTime_Preparing=3;  % ׼������MI�Ļ�е���ƶ�3s֮���ֱ�ӽ�����Ϣ�������Ļ�����AO+FES+Robot��ʱ�仹��5s
            MovingCommand='Y0';  % ��ʱY0���ƶ���е��
            MovingCommand_glo='G3';  % ��ʱ�����ַ���״̬
            % ׼������MI�Ļ�е���ƶ�
            if Task_next==0 || Task_next==1
                PreparingCommand='Y3';
                PreparingCommand_glo='G3';  % ��ʱ�����ַ���״̬
            end
            if Task_next==2
                PreparingCommand='Y4';
                PreparingCommand_glo='G3';  % ��ʱ�����ַ���״̬
            end
        end
        if Train_Thre_Global_Flag==1
            % ��ʱ�����Ѿ���ԣ���Ҫ����
            if Task_now==1
                MI_AOTime_Moving=4;  % ��ǰ��Ҫ����ʵ�ʵ����������ƶ���е�ۣ�����4s֮��ͽ���׼������MI�Ļ�е���ƶ�
                MovingCommand='Y1';
                MovingCommand_glo='G3';  % ��ʱ�����ַ���״̬
            end
            if Task_now==2
                MI_AOTime_Moving=8;  % ��ǰ��Ҫ����ʵ�ʵ����������ƶ���е�ۣ�����8s֮��ͽ���׼������MI�Ļ�е���ƶ�
                MovingCommand='Y2';
                MovingCommand_glo='G2';  % ��ʱ��������ȭ
            end
            MI_AOTime_Preparing=3;  % ׼������MI�Ļ�е���ƶ�3s֮���ֱ�ӽ�����Ϣ�������Ļ�����AO+FES+Robot��ʱ����MI_AOTime_Moving+MI_AOTime_Preparing
            if Task_next==0 || Task_next==1
                PreparingCommand='Y3';
                PreparingCommand_glo='G3';  % ��ʱ�����ַ���״̬
            end
            if Task_next==2
                PreparingCommand='Y4';
                PreparingCommand_glo='G3';  % ��ʱ�����ַ���״̬
            end
        end
    end
    if Task_now == 0
        % �������˶��Ǿ�Ϣ̬��ʱ��
        MI_AOTime_Moving=1;
        MI_AOTime_Preparing=4;  % ����ʱ����΢���һ��
        MovingCommand='Y0';
        MovingCommand_glo='G3';  % ��ʱ�����ַ���״̬
        % ���Ǹ��ݺ��������������ʵ�ʵ�λ��
        if Task_next==0 || Task_next==1
            PreparingCommand='Y3';
            PreparingCommand_glo='G3';  % ��ʱ�����ַ���״̬
        end
        if Task_next==2
            PreparingCommand='Y4';
            PreparingCommand_glo='G3';  % ��ʱ�����ַ���״̬
        end
    end
end

%% �����ⷢ�������ǩ
% ���������ڽ������������ڼ��״̬
% �����������弯��RandomTrial, �ڼ�������AllTrial, ����������oxy
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

    disp(['Oxy ���ͣ�', task_oxy, ', ���� ', name_oxy]);
    oxy.WriteEvent(task_oxy, name_oxy);
end