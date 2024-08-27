%% 准备测试和机械臂之间的控制的通信
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
            % 如果是握拳的话，过一段时间放松下来
            textSend='G1';
            sendbuf(1,1) = hex2dec('bf') ;
            sendbuf(1,2) = hex2dec('bf') ;
            fwrite(GloveControl, sendbuf);
            pause(3);
            sendbuf(1,1) = hex2dec('ff') ;
            sendbuf(1,2) = hex2dec('ff') ;
            fwrite(GloveControl, sendbuf);
        case 1
            % 放松状态，由于新林代码的问题，这里需要加两个ff
            textSend='G2';
            %pasue(0.1);
            sendbuf(1,1) = hex2dec('ff') ;
            sendbuf(1,2) = hex2dec('ff') ;
            fwrite(GloveControl, sendbuf);
        case 2
            % 张开状态，同样过一段时间就要放松下来
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