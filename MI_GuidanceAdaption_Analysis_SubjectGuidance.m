% �˶����������������
subject_name = 'Jyt_test_0719_online';  % ��������
foldername_Sessions = 'Jyt_test_0719_online_20240719_164242159_data';  % ��session����1��ʱ����Ҫ�ֹ�����foldername_Sessions
foldername_Engagements = 'Online_Engagements_Jyt_test_0719_online';
foldername_trajectory = fullfile(foldername_Sessions, ['Online_EEGMI_trajectory_', subject_name]);

% Ƶ���˲��õ�����
sample_frequency  = 256; % ����Ƶ��
nfft = 512; % FFT �ĵ���
window = hamming(128); % ʹ�ú�����
overlap = 64; % �ص���������

% pca��ά�趨
pca_dim = 47;

% ������ʼ�ͽ�����trial����
startTrial = 1; % ��ʼtrial������
endTrial = 96; % ����trial������

% ��ʼ���洢Ԥ��ֵ�ͱ�ǩ������
allData_AccTrial = [];
allData_ThreTrial = [];

% �������Ȥ��ͨ��
channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];

% ��ȡÿһ������ÿһ��trial����ֵ
data_thre = load(fullfile(foldername_Sessions, ['Online_EEGMI_trajectory_', subject_name], ['Online_EEGMI_trajectory_', subject_name, '.mat']), 'Train_Performance');
data_thres = data_thre.Train_Performance;
trials_category = (endTrial-startTrial+1)/3;
for category = 1:2
    %data_thres_visual = [];
    labels = data_thres(3,:);
    data_thres_ = data_thres(2,labels==category);
    data_thres_repeated = repmat(data_thres_(1:trials_category), 1, 1);
    % ������ת��Ϊ������
    data_thres_repeated = data_thres_repeated(:)';
    allData_ThreTrial{category+1} = data_thres_repeated;
end

% ��ȡÿһ������ÿһ��trial��ƽ������
% ����ָ����Χ�ڵ�trial
for category = 0:2
    % ��ʼ���洢ÿ��������ݵ�����
    categoryDataAccTrial = [];
    
    for trial = startTrial:endTrial
        % �����ļ���ģʽ
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        
        % ��ȡ�ļ�����ƥ����ļ��б�
        fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
        
        % �����ҵ����ļ�
        for fileIdx = 1:length(fileList)
            % �����ļ��е�TrialData_Processed����
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name));
            
            % ��ȡ����
           categoryDataAccTrial = [categoryDataAccTrial, max(data.MI_Acc_GlobalAvg)];
            
        end
    end
    
    % �洢������������
    allData_AccTrial{category+1} = categoryDataAccTrial;
end

% Ϊÿ��������ͼ��
for i = 3:length(allData_AccTrial)
    figure; % ������ͼ�δ���
    % ʹ��smoothdata���������ݽ���ƽ������
    smoothedData = movmean(allData_AccTrial{i}, 4);
    plot(smoothedData, 'LineWidth', 2); % ������ͼ
    hold on;
    if i>1
        smoothedData_Thre = movmean(allData_ThreTrial{i}, 1);
        plot(smoothedData_Thre, 'LineWidth', 2);
    end
    hold off;
    title(sprintf('Category %d Accuracy', i-1)); % ���ñ���
    xlabel('Trial Number'); % x���ǩ
    ylabel('Accuracy'); % y���ǩ
    grid on; % ��ʾ����
    ylim([0.3 0.6]); % ����y�᷶Χ
end