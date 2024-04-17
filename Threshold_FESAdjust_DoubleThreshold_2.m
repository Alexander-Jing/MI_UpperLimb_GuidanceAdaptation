%% ����֮ǰ�ı������ж��Ƿ���Ҫ��̼�
function Fes_flag_ = Threshold_FESAdjust_DoubleThreshold_2(resultsMI, mu_suppressions, FES_ExamingNum)
    MI_num = size(mu_suppressions, 2);
    Fes_flag_ = 0;
    
    if mod(MI_num, FES_ExamingNum) == 0
        % ��ȡ֮ǰ���������
        mu_suppressions_ = mu_suppressions(1, :);
        resultsMI_ = resultsMI(1, :);
        
        % ��mu˥������ֵ�޸��£���ֹ���ַǸ���
        mu_suppressions_(mu_suppressions_ < 0) = 0.01;
        
        % �����·�����ֵ, �����ֵ����0��1֮��
        visual_feedback = (resultsMI_ .* mu_suppressions_);
        
        visual_feedback(visual_feedback > 1) = 1.0;
        visual_feedback(visual_feedback < 0) = 0.01;
        performance_MI = 1.0 - mean(visual_feedback);  % �����ֵ�������ж��Ƿ���Ҫ������̼�
        % ���ڸ��ʽ���ѡ���Ƿ���
        if rand() < performance_MI
            Fes_flag_ = 1;
        else
            Fes_flag_ = 0;
        end
    end

end