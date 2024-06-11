newtimef% 运动想象基本参数设置
subject_name = 'Jyt_test_0606_online';  % 被试姓名
foldername_Sessions = 'Jyt_test_0606_online_20240606_201926565_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
foldername_Engagements = 'Online_Engagements_Jyt_test_0606_online';
% 定义起始和结束的trial数量
startTrial = 1; % 起始trial的数字
endTrial = 24; % 结束trial的数字

% 初始化存储预测值和标签的数组
allPredictions = [];
allLabels = [];
allData = [];

% 定义感兴趣的通道
channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];

% 初始化t-SNE数据和标签
tsneDataAll = [];
tsneLabelsAll = [];

% 遍历指定范围内的trial
for category = 0:2
    % 初始化存储每个类别数据的数组
    categoryData = [];
    
    for trial = startTrial:endTrial
        % 构建文件名模式
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_6EI_mu.mat', subject_name, category, trial);
        
        % 获取文件夹中匹配的文件列表
        fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
        
        % 遍历找到的文件
        for fileIdx = 1:length(fileList)
            % 加载文件中的TrialData_Processed变量
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'TrialData_Processed');
            
            % 获取数据大小
            [numRows, ~] = size(data.TrialData_Processed);
            
            % 确保数据行数可以被33整除
            if mod(numRows, 33) == 0
                % 计算样本数量
                numSamples = numRows / 33;
                
                % 取最后6个样本
                for sampleIdx = numSamples-5:numSamples
                    % 计算当前样本的起始行
                    startRow = (sampleIdx-1)*33 + 1;
                    % 提取样本
                    sampleData = data.TrialData_Processed(startRow:startRow+32, :);
                    % 选择指定的通道
                    sampleData = sampleData(channels, :);
                    % 存储样本数据
                    categoryData = cat(3, categoryData, sampleData);
                end
            end
        end
    end
    
    % 存储所有类别的数据
    allData{category+1} = categoryData;
end

% 假设 allData{2} 和 allData{3} 分别存储了类别1和类别2的数据
% 并且数据的尺寸是 [样本数 x 通道数 x 时间点数]

% 提取两个类别的数据
dataClass1 = allData{2};
dataClass2 = allData{3};

% 将数据转置以符合 FLD 的输入要求 [样本数 x 特征数]
dataClass1 = permute(dataClass1, [3, 1, 2]);
dataClass2 = permute(dataClass2, [3, 1, 2]);

% 将数据重塑为二维数组
dataClass1 = reshape(dataClass1, [], size(dataClass1, 2)*size(dataClass1, 3));
dataClass2 = reshape(dataClass2, [], size(dataClass2, 2)*size(dataClass2, 3));

[V, eigvalueSum] = fld([dataClass1;dataClass2], [ones(size(dataClass1,1),1);2*ones(size(dataClass1,1),1)],1);
fldProjectionClass1 = dataClass1 * V;
fldProjectionClass2 = dataClass2 * V;

% 绘制 FLD 投影
figure;
scatter(fldProjectionClass1(:,1), zeros(size(fldProjectionClass1,1),1), 10, 'r', 'filled');
hold on;
scatter(fldProjectionClass2(:,1), zeros(size(fldProjectionClass2,1),1), 10, 'b', 'filled');
hold off;
title('Fisher''s Linear Discriminant Projection');
xlabel('FLD Score');
ylabel('Zero Line');
legend('Category 1', 'Category 2');

