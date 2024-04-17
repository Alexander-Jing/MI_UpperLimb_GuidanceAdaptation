function Online_Data2Server_Send(send_order, data_x, ip, port, subject_name, config_data)
    
    % config_data = [512;30;motor_class;session;trial;window;score;0;0;0;0 ];  % 登记上传的数据的相关参数，分别是WindowLength，channels，运动想象类别motor_class,session数量,trial数量,trial里面的数�?,score的数值，空出来的数据1（暂时置�?0），空出来的数据2（暂时置�?0），空出来的数据3（暂时置�?0），空出来的数据4（暂时置�?0�?
    % config = whos('data_x');
    data2Server = data_x;
     
    % data2Server = load('data2Server.mat','data2Server');
    % data2Server = struct2array(data2Server);
    % config_data = [512;30;0;motor_class-1];  % 登记上传的数据的相关参数，分别是WindowLength，channels，空出来的数据（暂时置为0），运动想象类别
    time_out = 60; % 投�?�数据包的等待时�?
    tcpipClient = tcpip(ip, port,'NetworkRole','Client');
    %tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
    set(tcpipClient,'OutputBufferSize',4*999*30*256*8*10);%2048*4096 67108880+64
    set(tcpipClient,'Timeout',time_out);
    tcpipClient.InputBufferSize = 8388608/2;%8M
    tcpipClient.ByteOrder = 'bigEndian';
    fopen(tcpipClient);
    disp("���ӳɹ�")
    disp("���ݷ���")

    % send_order = 1.0;  % 发�?�命令控制，用于控制服务器，命令�?1是实时交互命令，命令�?3是上传数据的命令
    send_data = [send_order; config_data(:); data2Server(:)];
    config_send = whos('send_data');   % whos('send_data')将返回该变量的名称�?�大小�?�字节数、类型等信息
    fwrite(tcpipClient,[config_send.bytes/2; send_data],'float32');  % 这里matlab的double�?8个字节，然后这里使用�?4字节的float32传输，所以config_send.bytes要除�?2，表示使�?4字节的float32形式传输用了多少个字�?
    
    % 断开连接
    disp('���ӶϿ�')
    fclose(tcpipClient);
end

