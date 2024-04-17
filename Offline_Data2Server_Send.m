function Offline_Data2Server_Send(data_x, ip, port, subject_name, config_data, send_order, foldername)
    
    config = whos('data_x');
    data2Server = [];
    h = waitbar(0, 'data preparing');
    for class_type = 1:config.size(1,1)
       for windows_num = 1:config.size(1,2)
           size_ = size(data2Server);
           waitbar((size_(1)/30)/(config.size(1,1)*config.size(1,2)), h); 
           data2Server = [data2Server;data_x{class_type,windows_num}];
       end
    end
    % 中�?�保存下要发送的数据
    foldername = [foldername, '\\Offline_Data2Server_', subject_name]; % 指定文件夹路径和名称
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    save([foldername, '\\', FunctionNowFilename(['Offline_EEG_data2Server_', subject_name], '.mat' )],'data2Server');
    % save('data2Server.mat','data2Server');
    % 
    % data2Server = load('data2Server.mat','data2Server');
    % data2Server = struct2array(data2Server);
    % config_data = [512;30;999;2];  % 登记上传的数据的相关参数
    time_out = 600; % 投�?�数据包的等待时�?
    tcpipClient = tcpip(ip, port,'NetworkRole','Client');
    %tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
    set(tcpipClient,'OutputBufferSize',4*999*30*256*8*10);%2048*4096 67108880+64
    set(tcpipClient,'Timeout',time_out);
    tcpipClient.InputBufferSize = 8388608;%8M
    tcpipClient.ByteOrder = 'bigEndian';
    fopen(tcpipClient);
    disp("data sending")
    disp("data sent")

    % send_order = 3.0;  % 发�?�命令控制，用于控制服务�?
    send_data = [send_order; config_data(:); data2Server(:)];
    config_send = whos('send_data');   % whos('send_data')将返回该变量的名称�?�大小�?�字节数、类型等信息
    fwrite(tcpipClient,[config_send.bytes/2; send_data],'float32');  % 这里matlab的double�?8个字节，然后这里使用�?4字节的float32传输，所以config_send.bytes要除�?2，表示使�?4字节的float32形式传输用了多少个字�?

    fclose(tcpipClient);
end

