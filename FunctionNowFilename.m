% https://www.cnblogs.com/helloweworld/p/3522585.html
%----------------------filename: FunctionNowFilename.m -----------------------

function [ fname ] = FunctionNowFilename( pre, post )
%NOW_FILENAME convert current time to filename
% NOW_FILENAME returns current time to filename as:
%           2010-02-23_093803413
% NOW_FILENAME('pre', 'post') returns
%           pre2010-02-23_094339313post
% NOW_FILENAME('eion-', '.mat') returns
%           eion-2010-02-23_094410117.mat
% AUTHOR: TANG Houjian @ 2010_02_12 10_04
    if nargin == 0
        pre = '';
        post = '';
    elseif nargin == 1
        post = '';
    end
    t = clock; % Get current time
    fname = [pre, num2str(t(1:1), '%04d'), ...  % Year
                  num2str(t(2:3), '%02d'), '_', ...   % -month-day_
                  num2str(t(4:5), '%02d'), ...  % hour min
                  num2str(fix(t(6)*1000),   '%05d'), post]; % sec+ms
end
%-----------------------------end of file now_filename.m-------------------






