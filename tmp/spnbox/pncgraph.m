function [Graph, varargout] = pncgraph(pnobj, opt, varargin)

% PNCGRAPH - The Coverability Graph of a Petri Net
% 
% [Graph] = pncgraph(pnobj)
%
% returns the coverability graph of the PN of object pnobj. 
%
% Graph is a cell array in which:
%
%  * Graph{1}{1} = m0, the initial marking
%  * Graph{i}{1} is the marking label of the node i
%  * Graph{i}{2} is the list of (direct) predecessor nodes: 
%    Graph{i}{2}{j}.n is the number of the j'th predecessor node and
%    Graph{i}{2}{j}.t is the (index of the) transition by which node
%    i is reached; in particular, if Graph{1} has no predecessors, 
%    Graph{1}{2} = {}.
%  * Graph{i}{3} is the list of (direct) successor nodes:
%    Graph{i}{3}{j}.n is the number of the j'th successor node and
%    Graph{i}{3}{j}.t is the (index of the) transition by which the
%    j'th successor node is reached. 
%
% [Graph] = pncgraph(pnobj, is_reach)
%
% If is_reach is not zero, the function builds the reachability graph.
% Use this for bounded Petri nets only. 
%
% [Graph, m1, m2, ...] = pncgraph(pnobj, is_reach, f1, f2, ...)
%
% evaluates at every node of the reachability graph the functions f1, 
% f2, ... . The format of an fi should be the following:
%
% scalar = fi(marking)
%
% where marking is a column vector. When fi is called, marking is set
% to the current node marking. For those applications which also need
% the PN object, the following format can be used
% 
% scalar = fi(marking, pnobj)
%
% The expected return value of a function fi is a scalar. PNCGRAPH sets 
% mi for i = 1, 2, ..., to cell arrays storing in mi the markings 
% for which the evaluation of fi has been nonzero. Thus, mi{k}.m is the
% k'th marking for which 'scalar' has been nonzero, and mi{k}.s is the 
% value of 'scalar'. 
%
% It is possible to force the program to exit as soon as for all fi's, a
% marking has been found such that the evaluation of fi is nonzero: set
% opt(1) to is_reach and opt(2) to a nonzero value in the format below:
%
% [Graph, m1, m2, ...] = pncgraph(pnobj, opt, f1, f2, ...)

% Written by Marian V. Iordache, miordach@nd.edu
% August 2001

if ~ispn(pnobj), error('First argument is not a PN object. Use GETPN!'); end

Dm = pnobj.Dm; Dp = pnobj.Dp; m0 = pnobj.m0(:);
[m,n] = size(Dm); 
D = Dp - Dm;

if nargin < 2, opt = []; end
if isempty(opt)
    is_reach = 0;
    is_term = 0;
else
    is_reach = opt(1);
    if length(opt) > 1
        is_term = opt(2);
    else
        is_term = 0;
    end
end 

no = nargout - 1;
nfx = length(varargin); 
fun = {}; addarg = {}; fl = 0; j = 0;
% Separating functions from their additional arguments 
for i = 1:nfx 
    ctmp = class(varargin{i});
    % the additional arguments are assumed not of class char
    if strcmp(ctmp,'char') | strcmp(ctmp,'function_handle')
        j = j + 1; k = 1;
        fun{j} = varargin{i};
        addarg{j} = {};
    elseif ~j
        error('Invalid call syntax: type "help pncgraph" for syntax information');
    else
        addarg{j}{k} = varargin{i}; k = k + 1;
    end
end
nf = j;
if nf < no
    error('The number of output arguments does not match the number of input arguments');
end

argfo = ones(nf,1); % the number of outputs of each fi
argfi = ones(nf,1); % the number of inputs of each fi
for i = 1:nf
    fnm = fun{i};
    if ~strcmp(class(fnm),'char')
        fnm = func2str(fnm);
    end
    argfo(i) = nargout(fnm);
    argfi(i) = nargin(fnm);
end
for i = 1:no
   varargout{i} = {};
end

Graph = {{m0, {}, {}}};
node_num = 1;
waitlist = 1; mready = zeros(1,min(nf,no)); 
initial = 1;

while ~isempty(waitlist)
    %disgraph(Graph); % two debug lines
    %disp('========================================'); 
    i = waitlist(1); waitlist = waitlist(2:length(waitlist));
    omrk = Graph{i}{1};   % the current marking
    for j = 1:min(nf,no) % evaluate the argument functions
        if argfo(j)      % if the argument function has an output
            if argfi(j) > 1
                ev = feval(fun{j},omrk,pnobj,addarg{j}{:});
            else
                ev = feval(fun{j},omrk,addarg{j}{:});
            end
            evl = length(ev); % for the case when fun{j} doesn't return a scalar
            if initial % initialization operations performed only once
                if evl > 1
                    for k = 1:evl % initialize varargout{j}
                        varargout{j}{k} = {}; 
                    end
                    xready{j}{1} = zeros(1,evl); 
                end
            end
            if evl == 1
                if ev
                    varargout{j} = [varargout{j}, {struct('m',omrk,'s',ev)}];
                    mready(j) = 1;
                end
            else % considers the case when fun{j} does not return a scalar
                for k = 1:evl
                    if ev(k)
                       varargout{j}{k} = [varargout{j}{k}, {struct('m',omrk,'s',ev(k))}];
                    end
                end
                xready{j}{1} = xready{j}{1} | ev';
                if xready{j}{1}
                    mready(j) = 1;
                end
            end
        end
    end
    initial = 0;
    if is_term
        if mready, return; end
    end
    for j = 1:n
        if omrk >= Dm(:,j) % i.e. if t_j is enabled
            eqflag = 0; infflag = 0;
            mrk = omrk + D(:,j); % marking reached by firing t_j
            zout = node_num:-1:1;% DO NOT change this line without changing line XX!
            if ~is_reach % operations below not needed for reachability graph
                % check whether the new marking is larger than prev. markings
                vout = pnpred(Graph,i); % compute the predecessor nodes
                y = zeros(length(mrk),1); yout = [];
                for k = vout
                    z = mrk - Graph{k}{1};
                    if isfinite(z), yout = [yout, k]; end
                    z(find(isnan(z))) = 0; % correct the result of Inf - Inf
                    if z >= 0, y = y + z; infflag = 1; end
                    if ~z, eqflag = 1; break; end
                end
                if infflag % update marking by adding Inf elements
                    y(find(y)) = Inf;
                    mrk = mrk + y;
                end 
                % operation below insures that we do not repeat comparisons in test below
                zout(node_num+1-yout) = [];  % line XX 
            end
            if ~eqflag % test whether the node already exists
                for k = zout
                    if mrk == Graph{k}{1}
                        eqflag = 1;
                        break
                    end
                end
            end
            if eqflag % update nodes
                Graph{i}{3}{length(Graph{i}{3})+1} = struct('n',k,'t',j);
                Graph{k}{2}{length(Graph{k}{2})+1} = struct('n',i,'t',j);
            else % add new node
                node_num = node_num + 1;
                waitlist = [node_num, waitlist];
                Graph{node_num} = {mrk, {struct('n',i,'t',j)}, {}};
                Graph{i}{3}{length(Graph{i}{3})+1} = struct('n',node_num,'t',j);
            end
        end
    end
end

if nargout == 0
    disgraph(Graph);
end

    
  