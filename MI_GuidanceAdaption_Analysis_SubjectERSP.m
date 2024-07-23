newtimef% �˶����������������
subject_name = 'Jyt_test_0719_online';  % ��������
foldername_Sessions = 'Jyt_test_0719_online_20240719_164242159_data';  % ��session����1��ʱ����Ҫ�ֹ�����foldername_Sessions
foldername_Engagements = 'Online_Engagements_Jyt_test_0719_online';
% ������ʼ�ͽ�����trial����
startTrial_1 = 13; % ��һ����ʼtrial������
endTrial_1 = 24; % ��һ�����trial������

startTrial_2 = 25; % �ڶ�����ʼtrial������
endTrial_2 = 36; % �ڶ������trial������

% ��ʼ���洢Ԥ��ֵ�ͱ�ǩ������
allPredictions = [];
allLabels = [];
allData = [];

% �������Ȥ��ͨ��
channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];
channel_selected = 24;  % ѡ��C3��Ϊ������ͨ��

% ��ʼ��t-SNE���ݺͱ�ǩ
tsneDataAll = [];
tsneLabelsAll = [];

% ����ָ����Χ�ڵ�trial
for category = 0:2
    % ��ʼ���洢ÿ��������ݵ�����
    categoryData = [];
    
    for trial = startTrial_1:endTrial_1
        % �����ļ���ģʽ
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        
        % ��ȡ�ļ�����ƥ����ļ��б�
        fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
        
        % �����ҵ����ļ�
        for fileIdx = 1:length(fileList)
            % �����ļ��е�TrialData_Processed����
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'TrialData_Processed');
            
            % ��ȡ���ݴ�С
            [numRows, ~] = size(data.TrialData_Processed);
            
            % ȷ�������������Ա�33����
            if mod(numRows, 33) == 0
                % ������������
                numSamples = numRows / 33;
                sampleFrames = [];
                % ѡȡ����
                for sampleIdx = 1:numSamples
                    % ֻѡȡ���� �����ݣ��Ӷ�����һ��������trial������
                    if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                        % ���㵱ǰ��������ʼ��
                        startRow = (sampleIdx-1)*33 + 1;
                        % ��ȡ����
                        sampleData = data.TrialData_Processed(startRow:startRow+32, :);
                        % ѡ��ָ����ͨ��
                        sampleData = sampleData(channel_selected, :);
                        % �洢��������
                        sampleFrames = [sampleFrames; sampleData']; 
                    end
                end
                categoryData = [categoryData, sampleFrames];
            end
        end
    end

    for trial = startTrial_2:endTrial_2
        % �����ļ���ģʽ
        filePattern = sprintf('Online_EEG_data2Server_%s_class_%d_session_*_trial_%d_window_9EI_mu.mat', subject_name, category, trial);
        
        % ��ȡ�ļ�����ƥ����ļ��б�
        fileList = dir(fullfile(foldername_Sessions, foldername_Engagements, filePattern));
        
        % �����ҵ����ļ�
        for fileIdx = 1:length(fileList)
            % �����ļ��е�TrialData_Processed����
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'TrialData_Processed');
            
            % ��ȡ���ݴ�С
            [numRows, ~] = size(data.TrialData_Processed);
            
            % ȷ�������������Ա�33����
            if mod(numRows, 33) == 0
                % ������������
                numSamples = numRows / 33;
                sampleFrames = [];
                % ѡȡ����
                for sampleIdx = 1:numSamples
                    % ֻѡȡ���� �����ݣ��Ӷ�����һ��������trial������
                    if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                        % ���㵱ǰ��������ʼ��
                        startRow = (sampleIdx-1)*33 + 1;
                        % ��ȡ����
                        sampleData = data.TrialData_Processed(startRow:startRow+32, :);
                        % ѡ��ָ����ͨ��
                        sampleData = sampleData(channel_selected, :);
                        % �洢��������
                        sampleFrames = [sampleFrames; sampleData']; 
                    end
                end
                categoryData = [categoryData, sampleFrames];
            end
        end
    end
    % �洢������������
    allData{category+1} = categoryData;
end

% ���� allData{2} �� allData{3} �ֱ�洢�����1�����2������
% ��ȡ������������
dataClass0 = allData{1};
dataClass1 = allData{2};
dataClass2 = allData{3};
%dataClass_all = [dataClass1, dataClass2];

% ����ERSPͼ
[ersp,itc,powbase,times,freqs]=newtimef(dataClass1,256*12,[-3*1000 11*1000],256, 0,'plotitc','off',...
    'freqs',[1 35],  'erspmax', 10, 'scale', 'log', 'plotmean', 'off');

% ����һ���µ�ͼ�δ���
figure;

% ʹ�� imagesc ������ʾERSP
imagesc(times, freqs, ersp);

% ���������᷽�� - ͨ��ʱ����x�ᣬƵ����y��
axis xy;

% �����ɫ���Ա�ʾ��ͬ���ʵ���ɫ����
hColorbar = colorbar;
hColorbar.Label.String = 'dB';  % ������ɫ���ı�ǩΪ 'dB'

% ��ǿ��ɫ��������
hColorbar.Limits = [-10 10]; % ������ɫ���ķ�Χ
colormap jet; % ʹ�� 'jet' ��ɫͼ�����������޵���ɫ

% ��ӱ�������ǩ
title('C3');
xlabel('Times (ms)');
ylabel('Frequency (Hz)');

% ��x���0�̶ȴ����һ����ɫ����
line([0 0], ylim, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);

% ���ú��ʵ���ɫ��Χ
caxis([-10 10]);