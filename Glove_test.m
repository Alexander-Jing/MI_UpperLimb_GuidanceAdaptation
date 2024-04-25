%% 准备测试和机械臂之间的控制的通信
pnet('closeall');
clc;
clear;
close all;
%% Establish RobotControl comm.
global GloveControl 
GloveControl = tcpip("192.168.2.30", 8003, 'NetworkRole','client');
fopen(GloveControl);

RandomScene = [0,1,2,0,1,2];
pause(1);

for i=1:length(RandomScene)
    pause(5);
    disp(['Send message: ', num2str(RandomScene(i))]);
    switch RandomScene(i) 
        case 0
            textSend='G1';
            %pause(0.1);
            fwrite(GloveControl, textSend);
        case 1
            textSend='G2';
            %pasue(0.1);
            fwrite(GloveControl, textSend);
        case 2
            textsend='G3';
            %pause(0.1);
            fwrite(GloveControl, textsend);
    end
end

fclose(GloveControl);