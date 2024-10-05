% �˶����������������
subject_name = 'Wmy_online';  % ��������
foldername_Sessions = 'Wmy_online_20241005_170043403_data';  % ��session����1��ʱ����Ҫ�ֹ�����foldername_Sessions
foldername_Engagements = 'Online_Engagements_Wmy_online';
foldername_trajectory = fullfile(foldername_Sessions, ['Online_EEGMI_trajectory_', subject_name]);

% ������ʼ�ͽ�����trial����
startTrial = 1; % ��ʼtrial������
endTrial = 108; % ����trial������
allData_ThreTrial = [];
allData_AccTrial = [];

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
    data_acc_ = data_thres(1,labels==category);
    data_thres_repeated = repmat(data_thres_(1:trials_category), 1, 1);
    data_acc_repeated = repmat(data_acc_(1:trials_category), 1, 1);
    % ������ת��Ϊ������
    data_thres_repeated = data_thres_repeated(:)';
    data_acc_repeated = data_acc_repeated(:)';
    allData_ThreTrial = [allData_ThreTrial; data_thres_repeated];
    allData_AccTrial = [allData_AccTrial; data_acc_repeated];
end

% Ϊÿ��������ͼ��
for i = 1:size(allData_AccTrial, 1)
    figure; % ������ͼ�δ���
    % ʹ��smoothdata���������ݽ���ƽ������
    smoothedData = movmean(allData_AccTrial(i,:), 8);
    plot(smoothedData, 'LineWidth', 2); % ������ͼ
    hold on;
    smoothedData_Thre = movmean(allData_ThreTrial(i,:), 4)/1.0;
    plot(smoothedData_Thre, 'LineWidth', 2);
    hold off;
    title(sprintf('Category %d Accuracy', i)); % ���ñ���
    xlabel('Trial Number'); % x���ǩ
    ylabel('Accuracy'); % y���ǩ
    grid on; % ��ʾ����
    ylim([0.2 0.60]); % ����y�᷶Χ
    legend('Average Accuracy', 'Target Accuracy'); % ���ͼ��
end
