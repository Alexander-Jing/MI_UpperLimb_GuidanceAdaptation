% �˶����������������
subject_name = 'Wzq_compare_online';  % ��������
foldername_Sessions = 'Wzq_compare_online_20241003_205711999_data';  % folder data
foldername_Engagements = 'Online_Engagements_Wzq_compare_online';
% ������ʼ�ͽ�����trial����
startTrial_1 = 61; % ��һ����ʼtrial������
endTrial_1 = 72; % ��һ�����trial������

session2 = 1; % �Ƿ�ʹ�õڶ���session
startTrial_2 = 85; % �ڶ�����ʼtrial������
endTrial_2 = 96; % �ڶ������trial������

% ��ʼ���洢Ԥ��ֵ�ͱ�ǩ������
allPredictions = [];
allLabels = [];

% ����ָ����Χ�ڵ�trial
for category = 0:2
    % ����ָ����Χ�ڵ�trial
    for trial = startTrial_1:endTrial_1
        % �����ļ���ģʽ
        split_name = strsplit(subject_name, '_');
        if strcmp(split_name(end), 'control') || strcmp(split_name(end-1), 'compare')
            % �ڶ���ʵ���У�������û�н������ߵĸ��£�����windows������û�и��£��Ӷ��������洢��ʱ����������
            filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_8EI_mu.mat', subject_name, category, trial);
        else
            filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        end
        
        % ��ȡ�ļ�����ƥ����ļ��б�
        fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
        
        % �����ҵ����ļ�
        for fileIdx = 1:length(fileList)
            % �����ļ��е�resultsMI����
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'resultsMI');
            
            % ��ȡԤ��ֵ�ͱ�ǩ
            predictions = data.resultsMI(1, :);
            labels = data.resultsMI(end, :);
            
            % �洢���
            allPredictions = [allPredictions, predictions];
            allLabels = [allLabels, labels];
        end
    end
    if session2 == 1  % �����Ҫ������session
        for trial = startTrial_2:endTrial_2
            % �����ļ���ģʽ
            split_name = strsplit(subject_name, '_');
            if strcmp(split_name(end), 'control') || strcmp(split_name(end-1), 'compare')
                % �ڶ���ʵ���У�������û�н������ߵĸ��£�����windows������û�и��£��Ӷ��������洢��ʱ����������
                filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_8EI_mu.mat', subject_name, category, trial);
            else
                filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
            end
            % ��ȡ�ļ�����ƥ����ļ��б�
            fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
            
            % �����ҵ����ļ�
            for fileIdx = 1:length(fileList)
                % �����ļ��е�resultsMI����
                data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'resultsMI');
                
                % ��ȡԤ��ֵ�ͱ�ǩ
                predictions = data.resultsMI(1, :);
                labels = data.resultsMI(end, :);
                
                % �洢���
                allPredictions = [allPredictions, predictions];
                allLabels = [allLabels, labels];
            end
        end
    end
end


% �������徫��
%totalAccuracy = sum(allLabels == allPredictions) / length(allLabels);

% �����������
[C,~] = confusionmat(allLabels, allPredictions);
totalAccuracy = sum(diag(C))/sum(C(:));

% ��ʼ��F1��������
recall = zeros(1,3);
precision = zeros(1,3);
F1scores = zeros(1,3);

% ����ÿ������F1����
for class = 1:3
    precision(class) = C(class,class) / sum(C(:,class));
    recall(class) = C(class,class) / sum(C(class,:));
    F1scores(class) = 2 * precision(class) * recall(class) / (precision(class) + recall(class));
end

% ����ƽ��F1����
averageF1score = mean(F1scores);

% ��ʾ���
fprintf('Trial: %d �� %d \n', startTrial_1, endTrial_1);
if session2==1
    fprintf('Trial: %d �� %d \n', startTrial_2, endTrial_2);
end
fprintf('���徫��: %.2f\n', totalAccuracy);
fprintf('ƽ��F1����: %.2f\n', averageF1score);
for category = 1:3
    fprintf('��� %d ���ٻ���: %.2f\n', category-1, recall(category));
    %fprintf('��� %d �ľ�ȷ��: %.2f\n', category-1, precision(category));
    fprintf('��� %d ��F1����: %.2f\n', category-1, F1scores(category));
end