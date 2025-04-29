function [vout] = pnpred(Graph,xi,sc)

% PNPRED - Predecessor/successor nodes in a coverability graph
%
% [vout] = pnpred(Graph,i)
%
% sets vout to the list of nodes in the coverability graph Graph 
% which precede the node i. Note that vout is an integer vector and
% i is an integer. For the data format of Graph, refer to PNCGRAPH. 
% Thus the marking of node j of Graph is Graph{j}{1}.
%
% To compute the successor nodes, use the format
%
% [vout] = pnpred(Graph,i,3)

% Written by Marian V. Iordache, miordach@nd.edu

nnode = length(Graph);  vout = []; 
if xi > nnode | xi < 1, return; end

if nargin < 3,
    sc = 2;
end

ind = zeros(1,nnode);
waitlist = xi; 

while ~isempty(waitlist)
    cnode = waitlist(1); waitlist = waitlist(2:length(waitlist));
    ind(cnode) = 1;
    for i = 1:length(Graph{cnode}{sc})
        j = Graph{cnode}{sc}{i}.n;
        if ~ind(j)
            waitlist = [j, waitlist];
        end
    end
end
vout = find(ind);
