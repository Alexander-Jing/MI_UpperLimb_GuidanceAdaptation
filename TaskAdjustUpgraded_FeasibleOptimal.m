%% ����֮ǰ�ı��ֽ��е��������Ѷ�
function [Flag_FesOptim, Train_Thre_Global_Optim, RestTimeLen] = TaskAdjustUpgraded_FeasibleOptimal(scores_trial, Train_Performance, Trials, AllTrial, RestTimeLenBaseline, min_max_value_EI)
    EI_max = max(min_max_value_EI(1,:));
    EI_min = min(min_max_value_EI(2,:));
    RestTimeLenBaseline_add = 5;
    % һ��ʼ��ʱ�������޸�������ֵ��ֻ��ʹ�ÿ��в���
    if AllTrial < 4  
        Flag_FesOptim = 0;  % ʹ�ÿ��н�
        Train_Thre_Global_Optim = 0.0;
        RestTimeLen = RestTimeLenBaseline;
    else
        %��ȡ֮ǰ3�������EIָ��ı仯�����΢�ֵ���ʽ��
        delta_score = scores_trial(end-2:end) - scores_trial(end-3:end-1);  
        delta_score(delta_score<=0) = -1;
        delta_score(delta_score>0) = 1;  
         
        deltaSum_ = sum(delta_score);
        switch deltaSum_
            case 3
                % �ӳ���Ϣʱ��
                RestTimeLen = RestTimeLenBaseline + RestTimeLenBaseline_add;
                disp(["��Ϣʱ���ӳ���", num2str(RestTimeLen)]);
            case 1
                % ������Ϣʱ��
                RestTimeLen = RestTimeLenBaseline;
            case -1
                % ������Ϣʱ��
                RestTimeLen = RestTimeLenBaseline ;
            case -3
                % �ӳ���Ϣʱ��
                RestTimeLen = RestTimeLenBaseline + RestTimeLenBaseline_add;
                disp(["��Ϣʱ���ӳ���", num2str(RestTimeLen)]);
        end
        % �����ǰ��EI��ֵ�Ǵ������ֵ�Ļ���ͬ��������Ϣ
        if scores_trial(end) > EI_max
            RestTimeLen = RestTimeLenBaseline + RestTimeLenBaseline_add;
        end
        
        % ��������е������� max(MI_Acc_GlobalAvg)./Train_Thre_Global
        ratio_ = Train_Performance(1, :) ./ Train_Performance(2, :);
        % ��������ı��ʺ͵����кϲ�
        Train_Performance_ = vertcat(ratio_, Train_Performance(3, :));
        Trigger = Trials(AllTrial);  % ȷ����ǰ�����
        tasks = Train_Performance_(2,:);
        task_performance = Train_Performance_(1,tasks==Trigger);  % ��ȡͬ��������
        
        if size(task_performance, 1) < 3
            performance_eval = task_performance;  % �������3�εĻ���ֱ����ȡ���е�
        else
            performance_eval = task_performance(1,end-2+1:end);  % ��ȡ֮ǰ2��ʵ��ı��֣�ʹ����2�ε�ʵ��������滮��������ʵ���Ѷ�
        end
        % ʹ�û��ڦ�-greedy�ķ�������������Ȩ�صĵ���
        performance_pro = mean(performance_eval(1,:));  % ����ǰ2����ƽ��������Ϊ����ε���ֵ
        % ���ڸ��ʽ���ѡ����л������ţ�performance_proԽ����Խ�п��������Ѷ�
        if rand() < performance_pro
            % ѡȡTrain_Performance(1, :)�����0.75��λ������Ϊ�µ����ŵ���ֵ
            Train_Thre_Global_Optim = quantile(Train_Performance(1, :), 0.75);
            Flag_FesOptim = 1;
        else
            % ʹ�ÿ��н�
            Flag_FesOptim = 0;
            Train_Thre_Global_Optim = 0.0;
        end
    end
end