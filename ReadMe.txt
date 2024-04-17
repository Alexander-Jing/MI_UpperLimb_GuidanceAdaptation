1. The communication of motor imagery between matlab and unity3D, matlab and server
matlab -> unity
	SceneControl 0
	SceneCross 1
	SceneRest 2
Idle 0   -> SceneIdle 0+3
MI1 1   -> SceneMI_Drinking 1+3
MI2 2   -> Scene_Milk 2+3

matlab -> server (python)
Idle 0   -> Idle  0
MI1 1   -> MI1 1
MI2 2   -> MI2 2

2. The saved data of the offline/online model (on the MATLAB) 

- SubName  # root folder, the name of the testing subject 
# offline data 
-- Offline_EEGMI_RawData_SubName  # the rawdata of the offline collection
--- Offline_EEGMI_RawData_SubName.mat

-- Offline_EEGMI_SubName  # the preprocessed data for the subject 
--- Offline_EEG_data_SubName.mat  # the offline data collected 
--- Offline_EEG_label_SubName.mat  # the offline labels for the data

-- Offline_Data2Server_SubName   # the preprocessed data for the server 
--- Offline_EEG_data2Server_SubName.mat   # the preprocessed data for the server 

# online data 
-- Level2task_SubName   # the intial arrangement of the trials in the sessions 
--- Online_EEGMI_session_SessionId_SubName.mat  #  the intial arrangement of the trials in the sessions

-- Online_EEGMI_RawData_SubName  # the raw data of each session of online training 
--- Online_EEGMI_RawData_SessionId_SubName.mat  # the online data of each session collected 

3. The saved data of the offline/online model (on the Server SSH)

- MI_Online
-- Offline_DataCollected  # the offline training data 
--- SubName 
---- class_ClassId_window_WindowId.csv

-- Online_DataCollected  # the online training data, these data will be updated progressively 
--- SubName
---- class_ClassId_session_SessionId_trial_TrialId_window_WindowId_score_ScoreValue.csv

-- Offline_experiments  # the training process and results of the models for each subject 
--- SubName 
---- hypersearch_summary
---- model results of different hyperparameters

-- Online_experiments  # the saved parameters and updated models of the model 
--- SubName 
---- model results of different hyperparameters

4. The text display of Text of unity3D during training and the communication of the display 
matlab -> unity3D
progress bar:
scores (sendbuf(1,5) = uint8((score/100.0))) -> slider (ServerSocket.Instance.data.reserve)
scores (sendbuf(1,5) = uint8((score/100.0))) -> silder (textMesh[0].text = "Score: " + SliderManager.decNumber.ToString();)

text:
text (sendbuf(1,3) = hex2dec('00');) -> textMesh[1] (textMesh[1].text = "Motor Imaging";)
text (sendbuf(1,3) = hex2dec('01');) -> textMesh[1] (textMesh[1].text = "Excellent!";)
text (sendbuf(1,3) = hex2dec('02');) -> textMesh[1] (textMesh[1].text = "Don’t give up! Keep going!";)
