function [ output_args ] = Rsx_ButterFilter(FiterOrder,Wband,SampleFre,FiterType,Data,Channelnum)
% �������ܣ����������Ƶ�ʴ����˲������ͽ��а��������˲�
% ����˵����FiterOrder--�˲���������Wband--Ƶ�����䣬SampleFre--����Ƶ�ʣ�FiterType--�˲������ͣ���ͨ���ߴ���
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
% %% FFT�鿴Ƶ��
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
% % �鿴�����˲�����Ӧ
% figure(2)
% freqz(Pa,Pb);
end

