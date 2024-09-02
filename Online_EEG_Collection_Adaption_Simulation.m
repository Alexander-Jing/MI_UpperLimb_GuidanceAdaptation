%% ��ʼ�����ر���������
pnet('closeall');
clc;
clear;
close all;
%% ����ʵ��������ò��֣���������ÿһ�����Ե���������ݱ�����������޸�
% �����ⲿ���Ǵ����α����ģ��ʵ�飬�������ﲻ���������豸�����ӣ�ֻ����server������

% �����ļ���ȡ
subject_name_simu = 'Jyt_test_0901_online_simu';  % ��������
subject_name = 'Jyt_test_0901_online';  % ��������
sub_offline_collection_folder = 'Jyt_test_0901_offline_20240901_193737949_data';  % ���Ե����߲ɼ�����
subject_name_offline =  'Jyt_test_0901_offline';  % �����ռ�����ʱ��ı�������
foldername_Sessions = 'Jyt_test_0901_online_20240901_204911380_data';  % ��session����1��ʱ����Ҫ�ֹ�����foldername_Sessions
foldername_RawData = 'Online_EEGMI_RawData_Jyt_test_0901_online';  % ���ڴ洢ԭʼ���ݵ��ļ���

% MI�Ե���ر���
sample_frequency = 256; 
WindowLength = 512;  % ÿ�����ڵĳ���
channel_selection = 1;  % �ж��Ƿ�Ҫ����ͨ��ѡ�񣬳�ʼֵ����Ϊ0�������������ݣ������ں���������Ͽ��Կ���ѡ��
if channel_selection==0
    channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��,
    mu_channels = struct('C3',24, 'C4',22);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
    EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
else
    channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  % ѡ���ͨ��������ȥ����OZ��M1,M2��Fp1��Fp2�⼸��channel
    mu_channels = struct('C3',24-3, 'C4',22-3);  % ���ڼ���ERD/ERS�ļ���channels����C3��C4����ͨ��,��Ҫ�趨λ��
    EI_channels = struct('F3', 29-3, 'Fz', 28-3, 'F4', 27-3);  % ���ڼ���EIָ��ļ���channels����Ҫȷ����λ�õ�
end

% ģ��ʵ��洢�ı���
MI_Acc = [];  % ���ڴ洢һ��trial��������з�����ʣ���һ��trial�����洢�����ݸ�ʽ MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)]; һ��trial����֮�� MI_Acc = [];
MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ��������ʣ���һ��trial�����洢�����ݸ�ʽ MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)]; һ��trial����֮�� MI_Acc_GlobalAvg = [];
resultsMI = [];  % ���ڴ洢ÿһ��trial�����results����һ��trial����洢���洢��ʽ resultMI_ = [resultMI; Trigger]; resultsMI = [resultsMI, resultMI_]; һ��trial����֮�� resultsMI = [];
TrialData_Processed = [];  % ���ڴ洢ѵ���е�ʵʱ���ݣ���һ��trial�����洢�� �洢��ʽ TrialData_Processed = [TrialData_Processed; [preMIData_processed;TriggerRepeat_]]; һ��trial����֮�� TrialData_Processed = [];

% Ԥ���趨�õ�ʵ�����trial_random = 2��ʱ������
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

% ������ͨ������
%ip = '172.18.22.21';
ip = '127.0.0.1';
port = 8880;  % �ͺ�˷��������ӵ���������

%% ׼����ʼ�Ĵ洢���ݵ��ļ���
foldername = ['.\\', FunctionNowFilename([subject_name_simu, '_'], '_SimuData')]; % ָ���ļ���·��������
if ~exist(foldername, 'dir')
   mkdir(foldername);
end
for session_idx=8:8
    % session��������ݲɼ�
    disp(["session: ", num2str(session_idx)]);
    session_rawdata = RawDataTrial(session_idx, subject_name, foldername_Sessions, foldername_RawData);
    for trial_idx=1:12
        % trial��������ݲɼ�
        trial_rawdata = session_rawdata(:, (trial_idx-1)*10*256+1:(trial_idx)*10*256);
        % ȷ�����ܵ�trial_idx
        if session_idx > 1
            AllTrial_Session = 12*(session_idx-1) + trial_idx;  % �����session����1���������Ҫ������ʵ�ʵ�AllTrial����ֵ
        else
            AllTrial_Session = trial_idx;
        end
        disp(["trial: ", num2str(AllTrial_Session)]);
        for window_idx=1:9
            % �ɼ�ÿһ��window������
            window_rawdata = trial_rawdata(:, 256*(window_idx-1)+1:256*(window_idx-1)+512);
            Trigger = window_rawdata(end,1);
            assert(Trigger==Trials(AllTrial_Session), "Trigger �� Trials �Ų���������ͬ��");
            [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess_Hanning(window_rawdata, Trials(AllTrial_Session), sample_frequency, WindowLength, channels);
            % ���͵÷��Լ�һϵ������
            config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0 ;0;0;0;0 ];
            order = 1.0;
            resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name_simu, config_data, foldername);  % �������ݸ����ϵ�ģ�ͣ����������
            % resultMI�����ݽṹ��[Ԥ������; �������ֱ��softmax����; ʵ�ʵ����]
            disp(['predict cls: ', num2str(resultMI(1,1))]);
            disp(['cls prob: ', num2str(resultMI(1+(1+Trigger),1))]);  % ע�������Ӧ�Ĺ�ϵ������Ӧ����Trigger+2���ܶ�Ӧ�ϸ���
            disp(['probs: ', num2str(resultMI(2,1)), ', ', num2str(resultMI(3,1)), ',', num2str(resultMI(4,1))]);
            disp(['Trigger: ', num2str(Trigger)]);
            
            pause(1);  % ��ͣ1s
            % �ռ�ȫ�ֵĸ��ʣ�������ʾ
            MI_Acc = [MI_Acc, resultMI(1+(1+Trigger),1)];
            MI_Acc_GlobalAvg = [MI_Acc_GlobalAvg, mean(MI_Acc)];
            resultMI_ = [resultMI; Trigger];
            resultsMI = [resultsMI, resultMI_];
            % �ռ���ε����ݣ�׼���������
            TriggerRepeat_ = repmat(Trigger,1,512);
            TrialData_Processed = [TrialData_Processed; [FilteredDataMI;TriggerRepeat_]];
        end
        % һ��trial����֮��Ĳ���
        % �������ݺ͸���ģ��
        config_data = [WindowLength;size(channels, 2);Trials(AllTrial_Session);session_idx;AllTrial_Session;size(MI_Acc, 2);0; 0;0;0;0 ];
        order = 2.0;  % �������ݺ�ѵ��������
        Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name_simu, config_data);  % ����ָ��÷������������ݣ�[0,0,0,0]���������ڴ������ݣ���ֹӦΪ�ռ�Ӱ�촫��
        pause(5.0);
        SaveMIEngageTrials(subject_name_simu, foldername, config_data, resultsMI, ...
            MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed);
        resultsMI = [];  % MI������������ֵ��ԭ
        MI_Acc = [];  % ���ڴ洢һ��trial��������з������
        MI_Acc_GlobalAvg = [];  % ���ڴ洢һ��trial�����ȫ�ֵ�ƽ���������
        TrialData_Processed = [];
    end
end


%% ׼��ÿһ��sessionÿһ��trial��rawdata�ĺ���
% ���룺session��� session_idx���������� subject_name�����ݴ洢�ļ���foldername_Sessions��rawdata���ݴ洢���ļ���foldername_RawData
% �����session_rawdata: ׼���õ�session��ÿһ��trial��ԭʼ���ݣ����ݸ�ʽ33(32 channel + 1 trigger) * (10 * 256 * 12)
function session_rawdata = RawDataTrial(session_idx, subject_name, foldername_Sessions, foldername_RawData)
    load(fullfile(foldername_Sessions, foldername_RawData, ['Online_EEGMI_RawData_session_', num2str(session_idx), '_', subject_name, '.mat']));
    rawdata_session = TrialData;
    % ��ȡtrigger
    trigger = rawdata_session(end, :);
    % ֻ��ȡMI��ص�trigger������
    valid_columns = find(trigger == 0 | trigger == 1 | trigger == 2);
    % ��ȡ����
    session_rawdata = rawdata_session(:, valid_columns);
end

%% �洢���˶���������еĲ����ָ��
function SaveMIEngageTrials(subject_name, foldername, config_data, resultsMI, ...
    MI_Acc, MI_Acc_GlobalAvg, TrialData_Processed)
    
    foldername = [foldername, '\\Online_Engagements_', subject_name]; % �����ļ����Ƿ����
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end

    save([foldername, '\\', ['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  ...
        '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), ...
        '_window_', num2str(config_data(6,1)), 'EI_mu' ], '.mat' ],'resultsMI',...
        'MI_Acc','MI_Acc_GlobalAvg','TrialData_Processed');  % �洢��ص���ֵ
end
