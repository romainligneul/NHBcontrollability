%%% define transition matrices
%%%%%%%%%%%%%%%%%% SS
% A1 = purple / A2 = blue / A3 = yellow
% S1 = purple+blue / A2 = purple+yellow / A3 = blue+yellow
%%%% cond 1: no control 2
% action 1 X     % A(12)  %B(13)       %C(23)
E.T{1}{1} = ['[noise(1)/2 1-noise(1) noise(1)/2; ',... % A(12)
    'noise(2)/2 noise(2)/2 1-noise(2); ',...             % B(13)
    '1-noise(3) noise(3)/2 noise(3)/2]'];                % C(23)
% action 2
E.T{1}{2} = ['[noise(1)/2 1-noise(1) noise(1)/2; ',...
    'noise(2)/2 noise(2)/2 1-noise(2); ',...
    '1-noise(3) noise(3)/2 noise(3)/2]'];
% action 3
E.T{1}{3} = ['[noise(1)/2 1-noise(1) noise(1)/2; ',...
    'noise(2)/2 noise(2)/2 1-noise(2); ',...
    '1-noise(3) noise(3)/2 noise(3)/2]'];
%%%% cond 2: no control 2
% action 1 X     % A(12)  %B(13)       %C(23)
E.T{2}{1} = ['[noise(1)/2 noise(1)/2 1-noise(1); ',... % A(12)
    '1-noise(2) noise(2)/2 noise(2)/2; ',...  % B(13)
    'noise(3)/2 1-noise(3) noise(3)/2]'];     % C(23)
% action 2 Y
E.T{2}{2} = ['[noise(1)/2 noise(1)/2 1-noise(1); ',... % A(12)
    '1-noise(2) noise(2)/2 noise(2)/2; ',...  % B(13)
    'noise(3)/2 1-noise(3) noise(3)/2]'];     % C(23)
% action 3 Z
E.T{2}{3} = ['[noise(1)/2 noise(1)/2 1-noise(1); ',... % A(12)
    '1-noise(2) noise(2)/2 noise(2)/2; ',...  % B(13)
    'noise(3)/2 1-noise(3) noise(3)/2]'];     % C(23)

%%%%%%%%%%%%%%%%%% AS
% A1 = purple / A2 = blue / A3 = yellow
% S1 = triangle(purple+blue) / A2 = square(purple+yellow) / A3 =
% circle(blue+yellow)

% cond 3: continuous flow of states
% action 1       % A(12)  %B(13)  %C(23)
E.T{3}{1} = ['[noise(1)/2 noise(1)/2 1-noise(1); ',... % A(12)
    'noise(1)/2 noise(1)/2 1-noise(1); ',...  % B(13)
    'noise(1)/2 noise(1)/2 1-noise(1)]'];     % C(23) => should never happen.
% action 2
E.T{3}{2} = ['[noise(2)/2 1-noise(2) noise(2)/2; ',...
    'noise(2)/2 1-noise(2) noise(2)/2; ',...
    'noise(2)/2 1-noise(2) noise(2)/2]'];
% action 3
E.T{3}{3} = ['[1-noise(3) noise(3)/2 noise(3)/2;',...
    '1-noise(3) noise(3)/2 noise(3)/2;',...
    '1-noise(3) noise(3)/2 noise(3)/2]'];

% cond 4: repeat possible
% action 1       % A(12)  %B(13)  %C(23)
E.T{4}{1}= [  '[1-noise(1) noise(1)/2 noise(1)/2;',...  % A(12)
    '1-noise(1) noise(1)/2 noise(1)/2;',... % B(13)
    '1-noise(1) noise(1)/2 noise(1)/2]'];    % C(23)
% action 2
E.T{4}{2} = ['[noise(2)/2 noise(2)/2 1-noise(2);',...
    'noise(2)/2 noise(2)/2 1-noise(2);',...
    'noise(2)/2 noise(2)/2 1-noise(2)]'];
% action 3
E.T{4}{3} = ['[noise(3)/2 1-noise(3) noise(3)/2; ',...
    'noise(3)/2  1-noise(3) noise(3)/2; ',...
    'noise(3)/2  1-noise(3) noise(3)/2]'];

% cond 4: repeat possible
% action 1       % A(12)  %B(13)  %C(23)
E.T{5}{1}= [  '[1/3 1/3 1/3;',...  % A(12)
    '1/3 1/3 1/3;',... % B(13)
    '1/3 1/3 1/3]'];    % C(23)
% action 2
E.T{5}{2} = [  '[1/3 1/3 1/3;',...  % A(12)
    '1/3 1/3 1/3;',... % B(13)
    '1/3 1/3 1/3]'];    % C(23)
% action 3
E.T{5}{3} = [  '[1/3 1/3 1/3;',...  % A(12)
    '1/3 1/3 1/3;',... % B(13)
    '1/3 1/3 1/3]'];    % C(23)