%% 根据之前的表现来判断是否需要电刺激
function Fes_flag_ = Threshold_FESAdjust_DoubleThreshold_2(resultsMI, mu_suppressions, FES_ExamingNum)
    MI_num = size(mu_suppressions, 2);
    Fes_flag_ = 0;
    
    if mod(MI_num, FES_ExamingNum) == 0
        % 提取之前的相关数据
        mu_suppressions_ = mu_suppressions(1, :);
        resultsMI_ = resultsMI(1, :);
        
        % 将mu衰减的数值修改下，防止出现非负的
        mu_suppressions_(mu_suppressions_ < 0) = 0.01;
        
        % 计算下反馈数值, 这个数值属于0到1之间
        visual_feedback = (resultsMI_ .* mu_suppressions_);
        
        visual_feedback(visual_feedback > 1) = 1.0;
        visual_feedback(visual_feedback < 0) = 0.01;
        performance_MI = 1.0 - mean(visual_feedback);  % 计算均值，用于判断是否需要辅助电刺激
        % 基于概率进行选择是否辅助
        if rand() < performance_MI
            Fes_flag_ = 1;
        else
            Fes_flag_ = 0;
        end
    end

end