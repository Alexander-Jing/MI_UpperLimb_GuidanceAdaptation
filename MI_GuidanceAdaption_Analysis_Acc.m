% 运动想象基本参数设置
subject_name = 'Wzq_compare_online';  % 被试姓名
foldername_Sessions = 'Wzq_compare_online_20241003_205711999_data';  % folder data
foldername_Engagements = 'Online_Engagements_Wzq_compare_online';
% 定义起始和结束的trial数量
startTrial_1 = 61; % 第一组起始trial的数字
endTrial_1 = 72; % 第一组结束trial的数字

session2 = 1; % 是否使用第二个session
startTrial_2 = 85; % 第二组起始trial的数字
endTrial_2 = 96; % 第二组结束trial的数字

% 初始化存储预测值和标签的数组
allPredictions = [];
allLabels = [];

% 遍历指定范围内的trial
for category = 0:2
    % 遍历指定范围内的trial
    for trial = startTrial_1:endTrial_1
        % 构建文件名模式
        split_name = strsplit(subject_name, '_');
        if strcmp(split_name(end), 'control') || strcmp(split_name(end-1), 'compare')
            % 在对照实验中，由于是没有进行在线的更新，所以windows的数量没有更新，从而导致最后存储的时候是这样的
            filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_8EI_mu.mat', subject_name, category, trial);
        else
            filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        end
        
        % 获取文件夹中匹配的文件列表
        fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
        
        % 遍历找到的文件
        for fileIdx = 1:length(fileList)
            % 加载文件中的resultsMI变量
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'resultsMI');
            
            % 提取预测值和标签
            predictions = data.resultsMI(1, :);
            labels = data.resultsMI(end, :);
            
            % 存储结果
            allPredictions = [allPredictions, predictions];
            allLabels = [allLabels, labels];
        end
    end
    if session2 == 1  % 如果还要导入别的session
        for trial = startTrial_2:endTrial_2
            % 构建文件名模式
            split_name = strsplit(subject_name, '_');
            if strcmp(split_name(end), 'control') || strcmp(split_name(end-1), 'compare')
                % 在对照实验中，由于是没有进行在线的更新，所以windows的数量没有更新，从而导致最后存储的时候是这样的
                filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_8EI_mu.mat', subject_name, category, trial);
            else
                filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
            end
            % 获取文件夹中匹配的文件列表
            fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
            
            % 遍历找到的文件
            for fileIdx = 1:length(fileList)
                % 加载文件中的resultsMI变量
                data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'resultsMI');
                
                % 提取预测值和标签
                predictions = data.resultsMI(1, :);
                labels = data.resultsMI(end, :);
                
                % 存储结果
                allPredictions = [allPredictions, predictions];
                allLabels = [allLabels, labels];
            end
        end
    end
end


% 计算总体精度
%totalAccuracy = sum(allLabels == allPredictions) / length(allLabels);

% 计算混淆矩阵
[C,~] = confusionmat(allLabels, allPredictions);
totalAccuracy = sum(diag(C))/sum(C(:));

% 初始化F1分数数组
recall = zeros(1,3);
precision = zeros(1,3);
F1scores = zeros(1,3);

% 计算每个类别的F1分数
for class = 1:3
    precision(class) = C(class,class) / sum(C(:,class));
    recall(class) = C(class,class) / sum(C(class,:));
    F1scores(class) = 2 * precision(class) * recall(class) / (precision(class) + recall(class));
end

% 计算平均F1分数
averageF1score = mean(F1scores);

% 显示结果
fprintf('Trial: %d 到 %d \n', startTrial_1, endTrial_1);
if session2==1
    fprintf('Trial: %d 到 %d \n', startTrial_2, endTrial_2);
end
fprintf('总体精度: %.2f\n', totalAccuracy);
fprintf('平均F1分数: %.2f\n', averageF1score);
for category = 1:3
    fprintf('类别 %d 的召回率: %.2f\n', category-1, recall(category));
    %fprintf('类别 %d 的精确率: %.2f\n', category-1, precision(category));
    fprintf('类别 %d 的F1分数: %.2f\n', category-1, F1scores(category));
end