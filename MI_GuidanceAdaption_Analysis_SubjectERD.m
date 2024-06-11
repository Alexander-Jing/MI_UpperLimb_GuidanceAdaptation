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
endTrial = 96; % 结束trial的数字

% 初始化存储预测值和标签的数组
allData_MuSupTrial = [];

% 读取每一个类别的每一个trial的平均概率
% 遍历指定范围内的trial
for category = 0:2
    % 初始化存储每个类别数据的数组
    categoryDataMuSupTrial = [];
    
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
           categoryDataMuSupTrial = [categoryDataMuSupTrial, mean(data.mu_suppressions(1,:))];
            
        end
    end
    
    % 存储所有类别的数据
    allData_MuSupTrial{category+1} = categoryDataMuSupTrial;
end

% 为每个类别绘制图形
for i = 1:length(allData_MuSupTrial)
    figure; % 创建新图形窗口
    % 使用smoothdata函数对数据进行平滑处理
    smoothedData = movmean(allData_MuSupTrial{i}, 4);
    plot(smoothedData, 'LineWidth', 2); % 绘制线图
    title(sprintf('Category %d Mu Sup', i-1)); % 设置标题
    xlabel('Trial Number'); % x轴标签
    ylabel('Accuracy'); % y轴标签
    grid on; % 显示网格
    %ylim([0.3 0.6]); % 设置y轴范围
end

startTrial_1 = 1;
endTrial_1 = 12;
startTrial_2 = 85;
endTrial_2 = 96;
for category = 1:length(allData_MuSupTrial)
    fprintf('Trial: %d 到 %d \n', startTrial_1, endTrial_1);
    fprintf('类别 %d 的mu衰减: %.2f\n', category-1, mean(allData_MuSupTrial{category}((startTrial_1-1)/3+1:endTrial_1/3)));
end

for category = 1:length(allData_MuSupTrial)
    fprintf('Trial: %d 到 %d \n', startTrial_2, endTrial_2);
    fprintf('类别 %d 的mu衰减: %.2f\n', category-1, mean(allData_MuSupTrial{category}((startTrial_2-1)/3+1:endTrial_2/3)));
end

