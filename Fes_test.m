% for fes testing

system('F:\CASIA\MI_engagement\fes\fes\x64\Debug\fes.exe&'); 
%system('D:\workspace\fes\x64\Release\fes.exe&');
%system('F:\MI_engagement\fes\fes\x64\Debug\fes.exe&');
pause(1);
StimControl = tcpip('localhost', 8888, 'NetworkRole', 'client','Timeout',1000);
StimControl.InputBuffersize = 1000;
StimControl.OutputBuffersize = 1000;

fopen(StimControl);
% StimCommand = uint8(zeros(1,6));
% StimCommand(1,1) = 0; % 0 start 100 stop
% StimCommand(1,2) = 8; % amplitude，电流幅值单位毫安
% StimCommand(1,3) = 3; % t_up  上升沿多久
% StimCommand(1,4) = 14; % t_flat  中间多久
% StimCommand(1,5) = 2; % t_down  下降沿多久
% StimCommand(1,6) = 3; % 1 left calf 2 left thigh 3 right thigh  实验通道，总共8个
% fwrite(StimControl,StimCommand);%刺激开始

tStim = [3,14,2]; % [t_up,t_flat,t_down] * 100ms
StimCommand_1 = uint8([0,7,tStim,1]); % left calf
StimCommand_2 = uint8([0,7,tStim,2]); % left thigh
StimCommand_3 = uint8([0,5,tStim,3]); % right thigh 


StimCommand = StimCommand_1;
fwrite(StimControl,StimCommand);
pause(3);
%StimCommand(1,1) = 100;
%fwrite(StimControl,StimCommand);

pause(2);
StimCommand = StimCommand_2;
fwrite(StimControl,StimCommand);
pause(3);
%StimCommand(1,1) = 100;
%fwrite(StimControl,StimCommand);

pause(2);
StimCommand = StimCommand_1;
fwrite(StimControl,StimCommand);
pause(3);

pause(2);
StimCommand = StimCommand_2;
fwrite(StimControl,StimCommand);
pause(3);

pause(2);
StimCommand = StimCommand_1;
fwrite(StimControl,StimCommand);
pause(3);

StimCommand(1,1) = 100;
fwrite(StimControl,StimCommand);


system('taskkill /F /IM fes.exe');
close all;

