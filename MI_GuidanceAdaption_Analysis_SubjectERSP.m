newtimef% 运动想象基本参数设置
subject_name = 'Jyt_test_0719_online';  % 被试姓名
foldername_Sessions = 'Jyt_test_0719_online_20240719_164242159_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
foldername_Engagements = 'Online_Engagements_Jyt_test_0719_online';
% 定义起始和结束的trial数量
startTrial_1 = 13; % 第一组起始trial的数字
endTrial_1 = 24; % 第一组结束trial的数字

startTrial_2 = 25; % 第二组起始trial的数字
endTrial_2 = 36; % 第二组结束trial的数字

% 初始化存储预测值和标签的数组
allPredictions = [];
allLabels = [];
allData = [];

% 定义感兴趣的通道
channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];
channel_selected = 24;  % 选择C3作为分析的通道

% 初始化t-SNE数据和标签
tsneDataAll = [];
tsneLabelsAll = [];

% 遍历指定范围内的trial
for category = 0:2
    % 初始化存储每个类别数据的数组
    categoryData = [];
    
    for trial = startTrial_1:endTrial_1
        % 构建文件名模式
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        
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
                sampleFrames = [];
                % 选取样本
                for sampleIdx = 1:numSamples
                    % 只选取下面 的数据，从而构成一个完整的trial的数据
                    if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                        % 计算当前样本的起始行
                        startRow = (sampleIdx-1)*33 + 1;
                        % 提取样本
                        sampleData = data.TrialData_Processed(startRow:startRow+32, :);
                        % 选择指定的通道
                        sampleData = sampleData(channel_selected, :);
                        % 存储样本数据
                        sampleFrames = [sampleFrames; sampleData']; 
                    end
                end
                categoryData = [categoryData, sampleFrames];
            end
        end
    end

    for trial = startTrial_2:endTrial_2
        % 构建文件名模式
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        
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
                sampleFrames = [];
                % 选取样本
                for sampleIdx = 1:numSamples
                    % 只选取下面 的数据，从而构成一个完整的trial的数据
                    if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                        % 计算当前样本的起始行
                        startRow = (sampleIdx-1)*33 + 1;
                        % 提取样本
                        sampleData = data.TrialData_Processed(startRow:startRow+32, :);
                        % 选择指定的通道
                        sampleData = sampleData(channel_selected, :);
                        % 存储样本数据
                        sampleFrames = [sampleFrames; sampleData']; 
                    end
                end
                categoryData = [categoryData, sampleFrames];
            end
        end
    end
    % 存储所有类别的数据
    allData{category+1} = categoryData;
end

% 假设 allData{2} 和 allData{3} 分别存储了类别1和类别2的数据
% 提取两个类别的数据
dataClass0 = allData{1};
dataClass1 = allData{2};
dataClass2 = allData{3};
%dataClass_all = [dataClass1, dataClass2];

% 绘制ERSP图
[ersp,itc,powbase,times,freqs]=newtimef(dataClass1,256*12,[-3*1000 11*1000],256, 0,'plotitc','off',...
    'freqs',[1 35],  'erspmax', 10, 'scale', 'log', 'plotmean', 'off');

% 创建一个新的图形窗口
figure;

% 使用 imagesc 函数显示ERSP
imagesc(times, freqs, ersp);

% 设置坐标轴方向 - 通常时间是x轴，频率是y轴
axis xy;

% 添加颜色条以表示不同功率的颜色编码
hColorbar = colorbar;
hColorbar.Label.String = 'dB';  % 设置颜色条的标签为 'dB'

% 增强颜色条的亮度
hColorbar.Limits = [-10 10]; % 设置颜色条的范围
colormap jet; % 使用 'jet' 颜色图，它具有鲜艳的颜色

% 添加标题和轴标签
title('C3');
xlabel('Times (ms)');
ylabel('Frequency (Hz)');

% 在x轴的0刻度处添加一条黑色虚线
line([0 0], ylim, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);

% 设置合适的颜色范围
caxis([-10 10]);