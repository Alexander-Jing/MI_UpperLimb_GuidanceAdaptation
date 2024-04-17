function [FilteredDataMI, EI_index, mu_power] = Online_DataPreprocess_Hanning(rawdata, class, sample_frequency, WindowLength, channels)    
    %% 采集参数
    %sample_frequency = 256; 
    
    %WindowLength = 512;  % 每个窗口的长度
    %SlideWindowLength = 256;  % 滑窗间隔
    
    Trigger = double(rawdata(end,:)); %rawdata最后一行
    %RawData = double(rawdata(1:32, :));
    %Labels = double(rawdata(33, Trigger~=6));  % 收集rawdata和label
    %channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % 选择的通道
    
    RawDataMI = double(rawdata(1:end-1, Trigger==class));  % 提取这一类的状态的数据（运动想象，空想，运动想象之前的状态）
    FilteredDataMI = DataFilter(RawDataMI, sample_frequency, [3,50], [49,51]);  % 滤波去噪
    FilteredDataMI = FilteredDataMI(channels, :);  % 提取指定的channels
    %[EI_index, mu_power] = DataIndex(FilteredDataMI, WindowLength, sample_frequency, channels); 
    [EI_index, mu_power] = DataIndex_Hanning(FilteredDataMI, WindowLength, sample_frequency, channels);  % 使用pwelch和汉明窗的版本
    
    
    %% 滤波函数
    function FilteredData = DataFilter(RawData, sample_frequency, Wband, Wband_notch) 
        FilterOrder = 4;  % 设置带通滤波器的阶数
        NotchFilterOrder = 2;  % 设置陷波滤波器的阶数（这里使用巴特沃斯带阻滤波器）
        %Wband = [3,50];  % 带通滤波器，滤波器这边需要参考相关的文献进行修改，这里参考佳星师姐的论文中的滤波器设置
        %Wband_notch = [49,51];  % 陷波滤波器
        FilterType = 'bandpass';
        FilterTypeNotch = 'stop';  % matlab的butter函数里面，设置'stop'会自动设置成2阶滤波器

        % 使用陷波滤波器去除工频噪声
        FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
        % 使用带通滤波器去除噪声
        FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
    end
    
    %% 计算划窗的函数
    function [windows_per_session, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength)
        data_points_per_session = size(RawData,2);  % 每一个session的数据量
        % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % 每一个session的时间长度

        windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session滑窗后的窗数量

        % shape: (1, number of windows in this session)
        DataSamplePre = cell(1, windows_per_session);
    end

    %% 划窗函数
    function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength)
        % channels = [3:32]; 
        % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
        % channels = [3,8,27,28,30,31,32,33]-1;  % 确定前额叶的通道，由于记录的信号CH-1是Trigger，所以所有的索引减去1
        LabelWindows = [];

        % 生成划窗的数据
        for i = 1:windows_per_session
            PointStart = (i-1)*SlideWindowLength;  % 在数据中确定起始点
            DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % 生成划窗的元祖
            LabelWindows = [LabelWindows; class_index];  % 生成装label的数据
        end
        DataSamlpe = DataSamplePre;
    end
    %% 计算相关频带指标的函数
    function [EI_index, mu_power] = DataIndex(FilteredData, WindowLength, sample_frequency, channels)
        % 对滤波后的数据计算相关频带的能量指标
        k_ = WindowLength/sample_frequency;  % 由于使用的是离散傅里叶变换FFT，这里需要计算频率f和离散k之间的关系，参考DFT离散傅里叶变换的相关资料
        number_of_channels = size(channels, 2);
        alpha_band = [8:12]*k_;
        theta_band = [4:8]*k_;
        beta_band = [12:25]*k_;
        mu_band = [8:13]*k_; 
        DataPSD = FilteredData;
        E_beta = ones([1, number_of_channels]);
        E_alpha = ones([1, number_of_channels]);
        E_theta = ones([1, number_of_channels]);
        E_mu = ones([1, number_of_channels]);
        EI_ = ones([1, number_of_channels]); 
        
        % 计算傅里叶变换之后的信号的PSD图
        for i = 1:number_of_channels
            DataPSD(i,:) = abs(fft(FilteredData(i,:))).^2;  % 计算变换之后的频域幅值平方，用于计算能量，注意这里要对于每一个channel计算fft变换之后的频谱图
        end
        
        % 计算频带的相关指标
        for j = 1:number_of_channels
            E_beta(1,j) = sum(DataPSD(j,beta_band));
            E_alpha(1,j) = sum(DataPSD(j,alpha_band));
            E_theta(1,j) = sum(DataPSD(j,theta_band));
            E_mu(1,j) = sum(DataPSD(j,mu_band));
        end
        
        % 计算相关的指标数值
        for j = 1:number_of_channels
           EI_(1,j) = E_beta(1,j)/(E_alpha(1,j) + E_theta(1,j));  % EI指标的计算 
        end
        % 返回每一个channel对应的EI指标和mu频带的能量
        EI_index = EI_';
        mu_power = E_mu';  % 注意这里输出的都是转置  
    end
    
    % 使用pwelch和hanning窗计算相关频带指标的函数
    function [EI_index, mu_power] = DataIndex_Hanning(FilteredData, WindowLength, sample_frequency, channels)
        number_of_channels = size(channels, 2);
        % 对滤波后的数据计算相关频带的能量指标
        alpha_band = [8,12];
        theta_band = [4,8];
        beta_band = [12,25];
        mu_band = [8,12]; 
        E_beta = ones([1, number_of_channels]);
        E_alpha = ones([1, number_of_channels]);
        E_theta = ones([1, number_of_channels]);
        E_mu = ones([1, number_of_channels]);
        E_alpha_theta = ones([1, number_of_channels]);
        EI_ = ones([1, number_of_channels]); 
        
        % 提取每一个频带的信号
        FilteredData_beta = DataFilter(FilteredData, sample_frequency, beta_band, [49,51]);
        FilteredData_alpha = DataFilter(FilteredData, sample_frequency, alpha_band, [49,51]);
        FilteredData_theta = DataFilter(FilteredData, sample_frequency, theta_band, [49,51]);
        FilteredData_mu = DataFilter(FilteredData, sample_frequency, mu_band, [49,51]);

        % 使用pwelch和hanning窗来计算频带的相关指标
        for j = 1:number_of_channels
            [pxx_beta, ] = pwelch(FilteredData_beta(j, :), hanning(128), 64, 128, sample_frequency);
            E_beta(1,j) = 10 * log10(sum(pxx_beta));
            [pxx_alpha, ] = pwelch(FilteredData_alpha(j, :), hanning(128), 64, 128, sample_frequency);
            E_alpha(1,j) = 10 * log10(sum(pxx_alpha));
            [pxx_theta, ] = pwelch(FilteredData_theta(j, :), hanning(128), 64, 128, sample_frequency);
            E_theta(1,j) = 10 * log10(sum(pxx_theta));
            [pxx_mu, ] = pwelch(FilteredData_mu(j, :), hanning(128), 64, 128, sample_frequency);
            E_mu(1,j) = 10 * log10(sum(pxx_mu));

            % 专门准备一个用于计算EI指标分母上alpha theta频带能量的数值
            E_alpha_theta(1,j) = 10 * log10(sum(pxx_alpha + pxx_theta));
        end
        
        % 计算相关的指标数值
        for j = 1:number_of_channels
           EI_(1,j) = E_beta(1,j) - E_alpha_theta(1,j);  % EI指标的计算，这里需要修改下 
        end
        % 返回每一个channel对应的EI指标和mu频带的能量
        EI_index = EI_';
        mu_power = E_mu';  % 注意这里输出的都是转置  
    end
end