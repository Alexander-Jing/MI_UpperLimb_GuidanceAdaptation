% %% �洢ԭʼ����
% save([foldername_rawdata, '\\', FunctionNowFilename(['Offline_EEGMI_RawData_', subject_name], '.mat' )],'TrialData','ChanLabel');
% 
% %% ����Ԥ����
% % ������������
% rawdata = TrialData;
% sample_frequency = 256; 
% WindowLength = 512;  % ÿ�����ڵĳ���
% SlideWindowLength = 256;  % �������
% [DataX, DataY, windows_per_session] = Offline_DataPreprocess_Hanning_GuidanceAdaption(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername, seconds_per_trial);
% 
% %% ÿһ�������Ӧ�ĸ���ָ���ƽ�������Լ�4��λ��ȷ�������Ҵ洢���ָ��
% foldername_Scores = [foldername, '\\Offline_EEGMI_Scores_', subject_name]; % ָ���ļ���·��������
% if ~exist(foldername_Scores, 'dir')
%    mkdir(foldername_Scores);
% end
% % �����������ָ��ľ�ֵ�ͷ���  
% mean_std_muSup = compute_mean_std(mu_suppressions, 'mu_suppressions');  
% mean_std_EI_score = compute_mean_std(EI_index_scores, 'EI_index_scores');
% % �����ķ�λ��
% [quartile_caculation_mu, min_max_value_mu] = Offline_Bootstrapping_quartile(mu_suppressions, 'mu_suppressions', 1000);
% [quartile_caculation_EI, min_max_value_EI] = Offline_Bootstrapping_quartile(EI_index_scores, 'EI_index_scores', 1000);
% 
% % �洢�������
% save([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name], '.mat' ],'scores_task','EI_indices','mu_powers', ...
%     'mu_suppressions','EI_index_scores', 'mean_std_EI_score','mean_std_muSup','quartile_caculation_mu',"min_max_value_mu","quartile_caculation_EI","min_max_value_EI"); 

%% Ԥ�������ݴ���
% ���ô���Ĳ���
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);

%% �رյ�̼�
StimCommand(1,1) = 100;
fwrite(StimControl,StimCommand);
system('taskkill /F /IM fes.exe');
close all;

%% ��ȡƽ������ȷ����ĺ���
function mean_std_scores = compute_mean_std(scores_task, scores_name)
    % ��ȡscores��triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % ��ȡ���в�ͬ��triggers
    unique_triggers = unique(triggers);

    % ��ʼ�����
    mean_scores = zeros(size(unique_triggers));
    std_scores = zeros(size(unique_triggers));

    % ����ÿһ��trigger�������Ӧ��score�ľ�ֵ
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
        std_scores(i) = std(scores(triggers == trigger));
    end
    mean_std_scores = [mean_scores; std_scores];

    % ������
    disp(['ÿһ��Trigger��ƽ��', scores_name, '�����ǣ�']);
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' ��ƽ�������� ' num2str(mean_scores(i))]);
        disp(['Trigger ' num2str(unique_triggers(i)) ' �ı�׼���� ' num2str(std_scores(i))]);
    end
end
%% �������muƵ��˥��ָ��
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % ���������Ե�λ�õ���ص�ָ�� 
    mu_suppresion =  - ERD_C3;  % ��һ����[0,1]����������
end
    
    %% ������ص�EIָ��ĺ���
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
    EI_index_score = mean(EI_index(channels_, 1));

end