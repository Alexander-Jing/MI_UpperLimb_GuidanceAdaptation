% %% 存储原始数据
% save([foldername_rawdata, '\\', FunctionNowFilename(['Offline_EEGMI_RawData_', subject_name], '.mat' )],'TrialData','ChanLabel');
% 
% %% 数据预处理
% % 划窗参数设置
% rawdata = TrialData;
% sample_frequency = 256; 
% WindowLength = 512;  % 每个窗口的长度
% SlideWindowLength = 256;  % 滑窗间隔
% [DataX, DataY, windows_per_session] = Offline_DataPreprocess_Hanning_GuidanceAdaption(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername, seconds_per_trial);
% 
% %% 每一种任务对应的各项指标的平均分数以及4分位数确定，并且存储相关指标
% foldername_Scores = [foldername, '\\Offline_EEGMI_Scores_', subject_name]; % 指定文件夹路径和名称
% if ~exist(foldername_Scores, 'dir')
%    mkdir(foldername_Scores);
% end
% % 计算各个变量指标的均值和方差  
% mean_std_muSup = compute_mean_std(mu_suppressions, 'mu_suppressions');  
% mean_std_EI_score = compute_mean_std(EI_index_scores, 'EI_index_scores');
% % 计算四分位数
% [quartile_caculation_mu, min_max_value_mu] = Offline_Bootstrapping_quartile(mu_suppressions, 'mu_suppressions', 1000);
% [quartile_caculation_EI, min_max_value_EI] = Offline_Bootstrapping_quartile(EI_index_scores, 'EI_index_scores', 1000);
% 
% % 存储相关数据
% save([foldername_Scores, '\\', ['Offline_EEGMI_Scores_', subject_name], '.mat' ],'scores_task','EI_indices','mu_powers', ...
%     'mu_suppressions','EI_index_scores', 'mean_std_EI_score','mean_std_muSup','quartile_caculation_mu',"min_max_value_mu","quartile_caculation_EI","min_max_value_EI"); 

%% 预处理数据传输
% 设置传输的参数
send_order = 3.0;
config_data = [WindowLength, size(channels, 2), windows_per_session, classes];
%Offline_Data2Server_Send(DataX, ip, port, subject_name, config_data, send_order, foldername);
class_accuracies = Offline_Data2Server_Communicate(DataX, ip, port, subject_name, config_data, send_order, foldername);

%% 关闭电刺激
StimCommand(1,1) = 100;
fwrite(StimControl,StimCommand);
system('taskkill /F /IM fes.exe');
close all;

%% 获取平均参与度分数的函数
function mean_std_scores = compute_mean_std(scores_task, scores_name)
    % 获取scores和triggers
    scores = scores_task(1,:);
    triggers = scores_task(2,:);

    % 获取所有不同的triggers
    unique_triggers = unique(triggers);

    % 初始化输出
    mean_scores = zeros(size(unique_triggers));
    std_scores = zeros(size(unique_triggers));

    % 对于每一个trigger，计算对应的score的均值
    for i = 1:length(unique_triggers)
        trigger = unique_triggers(i);
        mean_scores(i) = mean(scores(triggers == trigger));
        std_scores(i) = std(scores(triggers == trigger));
    end
    mean_std_scores = [mean_scores; std_scores];

    % 输出结果
    disp(['每一个Trigger的平均', scores_name, '分数是：']);
    for i = 1:length(unique_triggers)
        disp(['Trigger ' num2str(unique_triggers(i)) ' 的平均分数是 ' num2str(mean_scores(i))]);
        disp(['Trigger ' num2str(unique_triggers(i)) ' 的标准差是 ' num2str(std_scores(i))]);
    end
end
%% 计算相关mu频带衰减指标
function mu_suppresion = MI_MuSuperesion(mu_power_, mu_power, mu_channels)
    ERD_C3 = (mu_power(mu_channels.C3, 1) - mu_power_(mu_channels.C3, 1)); 
    %ERD_C4 = (mu_power(mu_channels.C4, 1) - mu_power_(mu_channels.C4, 1));  % 计算两个脑电位置的相关的指标 
    mu_suppresion =  - ERD_C3;  % 归一化到[0,1]的区间里面
end
    
    %% 计算相关的EI指标的函数
function EI_index_score = EI_index_Caculation(EI_index, EI_channels)
    channels_ = [EI_channels.Fp1,EI_channels.Fp2, EI_channels.F7, EI_channels.F3, EI_channels.Fz, EI_channels.F4, EI_channels.F8'];
    EI_index_score = mean(EI_index(channels_, 1));

end