function R = Online_Data2Server_Communicate(send_order, data_x, ip, port, subject_name, config_data, foldername)
    
    % config_data = [512;30;motor_class;session;trial;window;score;0;0;0;0 ];  % 登记上传的数据的相关参数，分别是WindowLength，channels，运动想象类别motor_class,session数量,trial数量,trial里面的数�??,score的数值，空出来的数据1（暂时置�??0），空出来的数据2（暂时置�??0），空出来的数据3（暂时置�??0），空出来的数据4（暂时置�??0�??
    % config = whos('data_x');
    data2Server = data_x;
    
    % 中�?�保存下要发送的数据 
    foldername = [foldername, '\\Online_data2server', subject_name]; % 指定文件夹路径和名称
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    save([foldername, '\\', FunctionNowFilename(['Online_EEG_data2Server_', subject_name, '_class_', num2str(config_data(3,1)),  '_session_', num2str(config_data(4,1)), '_trial_', num2str(config_data(5,1)), '_window_', num2str(config_data(6,1)), '_score_', num2str(config_data(7,1)), '_' ], '.mat' )],'data2Server');
    
    % 传输数据
    time_out = 600; % 投�?�数据包的等待时�??
    tcpipClient = tcpip(ip, port,'NetworkRole','Client');
    %tcpipClient = tcpip('172.18.22.21', 8888,'NetworkRole','Client');
    set(tcpipClient,'OutputBufferSize',4*999*30*256*8*10);%2048*4096 67108880+64
    set(tcpipClient,'Timeout',time_out);
    tcpipClient.InputBufferSize = 8388608/256;%8M
    tcpipClient.ByteOrder = 'bigEndian';
    fopen(tcpipClient);
    %disp("���ӳɹ�")
    %disp("���ݷ���")

    % send_order = 1.0;  % 发�?�命令控制，用于控制服务器，命令1是实时交互命令，命令3是上传数据的命令
    send_data = [send_order; config_data(:); data2Server(:)];
    config_send = whos('send_data');   % whos('send_data')将返回该变量的名称大小字节数、类型等信息
    fwrite(tcpipClient,[config_send.bytes; send_data],'float32');  % 这里matlab的double8个字节，然后这里使用4字节的float32传输，所以config_send.bytes要除2，表示使4字节的float32形式传输用了多少个字

    % 接收数据
    %disp("���ݽ���")
    recv_data = [];
    %重复多次接收
    % h=waitbar(0,'正在接收数据');
    while isempty(recv_data)
        recv_data=fread(tcpipClient);%读取第一组数
    end
    header = convertCharsToStrings(native2unicode(recv_data,'utf-8'));
    recv_bytes = str2double(regexp(header,'(?<=(L": )).*?(?=(,|$))','match'))-2;%正则化提取数据大�??
    while length(recv_data)<recv_bytes
        if recv_data(end)==125
            break
        end
        waitbar(length(recv_data)/recv_bytes)
        recv_package = [];
        while isempty(recv_package)
            try
                recv_package=fread(tcpipClient);
            catch
                continue
            end
        end
        recv_data = vertcat(recv_data,recv_package);
    end
    % close(h)
    chararray = native2unicode(recv_data,'utf-8');
    str = convertCharsToStrings(chararray);  % 接收到的数据，为字典格式
    try
        dic = jsondecode(str);%将json形式的字典数据里面的矩阵数据提取
        R = dic.R;
        %disp('���յ�����: ')
        %disp(R)
    catch
        disp('WARNNING:���ܲ���ȫ')
    end
    %disp('���ӶϿ�')

    fclose(tcpipClient);
end

