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
system('E:\MI_AO_Animation\UpperLimb_Animation_modified\unity_test.exe&');
%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_Animation\unity_test.exe&');
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
subject_name = 'Jyt_test_0110_online_test';  % ��������
sub_offline_collection_folder = 'Jyt_test_0108_offline_20240109_222305628_data';  % ���Ե����߲ɼ�����
subject_name_offline =  'Jyt_test_0108_offline';  % �����ռ�����ʱ��ı�������
session_idx = 1;  % session index�����������1�Ļ������Զ���������Ų�
MotorClass = 2; % �˶�������������ע�������Ǵ���Ƶ��˶�������������������������idle״̬
DiffLevels = [1,2];  % ����������˶�������Ѷ��Ų���Խ����Խ�ѣ����е�1,2��Ӧ�����˶���������ͣ���unity��Ӧ
MajorPoportion = 0.6;  % ÿһ��session���治ͬ�����˶�����������ռ�ı�ֵ
%TrialNum = 40;  % ÿһ��session�����trial������
TrialNum = 30;  % ÿһ��session�����trial������


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

% ͨ������
ip = '172.18.22.21';
port = 8888;  % �ͺ�˷��������ӵ���������

%% ׼����ʼ�Ĵ洢���ݵ��ļ���
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % ָ���ļ���·��������
if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% ����mu˥����׷�ٹ켣
% ��ȡ֮ǰ�����߲ɼ�������
foldername_Scores = [sub_offline_collection_folder, '\\Offline_EEGMI_Scores_', subject_name_offline]; % ָ��֮ǰ�洢�������ļ���·��������
mean_std_EI_score = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_EI_score');
mean_std_muSup = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'mean_std_muSup');

% �������ڵĹ켣
traj = generate_traj(mean_std_muSup.mean_std_muSup, TrialNum);

%% �˶��������ݰ���
TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
%All_data = [];
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

randomindex = [];                                                          % ��ʼ��trials�ļ���
for i= 1:(MotorClass)                                                    % ע�⣬����ֻ�����˶���������񣬺��������ʵ�����������صľ�Ϣ״̬
    index_i = ones(TrialNum/MotorClass,1)*i;                             % size TrialNum/MotorClasses*1����������
    randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
end

RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������

%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
scores = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window�ķ���ֵ
EI_indices = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��EI����ֵ
EI_index_scores = [];  % ���ڴ洢EI_index_Caculation(EI_index, EI_channels)���������EI_index_score��ֵ
mu_powers = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��muƵ����������ֵ
mu_suppressions = [];  % ���ڴ洢ÿһ��trial�����mu_suppression
resultsMI = [];  % ���ڴ洢ÿһ��trial�����results

scores_trial = [];  % ���ڴ洢ÿһ��trial��ƽ������ֵ
muSups_trial = [];  % ���ڴ洢ÿһ��trial�����������ֵ����ǰ���������ָ������Ϊtrial���������resultMI*MuSup����MI_MUSup_thre  max(resultMI*MuSup)/MI_MUSup_thre
MI_MUSup_thre_weights = []; % ���ڴ洢ÿһ��trial��Ȩ��
MI_MUSup_thres = [];  % ���ڴ洢ÿһ��trial����ֵ
RestTimeLens = [];  % ���ڴ洢ÿһ��trial����Ϣʱ��

clsFlag = 0; % �����ж�ʵʱ�����Ƿ���ȷ��flag
clsTime = 100;  % ��ʼ��������ȷ��ʱ��
clsControl = 0;  % �������֮���ж��Ƿ���Ϣ��flag
RestTimeLenBaseline = 5 + session_idx;  % ��Ϣʱ������session����������
RestTimeLen = RestTimeLenBaseline;  % ��ʼ����Ϣʱ��
Trials = RandomTrial;

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
    if Timer==2
        if Trials(AllTrial)==0  % ��������
            Trigger = 0;
            sendbuf(1,1) = hex2dec('03') ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        if Trials(AllTrial)> 0  % �˶���������
            Trigger = Trials(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity) ;
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('00') ;
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % ��2s��ʱ��ȡ512��Trigger==6�Ĵ��ڣ����ݴ����ҽ��з���
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        % ���������ȡ��MI֮ǰ��Ƶ������
        [~, ~, mu_power_] = Online_DataPreprocess(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; 6];
        mu_powers = [mu_powers, mu_power_];  % �����ص�mu��������

        % ȷ����һ�ֵ���ֵ
        if Trials(AllTrial)> 0
            Trigger_num_ = count_trigger(Trials, Trigger);
            MI_MUSup_thre = traj{Trigger}(Trigger_num_+1);  % ������ֵ
            % ȷ����Ȩ֮�����ֵ
            MI_MUSup_thre = MI_MUSup_thre_weight * MI_MUSup_thre;
            disp(['Trial: ', num2str(AllTrial), ' Cls: ', num2str(Trials(AllTrial))])
            disp(['Threshold: ', num2str(MI_MUSup_thre)]);
            % threshold ���ݴ��������Լ���ʾ
            sendbuf(1,6) = uint8((MI_MUSup_thre*100));
            fwrite(UnityControl,sendbuf);  
            MI_MUSup_thre_weights = [MI_MUSup_thre_weights, [MI_MUSup_thre_weight;Trigger]];
            MI_MUSup_thres = [MI_MUSup_thres, [MI_MUSup_thre;Trigger]];
        end
    end
    % ��4s��ʼȡ512��Trigger~=6��MI�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer > 3 && Trials(AllTrial)> 0 && clsFlag == 0 && clsControl == 0
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�
        scores = [scores, score];  % ����÷�

        % ���͵÷��Լ�һϵ������
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 1.0;
        resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
        disp(['predict cls: ', num2str(resultMI(1,1))]);
        disp(['cls prob: ', num2str(resultMI(2,1))]);
        % �÷�����ʵʱ��ʾ
        visual_feedback = (resultMI(2,1) * mu_suppression);
        sendbuf(1,5) = uint8((visual_feedback*100.0));
        fwrite(UnityControl,sendbuf);
           
        % �ж��Ƿ���Ҫ��
        if resultMI(2,1) * mu_suppression >= MI_MUSup_thre
            clsFlag = 1;  % ʶ����ȷ����1
        else
            clsFlag = 0;
        end

%         if resultMI == Trials(AllTrial)
%             clsFlag = 1;  % ʶ����ȷ����1
%         else
%             clsFlag = 0;
%         end   

        % �洢��һϵ��ָ�����ֵ
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % ���������Trigger�������ֵ������洢
        mu_suppression = [mu_suppression; Trigger]; % ���������Trigger�������ֵ������洢
        EI_index_score = [EI_index_score; Trigger];
        resultMI_ = [resultMI; Trigger];
        
        resultsMI = [resultsMI, resultMI_];
        EI_index_scores = [EI_index_scores, EI_index_score];
        EI_indices = [EI_indices, EI_index];  % �����ص�EIָ����ֵ  
        mu_powers = [mu_powers, mu_power_MI];  % �����ص�mu��������
        mu_suppressions = [mu_suppressions, mu_suppression];  % �����ص�mu˥����������ں����ķ���
    end
    
   %% �˶�������뷴���׶Σ����/ʱ�䷶Χ��û����ԣ�,ͬʱ����ģ��
   % ����˿�ʼ���Ŷ��� 
   if clsFlag == 1 && clsControl == 0
       Trigger = 7; 
       clsTime = Timer;  % ���Ƿ�����ȷ��ʱ��
        if Trials(AllTrial) > 0  % �˶���������
            Trigger = Trials(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity);
            sendbuf(1,2) = hex2dec('01') ;
            sendbuf(1,3) = hex2dec('01') ;  % ���뷴������ʾ����
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ������2��flag
        clsControl = 1;
        clsFlag = 0;
   end
    
    % ����˿�ʼ��Ϣ������
    if clsFlag == 0 && Timer == (MaxMITime) && clsControl == 0
        Trigger = 7;
        if Trials(AllTrial) > 0  % �˶���������
            Trigger = Trials(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trigger + 3)];
            sendbuf(1,1) = hex2dec(mat2unity);
            sendbuf(1,2) = hex2dec('00') ;
            sendbuf(1,3) = hex2dec('02') ;  % ���뷴������ʾ����
            sendbuf(1,4) = hex2dec('00') ;
            fwrite(UnityControl,sendbuf);  
        end
        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        clsControl = 2;
    end
    
   %% ��Ϣ�׶Σ�ȷ����һ������
    % ����ֻ��5s����Ϣ
    if Timer==7 && Trials(AllTrial)==0 && clsControl == 0 %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % �����㷨
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score(1,1);0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ����ȷ����һ������
        average_score = mean(EI_index_scores(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        max_MuSup = max(mu_suppressions(1,:))/MI_MUSup_thre;  % ��������Mu˥��������ֵ����������������
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % �洢��������
        
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline,TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    % �˶����������֮��AO������֮��������Ϣ
    if Trials(AllTrial)>0 && Timer == (clsTime + 8) && clsControl == 1  %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % ����ȷ����һ������
        average_score = mean(EI_index_scores(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        max_MuSup = max(mu_suppressions(1,:))/MI_MUSup_thre;  % ��������Mu˥��������ֵ����������������
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % �洢��������
        
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline,TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    % �˶�����û����ԣ����ѽ�����֮��������Ϣ
    if Trials(AllTrial)>0 && clsFlag == 0 && Timer == (MaxMITime + 8) && clsControl == 2
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  
        % ����ȷ����һ������
        average_score = mean(EI_index_scores(1, :));  % ���ﻻ��EIָ�꣬�������ܻ��ỻ
        scores_trial = [scores_trial, average_score];  % �洢��ƽ���ķ���
        max_MuSup = max(mu_suppressions(1,:))/MI_MUSup_thre;  % ��������Mu˥��������ֵ����������������
        muSups_trial = [muSups_trial, [max_MuSup; Trials(AllTrial)]];  % �洢��������
        
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
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
    
    %% ���ĸ�����ֵ��λ
    % ������������5s������7s֮��ʼ��Ϣ������10s�ͽ�������
    if Timer == 10 && Trials(AllTrial)==0 && clsControl == 0 %������Ϣ��׼����һ��
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI);
        %��ʱ����0
        Timer = 0;  % ��ʱ����0
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        resultsMI = [];  % MI������������ֵ��ԭ
        EI_index_scores = [];  % EIָ�걣����ֵ��ԭ
        mu_suppressions = [];  % mu˥��������ֵ��ԭ
        
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �����֮��AO֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Trials(AllTrial)>0 && Timer == (clsTime + 8 + RestTimeLen) && clsControl == 1  %������Ϣ
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        % cls������flag��0
        clsFlag = 0;  % ����flag��0
        clsControl = 0;
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        resultsMI = [];  % MI������������ֵ��ԭ
        EI_index_scores = [];  % EIָ�걣����ֵ��ԭ
        mu_suppressions = [];  % mu˥��������ֵ��ԭ
        
        % �������û�ԭ
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �˶�����û����ԣ�����֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Trials(AllTrial)>0 && clsFlag == 0 && Timer == (MaxMITime + 8 + RestTimeLen) && clsControl == 2
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        % clsflag��0
        clsFlag = 0;  % ����flag��0
        clsControl = 0;
        % ÿһ��trial����ֵ��ԭ
        scores = [];  % ����ֵ��ԭ
        EI_indices = [];  % EI����ֵ��ԭ
        mu_powers = [];  % muƵ����������ֵ��ԭ
        resultsMI = [];  % MI������������ֵ��ԭ
        EI_index_scores = [];  % EIָ�걣����ֵ��ԭ
        mu_suppressions = [];  % mu˥��������ֵ��ԭ
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
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_trajectory_',num2str(session_idx), '_', subject_name], '.mat' )],'scores_trial','traj','MI_MUSup_thre_weights','MI_MUSup_thres','RestTimeLens','muSups_trial','scores_trial');


%% �洢���˶���������еĲ����ָ��
function SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % �����ļ����Ƿ����
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', FunctionNowFilename(['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' )],'EI_indices','mu_powers','mu_suppressions', 'EI_index_scores','resultsMI');  % �洢��ص���ֵ
end
%% �������muƵ��˥��ָ��
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1))/mu_power_(mu_channels.C3, 1); 
    ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1))/mu_power_(mu_channels.C4, 1);  % ���������Ե�λ�õ���ص�ָ�� 
    mu_suppresion = abs(ERD_C4 - ERD_C3);
end

%% ������ص�EIָ��ĺ���
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
    EI_index_score = mean(EI_index(channels_, 1));
end

%% ���ɹ켣�ĺ���
function traj = generate_traj(mean_std_muSup, TrialNum)
    % ��ȡ��������
    n = size(mean_std_muSup, 2);

    % ��ʼ��һ���յ� cell �������洢ÿ�����Ĺ켣
    traj = cell(1, n);

    % ����ÿһ�����
    for i = 1:n
        % ��ȡ mean �� std
        mean_val = mean_std_muSup(1, i);
        std_val = mean_std_muSup(2, i);

        % ��ʼ��һ���յ��������洢�켣
        traj{i} = zeros(TrialNum, 1);

        % ����켣
        for x = 1:TrialNum
            traj{i}(x) = mean_val + (std_val) * (1 - exp(-3 * x / TrialNum));
        end
    end
end
% Trials�����жϵ�ǰ����Ѿ����ֹ����ٴεĺ��������ھ�ϸ�Ĺ켣����
function count = count_trigger(Trials, AllTrial)
    % ��ȡ Trigger
    Trigger = Trials(AllTrial);
    
    % ���� Trigger �� Trials(1:AllTrial-1) �е�����
    count = sum(Trials(1:AllTrial-1) == Trigger);
end
