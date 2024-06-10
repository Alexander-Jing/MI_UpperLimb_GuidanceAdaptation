% 运动想象基本参数设置
subject_name = 'Jyt_test_0606_online';  % 被试姓名
foldername_Sessions = 'Jyt_test_0606_online_20240606_201926565_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
foldername_Engagements = 'Online_Engagements_Jyt_test_0606_online';
foldername_trajectory = fullfile(foldername_Sessions, ['Online_EEGMI_trajectory_', subject_name]);

% 频域滤波用的数据
sample_frequency  = 256; % 采样频率
nfft = 512; % FFT 的点数
window = hamming(128); % 使用汉明窗
overlap = 64; % 重叠的样本数

% pca降维设定
pca_dim = 47;

% 定义起始和结束的trial数量
startTrial = 1; % 起始trial的数字
endTrial = 72; % 结束trial的数字

% 初始化存储预测值和标签的数组
allData_AccTrial = [];
allData_ThreTrial = [];

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
    % 遍历数组，将大于0.4的数值除以1.25
    for i = 1:length(data_thres_)
        if data_thres_(i) > 0.4
            data_thres_(i) = data_thres_(i) / 1.25;
        end
    end
    data_thres_repeated = repmat(data_thres_(1:trials_category), 1, 1);
    % 将矩阵转换为行向量
    data_thres_repeated = data_thres_repeated(:)';
    allData_ThreTrial{category+1} = data_thres_repeated;
end

% 读取每一个类别的每一个trial的平均概率
% 遍历指定范围内的trial
for category = 0:2
    % 初始化存储每个类别数据的数组
    categoryDataAccTrial = [];
    
    for trial = startTrial:endTrial
        % 构建文件名模式
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_6EI_mu.mat', subject_name, category, trial);
        
        % 获取文件夹中匹配的文件列表
        fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
        
        % 遍历找到的文件
        for fileIdx = 1:length(fileList)
            % 加载文件中的TrialData_Processed变量
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name));
            
            % 获取数据
           categoryDataAccTrial = [categoryDataAccTrial, max(data.MI_Acc_GlobalAvg)];
            
        end
    end
    
    % 存储所有类别的数据
    allData_AccTrial{category+1} = categoryDataAccTrial;
end

% 为每个类别绘制图形
for i = 3:length(allData_AccTrial)
    figure; % 创建新图形窗口
    % 使用smoothdata函数对数据进行平滑处理
    smoothedData = movmean(allData_AccTrial{i}, 4);
    plot(smoothedData, 'LineWidth', 2); % 绘制线图
    hold on;
    if i>1
        smoothedData_Thre = movmean(allData_ThreTrial{i}, 1);
        plot(smoothedData_Thre, 'LineWidth', 2);
    end
    hold off;
    title(sprintf('Category %d Accuracy', i-1)); % 设置标题
    xlabel('Trial Number'); % x轴标签
    ylabel('Accuracy'); % y轴标签
    grid on; % 显示网格
    ylim([0.3 0.6]); % 设置y轴范围
end
