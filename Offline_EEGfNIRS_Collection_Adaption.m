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
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');      % Unity����exe�ļ���ַ
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
subject_name = 'Thy_compare_offline';  % ��������
TrialNum = 30*4;  % ���òɼ�������
Trial_setSession = 1;  % �����Ƿ���Ҫ���ڲɼ���TrialNum��trial��session����ÿһ��session����TrialNum/session��������1����Ϊ�ǣ�0����Ϊ��
Trial_Session = 4;  % �����������Ϊ1����Ҫ����session���������趨

%TrialNum = 3;  % ���òɼ�������
%Trial_setSession = 0;  % �����Ƿ���Ҫ���ڲɼ���TrialNum��trial��session����ÿһ��session����TrialNum/session��������1����Ϊ�ǣ�0����Ϊ��
%Trial_Session = 1;  % �����������Ϊ1����Ҫ����session���������趨

%TrialNum = 3*10;
MotorClasses = 3;  % �˶��������������������ã�ע�������ǰѿ���idle״̬ҲҪ�Ž�ȥ�ģ�ע�������������[0,1,2]����readme.txt����Ķ�Ӧ
% ��ǰ���õ�����
% Idle 0   -> SceneIdle 
% MI1 1   -> SceneMI_Drinking 
% MI2 2   -> Scene_Milk 
% �ɴ����������õ��ֵ�
task_keys = {0, 1, 2};
task_values = {'SceneIdle', 'SceneMI_Drinking', 'Scene_Milk'};
task_dict = containers.Map(task_keys, task_values);
RestTimeLenBaseline = 5;  % ��Ϣʱ��ȷ��
seconds_per_trial  = 5;  % ÿһ��trial��ʱ�䳤�ȣ�����ʵ���������

% �Ե��豸�����ݲɼ�
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
weight_mu = 0.6;  % ���ڼ���ERD/ERSָ���EIָ��ļ�Ȩ��

% ͨ������
%ip = '172.18.22.21';
ip = '127.0.0.1';
port = 8880;  % �ͺ�˷��������ӵ���������

% ��̼�ǿ������
Fes_flag = 0;  % �Ƿ���Fes������1�ǿ�����0�ǹر�
StimAmplitude_1 = 5;
StimAmplitude_2 = 5;  % ��ֵ���ã�mA��

% ���ý��������Ӳ���
oxy = actxserver('oxysoft.oxyapplication');  % ���ӽ�����
disp(['Connected to Oxy Version: ', oxy.strVersion]);

% �Ѷȼ����뻮������
%task_weights = [3,5,2];

%% ���õ�̼�����
%��������
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

%% �˶��������ݰ���
Trigger = 0;                                                               % ��ʼ��Trigger�����ں��������ݴ洢
AllTrial = 0;

if Trial_setSession==0
    TrialIndex = randperm(TrialNum);                                           % ���ݲɼ��������������˳�������
    %All_data = [];
    randomindex = [];                                                          % ��ʼ��trials�ļ���
    for i= 0:(MotorClasses-1)
        index_i = ones(TrialNum/MotorClasses,1)*i;                             % size TrialNum/MotorClasses*1����������
        randomindex = [randomindex; index_i];                                  % �����������ϣ�����size TrialNum*1
    end
    RandomTrial = randomindex(TrialIndex);                                     % ������ɸ���Trial��Ӧ������

elseif Trial_setSession==1
    RandomTrial = [];
    TrialIndex = [];
    % ���������session��ʽ���������ռ��Ļ���ÿһ��session����TrialNum/Trial_Session��trial
    trials_perSession = TrialNum/Trial_Session;  % һ��session�����trial����
    % һ��session������Ų�
    for session_idx = 1:Trial_Session
        TrialIndex_session = randperm(trials_perSession);                          % ���ݲɼ��������������˳�������
        randomindex_session = [];                                                  % ��ʼ��trials�ļ���
        for i= 0:(MotorClasses-1)
            index_i = ones(trials_perSession/MotorClasses,1)*i;                    % size trials_perSession/MotorClasses*1����������
            randomindex_session = [randomindex_session; index_i];                  % �����������ϣ�����size trials_perSession*1
        end
        RandomTrial = [RandomTrial; randomindex_session(TrialIndex_session)];      % �������ÿһ��session�������Trial��Ӧ�����񣬲��ҽ��кϲ�
        TrialIndex = [TrialIndex; TrialIndex_session];                             % �ռ����е�trialIndex���ں����Ĵ洢
    end
end
%% ʵ�����ݲɼ��洢����
% ������ز���
classes = MotorClasses;
foldername = ['.\\', FunctionNowFilename([subject_name, '_'], '_data')]; % ָ���ļ���·��������

if ~exist(foldername, 'dir')
   mkdir(foldername);
end
% ���ô洢score������
scores = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window�ķ���ֵ
EI_indices = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��EI����ֵ,�洢��ʽ EI_indices = [EI_indices, EI_index]; һ��trial����洢4��window����ֵ
EI_index_scores = [];  % ���ڴ洢EI_index_Caculation(EI_index, EI_channels)���������EI_index_score��ֵ���洢��ʽ EI_index_score = [EI_index_score; Trigger]; EI_index_scores = [EI_index_scores, EI_index_score];  һ��trial����洢4��window����ֵ
mu_powers = [];  % ���ڴ洢ÿһ��trial�����ÿһ��window��muƵ����������ֵ�� �洢��ʽ mu_powers = [mu_powers, mu_power_MI];  һ��trial����洢5��window����ֵ
scores_task = [];  % ���ڴ洢score��task���洢��ʽ scores_task = [scores_task, scores_task_]; һ��trial����洢4��window����ֵ
mu_suppressions = [];  % ���ڴ洢MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels)���������mu_suppression���洢��ʽmu_suppression = [mu_suppression; Trigger]; mu_suppressions = [mu_suppressions, mu_suppression]; һ��trial����洢4��window����ֵ

%% ��ʼʵ�飬���߲ɼ�
Timer = 0;
TrialData = [];
while(AllTrial <= TrialNum)
    if Timer==0  %��ʾרע cross
        Trigger = 6;
        sendbuf(1,1) = hex2dec('01') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);       
        AllTrial = AllTrial + 1;
        % ȷ������Ϣʱ��ĳ��ȣ��м����30��trial��6���ӣ������Ϣ�£���Ϣһ��ʱ��
        % ���Trial_setSession = 1;Ҳ����������Session�Ļ�����ôһ��Session������30��trial��ͬ��Ҳ��30��trial��ʱ����Ϣ��
        if mod(AllTrial,30)==0 && AllTrial<TrialNum
            RestTimeLenBaseline = 60*3;
            disp(["30��trial�ˣ���Ϣ3����"])
        else
            RestTimeLenBaseline = 5;
        end
        if AllTrial > TrialNum
            break;
        end
    end
    
    if Timer==2
        Trigger = RandomTrial(AllTrial);  % ���Ŷ�����AO������Idle, MI1, MI2��
        mat2unity = ['0', num2str(Trigger + 3)];
        sendbuf(1,1) = hex2dec(mat2unity) ;
        if Trigger==1
            % MI 1ʹ�ü�ؽڵĶ�������
            sendbuf(1,2) = hex2dec('04') ;  % 0x04: 4���ٲ���, 0x02: 2���ٲ���, 0x01: 1���ٲ���, ָ������֡
        elseif Trigger==2
            % MI 2�ֲ�ʹ���ر����õ�02��2���ٶ��������ã���һ���ֲ�����־����ӵĲ��֣�������ץ��
            sendbuf(1,2) = hex2dec('02') ;  % 0x04: 4���ٲ���, 0x02: 2���ٲ���, 0x01: 1���ٲ���, ָ������֡
        end
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        % ���������ȡ��MI֮ǰ��Ƶ������
        [~, ~, mu_power_] = Online_DataPreprocess_Hanning(rawdata, 6, sample_frequency, WindowLength, channels);
        mu_power_ = [mu_power_; 6];
        mu_powers = [mu_powers, mu_power_];  % �����ص�mu��������
        
        % ��ӵ�̼�����̼���ʱ��Ϊ2s
        if Fes_flag == 1  % �Ƿ�ѡ���̼�
            Trigger = RandomTrial(AllTrial);
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

        % ��������ǩ
        oxy.WriteEvent('P', 'Prepare');
        disp('�������ǩ P');
    end

    % ��4s��ʼȡ512��Trigger~=6��MI�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer > (2+1) && Timer <= (2+5) && RandomTrial(AllTrial)> 0
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trigger, sample_frequency, WindowLength, channels);
        % mu_suppression = (mu_power_MI(mu_channel,1) - mu_power_(mu_channel,1))/mu_power_(mu_channel,1);  % ����miuƵ��˥�����
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�
        scores = [scores, score];  % ����÷�
        scores_task_ = [score; Trigger];
        scores_task = [scores_task, scores_task_];  % �������-����ԣ����ں����ķ��������Ѷ��õ�
        
        % �洢�⼸��ָ�����ֵ
        EI_index_score = [EI_index_score; Trigger];
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  
        mu_suppression = [mu_suppression; Trigger]; % ���������Trigger�������ֵ������洢

        EI_index_scores = [EI_index_scores, EI_index_score];  % �����ص�EI_index_scores��ֵ��ע������Ǽ����˼���channelsͨ����ƽ����ֵ�������Ǹ�EI_indices�Ǵ洢��������ֵ
        EI_indices = [EI_indices, EI_index];  % �����ص�EIָ����ֵ�����ں����ķ���  
        mu_powers = [mu_powers, mu_power_MI];  % �����ص�mu�������������ں����ķ���
        mu_suppressions = [mu_suppressions, mu_suppression];  % �����ص�mu˥����������ں����ķ���
    end
    
    if Timer==7 && RandomTrial(AllTrial)> 0  %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);
        
        % ��������ǩ��ȷ��֮ǰ�����ݵı�ǩ
        FnirsLabelTask(RandomTrial, AllTrial, oxy);
    end
    
    % ��4s��ʼȡ512��Trigger~=6��Rest�Ĵ��ڣ����ݴ����ҽ��з���
    if Timer > (2+1) && Timer <= (2+5) && RandomTrial(AllTrial)==0
        rawdata = TrialData(:,end-512+1:end);  % ȡǰһ��512�Ĵ���
        rawdata = rawdata(2:end,:);
        
        [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(rawdata, Trigger, sample_frequency, WindowLength, channels);
        % mu_suppression = (mu_power_MI(mu_channel,1) - mu_power_(mu_channel,1))/mu_power_(mu_channel,1);  % ����miuƵ��˥�����
        % ��������ָ��
        mu_suppression = MI_MuSuperesion(mu_power_, mu_power_MI, mu_channels);  
        EI_index_score = EI_index_Caculation(EI_index, EI_channels);
        
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�
        scores = [scores, score];  % ����÷�
        scores_task_ = [score; Trigger];
        scores_task = [scores_task, scores_task_];  % �������-����ԣ����ں����ķ��������Ѷ��õ�
        
        % �洢�⼸��ָ�����ֵ
        EI_index_score = [EI_index_score; Trigger];
        EI_index = [EI_index; Trigger];
        mu_power_MI = [mu_power_MI; Trigger];  
        mu_suppression = [mu_suppression; Trigger]; % ���������Trigger�������ֵ������洢

        EI_index_scores = [EI_index_scores, EI_index_score];  % �����ص�EI_index_scores��ֵ��ע������Ǽ����˼���channelsͨ����ƽ����ֵ�������Ǹ�EI_indices�Ǵ洢��������ֵ
        EI_indices = [EI_indices, EI_index];  % �����ص�EIָ����ֵ�����ں����ķ���  
        mu_powers = [mu_powers, mu_power_MI];  % �����ص�mu�������������ں����ķ���
        mu_suppressions = [mu_suppressions, mu_suppression];  % �����ص�mu˥����������ں����ķ���

    end
    
    if Timer==7 && RandomTrial(AllTrial)==0  %��ʼ��Ϣ
        Trigger = 7;
        sendbuf(1,1) = hex2dec('02') ;
        sendbuf(1,2) = hex2dec('00') ;
        sendbuf(1,3) = hex2dec('00') ;
        sendbuf(1,4) = hex2dec('00') ;
        fwrite(UnityControl,sendbuf);  

        % ��������ǩ��ȷ��֮ǰ�����ݵı�ǩ
        FnirsLabelTask(RandomTrial, AllTrial, oxy);
    end
    
    % �ڳ�ʱ�����Ϣ�У������̼�����Ϊ��Ϣ�Ŀ�ʼ
    if mod(AllTrial,30)==0 && Timer==7+5
        StimCommand = StimCommand_1;
        fwrite(StimControl,StimCommand);
        disp(['��Ϣʱ�䣬MI������̼�����ʱ�Ѿ���Ϣ5s']);
    end    
    
    % �ڳ�ʱ�����Ϣ�У������̼�����Ϊ��Ϣ�Ŀ�ʼ
    if mod(AllTrial,30)==0 && Timer==7+15
        StimCommand = StimCommand_2;
        fwrite(StimControl,StimCommand);
        disp(['��Ϣʱ�䣬MI������̼�����ʱ�Ѿ���Ϣ15s']);
    end 

    % �ڳ�ʱ�����Ϣ�У������̼�����Ϊ��Ϣ�Ľ���
    if mod(AllTrial,30)==0 && Timer==7+180-20
        StimCommand = StimCommand_1;
        fwrite(StimControl,StimCommand);
        disp(['��Ϣʱ�䣬MI������̼�����ʱ������Ϣ��������20s']);
    end

    % �ڳ�ʱ�����Ϣ�У������̼�����Ϊ��Ϣ�Ľ���
    if mod(AllTrial,30)==0 && Timer==7+180-15
        StimCommand = StimCommand_2;
        fwrite(StimControl,StimCommand);
        disp(['��Ϣʱ�䣬MI������̼�����ʱ������Ϣ��������15s']);
    end

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
    
    if Timer == (7 + RestTimeLenBaseline) && RandomTrial(AllTrial)> 0
        Timer = 0;  % ��ʱ����0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�

        % ��������ǩ��ȷ��֮ǰ�����ݵı�ǩ
        oxy.WriteEvent('R', 'Rest');
    end
    
    if Timer == (7 + RestTimeLenBaseline) && RandomTrial(AllTrial)==0
        Timer = 0;  % ��ʱ����0
        disp(['Trial: ', num2str(AllTrial), ', Task: ', num2str(RandomTrial(AllTrial))]);  % ��ʾ�������
        score = weight_mu * mu_suppression + (1 - weight_mu) * EI_index_score;  % ����÷�
        
        % ��������ǩ��ȷ��֮ǰ�����ݵı�ǩ
        oxy.WriteEvent('R', 'Rest');
    end
    
end
%% �洢ԭʼ����
close all
TrialData = TrialData(2:end,:);  %ȥ�������һ��
ChanLabel = flip({infoList.chanLabel});
pnet('closeall')   % �����ӹر�
% �洢ԭʼ����
foldername_rawdata = [foldername, '\\Offline_EEGMI_RawData_', subject_name]; % ָ���ļ���·��������
if ~exist(foldername_rawdata, 'dir')
   mkdir(foldername_rawdata);
end
save([foldername_rawdata, '\\', FunctionNowFilename(['Offline_EEGMI_RawData_', subject_name], '.mat' )],'TrialData','TrialIndex','ChanLabel');

%% ����Ԥ����
% ������������
rawdata = TrialData;
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
SlideWindowLength = 256;  % �������
[DataX, DataY, windows_per_session] = Offline_DataPreprocess_Hanning_GuidanceAdaption(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername, seconds_per_trial);

%% ÿһ�������Ӧ�ĸ���ָ���ƽ�������Լ�4��λ��ȷ�������Ҵ洢���ָ��
foldername_Scores = [foldername, '\\Offline_EEGMI_Scores_', subject_name]; % ָ���ļ���·��������
if ~exist(foldername_Scores, 'dir')
   mkdir(foldername_Scores);
end
% �����������ָ��ľ�ֵ�ͷ���  
mean_std_muSup = compute_mean_std(mu_suppressions, 'mu_suppressions');  
mean_std_EI_score = compute_mean_std(EI_index_scores, 'EI_index_scores');
% �����ķ�λ��
[quartile_caculation_mu, min_max_value_mu] = Offline_Bootstrapping_quartile(mu_suppressions, 'mu_suppressions', 1000);
[quartile_caculation_EI, min_max_value_EI] = Offline_Bootstrapping_quartile(EI_index_scores, 'EI_index_scores', 1000);

% �洢�������
save([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name], '.mat' ],'scores_task','EI_indices','mu_powers', ...
    'mu_suppressions','EI_index_scores', 'mean_std_EI_score','mean_std_muSup','quartile_caculation_mu',"min_max_value_mu","quartile_caculation_EI","min_max_value_EI"); 

%% Ԥ�������ݴ���
% ���ô���Ĳ���
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);

%% �رյ�̼�
StimCommand(1,1) = 100;
fwrite(StimControl,StimCommand);
system('taskkill /F /IM fes.exe');
close all;

%% ��ȡƽ������ȷ����ĺ���
function mean_std_scores = compute_mean_std(scores_task, scores_name)
    % ��ȡscores��triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % ��ȡ���в�ͬ��triggers
    unique_triggers = unique(triggers);

    % ��ʼ�����
    mean_scores = zeros(size(unique_triggers));
    std_scores = zeros(size(unique_triggers));

    % ����ÿһ��trigger�������Ӧ��score�ľ�ֵ
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
        std_scores(i) = std(scores(triggers == trigger));
    end
    mean_std_scores = [mean_scores; std_scores];

    % ������
    disp(['ÿһ��Trigger��ƽ��', scores_name, '�����ǣ�']);
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' ��ƽ�������� ' num2str(mean_scores(i))]);
        disp(['Trigger ' num2str(unique_triggers(i)) ' �ı�׼���� ' num2str(std_scores(i))]);
    end
end
%% �������muƵ��˥��ָ��
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % ���������Ե�λ�õ���ص�ָ�� 
    mu_suppresion =  - ERD_C3;  % ��һ����[0,1]����������
end
    
    %% ������ص�EIָ��ĺ���
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.F3, EI_channels.Fz, EI_channels.F4];
    EI_index_score = mean(EI_index(channels_, 1));

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