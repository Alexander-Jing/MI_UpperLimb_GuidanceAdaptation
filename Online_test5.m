%% 鍒濆鍖栵紝鍏抽棴鎵?鏈夎繛鎺?
pnet('closeall');
clc;
clear;
close all;
%% 鍚姩Unity绋嬪簭锛屽苟鍒濆鍖?
% 绋嬪簭璇存槑锛氬彂閫佸懡浠ゅ叡5瀛楄妭
%           Byte1锛氱敾闈?/鍔ㄤ綔鍒囨崲
%           Byte2锛氭帶鍒剁敾闈㈡槸鍚﹁繍鍔?
%           Byte3锛氱敾闈㈡枃瀛楁樉绀猴紙绂荤嚎璁粌瀹為獙鏃犳枃瀛楁彁绀猴級
%           Byte4锛氬姩浣滅被鍨?
%           Byte5锛氶鐣?
%system('F:\CASIA\mwl_data_collection\climbstair\ClimbStair3.exe&');       % Unity鍔ㄧ敾exe鏂囦欢鍦板潃
%system('E:\MI_engagement\unity_test\unity_test\build_test\unity_test.exe&');
%system('E:\UpperLimb_Animation\unity_test.exe&');
%system('E:\MI_AO_Animation\UpperLimb_Animation\unity_test.exe&');
%system('E:\MI_AO_Animation\UpperLimb_Animation_modified\unity_test.exe&');

%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_Animation\unity_test.exe&');
%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_Animation_modified_DoubleThreshold\unity_test.exe&');
%system('F:\MI_UpperLimb_AO\UpperLimb_AO\UpperLimb_AO_NewModel_MI\unity_test.exe&');
%system('E:\UpperLimb_AO_NewModel_MI\unity_test.exe&');
system('D:\workspace\UpperLimb_AO_NewModel_MI_ReachGrasp\unity_test.exe&');

pause(3)
UnityControl = tcpip('localhost', 8881, 'NetworkRole', 'client');          % 鏂扮殑绔彛鏀逛负8881
fopen(UnityControl);
pause(1)
sendbuf = uint8(1:5);
sendbuf(1,1) = hex2dec('00') ;
sendbuf(1,2) = hex2dec('00') ;
sendbuf(1,3) = hex2dec('00') ;
sendbuf(1,4) = hex2dec('00') ;
sendbuf(1,5) = hex2dec('00') ;
fwrite(UnityControl,sendbuf);
pause(3)

% 机械臂的通信部分 
RobotControl = tcpip('localhost', 5288, 'NetworkRole','client');
fopen(RobotControl);
GloveControl = tcpip("192.168.2.30", 8003, 'NetworkRole','client');
fopen(GloveControl);

%% 鍑嗗鍒濆鐨勫瓨鍌ㄦ暟鎹殑鏂囦欢澶?
subject_name = 'Jyt_test_online';  % 琚瘯鐨勫鍚?  

foldername = ['.\\', subject_name]; % 鎸囧畾鏂囦欢澶硅矾寰勫拰鍚嶇О

if ~exist(foldername, 'dir')
   mkdir(foldername);
end

%% 鐢熸垚浠诲姟瀹夋帓璋冨害
Trigger = 0;                                                               % 鍒濆鍖朤rigger锛岀敤浜庡悗缁殑鏁版嵁瀛樺偍
AllTrial = 0;

session_idx = 1;

MotorClass = 2; % 娉ㄦ剰杩欓噷鏄函璁捐鐨勮繍鍔ㄦ兂璞″姩浣滅殑鏁伴噺锛屼笉鍖呮嫭绌烘兂idle鐘舵??
MajorPoportion = 0.6;
TrialNum = 6;
DiffLevels = [1,2];
trial_random = 0;

% if session_idx == 1  % 濡傛灉鏄涓?涓猻ession锛岄偅闇?瑕佺敓鎴愮浉鍏崇殑浠诲姟闆嗗悎
%     Level2task(MotorClass, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name);
%     path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(session_idx), '_', '.mat'];
%     ChoiceTrial = load(path,'session');
% else
%     path = [foldername, '\\', 'Level2task', '_', subject_name, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(session_idx), '_', '.mat'];
%     ChoiceTrial = load(path,'session');
% end

%ChoiceTrial = ChoiceTrial.session;
original_seq = [1,2,0];  % 原始序列数组
training_seqs = 8;  % 训练轮数
Trials = [];  % 初始化训练的数组

for seq_id = 1:training_seqs
    
    temp_array = original_seq;  % 复制原始数组
    if trial_random
        non_zero_indices = find(temp_array);  % 找到非零元素的索引
        random_permutation = randperm(length(non_zero_indices));  % 生成非零元素的随机排列
        temp_array(non_zero_indices) = temp_array(non_zero_indices(random_permutation));  % 将原始数组中的非零元素重新排列
    end

    Trials = [Trials, temp_array];  % 将重新排列的数组添加到结果数组
end    

ChoiceTrial = Trials;
 %ChoiceTrial = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];  % 涓存椂浣跨敤
%% 寮?濮嬪疄楠岋紝绂荤嚎閲囬泦
Timer = 0;
TrialData = [];
MaxMITime = 30; % 鍦ㄧ嚎杩愬姩鎯宠薄鏈?澶у厑璁告椂闂? 
sample_frequency = 256; 
WindowLength = 512;  % 姣忎釜绐楀彛鐨勯暱搴?
channels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道,
mu_channels = struct('C3',24, 'C4',22);  % 用于计算ERD/ERS的几个channels，是C3和C4两个通道,需要设定位置
EI_channels = struct('Fp1', 32, 'Fp2', 31, 'F7', 30, 'F3', 29, 'Fz', 28, 'F4', 27, 'F8', 26);  % 用于计算EI指标的几个channels，需要确定下位置的
weight_mu = 0.6;  % 鐢ㄤ簬璁＄畻ERD/ERS鎸囨爣鍜孍I鎸囨爣鐨勫姞鏉冨拰
scores = [];  % 鐢ㄤ簬瀛樺偍姣忎竴涓猼rial閲岄潰鐨勫垎鏁板??
scores_avg = [];
scores_trial = [];  % 鐢ㄤ簬瀛樺偍姣忎竴涓猼rial鐨勫钩鍧囧垎鏁板??
ip = '172.18.22.21';
port = 8888;  % 鍜屽悗绔湇鍔″櫒杩炴帴鐨勪袱涓弬鏁?
clsFlag = 0; % 鐢ㄤ簬鍒ゆ柇瀹炴椂鍒嗙被鏄惁姝ｇ‘鐨刦lag
trial_time_all = 65;

Trials = [];
Trials = [Trials, ChoiceTrial(1,1)];  % 鍒濆鍖朢andomTrial锛岀涓?涓暟鍊兼槸ChoiceTrial浠诲姟闆嗗悎涓殑绗竴涓?
results = [];
resultMI = Trigger;

for trial_idx = 1:length(ChoiceTrial)
    score_thre = 30;
    score_thre1 = score_thre;
    sendbuf(1,7) = uint8((score_thre1));
    fwrite(UnityControl,sendbuf);
    seg_trial= 0;
    for timer = 1:trial_time_all
       pause(1.0);
       if timer <= 28
           if  (timer - 7*seg_trial >= 1) & (timer - 7*seg_trial <= 4)
               disp('*********Online Testing***********');
               Trigger = ChoiceTrial(trial_idx);  % 鎾斁鍔ㄤ綔鐨凙O鍔ㄧ敾锛圛dle, MI1, MI2锛?
               mat2unity = ['0', num2str(Trigger + 3)];
               sendbuf(1,1) = hex2dec(mat2unity);
               sendbuf(1,2) = hex2dec('01');
               sendbuf(1,3) = hex2dec('00');
               sendbuf(1,4) = hex2dec('00');
               % threshold 鏁版嵁浼犺緭璁剧疆浠ュ強鏄剧ず
               sendbuf(1,6) = uint8((score_thre));
               sendbuf(1,8) = hex2dec('00');

               fwrite(UnityControl,sendbuf);  
    
               rawdata = rand(33,512);  % 鐢熸垚鍘熷鐨勬暟鎹紝浠ュ強鍘绘帀浜唗rigger==6鐨勯儴鍒?
               Trigger = [ChoiceTrial(1,trial_idx) * ones(1,512)]; 
               rawdata = [rawdata; Trigger];  % 鐢熸垚鎵?鏈夋暟鎹?
               [FilteredDataMI, EI_index, mu_power_MI] = Online_DataPreprocess(rawdata, ChoiceTrial(1,trial_idx), sample_frequency, WindowLength, channels);
               score = weight_mu * sum(mu_power_MI) + (1 - weight_mu) * sum(EI_index);  % 璁＄畻寰楀垎锛岃繖閲屼复鏃朵娇鐢ㄦ眰鍜屾潵琛ㄥ緛锛屽悗缁渶瑕佷慨鏀?
               
               score = 100*(2 * rand() - 1);
               if score <= 1.0
                   score = 1.0*100;
               end
    
               config_data = [WindowLength;size(channels, 2);ChoiceTrial(1,trial_idx);session_idx;trial_idx;timer;score;0;0;0;0 ];
               order = 1.0;
               
               %resultMI = Online_Data2Server_Communicate(order, FilteredDataMI, ip, port, subject_name, config_data, foldername);  % 浼犺緭鏁版嵁缁欑嚎涓婄殑妯″瀷锛岀湅鍒嗙被鎯呭喌
               % score 鏁版嵁浼犺緭璁剧疆
               score_fb = score/100.0 * 200.0;
               
               if score_fb > 200.0
                   score_fb = 200.0;
               end
    
               scores  = [scores, score_fb];
               scores_avg = [scores_avg, mean(scores)];
    
               score_thre1 = Online_Threshold1(scores, score_thre1, score_thre, "Game");
               sendbuf(1,7) = uint8((score_thre1));   
               if timer>1
                   score_last = scores_avg(end-1);
                   score_fb_vb = scores_avg(end);
                   disp(['score last:', num2str(score_last)]);
                   disp(['score now:', num2str(score_fb_vb)]);
                   % 生成score_last到score_fb的列表，这样的话，动画播放的就是一个连续的序列，而不是跳变的情况
                   if score_last <= score_fb_vb
                        score_list = score_last:1:score_fb_vb;
                    else
                        score_list = score_last:-1:score_fb_vb;
                   end
    
                   for i =1:length(score_list)
                        sendbuf(1,5) = uint8(score_list(i));
                        fwrite(UnityControl,sendbuf);
                   end
               else
                    sendbuf(1,5) = uint8(score_fb);
                    fwrite(UnityControl,sendbuf);
               end
    
               disp(['session: ', num2str(session_idx)]);
               disp(['trial: ', num2str(trial_idx)]);
               disp(['window: ', num2str(timer/5)]);
               disp(['moter_class: ', num2str(ChoiceTrial(1,trial_idx))]);
               %disp(['predict_class: ', num2str(resultMI(1,1))]);
               %disp(['predict_probilities: ', num2str(resultMI(2,1))]);
               disp(['score: ', num2str(score)]);
           end
           if (timer - 7*seg_trial == 5) | (timer - 7*seg_trial == 6) | (timer - 7*seg_trial == 7)
%                sendbuf(1,1) = hex2dec(mat2unity);
%                sendbuf(1,2) = hex2dec('01');
               sendbuf(1,3) = hex2dec('00');
               sendbuf(1,4) = hex2dec('00');
               previous_best = max(scores(end-2:end));
               if previous_best > 125
                   sendbuf(1,8) = hex2dec('01');
                   disp(['good performance, keep ', 'value: ', num2str(previous_best)]);
               else
                   sendbuf(1,8) = hex2dec('02');
                   disp(['poor performance, adjust, ', 'value: ', num2str(previous_best)]);
               end
               fwrite(UnityControl,sendbuf); 
           end
           
           if mod(timer, 7) == 0
                seg_trial = seg_trial + 1;
           end
       end
       if timer == 29
           disp('*********Online Updating');
           % 浼犺緭鏁版嵁鍜屾洿鏂版ā鍨?
           %config_data = [WindowLength;size(channels, 2);ChoiceTrial(1,trial_idx);session_idx;trial_idx;timer/5;score;0;0;0;0 ];
           order = 2.0;  % 浼犺緭鏁版嵁鍜岃缁冪殑鍛戒护
           %Online_Data2Server_Send(order, [0,0,0,0], ip, port, subject_name, config_data);  % 鍙戦?佹寚浠わ紝璁╂湇鍔″櫒鏇存柊鏁版嵁锛孾0,0,0,0]鍗曠函鏄敤浜庡噾涓嬫暟鎹紝闃叉搴斾负绌洪泦褰卞搷浼犺緭
           results = [results, resultMI];
           scores_trial = [scores_trial, scores];
           scores = [];
           sendbuf(1,2) = hex2dec('02');
           sendbuf(1,3) = hex2dec('01');
           sendbuf(1,8) = hex2dec('00');
           fwrite(UnityControl,sendbuf);


           disp(['session: ', num2str(session_idx)]);
           disp(['trial: ', num2str(trial_idx)]);
           disp('training model');

       end

       if  timer==29  && ChoiceTrial(trial_idx)==1
           disp('Glove on');
           textsend='G1';
           %pause(0.1);
           fwrite(GloveControl, textsend);
       end
       if timer==31  && ChoiceTrial(trial_idx)==1
           disp('Robotic reaching');
           textSend='Y1';
           %pause(0.1);
           fwrite(RobotControl, textSend);
       end
       if  timer==29 && ChoiceTrial(trial_idx)==2
           disp('Glove grasp');
           textsend='G2';
           %pause(0.1);
           fwrite(GloveControl, textsend);
       end
       if timer==31  && ChoiceTrial(trial_idx)==2
            disp('Robotic back');
            textSend='Y2';
            %pause(0.1);
            fwrite(RobotControl, textSend);
       end

       if timer == (trial_time_all-5)
           sendbuf(1,1) = hex2dec('02') ;
           sendbuf(1,2) = hex2dec('00') ;
           sendbuf(1,3) = hex2dec('00') ;
           sendbuf(1,4) = hex2dec('00') ;
           fwrite(UnityControl,sendbuf); 
           disp("resting");
       end
           
   end
end

% s1 = scatter(1:length(results), results(:));
% s1.MarkerFaceColor = '#ff474c';
% s1.MarkerEdgeColor = '#ff474c';
% hold on
% s2 = scatter(1:length(ChoiceTrial), ChoiceTrial(:));
% s2.MarkerFaceColor = '#0485d1';
% s2.MarkerEdgeColor = '#0485d1';
% legend('results', 'ChoiceTrial');  % 娣诲姞鍥句緥

%% 浠诲姟鍒濆鐢熸垚鐨勫嚱鏁?
function Level2task(MotorClasses, MajorPoportion, TrialNum, DiffLevels, foldername, subject_name)  % MajorPoportion 姣忎竴涓猻ession涓殑涓昏鍔ㄤ綔鐨勬瘮渚嬶紱TrailNum 姣忎竴涓猻ession涓殑trial鏁伴噺, DiffLevels浠庝綆鍒伴珮鐢熸垚闅惧害鐨勭煩闃碉紝鐭╅樀閲岀殑鏁板?艰秺楂樿〃绀洪毦搴﹁秺楂? 
    
    foldername = [foldername, '\\', 'Level2task', '_', subject_name]; % 鎸囧畾鏂囦欢澶硅矾寰勫拰鍚嶇О
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    
    for SessionIndex = 1:MotorClasses  % 杩欓噷鐨凷essionIndex涔熸槸涓昏闅惧害瀵瑰簲鐨勪綅缃?
        session = [];
        MotorMain = DiffLevels(1, SessionIndex);  % 涓昏鎴愬垎鐨勮繍鍔?
        NumMain = round(TrialNum * MajorPoportion);  
        session = [session, repmat(MotorMain, 1, NumMain)];
        
        indices = find(DiffLevels==MotorMain);  % 鎵惧埌MotorMain瀵瑰簲鐨刬ndex
        DiffLevels_ = DiffLevels;
        DiffLevels_(indices) = [];  % 鍘绘帀MotorMain鐨勫墿涓嬬殑闅惧害鐭╅樀
        
        for i_=1:(MotorClasses - 1)
            MotorMinor = DiffLevels_(1, i_);  % 鍓╀笅鐨勫嚑涓姩浣?
            MinorProportion =  (1-MajorPoportion)/(MotorClasses - 1);  % 鍓╀笅鍔ㄤ綔鐨勬瘮閲?
            NumMinor = round(TrialNum * MinorProportion);
            session = [session, repmat(MotorMinor, 1, NumMinor)];  % 娣诲姞鍓╀笅鐨勫姩浣?
        end    
        session = [session, repmat(0, 1, NumMinor)];  % 娣诲姞鍜屽墿涓嬪姩浣滀竴鑷存瘮渚嬬殑绌烘兂鍔ㄤ綔
        path = [foldername, '\\', 'Online_EEGMI_session_', subject_name, '_', num2str(SessionIndex), '_', '.mat'];
        save(path,'session');  % 瀛樺偍鐩稿叧鏁版嵁锛屽悗闈㈠瓨鍌ㄧ敤
    end
    
end

%% 基于比例导引法来设计最优的可变2阈值
function score_thre1 = Online_Threshold1(scores, score_thre1, score_thre, mode)
    if length(scores) > 2
       scores_v = scores(2:end) - scores(1:end-1);
       if mode == 'PNG'
            if scores_v(end) > 0
                score_thre1 = score_thre1 + 0.1 * scores_v(end);
            else
               score_thre1 = score_thre1 + 0.75 * scores_v(end);
            end
       end
       if mode == 'Game'
            if scores_v(end) > 0
                positive_scores_v = scores_v(scores_v>0);
                score_thre1 = scores(end-1) + quantile(positive_scores_v,0.75);
                %score_thre1 = scores(end-1) + max(positive_scores_v);
                disp(['score_thre1: ', num2str(score_thre1)]);
            else
                score_thre1 = score_thre1 + 0.75 * scores_v(end);
            end
       end

       if score_thre1 < score_thre
           score_thre1 = score_thre;
       end
   end
end