% �˶����������������
subject_name = 'Jyt_test_0719_online';  % ��������
foldername_Sessions = 'Jyt_test_0719_online_20240719_164242159_data';  % ��session����1��ʱ����Ҫ�ֹ�����foldername_Sessions
foldername_Engagements = 'Online_Engagements_Jyt_test_0719_online';
% ������ʼ�ͽ�����trial����
startTrial = 73; % ��ʼtrial������
endTrial = 96; % ����trial������

% ��ʼ���洢Ԥ��ֵ�ͱ�ǩ������
allPredictions = [];
allLabels = [];

% ����ָ����Χ�ڵ�trial
for category = 0:2
    % ����ָ����Χ�ڵ�trial
    for trial = startTrial:endTrial
        % �����ļ���ģʽ
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        
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
fprintf('Trial: %d �� %d \n', startTrial, endTrial);
fprintf('���徫��: %.2f\n', totalAccuracy);
fprintf('ƽ��F1����: %.2f\n', averageF1score);
for category = 1:3
    fprintf('��� %d ���ٻ���: %.2f\n', category-1, recall(category));
    %fprintf('��� %d �ľ�ȷ��: %.2f\n', category-1, precision(category));
    fprintf('��� %d ��F1����: %.2f\n', category-1, F1scores(category));
end