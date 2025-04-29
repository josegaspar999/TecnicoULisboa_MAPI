function [str] = disgraph(graph)

% DISGRAPH - Text display of a coverability graph
%
% disgraph(graph)
%
% [str] = disgraph(graph)
%
% See PNCGRAPH.

% Written by Marian V. Iordache, miordach@nd.edu

a = [];
for i = 1:length(graph)
    if length(graph{1}{1}) < 7
        a = [a, sprintf('\nNODE %d\t %s',i, fvpr(graph{i}{1}'))];
    else
        a = [a, sprintf('\nNODE %d\t ',i)];
        for j = 1:length(graph{1}{1})
            if graph{i}{1}(j)
                a = [a, sprintf('p%d: %d; ', j, graph{i}{1}(j))];
            end
        end
    end
    a = [a, sprintf('\n IN:')];
    for j = 1:length(graph{i}{2})
        a = [a, sprintf(' %d, t%d;', graph{i}{2}{j}.n, graph{i}{2}{j}.t)];
    end
    a = [a, sprintf('\n OUT:')];
    for j = 1:length(graph{i}{3})
        a = [a, sprintf(' %d, t%d;', graph{i}{3}{j}.n, graph{i}{3}{j}.t)];
    end
end
a = [a, sprintf('\n')];

if nargout < 1
    disp(a);
else
    str = a;
end

