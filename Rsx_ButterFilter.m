function [ output_args ] = Rsx_ButterFilter(FiterOrder,Wband,SampleFre,FiterType,Data,Channelnum)
% 函数功能：根据输入的频率带和滤波器类型进行巴特沃兹滤波
% 参数说明：FiterOrder--滤波器阶数，Wband--频率区间，SampleFre--采样频率，FiterType--滤波器类型，带通或者带阻
% Sub_fre_num = size(Wband,1);
% if Sub_fre_num == 1
    wn = Wband/(SampleFre/2);
    [Pa,Pb] = butter(FiterOrder,wn,FiterType); 
    for i = 1:Channelnum
        Data(i,:) = filter(Pa,Pb,Data(i,:));
    end
    output_args = Data;
% else
%     output_args = zeros(size(Data),Sub_fre_num);
%     for i = 1:Sub_fre_num
%         wn = Wband(i,:)/(SampleFre/2);
%         [Pa,Pb] = butter(FiterOrder,wn,FiterType); 
%         for j = 1:Channelnum
%             output_args(j,:,i) = filter(Pa,Pb,Data(j,:));
%         end
%     end
% %% FFT查看频谱
% T = 1/SampleFre;                                             % Sampling period
% L = length(Data(1,:));                                       % Length of signal
% t = (0:L-1)*T;                                               % Time vector
% Y = fft(Data(1,:));
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% FFT_f = SampleFre*(0:(L/2))/L;
% figure(1)
% plot(FFT_f,P1)
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
% % 查看带阻滤波器响应
% figure(2)
% freqz(Pa,Pb);
end

