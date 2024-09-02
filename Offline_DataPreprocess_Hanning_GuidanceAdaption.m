function [DataX, DataY, windows_per_session] = Offline_DataPreprocess_Hanning_GuidanceAdaption(rawdata, classes, sample_frequency, WindowLength, SlideWindowLength, channels, subject_name, foldername, seconds_per_trial)    
    %% �ɼ�����
    %sample_frequency = 256; 
    
    %WindowLength = 512;  % ÿ�����ڵĳ���
    %SlideWindowLength = 256;  % �������
    
    Trigger = double(rawdata(end,:)); %rawdata���һ��
    % ����channels�������Ե�ñ�ӵĲ��ֵ缫���迹�ܲ��ȶ�����������ֱ����channels��ѡ��ע��Ŀǰ�豸��channelsͨ����1-32��ͨ�����ݣ�33��trigger������
    % Ŀǰ���õ�channelѡ��Ϊ��
    % channels = [1,2,3,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30];  
    % ѡ���ͨ��������ȥ����OZ��M1,M2��Fp1��Fp2�⼸��channel
    
    DataX = [];
    DataY = [];  % ��ʼ�������X��Y������
     
    for class_index = 0:(classes-1)
        RawDataMI = double(rawdata(channels, Trigger == class_index));  % ��ȡ��һ����˶��������ݣ�������ǰ��ͨ����ѡ�񣬷�ֹ�����迹�ǳ��ߵ�channelӰ������CAR
        RawDataMI_CAR = ref_CAR(RawDataMI);  % CAR ����
        FilteredDataMI = DataFilter(RawDataMI_CAR, sample_frequency);  % �˲�ȥ��
        [windows_per_session, winodws_num, SampleDataPre] = WindowsDataPre(FilteredDataMI, WindowLength, SlideWindowLength, sample_frequency, seconds_per_trial);
        [DataSample, LabelWindows] = DataWindows(SampleDataPre, FilteredDataMI, [], class_index, windows_per_session, SlideWindowLength, WindowLength, sample_frequency, winodws_num, seconds_per_trial);  % ��������ע�����ﲻ����ͨ��ѡ����
        DataX = [DataX; DataSample];
        DataY = [DataY, LabelWindows];
    end
    
    % ��;������Ҫ���͵����� 
    foldername = [foldername, '\\Offline_EEGMI_', subject_name]; % ָ���ļ���·��������
    if ~exist(foldername, 'dir')
       mkdir(foldername);
    end
    % Ԥ����֮������ݴ洢��������洫��ʧ�ܣ�ֱ�ӽ�������mat�ļ��͵���������
    save([foldername, '\\', FunctionNowFilename(['Offline_EEG_data_', subject_name], '.mat' )],'DataX');
    save([foldername, '\\', FunctionNowFilename(['Offline_EEG_label_', subject_name], '.mat' )],'DataY');
    
    %% Common Average Reference����
    function DataRef = ref_CAR(RawData)
        % �ο���https://github.com/sccn/eeglab/blob/develop/functions/sigprocfunc/reref.m�����д��
        nchan = size(RawData, 1);
        refmatrix = eye(nchan)-ones(nchan)*1/nchan;
        DataRef = refmatrix * RawData;
    end
    
    %% �˲�����
    function FilteredData = DataFilter(RawData, sample_frequency) 
        FilterOrder = 4;  % ���ô�ͨ�˲����Ľ���
        NotchFilterOrder = 2;  % �����ݲ��˲����Ľ���������ʹ�ð�����˹�����˲�����
        % ������˲��������ο����Ǻ��͹�����ļ�ƪ���ף�
        % Ma X, Qiu S, He H. Multi-channel EEG recording during motor imagery of different joints from the same limb[J]. Scientific data, 2020, 7(1): 191.
        % Ma X, Qiu S, Wei W, et al. Deep channel-correlation network for motor imagery decoding from the same limb[J]. IEEE Transactions on Neural Systems and Rehabilitation Engineering, 2019, 28(1): 297-306.
        Wband = [0.1, 40];  % �˲��������Ҫ�ο���ص����׽����޸ģ�����ο�����ʦ��������е��˲�������
        Wband_notch = [49,51];
        FilterType = 'bandpass';
        FilterTypeNotch = 'stop';  % matlab��butter�������棬����'stop'���Զ����ó�2���˲���

        % ʹ���ݲ��˲���ȥ����Ƶ����
        FilteredData = Rsx_ButterFilter(NotchFilterOrder,Wband_notch,sample_frequency,FilterTypeNotch,RawData,size(RawData,1));
        % ʹ�ô�ͨ�˲���ȥ������
        FilteredData = Rsx_ButterFilter(FilterOrder,Wband,sample_frequency,FilterType,FilteredData,size(FilteredData,1)); 
    end
    
    %% ���㻮���ĺ���
    function [windows_per_session, winodws_num, DataSamplePre] = WindowsDataPre(RawData, WindowLength, SlideWindowLength, sample_frequency, seconds_per_trial)
        
        trials_per_session = size(RawData,2)/(seconds_per_trial*sample_frequency);  % trial������
        winodws_num = (seconds_per_trial - (WindowLength/sample_frequency))/(SlideWindowLength/sample_frequency) + 1;  % һ��trial�Ļ���������
        
        windows_per_session = trials_per_session * winodws_num;  % session������Ĵ�����

        % shape: (1, number of windows in this session)
        DataSamplePre = cell(1, windows_per_session);
    end

    %% ��������
    function [DataSample, LabelWindows] = DataWindows(DataSamplePre, FilteredData, channels, class_index, windows_per_session, SlideWindowLength, WindowLength, sample_frequency, winodws_num, seconds_per_trial)
        % channels = [3:32]; 
        % channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
        % channels = [3,8,27,28,30,31,32,33]-1;  % ȷ��ǰ��Ҷ��ͨ�������ڼ�¼���ź�CH-1��Trigger���������е�������ȥ1
        LabelWindows = [];
        % scores = [];  % ���ڴ洢scores����������

        % ���ɻ���������
        for j = 1:(windows_per_session/winodws_num)
            for i = 1:winodws_num
                PointStart =(j-1)*sample_frequency*seconds_per_trial + (i-1)*SlideWindowLength;  % ��������ȷ����ʼ��
                %DataSamplePre{1, winodws_num*(j-1)+i} = FilteredData(channels, PointStart + 1:PointStart + WindowLength );  % ���ɻ�����Ԫ��
                DataSamplePre{1, winodws_num*(j-1)+i} = FilteredData(1:end, PointStart + 1:PointStart + WindowLength );  % ���ɻ�����Ԫ��, ���ﲻ�ٽ���channel��ѡ�񣬽���ǰ����channel��ѡ��
                LabelWindows = [LabelWindows; class_index];  % ����װlabel������
            end
        end
        DataSample = DataSamplePre;
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
        EI_index = EI_;
        mu_power = E_mu;  
    end
end