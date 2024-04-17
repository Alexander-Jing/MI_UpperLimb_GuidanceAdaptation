%% 根据之前的表现进行调整任务难度
function [Flag_FesOptim, Train_Thre_Global_Optim, RestTimeLen] = TaskAdjustUpgraded_FeasibleOptimal(scores_trial, Train_Performance, Trials, AllTrial, RestTimeLenBaseline, min_max_value_EI)
    EI_max = max(min_max_value_EI(1,:));
    EI_min = min(min_max_value_EI(2,:));
    RestTimeLenBaseline_add = 5;
    % 一开始暂时不进行修改任务阈值，只是使用可行部分
    if AllTrial < 4  
        Flag_FesOptim = 0;  % 使用可行解
        Train_Thre_Global_Optim = 0.0;
        RestTimeLen = RestTimeLenBaseline;
    else
        %提取之前3个任务的EI指标的变化情况（微分的形式）
        delta_score = scores_trial(end-2:end) - scores_trial(end-3:end-1);  
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  
         
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                % 延长休息时间
                RestTimeLen = RestTimeLenBaseline + RestTimeLenBaseline_add;
                disp(["休息时间延长至", num2str(RestTimeLen)]);
            case 1
                % 减少休息时间
                RestTimeLen = RestTimeLenBaseline;
            case -1
                % 减少休息时间
                RestTimeLen = RestTimeLenBaseline ;
            case -3
                % 延长休息时间
                RestTimeLen = RestTimeLenBaseline + RestTimeLenBaseline_add;
                disp(["休息时间延长至", num2str(RestTimeLen)]);
        end
        % 如果当前的EI数值是大于最大值的话，同样参与休息
        if scores_trial(end) > EI_max
            RestTimeLen = RestTimeLenBaseline + RestTimeLenBaseline_add;
        end
        
        % 计算表现中的完成情况 max(MI_Acc_GlobalAvg)./Train_Thre_Global
        ratio_ = Train_Performance(1, :) ./ Train_Performance(2, :);
        % 将计算出的比率和第三行合并
        Train_Performance_ = vertcat(ratio_, Train_Performance(3, :));
        Trigger = Trials(AllTrial);  % 确定当前的类别
        tasks = Train_Performance_(2,:);
        task_performance = Train_Performance_(1,tasks==Trigger);  % 提取同类别的数据
        
        if size(task_performance, 1) < 3
            performance_eval = task_performance;  % 如果不满3次的话，直接提取所有的
        else
            performance_eval = task_performance(1,end-2+1:end);  % 提取之前2次实验的表现，使用这2次的实验表现来规划接下来的实验难度
        end
        % 使用基于ξ-greedy的方法来进行任务权重的调整
        performance_pro = mean(performance_eval(1,:));  % 计算前2个的平均概率作为这个ξ的数值
        % 基于概率进行选择可行还是最优，performance_pro越高则越有可能提升难度
        if rand() < performance_pro
            % 选取Train_Performance(1, :)里面的0.75分位数来作为新的最优的阈值
            Train_Thre_Global_Optim = quantile(Train_Performance(1, :), 0.75);
            Flag_FesOptim = 1;
        else
            % 使用可行解
            Flag_FesOptim = 0;
            Train_Thre_Global_Optim = 0.0;
        end
    end
end