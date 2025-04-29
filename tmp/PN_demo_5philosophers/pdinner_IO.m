function ask_eat_or_think= pdinner_IO(act, t)

% Simulate the "five philosophers dinner problem".
%
% Input:
%  act: 0x0 : the Petri net DOES NOT send information to the philosophers
%  t  : 1x1 : time
%
% Output:
%  ask_eat_or_think: 1x(5+5) : eat1,eat2,...,eat5,think1,think2,...,think5

% Nov2013, J. Gaspar

if nargin<1 && nargout<1
    pdinner_IO_demo;
    return
end
if prod(size(t))~=1, error('input arg "t" must be 1x1'); end

global flags_want_to_eat table_last_updt_t

if isempty(table_last_updt_t) || (now - table_last_updt_t)*24*60*60 > 1
    table_last_updt_t= now;
    flags_want_to_eat= []; % enforce update of "flags_want_to_eat" every second
end
    
if isempty(flags_want_to_eat)
    % first column = time in seconds
    % next 5 columns = want to eat flags at time t
    %
    tu= [...
        0.0  want_to_eat( [] ) ; ...
        1.0  want_to_eat( 1  ) ; ... % philosopher1 wants to eat t in [1,2]
        2.0  want_to_eat( 2  ) ; ... % philosopher2 wants to eat t in [2,3]
        3.0  want_to_eat( []  ) ; ...
        4.0  want_to_eat( [1 3] ) ; ... % philosophers 1 & 3 want to eat
        5.0  want_to_eat( [2 4] ) ; ...
        6.0  want_to_eat( [3 5] ) ; ...
        7.0  want_to_eat( [4 1] ) ; ...
        8.0  want_to_eat( [5 2] ) ; ...
        9.0  want_to_eat( [1 2] ) ; ... % one should not be able to eat...
        ];
    flags_want_to_eat= tu;
end

% philosophers want to eat (yes/no)? [thinking = not eating]

ind= find(t>=flags_want_to_eat(:,1));
if isempty(ind)
    % default ask_eat_or_think output for t < 0
    ask_eat_or_think= zeros(1,5+5);
else
    ask_eat_or_think= flags_want_to_eat(ind(end), 2:end);
end
ask_eat_or_think= [ask_eat_or_think  ~ask_eat_or_think];

return


function y= want_to_eat(kid)
y= zeros(1,5);
for i=1:length(kid)
    y(kid(i))= 1;
end


function pdinner_IO_demo

tRange= 0:.1:10;

fSav= [];
for t= tRange
    ask_eat_or_think= pdinner_IO([], t);
    fSav= [fSav; ask_eat_or_think];
end

%figure(200), clf;
plot_z(tRange, fSav(:,1:5), 'c.-');
ylabel('flags (want to eat)'); xlabel('time');
