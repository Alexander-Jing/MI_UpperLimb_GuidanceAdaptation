%% 准备测试和机械臂之间的控制的通信
pnet('closeall');
clc;
clear;
close all;
%% Establish RobotControl comm.
global RobotControl 
RobotControl = tcpip('localhost', 5288, 'NetworkRole','client');
fopen(RobotControl);

RandomScene = [0,1,0,1];
pause(1);

for i=1:length(RandomScene)
    pause(15);
    disp(['Send message: ', num2str(RandomScene(i))]);
    switch RandomScene(i)
        case 0
            textSend='Y1';
            %pause(0.1);
            fwrite(RobotControl, textSend);
        case 1
            textSend='Y2';
            %pasue(0.1);
            fwrite(RobotControl, textSend);
        case 2
            textsend='Y3';
            %pause(0.1);
            fwrite(RobotControl, textsend);
    end
end

fclose(RobotControl);