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
%system('E:\UpperLimb_AO_NewModel_MI\unity_test.exe&');
%system('D:\workspace\UpperLimb_AO_NewModel_MI\unity_test.exe&');
system('D:\workspace\UpperLimb_AO_NewModel_MI_ReachGrasp\unity_test.exe&');

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
subject_name = 'Jyt_test_0513_online';  % ��������������ʹ���ҵ�������ʱ���ڲ���
sub_offline_collection_folder = 'Jyt_test_0513_offline_20240513_171257133_data';  % ���Ե����߲ɼ�����
subject_name_offline =  'Jyt_test_0513_offline';  % �����ռ�����ʱ��ı�������
MotorClass = 2; % �˶�������������ע�������Ǵ���Ƶ��˶�������������������������idle״̬
%MotorClassMI = 2;  % ����ǵ��˶���������Ļ����Ǿ�ֱ��ָ������ͺ���
original_seq = [1,2, 0,0, 1,2, 0,0, 1,2, 1,2, 0,0];  % ԭʼ��������
%original_seq = [1, 2, 0];  % ԭʼ��������
training_seqs = 4;  % ѵ������
session_idx = 1;  % session index�����������1�Ļ������Զ���������Ų�
TrialNum = length(original_seq)*training_seqs;  % ÿһ������trial������

% �˶����������������
score_init = 1.0;  % ������֮ǰ����ʱ������mu˥����EIָ��ľ�ֵ
MaxMITime = 35; % �����˶������������ʱ�� 
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
weight_mu = 0.6;  % ���ڼ���ERD/ERSָ���EIָ��ļ�Ȩ��
MI_MUSup_thre = 0;  % ����MIʱ�����ֵ��ʼ��
MI_MUSup_thre_weight_baseline = 0.714;  % ���ڼ���MIʱ���mu˥������ֵȨ�س�ʼ����ֵ�����Ȩ��һ���Ǻͷ���ĸ�����صģ�Ҳ������������ݽ��е���
MI_MUSup_thre_weight = MI_MUSup_thre_weight_baseline;  % ���ڼ���MIʱ���mu˥������ֵȨ����ֵ�����Ȩ��һ���Ǻͷ���ĸ�����صģ�Ҳ������������ݽ��е���
trial_random = 0;  % �����ж��Ƿ�������ѵ��˳��Ĳ��� false 0�� true 1


% ͨ�����ã��������ӱ���python���㷨����
%ip = '172.18.22.21';
ip = '127.0.0.1';
port = 8880;  % �ͺ�˷��������ӵ���������

% ��̼�ǿ������
StimAmplitude_1 = 7;
StimAmplitude_2 = 9;  % ��ֵ���ã�mA��

% %% ���õ�̼�����
% ��������
system('D:\workspace\fes\x64\Debug\fes.exe&');
pause(1);
StimControl = tcpip('localhost', 8888, 'NetworkRole', 'client','Timeout',1000);
StimControl.InputBuffersize = 1000;
StimControl.OutputBuffersize = 1000;

% ���õ�̼���ز���
fopen(StimControl);
tStim = [3,14,2]; % [t_up,t_flat,t_down] * 100ms
StimCommand_1 = uint8([0,StimAmplitude_1,tStim,1]); % left calf
StimCommand_2 = uint8([0,StimAmplitude_2,tStim,2]); % left thigh

%% ��е�ۺ������ֵ�ͨ�Ų���
RobotControl = tcpip('localhost', 5288, 'NetworkRole','client');
fopen(RobotControl);
GloveControl = tcpip("192.168.2.30", 8003, 'NetworkRole','client');
fopen(GloveControl);

%% ׼����ʼ�Ĵ洢���ݵ��ļ���
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % ָ���ļ���·��������
if ~exist(foldername, 'dir')
   mkdir(foldername);
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
    if trial_random
        non_zero_indices = find(temp_array);  % �ҵ�����Ԫ�ص�����
        random_permutation = randperm(length(non_zero_indices));  % ���ɷ���Ԫ�ص��������
        temp_array(non_zero_indices) = temp_array(non_zero_indices(random_permutation));  % ��ԭʼ�����еķ���Ԫ����������
    end

    Trials = [Trials, temp_array];  % ���������е�������ӵ��������
end    


%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];  % ����ԭʼ���ݵĲɼ�

% ���ھ���/������ʲ��ֵ�ָ��洢
MI_Acc = [];  % ���ڴ洢һ��trial��������з������
MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ���������
MI_Acc_Trials = [];  % ���ڴ洢ȫ��ѵ���е�����trial�ķ�����ʣ�MI_Acc_Trials = [MI_Acc_Trials; [MI_Acc; Trigger]]
MI_Acc_GlobalAvg_Trials = [];  % ���ڴ洢ȫ��ѵ���е�����trial�����ȫ�ֵ�ƽ��������ʣ�MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials; [MI_Acc_GlobalAvg; Trigger]]

% ����ѵ��ʱ�̵����ݵĴ洢
Train_Seg = 0;  % ����ȷ���ǵڼ���Seg����ֵ
TrialData_Processed = [];  % ���ڴ洢ѵ���е�ʵʱ���ݣ�TrialData_Processed = [TrialData_Processed; [[Data_preprocessed;Trigger],[Data_preprocessed;Trigger],...[Data_preprocessed;Trigger]]]

% ����һЩ���Է�����ָ��Ĵ洢
mu_powers = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��muƵ����������ֵ
mu_suppressions = [];  % ���ڴ洢ÿһ��trial�����mu_suppression
mu_suppressions_normalized = [];  % ���ڴ洢ÿһ��trial�����mu_suppressions_normalized
EI_indices = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��EI����ֵ
EI_index_scores = [];  % ���ڴ洢EI_index_Caculation(EI_index, EI_channels)���������EI_index_score��ֵ
EI_index_scores_normalized = [];  % ���ڴ洢��һ����EI_index_scores��ֵ
resultsMI = [];  % ���ڴ洢ÿһ��trial�����results
muSups_trial = [];  % ���ڴ洢һ��trial��mu˥��
scores_trial = [];  % ���ڴ洢ÿһ��trial��ƽ������ֵ
RestTimeLens = [];  % ���ڴ洢��Ϣʱ�䳤��

% ����ѵ��ʱ�̵Ĳ�����flag�Ĵ���
Train_Thre = 0.45;  % ���ں���������keep����adjust����ֵ
Train_Flag = 0;  % �����ж���keep����adjust��flag
Train_Thre_Global_FeasibleInit = [0, 0.35, 0.35;
                                  0, 0.45, 0.45;
                                  0, 1,    2;];  % ��ʼ��ֵ�����ڿ��в��ֹ켣������
traj_Feasible = generate_traj_feasible(Train_Thre_Global_FeasibleInit, TrialNum);  % ����������ֵ�Ĺ켣�ĺ���
Train_Thre_Global = Train_Thre_Global_FeasibleInit(1,1);  % ���ڲ��ҵ��������ȫ�־�ֵ�Ŀ���-���Ų��Ե���ֵ�趨
Train_Thre_Global_Flag = 0;  % �����ж��Ƿ�ﵽ��ֵ��flag
Train_Performance = [];  % ���ڴ洢ÿһ��trial��ѵ�����֣� Train_Performance = [Train_Performance, [max(MI_Acc_GlobalAvg); Train_Thre_Global; Trigger]];
Flag_FesOptim = 0;  % �����ж���ѡ����л������ŵ�flag 
Train_Thre_FesOpt = [];  % ���ڴ洢�滮����ֵ�����飬�洢���� Train_Thre_FesOpt = [Train_Thre_FesOpt, [Train_Thre_Global_Optim; Flag_FesOptim; Trigger]];
Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;1]];
Train_Thre_FesOpt = [Train_Thre_FesOpt, [0;0;2]];  % ��ʼ��Train_Thre_FesOpt��һ��ʼ����ѡ�����

Online_FES_ExamingNum = 5;  % ���ߵ�ʱ��ÿ����ü���ж��Ƿ���Ҫ����FES����
Online_FES_flag = 0;  % ���������Ƿ����ʵʱFES�̼�����ؿ���flag
RestTimeLenBaseline = 7 + session_idx;  % ��Ϣʱ������session����������
RestTimeLen = RestTimeLenBaseline;  % ��ʼ����Ϣʱ��

% ����ָ��Ͳ���
MI_AO_Len = 150;  % ����ʵ���ж���֡

while(AllTrial <= TrialNum)
    %% ��ʾרע�׶�
    if Timer==0  %��ʾרע cross
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
    
    %% �˶�����׶�
    % ��ʼ����ǰ��׼��
    if Timer==2
        if Trials(AllTrial)==0  % ��������
            Trigger = 0;
            sendbuf(1,1) = hex2dec('03') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            sendbuf(1,8) = hex2dec('00');
            fwrite(UnityControl,sendbuf);  
        end
        if Trials(AllTrial)> 0  % �˶���������
            Trigger = Trials(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
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
            Trigger_num_ = count_trigger(Trials, AllTrial);  % �������ڼ�����AllTrial��Ӧ��Trigger֮ǰ�Ѿ������˶��ٴΣ��Ӷ�����켣
            Train_Thre_Global_Fes = traj_Feasible{Trigger+1}(Trigger_num_+1);  % ������е���ֵ
            % ��ȡ��һ�����һ�ε��ж��ǿ��л�������
            Trial_tasks = Train_Thre_FesOpt(3,:);
            Train_Thre_FesOpt_ = Train_Thre_FesOpt(:, Trial_tasks==Trials(AllTrial));
            Flag_FesOptim = Train_Thre_FesOpt_(2, end);  % ��ȡ��һ�ε����Ķ�Ӧ�Ŀ���/���ŵ�flag�ж�
            Train_Thre_Global_Optim = Train_Thre_FesOpt_(1, end);  % ��ȡ��һ�ε����Ķ�Ӧ�����ŵ���ֵ�������Ӧ���ж���ѡ�����ŵĻ�
            % ����TaskAdjustUpgraded_FeasibleOptimal���ж���ѡ����л�������
            if Flag_FesOptim == 0
                Train_Thre_Global = Train_Thre_Global_Fes;  % ѡ�����
                disp(['������һ���������һ��ѡ�����']);
            else
                Train_Thre_Global = Train_Thre_Global_Optim;  % ѡ������
                disp(['������һ���������һ��ѡ������']);
            end
        end
    end

    if Timer == 2 && Trials(AllTrial)> 0 && Timer < 30  % ��ʼ��ʱ�򽫶�������֡��ʱ��
       sendbuf(1,2) = hex2dec('01') ;
       sendbuf(1,3) = hex2dec('00') ;
       sendbuf(1,5) = uint8(0);
       fwrite(UnityControl,sendbuf);
    end
    
    % ��ʼ��̬����
    % �л�����չʾ����ʼ�˶�����
    if ((Timer-2)-7*Train_Seg == 0) && Timer > 2 && Trials(AllTrial)> 0 && Timer < 30
        Trigger = Trials(AllTrial);
        sendbuf(1,1) = hex2dec(mat2unity) ;
        sendbuf(1,2) = hex2dec('01') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        sendbuf(1,8) = hex2dec('00');
        fwrite(UnityControl,sendbuf);
        Train_Flag = 0;
    end

    % ����䶯
    if ((Timer-2)-7*Train_Seg >1) && ((Timer-2)-7*Train_Seg <=4) && Trials(AllTrial)> 0 && Timer < 30
        disp(['��ʼѵ��']);
        Trigger = Trials(AllTrial);
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        % ���͵÷��Լ�һϵ������
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(MI_Acc, 2);0 ;0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(2,1))]);
        
        % �ռ�ȫ�ֵĸ��ʣ�������ʾ
        MI_Acc = [MI_Acc, resultMI(2,1)];
        MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
        % ���ﵽȫ����ֵ��ʱ��flag��1
        if MI_Acc_GlobalAvg(end) > Train_Thre_Global
            Train_Thre_Global_Flag = 1;
            disp(['�ﵽ���� MI_Acc_GlobalAvg��', num2str(MI_Acc_GlobalAvg(end)), ', Train_Thre_Global: ',num2str(Train_Thre_Global)]);
        end
        
        % ���ݸ�����ʾ���������ڸ���ʵʱ����
        sendbuf(1,1) = hex2dec(mat2unity);
        sendbuf(1,2) = hex2dec('01');
        sendbuf(1,3) = hex2dec('00');
        sendbuf(1,4) = hex2dec('00');
        if Train_Seg > 1
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


        % ��ʱ�䵽���4s��ʱ���ռ�֮ǰ��3��seg�ĸ��ʣ����ڷ����Ƿ���Ҫkeep����adjust
        if (Timer-2)-7*Train_Seg ==4
            if max(MI_Acc(end-2:end)) > Train_Thre
                Train_Flag = 1;
            else
                Train_Flag = 0;
            end
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
    
    % �˶������Keep/Adjust����
    if ((Timer-2)-7*Train_Seg >= 5) && ((Timer-2)-7*Train_Seg <=6) && Trials(AllTrial)> 0 && Timer < 30
        Trigger = 10;
        disp(['��ʼ����']);
        sendbuf(1,3) = hex2dec('00');
        sendbuf(1,4) = hex2dec('00');
        if Train_Flag == 0
            sendbuf(1,8) = hex2dec('02');
            disp(['poor performance, adjust, ', 'value: ', num2str(max(MI_Acc(end-2:end)))]);
        else
            sendbuf(1,8) = hex2dec('01');
            disp(['good performance, keep ', 'value: ', num2str(max(MI_Acc(end-2:end)))]);
        end
        fwrite(UnityControl,sendbuf);

    end
    
   %% ��Ϣ̬ѵ���׶�
   if Timer > 2 && (mod(Timer-2, 4)==2 || mod(Timer-2, 4)==3 || mod(Timer-2, 4)==0) && Trials(AllTrial)==0  && Timer<=18
        Trigger = Trials(AllTrial);
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        % ���͵÷��Լ�һϵ������
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(2,1))]);
        
        % �ռ�ȫ�ֵĸ��ʣ�������ʾ
        MI_Acc = [MI_Acc, resultMI(2,1)];
        MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
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
   %% �˶�������뷴���׶Σ����/ʱ�䷶Χ��û����ԣ�,ͬʱ����ģ��
   if Timer == 30 && Trials(AllTrial) > 0
       Trigger = 8;
       if Train_Thre_Global_Flag==1  % �������ˣ��ﵽ��ֵ
           if Trials(AllTrial) > 0  % �˶���������
                % ���Ŷ�����AO������Idle, MI1, MI2��
                mat2unity = ['0', num2str(Trials(AllTrial) + 3)];
                sendbuf(1,1) = hex2dec(mat2unity);
                sendbuf(1,2) = hex2dec('02') ;
                sendbuf(1,3) = hex2dec('01') ;  % ���뷴������ʾ����
                sendbuf(1,4) = hex2dec('00') ;
                sendbuf(1,8) = hex2dec('00') ;
                fwrite(UnityControl,sendbuf);  
            end
            
            % ���е�̼�
            if Trials(AllTrial) == 1
                StimCommand = StimCommand_1;
                fwrite(StimControl,StimCommand);
            end
            if Trials(AllTrial) == 2
                StimCommand = StimCommand_2;
                fwrite(StimControl,StimCommand);
            end
            disp(['MI�ﵽ��ֵ��̼�']);
       else  % ���û�����
            if Trials(AllTrial) > 0  % �˶���������
                % ���Ŷ�����AO������Idle, MI1, MI2��
                mat2unity = ['0', num2str(Trials(AllTrial) + 3)];
                sendbuf(1,1) = hex2dec(mat2unity);
                sendbuf(1,2) = hex2dec('00') ;
                sendbuf(1,3) = hex2dec('02') ;  % ���뷴������ʾ����
                sendbuf(1,4) = hex2dec('00') ;
                sendbuf(1,8) = hex2dec('00') ;
                fwrite(UnityControl,sendbuf);  
            end
       end

        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ������flag
        %Train_Thre_Global_Flag = 0;
   end
    
   % ��е��/��������������
   if Timer == 30
       if Train_Thre_Global_Flag==1
           disp("����������");
           if Trials(AllTrial)==1
               disp('Glove on');
               textsend='G1';
               %pause(0.1);
               fwrite(GloveControl, textsend);
           end

           if Trials(AllTrial)==2
               disp('Glove grasp');
               textsend='G2';
               %pause(0.1);
               fwrite(GloveControl, textsend);
           end
       end
   end

   if Timer == 32
       if Train_Thre_Global_Flag==1
           disp('��е������');
           if Trials(AllTrial)==1
               disp('Robotic reaching');
               textSend='Y1';
               %pause(0.1);
               fwrite(RobotControl, textSend);
           end

           if Trials(AllTrial)==2
                disp('Robotic back');
                textSend='Y2';
                %pause(0.1);
                fwrite(RobotControl, textSend);
           end
           % ������flag
           Train_Thre_Global_Flag = 0;
       end
   end

   %% ��Ϣ�׶Σ�ȷ����һ������
    % ����ֻ��2s����Ϣ�����ǻ���10s���ڸ���ģ��
    if Timer==18 && Trials(AllTrial)==0  %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % �����㷨
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ����ȷ����һ������
        average_score = mean(EI_index_scores(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        max_MuSup = max(mu_suppressions(1,:));  % ��������Mu˥��������ֵ����������������
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % �洢��������
        %visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % �洢����Ӿ��������
        MI_Acc_Trials = [MI_Acc_Trials, [MI_Acc; repmat(Trials(AllTrial),1,length(MI_Acc));]];  % �洢����
        MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials, [MI_Acc_GlobalAvg(end); Trials(AllTrial)]];

        % ��Ϣ̬�����ݲɼ�������ֵ����
        RestTimeLen_ = [2; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    % �˶�����֮��AO�����ֽ�����֮��������Ϣ
    if Trials(AllTrial)>0 && Timer == 45  %��ʼ��Ϣ
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
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % �洢��������
        %visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % �洢����Ӿ��������
        MI_Acc_Trials = [MI_Acc_Trials, [MI_Acc; repmat(Trials(AllTrial),1,length(MI_Acc));]];  % �洢����
        MI_Acc_GlobalAvg_Trials = [MI_Acc_GlobalAvg_Trials, [MI_Acc_GlobalAvg(end); Trials(AllTrial)]];
        Train_Performance = [Train_Performance, [max(MI_Acc_GlobalAvg); Train_Thre_Global; Trials(AllTrial)]];
        
        % ��ֵ�������ֻ���Ҫ�޸�
        [Flag_FesOptim, Train_Thre_Global_Optim, RestTimeLen, Train_Thre_FesOpt] = TaskAdjustUpgraded_FeasibleOptimal(scores_trial, Train_Performance, Train_Thre_FesOpt, Trials, AllTrial, RestTimeLenBaseline, min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];+ 
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
    disp(['������', num2str(Train_Seg)]);
    % ��������
    if mod(Timer-2, 7)==0 && Timer > 2 && Timer < 30
        Train_Seg = Train_Seg + 1;
        if Train_Seg > 3
            Train_Seg = 0;
        end
    end
    
    %% ���ĸ�����ֵ��λ
    % ������������18s������18s֮��ʼ��Ϣ������30s�ͽ�����������10s���ڸ���ģ��
    if Timer == 30 && Trials(AllTrial)==0  %������Ϣ��׼����һ��
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed);
        %��ʱ����0
        Timer = 0;  % ��ʱ����0
        Train_Seg = 0;
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        resultsMI = [];  % MI������������ֵ��ԭ
        EI_index_scores = [];  % EIָ�걣����ֵ��ԭ
        mu_suppressions = [];  % mu˥��������ֵ��ԭ
        mu_suppressions_normalized = [];
        visual_feedbacks = [];
        MI_MUSup_thre1s_normalized = [];
        EI_index_scores_normalized = [];
        MI_Acc = [];  % ���ڴ洢һ��trial��������з������
        MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ���������
        TrialData_Processed = [];
        
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �����֮��AO֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Trials(AllTrial)>0 && Timer == (45 + RestTimeLen)  %������Ϣ
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        Train_Seg = 0;
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        resultsMI = [];  % MI������������ֵ��ԭ
        EI_index_scores = [];  % EIָ�걣����ֵ��ԭ
        mu_suppressions = [];  % mu˥��������ֵ��ԭ
        mu_suppressions_normalized = [];
        visual_feedbacks = [];
        MI_MUSup_thre1s_normalized = [];
        EI_index_scores_normalized = [];
        MI_Acc = [];  % ���ڴ洢һ��trial��������з������
        MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ���������
        TrialData_Processed = [];
        
        % �������û�ԭ
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
end
%% �洢ԭʼ����
close all
TrialData = TrialData(2:end,:);  %ȥ�������һ��
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % �����ӹر�
% �洢ԭʼ����
foldername_rawdata = [foldername, '\\Online_EEGMI_RawData_', subject_name]; % ָ���ļ���·��������
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_RawData_',num2str(session_idx), '_', subject_name], '.mat' )],'TrialData','Trials','ChanLabel');

%% �洢�켣׷������������ָ��
foldername_rawdata = [foldername, '\\Online_EEGMI_trajectory_', subject_name]; % ָ���ļ���·��������
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_trajectory_',num2str(session_idx), '_', subject_name], '.mat' )],'scores_trial','traj_Feasible',...
    'RestTimeLens','muSups_trial', 'scores_trial', 'MI_Acc_Trials', 'MI_Acc_GlobalAvg_Trials', 'Train_Performance','Train_Thre_FesOpt');


%% �洢���˶���������еĲ����ָ��
function SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, ...
    MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % �����ļ����Ƿ����
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', FunctionNowFilename(['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' )],'EI_indices','mu_powers','mu_suppressions', 'EI_index_scores','resultsMI',...
        'MI_Acc','MI_Acc_GlobalAvg','TrialData_Processed');  % �洢��ص���ֵ
end
%% �������muƵ��˥��ָ�꣬������Ҫ�޸�
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % ���������Ե�λ�õ���ص�ָ�� 
    mu_suppresion = - ERD_C3;  % ȡ��ֵ�������Ļ���ֵԽ��Խ��ERDЧӦԽ��
end

%% ������ص�EIָ��ĺ���
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
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