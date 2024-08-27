%% ׼�����Ժͻ�е��֮��Ŀ��Ƶ�ͨ��
pnet('closeall');
clc;
clear;
close all;
%% Establish RobotControl comm. 
GloveControl = tcpip("192.168.2.30", 8003, 'NetworkRole','client');
fopen(GloveControl);

RandomScene = [0,1,2,0,1,2];
pause(1);
sendbuf = uint8(1:2);
sendbuf(1,1) = hex2dec('ff') ;
sendbuf(1,2) = hex2dec('ff') ;

fwrite(GloveControl, sendbuf);

for i=1:length(RandomScene)
    pause(10);
    disp(['Send message: ', num2str(RandomScene(i))]);
    switch RandomScene(i) 
        case 0
            % �������ȭ�Ļ�����һ��ʱ���������
            textSend='G1';
            sendbuf(1,1) = hex2dec('bf') ;
            sendbuf(1,2) = hex2dec('bf') ;
            fwrite(GloveControl, sendbuf);
            pause(3);
            sendbuf(1,1) = hex2dec('ff') ;
            sendbuf(1,2) = hex2dec('ff') ;
            fwrite(GloveControl, sendbuf);
        case 1
            % ����״̬���������ִ�������⣬������Ҫ������ff
            textSend='G2';
            %pasue(0.1);
            sendbuf(1,1) = hex2dec('ff') ;
            sendbuf(1,2) = hex2dec('ff') ;
            fwrite(GloveControl, sendbuf);
        case 2
            % �ſ�״̬��ͬ����һ��ʱ���Ҫ��������
            textsend='G3';
            %pause(0.1);
            sendbuf(1,1) = hex2dec('c0') ;
            sendbuf(1,2) = hex2dec('c0') ;
            fwrite(GloveControl, sendbuf);
            pause(3);
            sendbuf(1,1) = hex2dec('ff') ;
            sendbuf(1,2) = hex2dec('ff') ;
            fwrite(GloveControl, sendbuf);
    end
end

fclose(GloveControl);