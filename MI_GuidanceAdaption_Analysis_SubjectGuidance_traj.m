% 运动想象基本参数设置
subject_name = 'Wmy_online';  % 被试姓名
foldername_Sessions = 'Wmy_online_20241005_170043403_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
foldername_Engagements = 'Online_Engagements_Wmy_online';
foldername_trajectory = fullfile(foldername_Sessions, ['Online_EEGMI_trajectory_', subject_name]);

% 定义起始和结束的trial数量
startTrial = 1; % 起始trial的数字
endTrial = 108; % 结束trial的数字
allData_ThreTrial = [];
allData_AccTrial = [];

% 定义感兴趣的通道
channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];

% 读取每一个类别的每一个trial的阈值
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
    % 将矩阵转换为行向量
    data_thres_repeated = data_thres_repeated(:)';
    data_acc_repeated = data_acc_repeated(:)';
    allData_ThreTrial = [allData_ThreTrial; data_thres_repeated];
    allData_AccTrial = [allData_AccTrial; data_acc_repeated];
end

% 为每个类别绘制图形
for i = 1:size(allData_AccTrial, 1)
    figure; % 创建新图形窗口
    % 使用smoothdata函数对数据进行平滑处理
    smoothedData = movmean(allData_AccTrial(i,:), 8);
    plot(smoothedData, 'LineWidth', 2); % 绘制线图
    hold on;
    smoothedData_Thre = movmean(allData_ThreTrial(i,:), 4)/1.0;
    plot(smoothedData_Thre, 'LineWidth', 2);
    hold off;
    title(sprintf('Category %d Accuracy', i)); % 设置标题
    xlabel('Trial Number'); % x轴标签
    ylabel('Accuracy'); % y轴标签
    grid on; % 显示网格
    ylim([0.2 0.60]); % 设置y轴范围
    legend('Average Accuracy', 'Target Accuracy'); % 添加图例
end
