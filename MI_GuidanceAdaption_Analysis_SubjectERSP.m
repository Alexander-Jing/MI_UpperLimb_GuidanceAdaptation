newtimef% �˶����������������
subject_name = 'Wyx_0923_compare_online';  % ��������
foldername_Sessions = 'Wyx_0923_compare_online_20240929_212507760_data';  % ��session����1��ʱ����Ҫ�ֹ�����foldername_Sessions
foldername_Engagements = 'Online_Engagements_Wyx_0923_compare_online';

EEG_Cap = 0;  % �ж�ʹ�õ��Ե�ñ���豸��0Ϊԭ������ñ��(Jyt-20240824-GraelEEG.xml)��1Ϊ�µ�ñ��(Jyt-20240918-GraelEEG.xml)
channel_selection=1; % �ж��Ƿ�Ҫ����ͨ��ѡ��Ŀǰ����Ϊ0�������������ݣ������ں���������Ͽ��Կ���ѡ��

% ������ʼ�ͽ�����trial����
startTrial_1 = 1; % ��һ����ʼtrial������
endTrial_1 = 12; % ��һ�����trial������

session2 = 1; % �Ƿ�ʹ�õڶ���session
startTrial_2 = 13; % �ڶ�����ʼtrial������
endTrial_2 = 36; % �ڶ������trial������

% ��ʼ���洢Ԥ��ֵ�ͱ�ǩ������
allPredictions = [];
allLabels = [];
allData = [];

% �������Ȥ��ͨ��
if EEG_Cap==0  % ѡ���ϵ�ñ��(Jyt-20240824-GraelEEG.xml)
    if channel_selection==0
        channel_selected = 24;  % ѡ��C3��Ϊ������ͨ��
    else
        channel_selected = 21;  % ѡ��C3��Ϊ������ͨ��
    end
elseif EEG_Cap==1  % ѡ���µ�ñ��(Jyt-20240918-GraelEEG.xml)
    if channel_selection==0
        channel_selected = 17;  % ѡ��C3��Ϊ������ͨ��
    else
        channel_selected = 14;  % ѡ��C3��Ϊ������ͨ��
    end
end

% ��ʼ��t-SNE���ݺͱ�ǩ
tsneDataAll = [];
tsneLabelsAll = [];

% ����ָ����Χ�ڵ�trial
for category = 0:2
    % ��ʼ���洢ÿ��������ݵ�����
    categoryData = [];
    
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
            % �����ļ��е�TrialData_Processed����
            data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'TrialData_Processed');
            
            % ��ȡ���ݴ�С
            [numRows, ~] = size(data.TrialData_Processed);
            
            % ȷ�������������Ա�33����
            if mod(numRows, 28) == 0
                % ������������
                numSamples = numRows / 28;
                sampleFrames = [];
                % ѡȡ����
                for sampleIdx = 1:numSamples
                    % ֻѡȡ���� �����ݣ��Ӷ�����һ��������trial������
                    if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                        % ���㵱ǰ��������ʼ��
                        startRow = (sampleIdx-1)*28 + 1;
                        % ��ȡ����
                        sampleData = data.TrialData_Processed(startRow:startRow+27, :);
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
    if session2 == 1 % �Ƿ�ʹ�õڶ���session
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
                % �����ļ��е�TrialData_Processed����
                data = load(fullfile(fileList(fileIdx).folder, fileList(fileIdx).name), 'TrialData_Processed');
                
                % ��ȡ���ݴ�С
                [numRows, ~] = size(data.TrialData_Processed);
                
                % ȷ�������������Ա�33����
                if mod(numRows, 28) == 0
                    % ������������
                    numSamples = numRows / 28;
                    sampleFrames = [];
                    % ѡȡ����
                    for sampleIdx = 1:numSamples
                        % ֻѡȡ���� �����ݣ��Ӷ�����һ��������trial������
                        if sampleIdx==1 || sampleIdx==2 || sampleIdx==4 || sampleIdx==6 || sampleIdx==8 || sampleIdx==10
                            % ���㵱ǰ��������ʼ��
                            startRow = (sampleIdx-1)*28 + 1;
                            % ��ȡ����
                            sampleData = data.TrialData_Processed(startRow:startRow+27, :);
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