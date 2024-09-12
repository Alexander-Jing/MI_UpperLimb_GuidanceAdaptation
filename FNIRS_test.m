oxy = actxserver('oxysoft.oxyapplication');  % 连接近红外
disp(['Connected to Oxy Version: ', oxy.strVersion]);
label = 'R';
name = 'rest';

% 一个虚拟的连接近红外的实验
for trial_idx=1:3
    pause(2);
    for Timer=1:12
        if Timer<=2
            label = 'P';
            name = 'Prepare';
        end
    
        if Timer>2 && Timer<=10
            label = 'T';
            name = 'Task';
        end

        if Timer>10
            label = 'R';
            name = 'Rest';
        end

        pause(1.0);
        oxy.WriteEvent(label, name);
        disp([label, ' ', name]);
    end
end