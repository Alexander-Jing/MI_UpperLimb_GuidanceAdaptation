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

system('E:\MI_AO_Animation\UpperLimb_Animation_modified_DoubleThreshold\unity_test.exe&');

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
subject_name = 'Jyt_test_0310_online';  % ��������
sub_offline_collection_folder = 'Jyt_test_0310_offline_20240310_195952653_data';  % ���Ե����߲ɼ�����
subject_name_offline =  'Jyt_test_0310_offline';  % �����ռ�����ʱ��ı�������
session_idx = 1;  % session index�����������1�Ļ������Զ���������Ų�
DiffLevels = [1,2];  % ����������˶�������Ѷ��Ų���Խ����Խ�ѣ����е�1,2��Ӧ�����˶���������ͣ���unity��Ӧ
MajorPoportion = 0.6;  % ÿһ��session���治ͬ�����˶�����������ռ�ı�ֵ
%TrialNum = 40;  % ÿһ��session�����trial������
TrialNum = 20;  % ÿһ��session�����trial������
MotorClass = 2; % �˶�������������ע�������Ǵ���Ƶ��˶�������������������������idle״̬
MotorClassMI = 2;  % ����ǵ��˶���������Ļ����Ǿ�ֱ��ָ������ͺ���


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

% ��̼�ǿ������
StimAmplitude_1 = 7;
StimAmplitude_2 = 9;  % ��ֵ���ã�mA��

%% ���õ�̼�����
% ��������
%system('F:\MI_engagement\fes\fes\x64\Debug\fes.exe&');
system('F:\CASIA\MI_engagement\fes\fes\x64\Debug\fes.exe&');
pause(1);
StimControl = tcpip('localhost', 8888, 'NetworkRole', 'client','Timeout',1000);
StimControl.InputBuffersize = 1000;
StimControl.OutputBuffersize = 1000;

% ���õ�̼���ز���
fopen(StimControl);
tStim = [3,14,2]; % [t_up,t_flat,t_down] * 100ms
StimCommand_1 = uint8([0,StimAmplitude_1,tStim,1]); % left calf
StimCommand_2 = uint8([0,StimAmplitude_2,tStim,2]); % left thigh

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
quartile_caculation_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_mu');
min_max_value_mu = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_mu');
quartile_caculation_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'quartile_caculation_EI');
min_max_value_EI = load([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name_offline], '.mat' ], 'min_max_value_EI');

% �������ڵĹ켣
%traj = generate_traj(mean_std_muSup.mean_std_muSup, TrialNum);
traj = generate_traj_quartile(quartile_caculation_mu.quartile_caculation_mu, TrialNum);

%% �˶��������ݰ���
TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
%All_data = [];
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

randomindex = [];   
if MotorClass > 1                                                       % ��ʼ��trials�ļ���
    for i= 1:(MotorClass)                                                    % ע�⣬����ֻ�����˶���������񣬺��������ʵ�����������صľ�Ϣ״̬
        index_i = ones(TrialNum/MotorClass,1)*i;                             % size TrialNum/MotorClasses*1����������
        randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
    end

    RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������
else
    Trials = repmat(MotorClassMI, TrialNum);   % ����ǵ�����Ļ�������ֱ����������
end

%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
scores = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window�ķ���ֵ
EI_indices = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��EI����ֵ
EI_index_scores = [];  % ���ڴ洢EI_index_Caculation(EI_index, EI_channels)���������EI_index_score��ֵ
EI_index_scores_normalized = [];  % ���ڴ洢��һ����EI_index_scores��ֵ
mu_powers = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��muƵ����������ֵ
mu_suppressions = [];  % ���ڴ洢ÿһ��trial�����mu_suppression
mu_suppressions_normalized = [];  % ���ڴ洢ÿһ��trial�����mu_suppressions_normalized
resultsMI = [];  % ���ڴ洢ÿһ��trial�����results
FES_flags = [];  % ���ڴ洢ÿһ��trial�����FES��̼���������ʩ�ӵ�̼�����Ϊ1
visual_feedbacks = [];  % ���ڴ洢ÿһ��trial�����visual_feedback�Ӿ���������ֵ
MI_MUSup_thre1s_normalized = [];  % ���ڴ洢ÿһ��trial�ĵڶ���ֵ

scores_trial = [];  % ���ڴ洢ÿһ��trial��ƽ������ֵ
muSups_trial = [];  % ���ڴ洢ÿһ��trial�����������ֵ����ǰ���������ָ������Ϊtrial���������resultMI*MuSup����MI_MUSup_thre  max(resultMI*MuSup)/MI_MUSup_thre
MI_MUSup_thre_weights = []; % ���ڴ洢ÿһ��trial��Ȩ��
MI_MUSup_thres = [];  % ���ڴ洢ÿһ��trial����ֵ
MI_MUSup_thres_normalized = [];  % ���ڴ洢ÿһ��trial�ĵ�һ��ֵ
RestTimeLens = [];  % ���ڴ洢ÿһ��trial����Ϣʱ��
visual_feedbacks_trial = [];  % ���ڴ洢ÿһ��trial��visual_feedback�Ӿ�������ƽ����ֵ

Online_FES_ExamingNum = 5;  % ���ߵ�ʱ��ÿ����ü���ж��Ƿ���Ҫ����FES����
Online_FES_flag = 0;  % ���������Ƿ����ʵʱFES�̼�����ؿ���flag
clsFlag = 0; % �����ж���ֵ0�Ƿ�ﵽ��flag
clsFlag1 = 0; % �����ж���ֵ1�Ƿ�ﵽ��flag
clsTime = 100;  % ��ʼ��������ȷ��ʱ��
clsControl = 0;  % �������֮���ж��Ƿ���Ϣ��flag
RestTimeLenBaseline = 7 + session_idx;  % ��Ϣʱ������session����������
RestTimeLen = RestTimeLenBaseline;  % ��ʼ����Ϣʱ��
if MotorClass > 1
    Trials = RandomTrial;
end

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
        [~, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; 6];
        mu_powers = [mu_powers, mu_power_];  % �����ص�mu��������

        % ȷ����һ�ֵ���ֵ
        if Trials(AllTrial)> 0
            %Trigger = Trials(AllTrial);
            Trigger_num_ = count_trigger(Trials, AllTrial);  % �������ڼ�����AllTrial��Ӧ��Trigger֮ǰ�Ѿ������˶��ٴΣ��Ӷ�����켣
            MI_MUSup_thre = traj{Trigger+1}(Trigger_num_+1);  % ������ֵ
            
            
            % ȷ����Ȩ֮�����ֵ�����ڱ���
            MI_MUSup_thre = MI_MUSup_thre;
            MI_MUSup_thre_weights = [MI_MUSup_thre_weights, [MI_MUSup_thre_weight;Trigger]];
            MI_MUSup_thres = [MI_MUSup_thres, [MI_MUSup_thre;Trigger]];

            % ��һ����ص���ֵ������ʵʱ��ʾ���ж����
            MI_MUSup_thre_normalized = mu_normalization(MI_MUSup_thre, min_max_value_mu.min_max_value_mu, Trigger+1);
            MI_MUSup_thre_normalized = MI_MUSup_thre_weight * MI_MUSup_thre_normalized;
            disp(['Trial: ', num2str(AllTrial), ' Cls: ', num2str(Trials(AllTrial))]);
            disp(['Mu Threshold��', num2str(MI_MUSup_thre)]);
            disp(['Threshold Normalized Weighted: ', num2str(MI_MUSup_thre_normalized)]);
            MI_MUSup_thres_normalized = [MI_MUSup_thres_normalized, [MI_MUSup_thre_normalized;Trigger]];
            MI_MUSup_thre1_normalized = MI_MUSup_thre_normalized;  % ȷ����ֵ2
            MI_MUSup_thre1s_normalized = [MI_MUSup_thre1s_normalized, [MI_MUSup_thre1_normalized; Trigger]];

            % threshold ���ݴ��������Լ���ʾ
            sendbuf(1,6) = uint8((MI_MUSup_thre_normalized*100));
            sendbuf(1,7) = uint8((MI_MUSup_thre1_normalized*100));
            fwrite(UnityControl,sendbuf);  
            % ��ʼ����ʾ���Ӿ�������ֵ
            sendbuf(1,5) = uint8((0.01*100.0));
            fwrite(UnityControl,sendbuf);
        end
        
        % ��ӵ�̼�����̼���ʱ��Ϊ2s
        if Trigger == 1
            StimCommand = StimCommand_1;
            fwrite(StimControl,StimCommand);
            disp(['MI֮ǰ������̼�']);
        end
        if Trigger == 2
            StimCommand = StimCommand_2;
            fwrite(StimControl,StimCommand);
            disp(['MI֮ǰ������̼�']);
        end
        
    end
    
    % ��5s��ʼȡ512��Trigger~=6��MI�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer > 4 && Trials(AllTrial)> 0 && clsFlag == 0 && clsControl == 0
        Trigger = Trials(AllTrial);
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trials(AllTrial), sample_frequency, WindowLength, channels);
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
        
        
        % �÷����ݹ�һ������ͬʱ������0-1֮�䣬����ʵʱ��ʾ�ͱȽ�
        mu_suppression_normalized = mu_normalization(mu_suppression, min_max_value_mu.min_max_value_mu, Trigger+1);
        visual_feedback = resultMI(2,1) * mu_suppression_normalized;
        
        if visual_feedback < 0.01
            visual_feedback = 0.01;
        elseif visual_feedback > 1
            visual_feedback = 1.0;
        end
        disp(['Mu Online��', num2str(mu_suppression)]);
        disp(['Mu normalized Weighted: ', num2str(visual_feedback)]);
        
        % ����EIָ��Ĺ�һ������
        EI_index_score_normalized = EI_normalization(EI_index_score, min_max_value_EI.min_max_value_EI);
        
        % �洢��һϵ��ָ�����ֵ
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  % ���������Trigger�������ֵ������洢
        mu_suppression = [mu_suppression; Trigger]; % ���������Trigger�������ֵ������洢
        EI_index_score = [EI_index_score; Trigger];
        EI_index_score_normalized = [EI_index_score_normalized; Trigger];
        resultMI_ = [resultMI; Trigger];
        mu_suppression_normalized = [mu_suppression_normalized; Trigger];

        
        resultsMI = [resultsMI, resultMI_];
        EI_index_scores = [EI_index_scores, EI_index_score];
        EI_index_scores_normalized = [EI_index_scores_normalized, EI_index_score_normalized];
        EI_indices = [EI_indices, EI_index];  % �����ص�EIָ����ֵ  
        mu_powers = [mu_powers, mu_power_MI];  % �����ص�mu��������
        mu_suppressions = [mu_suppressions, mu_suppression];  % �����ص�mu˥����������ں����ķ���
        mu_suppressions_normalized = [mu_suppressions_normalized, mu_suppression_normalized];
        visual_feedbacks = [visual_feedbacks, [visual_feedback; Trigger]];
        
        % ������ֵ2
        MI_MUSup_thre1_normalized = Online_Threshold1Adjust_DoubleThreshold_2(visual_feedbacks(1,:), MI_MUSup_thre1_normalized, MI_MUSup_thre_normalized, "Game");
        MI_MUSup_thre1s_normalized = [MI_MUSup_thre1s_normalized, [MI_MUSup_thre1_normalized; Trigger]];
        
        % ʵʱ���Ӿ���������
        sendbuf(1,5) = uint8((visual_feedback*100.0));
        sendbuf(1,7) = uint8((MI_MUSup_thre1_normalized*100));
        fwrite(UnityControl,sendbuf);


        % �ж��Ƿ���Ҫ��
        if visual_feedback >= MI_MUSup_thre_normalized
            clsFlag1 = 1;
            % ���е�̼�
            if Trials(AllTrial) == 1
                StimCommand = StimCommand_1;
                fwrite(StimControl,StimCommand);
            end
            if Trials(AllTrial) == 2
                StimCommand = StimCommand_2;
                fwrite(StimControl,StimCommand);
            end
            disp(['MI�ﵽ��ֵ0��̼�']);
        end

        if visual_feedback >= MI_MUSup_thre1_normalized
            clsFlag = 1;  % ʶ����ȷ����1
            disp(['MI�ﵽ��ֵ1��̼�']);
        else
            clsFlag = 0;
        end
        
%         if resultMI == Trials(AllTrial)
%             clsFlag = 1;  % ʶ����ȷ����1
%         else
%             clsFlag = 0;
%         end  

        % �������ͬʱ�����̼�����������ʱ�����һ�������ѣ��Ǿͼ����̼�
        Online_FES_flag = Threshold_FESAdjust_DoubleThreshold_1(resultsMI, mu_suppressions_normalized, Online_FES_ExamingNum);
        
        if Online_FES_flag == 1
            % ���е�̼�
            if Trigger == 1
                StimCommand = StimCommand_1;
                fwrite(StimControl,StimCommand);
            end
            if Trigger == 2
                StimCommand = StimCommand_2;
                fwrite(StimControl,StimCommand);
            end
            disp(['MI���߸�����̼�']);
            Online_FES_flag = 0;  % ��̼�����֮��������0
        end
        FES_flags = [FES_flags, [Online_FES_flag; Trigger]];  % �洢һ�µ�̼���ص���ֵ
    end
    
   %% �˶�������뷴���׶Σ����/ʱ�䷶Χ��û����ԣ�,ͬʱ����ģ��
   % ����˿�ʼ���Ŷ��� 
   if (clsFlag == 1 && clsFlag1==1) && clsControl == 0
       Trigger = 7; 
       clsTime = Timer;  % ���Ƿ�����ȷ��ʱ��
        if Trials(AllTrial) > 0  % �˶���������
            % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trials(AllTrial) + 3)];
            sendbuf(1,1) = hex2dec(mat2unity);
            sendbuf(1,2) = hex2dec('01') ;
            sendbuf(1,3) = hex2dec('01') ;  % ���뷴������ʾ����
            sendbuf(1,4) = hex2dec('00') ;
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

        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial);session_idx;AllTrial;size(scores, 2);score;0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        % ������3��flag
        clsControl = 1;
        clsFlag = 0;
        clsFlag1 = 0;
   end
    
    % ����˿�ʼ��Ϣ������
    if (clsFlag == 0 || clsFlag1==0) && Timer == (MaxMITime) && clsControl == 0
        Trigger = 7;
        if Trials(AllTrial) > 0  % �˶���������
            % ���Ŷ�����AO������Idle, MI1, MI2��
            mat2unity = ['0', num2str(Trials(AllTrial) + 3)];
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
        visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % �洢����Ӿ��������

        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline,TrialNum);
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_1(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum, min_max_value_EI.min_max_value_EI);
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
        visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % �洢����Ӿ��������
        
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline,TrialNum);
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_1(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum, min_max_value_EI.min_max_value_EI);
        RestTimeLen_ = [RestTimeLen; Trials(AllTrial)];
        RestTimeLens = [RestTimeLens, RestTimeLen_];
    end
    
    % �˶�����û����ԣ����ѽ�����֮��������Ϣ
    if Trials(AllTrial)>0 && (clsFlag==0 || clsFlag1==0) && Timer == (MaxMITime + 8) && clsControl == 2
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
        visual_feedbacks_trial = [visual_feedbacks_trial, [mean(visual_feedbacks(1,:)); Trials(AllTrial)]];  % �洢����Ӿ��������
        
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgradedMI(scores_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        %[Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum);
        [Trials, MI_MUSup_thre_weight, RestTimeLen, TrialNum] = TaskAdjustUpgraded_DoubleThreshold_1(scores_trial, muSups_trial, Trials, AllTrial, MI_MUSup_thre_weight_baseline, RestTimeLenBaseline, TrialNum, min_max_value_EI.min_max_value_EI);
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
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized, ...
            visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized);
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
        MI_MUSup_thre1s_normalized = [];
        EI_index_scores_normalized = [];
        
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �����֮��AO֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Trials(AllTrial)>0 && Timer == (clsTime + 8 + RestTimeLen) && clsControl == 1  %������Ϣ
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized, ...
            visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        % cls������flag��0
        clsFlag = 0;  % ����flag��0
        clsFlag1 = 0;  % ����clsFlag1��0
        clsControl = 0;
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
        
        % �������û�ԭ
        RestTimeLen = RestTimeLenBaseline;  % ��Ϣʱ�仹ԭ
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(Trials(AllTrial))]);  % ��ʾ�������
    end
    % �˶�����û����ԣ�����֮����Ϣ3s֮�󣬽�����Ϣ��׼����һ��
    if Trials(AllTrial)>0 && (clsFlag == 0 || clsFlag1==0) && Timer == (MaxMITime + 8 + RestTimeLen) && clsControl == 2
        % �洢��ص�EIָ���mu��������������
        SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized, ...
            visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized);
        % ��ʱ����0
        Timer = 0;  % ��ʱ����0
        % clsflag��0
        clsFlag = 0;  % ����flag��0
        clsFlag1 = 0;  % ����clsFlag1��0
        clsControl = 0;
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
save([foldername_rawdata, '\\', FunctionNowFilename(['Online_EEGMI_trajectory_',num2str(session_idx), '_', subject_name], '.mat' )],'scores_trial','traj','MI_MUSup_thre_weights',...
    'MI_MUSup_thres','RestTimeLens','muSups_trial','scores_trial','MI_MUSup_thres_normalized', 'visual_feedbacks_trial');


%% �洢���˶���������еĲ����ָ��
function SaveMIEngageTrials(EI_indices, mu_powers, mu_suppressions, subject_name, foldername, config_data, EI_index_scores, resultsMI, FES_flags, mu_suppressions_normalized,...
    visual_feedbacks, MI_MUSup_thre1s_normalized, EI_index_scores_normalized)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % �����ļ����Ƿ����
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', FunctionNowFilename(['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' )],'EI_indices','mu_powers','mu_suppressions', 'EI_index_scores','resultsMI','FES_flags','mu_suppressions_normalized', 'visual_feedbacks',...
        'MI_MUSup_thre1s_normalized', 'EI_index_scores_normalized');  % �洢��ص���ֵ
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

function traj = generate_traj_quartile(quartiles, TrialNum)
    % ��ȡ��������
    n = size(quartiles, 2);

    % ��ʼ��һ���յ� cell �������洢ÿ�����Ĺ켣
    traj = cell(1, n);

    % ����ÿһ�����
    for i = 1:n
        % ��ȡ0.25, 0.5, 0.75�ķ�λ��
        mu_supQ1 = quartiles(1, i);
        mu_supQ2 = quartiles(2, i);
        mu_supQ3 = quartiles(3, i);

        % ��ʼ��һ���յ��������洢�켣
        traj{i} = zeros(TrialNum, 1);
        
        % ���������λ����С��0�����⣬ǿ������������ǿ�����������ֵ���������޸�
        if mu_supQ2 < 0.0
            mu_supQ2 = 0.5;
        end
        if mu_supQ3 < 0.0
            mu_supQ3 = 2.0;
        end
        
        % ����켣
        for x = 1:TrialNum
            traj{i}(x) = mu_supQ2 + (mu_supQ3 - mu_supQ2) * (1 - exp(-3 * x / TrialNum));
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