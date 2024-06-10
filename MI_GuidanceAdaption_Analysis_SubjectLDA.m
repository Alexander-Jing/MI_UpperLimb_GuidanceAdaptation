% 运动想象基本参数设置
subject_name = 'Jyt_test_0606_online';  % 被试姓名
foldername_Sessions = 'Jyt_test_0606_online_20240606_201926565_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
foldername_Engagements = 'Online_Engagements_Jyt_test_0606_online';

% 频域滤波用的数据
sample_frequency  = 256; % 采样频率
nfft = 512; % FFT 的点数
window = hamming(128); % 使用汉明窗
overlap = 64; % 重叠的样本数

% pca降维设定
pca_dim = 47;

% 定义起始和结束的trial数量
startTrial = 61; % 起始trial的数字
endTrial = 84; % 结束trial的数字

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

dataClass1_psd = ExtractPSD(dataClass1, sample_frequency, nfft, window, overlap);
dataClass2_psd = ExtractPSD(dataClass2, sample_frequency, nfft, window, overlap);

% 此处可以添加特征提取器


% 将数据重塑为二维数组
dataClass1_psd = reshape(dataClass1, [], size(dataClass1, 2)*size(dataClass1, 3));
dataClass2_psd = reshape(dataClass2, [], size(dataClass2, 2)*size(dataClass2, 3));

% 执行 PCA 降维
[coeff_1, score_1, ~, ~, explained_1] = pca(dataClass1_psd);
[coeff_2, score_2, ~, ~, explained_2] = pca(dataClass2_psd);

% 选择主成分投影
dataClass1_psd = score_1(:, 1:pca_dim);
dataClass2_psd = score_2(:, 1:pca_dim);

% 合并两个类别的数据
combinedData = [dataClass1_psd; dataClass2_psd];

% 创建标签数组
labels = [ones(size(dataClass1_psd, 1), 1); -ones(size(dataClass2_psd, 1), 1)];

% 使用 MATLAB 的 fitcdiscr 函数进行 FLD
MdlLinear = fitcdiscr(combinedData, labels);

% 计算特征值和特征向量
[V, D] = eig(MdlLinear.BetweenSigma, MdlLinear.Sigma);

% 计算部分，计算投影的情况
% 提取最大特征值对应的特征向量
[~, maxEigIdx] = max(diag(D));
maxEigVector = V(:, maxEigIdx);

% 使用最大特征向量进行一维投影
projection1D = combinedData * maxEigVector;

% 分别获取两个类别的一维投影
projectionClass1_1D = projection1D(1:size(dataClass1, 1));
projectionClass2_1D = projection1D(size(dataClass1, 1)+1:end);

% 计算Fisher’s discriminant ratio (FDR)
meanDifference = abs(mean(projectionClass1_1D) - mean(projectionClass2_1D));
varWithin = var(projectionClass1_1D) + var(projectionClass2_1D);
FDR = meanDifference^2 / varWithin;
fprintf('Trial: %d 到 %d \n', startTrial, endTrial);
fprintf('Fisher’s discriminant ratio (FDR): %.2f\n', FDR);

% 绘制一维投影
figure;
scatter(projectionClass1_1D, zeros(size(projectionClass1_1D)), 'r', 'filled');
hold on;
scatter(projectionClass2_1D, zeros(size(projectionClass2_1D)), 'b', 'filled');
hold off;
title('Two-dimensional Projection using FLD with Maximum Eigenvalues');
xlabel('First Dimension');
ylabel('Second Dimension');
legend('Category 1', 'Category 2');

% 可视化部分，可以进行二维FLD投影的可视化
% 提取两个最大特征值对应的特征向量
[~, maxEigIdx] = maxk(diag(D), 2);
maxEigVectors = V(:, maxEigIdx);

% 使用最大特征向量进行二维投影
projection2D = combinedData * maxEigVectors;

% 分别获取两个类别的二维投影
projectionClass1 = projection2D(1:size(dataClass1, 1), :);
projectionClass2 = projection2D(size(dataClass1, 1)+1:end, :);

% 绘制二维投影
figure;
scatter(projectionClass1(:,1), projectionClass1(:,2), 'r', 'filled');
hold on;
scatter(projectionClass2(:,1), projectionClass2(:,2), 'b', 'filled');
hold off;
title('Two-dimensional Projection using FLD with Maximum Eigenvalues');
xlabel('First Dimension');
ylabel('Second Dimension');
legend('Category 1', 'Category 2');


%% 提取 PSD 特征
function [psd_samples] = ExtractPSD(eeg_data, sample_frequency, nfft, window, overlap)
   psd_samples = [];
   for i=1:size(eeg_data,1)
       psd_eegdata = zeros(size(eeg_data, 2), nfft/2+1);
       for j=1:size(eeg_data,2)
            [psd_eegdata(j, :), f] = pwelch(squeeze(eeg_data(i, j, :)), window, overlap, nfft, sample_frequency);
       end
       psd_samples = cat(3, psd_samples, psd_eegdata);
   end
   psd_samples = permute(psd_samples, [3, 1, 2]);
end
