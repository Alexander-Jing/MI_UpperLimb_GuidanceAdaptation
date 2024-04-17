function [FilteredDataMI, EI_index, mu_power] = Online_DataPreprocess_Hanning(rawdata, class, sample_frequency, WindowLength, channels)    
    %% �ɼ�����
    %sample_frequency = 256; 
    
    %WindowLength = 512;  % ÿ�����ڵĳ���
    %SlideWindowLength = 256;  % �������
    
    Trigger = double(rawdata(end,:)); %rawdata���һ��
    %RawData = double(rawdata(1:32, :));
    %Labels = double(rawdata(33, Trigger~=6));  % �ռ�rawdata��label
    %channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];  % ѡ���ͨ��
    
    RawDataMI = double(rawdata(1:end-1, Trigger==class));  % ��ȡ��һ���״̬�����ݣ��˶����󣬿��룬�˶�����֮ǰ��״̬��
    FilteredDataMI = DataFilter(RawDataMI, sample_frequency, [3,50], [49,51]);  % �˲�ȥ��
    FilteredDataMI = FilteredDataMI(channels, :);  % ��ȡָ����channels
    %[EI_index, mu_power] = DataIndex(FilteredDataMI, WindowLength, sample_frequency, channels); 
    [EI_index, mu_power] = DataIndex_Hanning(FilteredDataMI, WindowLength, sample_frequency, channels);  % ʹ��pwelch�ͺ������İ汾
    
    
    %% �˲�����
    function FilteredData = DataFilter(RawData, sample_frequency, Wband, Wband_notch) 
        FilterOrder = 4;  % ���ô�ͨ�˲����Ľ���
        NotchFilterOrder = 2;  % �����ݲ��˲����Ľ���������ʹ�ð�����˹�����˲�����
        %Wband = [3,50];  % ��ͨ�˲������˲��������Ҫ�ο���ص����׽����޸ģ�����ο�����ʦ��������е��˲�������
        %Wband_notch = [49,51];  % �ݲ��˲���
        FilterType = 'bandpass';
        FilterTypeNotch = 'stop';  % matlab��butter�������棬����'stop'���Զ����ó�2���˲���

        % ʹ���ݲ��˲���ȥ����Ƶ����
        FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
        % ʹ�ô�ͨ�˲���ȥ������
        FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
    end
    
    %% ���㻮���ĺ���
    function [windows_per_session, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength)
        data_points_per_session = size(RawData,2);  % ÿһ��session��������
        % seconds_per_session  = size(EIRawData,2)/sample_frequency;  % ÿһ��session��ʱ�䳤��

        windows_per_session = (data_points_per_session - WindowLength) / SlideWindowLength + 1;  % session������Ĵ�����

        % shape: (1, number of windows in this session)
        DataSamplePre = cell(1, windows_per_session);
    end

    %% ��������
    function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength)
        % channels = [3:32]; 
        % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
        % channels = [3,8,27,28,30,31,32,33]-1;  % ȷ��ǰ��Ҷ��ͨ�������ڼ�¼���ź�CH-1��Trigger���������е�������ȥ1
        LabelWindows = [];

        % ���ɻ���������
        for i = 1:windows_per_session
            PointStart = (i-1)*SlideWindowLength;  % ��������ȷ����ʼ��
            DataSamplePre{1, i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % ���ɻ�����Ԫ��
            LabelWindows = [LabelWindows; class_index];  % ����װlabel������
        end
        DataSamlpe = DataSamplePre;
    end
    %% �������Ƶ��ָ��ĺ���
    function [EI_index, mu_power] = DataIndex(FilteredData, WindowLength, sample_frequency, channels)
        % ���˲�������ݼ������Ƶ��������ָ��
        k_ = WindowLength/sample_frequency;  % ����ʹ�õ�����ɢ����Ҷ�任FFT��������Ҫ����Ƶ��f����ɢk֮��Ĺ�ϵ���ο�DFT��ɢ����Ҷ�任���������
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
        
        % ���㸵��Ҷ�任֮����źŵ�PSDͼ
        for i = 1:number_of_channels
            DataPSD(i,:) = abs(fft(FilteredData(i,:))).^2;  % ����任֮���Ƶ���ֵƽ�������ڼ���������ע������Ҫ����ÿһ��channel����fft�任֮���Ƶ��ͼ
        end
        
        % ����Ƶ�������ָ��
        for j = 1:number_of_channels
            E_beta(1,j) = sum(DataPSD(j,beta_band));
            E_alpha(1,j) = sum(DataPSD(j,alpha_band));
            E_theta(1,j) = sum(DataPSD(j,theta_band));
            E_mu(1,j) = sum(DataPSD(j,mu_band));
        end
        
        % ������ص�ָ����ֵ
        for j = 1:number_of_channels
           EI_(1,j) = E_beta(1,j)/(E_alpha(1,j) + E_theta(1,j));  % EIָ��ļ��� 
        end
        % ����ÿһ��channel��Ӧ��EIָ���muƵ��������
        EI_index = EI_';
        mu_power = E_mu';  % ע����������Ķ���ת��  
    end
    
    % ʹ��pwelch��hanning���������Ƶ��ָ��ĺ���
    function [EI_index, mu_power] = DataIndex_Hanning(FilteredData, WindowLength, sample_frequency, channels)
        number_of_channels = size(channels, 2);
        % ���˲�������ݼ������Ƶ��������ָ��
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
        
        % ��ȡÿһ��Ƶ�����ź�
        FilteredData_beta = DataFilter(FilteredData, sample_frequency, beta_band, [49,51]);
        FilteredData_alpha = DataFilter(FilteredData, sample_frequency, alpha_band, [49,51]);
        FilteredData_theta = DataFilter(FilteredData, sample_frequency, theta_band, [49,51]);
        FilteredData_mu = DataFilter(FilteredData, sample_frequency, mu_band, [49,51]);

        % ʹ��pwelch��hanning��������Ƶ�������ָ��
        for j = 1:number_of_channels
            [pxx_beta, ] = pwelch(FilteredData_beta(j, :), hanning(128), 64, 128, sample_frequency);
            E_beta(1,j) = 10 * log10(sum(pxx_beta));
            [pxx_alpha, ] = pwelch(FilteredData_alpha(j, :), hanning(128), 64, 128, sample_frequency);
            E_alpha(1,j) = 10 * log10(sum(pxx_alpha));
            [pxx_theta, ] = pwelch(FilteredData_theta(j, :), hanning(128), 64, 128, sample_frequency);
            E_theta(1,j) = 10 * log10(sum(pxx_theta));
            [pxx_mu, ] = pwelch(FilteredData_mu(j, :), hanning(128), 64, 128, sample_frequency);
            E_mu(1,j) = 10 * log10(sum(pxx_mu));

            % ר��׼��һ�����ڼ���EIָ���ĸ��alpha thetaƵ����������ֵ
            E_alpha_theta(1,j) = 10 * log10(sum(pxx_alpha + pxx_theta));
        end
        
        % ������ص�ָ����ֵ
        for j = 1:number_of_channels
           EI_(1,j) = E_beta(1,j) - E_alpha_theta(1,j);  % EIָ��ļ��㣬������Ҫ�޸��� 
        end
        % ����ÿһ��channel��Ӧ��EIָ���muƵ��������
        EI_index = EI_';
        mu_power = E_mu';  % ע����������Ķ���ת��  
    end
end