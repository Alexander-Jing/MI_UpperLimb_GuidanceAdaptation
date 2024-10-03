newtimef% 运动想象基本参数设置
subject_name = 'Wzq_compare_online';  % 被试姓名
foldername_Sessions = 'Wzq_compare_online_20241003_205711999_data';  % 当session大于1的时候，需要手工修正foldername_Sessions
foldername_Engagements = 'Online_Engagements_Wzq_compare_online';

EEG_Cap = 1;  % 判断使用的脑电帽子设备，0为原来的老帽子(Jyt-20240824-GraelEEG.xml)，1为新的帽子(Jyt-20240918-GraelEEG.xml)
channel_selection=1; % 判断是否要进行通道选择，目前设置为0，保留所有数据，但是在后面服务器上可以开启选择

% 定义起始和结束的trial数量
startTrial_1 = 73; % 第一组起始trial的数字
endTrial_1 = 84; % 第一组结束trial的数字12

session2 = 1; % 是否使用第二个session
startTrial_2 = 85; % 第二组起始trial的数字
endTrial_2 = 96; % 第二组结束trial的数字

% 初始化存储预测值和标签的数组
allPredictions = [];
allLabels = [];
allData = [];

% 定义感兴趣的通道
if EEG_Cap==0  % 选择老的帽子(Jyt-20240824-GraelEEG.xml)
    if channel_selection==0
        channel_selected = 24;  % 选择C3作为分析的通道
    else
        channel_selected = 21;  % 选择C3作为分析的通道
    end
elseif EEG_Cap==1  % 选择新的帽子(Jyt-20240918-GraelEEG.xml)
    if channel_selection==0
        channel_selected = 17;  % 选择C3作为分析的通道
    else
        channel_selected = 14;  % 选择C3作为分析的通道
    end
end

% 初始化t-SNE数据和标签
tsneDataAll = [];
tsneLabelsAll = [];

% 遍历指定范围内的trial
for category = 0:2
    % 初始化存储每个类别数据的数组
    categoryData = [];
    
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
            % 加载文件中的TrialData_Processed变量
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'TrialData_Processed');
            
            % 获取数据大小
            [numRows, ~] = size(data.TrialData_Processed);
            
            % 确保数据行数可以被33整除
            if mod(numRows, 28) == 0
                % 计算样本数量
                numSamples = numRows / 28;
                sampleFrames = [];
                % 选取样本
                for sampleIdx = 1:numSamples
                    % 只选取下面 的数据，从而构成一个完整的trial的数据
                    if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                        % 计算当前样本的起始行
                        startRow = (sampleIdx-1)*28 + 1;
                        % 提取样本
                        sampleData = data.TrialData_Processed(startRow:startRow+27, :);
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
    if session2 == 1 % 是否使用第二个session
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
                % 加载文件中的TrialData_Processed变量
                data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'TrialData_Processed');
                
                % 获取数据大小
                [numRows, ~] = size(data.TrialData_Processed);
                
                % 确保数据行数可以被33整除
                if mod(numRows, 28) == 0
                    % 计算样本数量
                    numSamples = numRows / 28;
                    sampleFrames = [];
                    % 选取样本
                    for sampleIdx = 1:numSamples
                        % 只选取下面 的数据，从而构成一个完整的trial的数据
                        if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                            % 计算当前样本的起始行
                            startRow = (sampleIdx-1)*28 + 1;
                            % 提取样本
                            sampleData = data.TrialData_Processed(startRow:startRow+27, :);
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
[ersp,itc,powbase,times,freqs]=newtimef(dataClass2,256*12,[-3*1000 11*1000],256, 0,'plotitc','off',...
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