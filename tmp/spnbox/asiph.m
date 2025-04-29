function [MS, NMS] = asiph(Dm, Dp, lst, PS, Dma, Dpa, verb)

% ASIPH - find minimal active siphons: direct implementation
%
% [MS, NMS] = asiph(D)
%
% [MS, NMS] = asiph(D^-,D^+,list,PAS, Dma, Dpa)
%
% [MS, NMS] = asiph(D^-,D^+,list,PAS, Dma, Dpa, verb)
%
% 'list' is an optional argument that should specify a subset of 
% {1, ..., m}, where m is the number of rows of the incidence matrix. 
% When 'list is used, only act. siphons that include one or more of the
% places from 'list' are returned. This feature allows the program to
% run faster. However note that in this case the result is the set of
% smallest act. siphons that include the places from the list; this includes
% the set of minimal act. siphons that contain places from list, but it may 
% include other act. siphons as well. Therefore the 3rd argument is useful
% when it is known (from theoretical considerations) that all returned 
% act. siphons are minimal. This is the case in SDP. If list = [], the
% program sets it to the default value list = 1:m.
%
% The columns of PAS are already known active siphons. Dma and Dpa are
% the incidence matrices of the active subnet.
%
% When Dma and Dpa are omitted, the maximal active subnet is assumed.
%
% MS is the updated PAS, and NMS the new minimal active siphons. 
%
% verb (default is 1) stands for verbosity. If verb = 1, the program will
% display some information about its progress.
%
% See also MSIPH, SIPH2, MINSIPH

% Written by Marian V. Iordache, miordach@nd.edu

% lst feature is not yet fully implemented! (the case when a source place 
% appears in the list has not been considered).

if nargin == 1
    D = Dm;
    Dm = -D.*(D < 0); 
    Dp =  D.*(D > 0); 
end

chk_data(Dm,Dp);
[m,n] = size(Dm);
x = 0;

if isempty(Dm), MS = Dm; NMS = MS; return; end

if nargin < 3, lst = 1:m; end

if isempty(lst), lst = 1:m; end

if nargin < 4, PS = zeros(m,0); end

if nargin < 5,  Dma = []; Dpa = [];  end

if nargin < 7, verb = 1; end

overb = verb;
if strcmp(class(verb),'double'), verb = verb~=0; end
if strcmp(class(verb),'struct'), ics = verb; verb = 2; end 

[m2, f] = size(PS);
newidx = zeros(1,f);

if m ~= m2
  error('Dimensions of 1-st, 2-nd and 4-th arguments do not agree')
end

chk_data(Dma, Dpa);
if isempty(Dma)
    [Dma, Dpa] = actn(Dm, Dp); % compute the active subnet
end
emrow = find(~sum(Dma+Dpa,2));
nerow = find(sum(Dma+Dpa,2));
as = PS;
lsta = 1:m;
lsta = lsta(nerow); % do not include in list unused places
as(emrow,:) = 0;  % transform active siphons to siphons of the active subnet
[u, v] = size(as);
as = checkv(as'); % remove repeated occurences

if isempty(lsta), MS = zeros(m,0); NMS = MS; return, end
tst = (Dma == Dm) & (Dpa == Dp);
if tst   % repetitive net
    sx = eye(m);
    sx = sx(:,lst);
else     % nonrepetitive net
    lst = 1:m; % TO BE REMOVED WHEN lst feature is implemented !!
    sx = asiph(Dma, Dpa, lsta, as', [], [], overb); % (minimal) siphons of the active subnet
end
[u, v] = size(sx);
MNS = PS'; %zeros(0,m); % set of minimal active siphons
NS  = zeros(0,m); % set of siphons of the active subnet which are not active siphons
for i = 1:v
    csiph = find(sx(:,i));
    pres_t = find(sum(Dp(csiph,:),1));
    post_t = find(sum(Dm(csiph,:),1));
    prest = zeros(1,n); prest(pres_t) = 1;
    postt = zeros(1,n); postt(post_t) = 1;
    ck = ~sum(xor(prest, postt&prest));
    if ck
        [MNS, newidx] = ins(MNS, sx(:,i)', newidx); %[MNS; sx(:,i)'];
    else
        NS  = [NS; sx(:,i)'];
    end
end

DM = Dm; DP = Dp; 
Dm = (Dm ~= 0); Dp = (Dp ~= 0);

% the set of input transitions of each place

it = Dp;

% number of input places of each transition

nip = sum(Dm,1);

% set of input places of each transition

pre_t = zeros(0,m);
for i = 1:n
    z = find(Dm(:,i));
    k = m-length(z);
    pre_t = [pre_t; z', zeros(1,k)];
end

source_t = sum(sum(Dp,1)&(sum(Dm,1) == 0));
% source_t stores the number of source transitions.

% main iteration

[u, v] = size(NS);
for i = 1:u
    M = NS(i,:);
    newplaces = M;
    intrans = sum(Dp(find(M),:), 1);
    otrans  = sum(Dm(find(M),:), 1);
    newtrans = xor(intrans, intrans& otrans); 
    N = M;

    while 1   % 
       intrans = sum(Dp(find(M(1,:)),:), 1);
       otrans  = sum(Dm(find(M(1,:)),:), 1);
       newtrans = xor(intrans, intrans& otrans); 
       
       MT = zeros(0,m);
       NT = MT;
       tt = newtrans;
       %tt = sum(it(find(newplaces(j,:)),:),1); 
       % tt(i)~=0 iff t_i input transition
       ttl = find(tt);   % ttl is the set of input transitions
       k = length(ttl);  % number of input transitions
       counter = ones(1,k);
       limit = nip(ttl); % limit of counter
       flg = 1;
       while flg  
          % loop to create new rows; flg is (counter <= limit)
          plc = diag(pre_t(ttl(1:k),counter(1:k))); 
          % plc: the input places
          nrow = zeros(1,m);
          tst = 1;  % if exists plc(i) = 0, the path cannot be  
          if isempty(plc) == 0     % in a siphon, because there
             tst = ~sum(plc == 0);% are source transitions
          end
          if tst                
             nrow(plc) = 1;        
             nnewplaces = nrow & (~M(1,:));% the new newplaces
             nrow = nrow | M(1,:);
             ck = check(MNS,nrow);
             intrans = sum(Dp(find(nrow),:), 1);
             otrans  = sum(Dm(find(nrow),:), 1);
             newtrans = xor(intrans, intrans& otrans); 
             % ck = 1 if nrow does not contain a min. siphon.
             if newtrans == 0 & ck
                flg = 0;
                [MNS, newidx]=ins(MNS,nrow,newidx);% update min. siphons
                %MNS = [MNS; M(1,:)];
                %MT = zeros(0,m);
                %NT = MT;
                %break;
                %end
             elseif ck 
                if check2(M, nrow)
                   MT = [MT; nrow];
                   NT = [NT; nnewplaces];
                end
             end
          end
          
          for a=1:k                   % Update of the counter
             if counter(a) < limit(a)
                counter(a) = counter(a) + 1;
                flg = 1;
                break
             else
                counter(a) = 1;
                flg = 0;
             end
          end
       end  % end code for new rows
       
       M = [M; MT]; % matrix of tentative siphons
       N = [N; NT]; % matrix of new places in each of the tentative siphons
       
       [nnx, f] = size(M);
       M = M(2:nnx,1:m);
       N = N(2:nnx,1:m);
       newplaces = N;
       if isempty(newplaces)
          break
       end
    end  % end while
    x = floor(100*i/u);
    if verb == 1
       if i == 1
          bck(5,0);fprintf(': ');
       elseif x < 10
          bck(2,0);
       else
          bck(3,0);
       end
       fprintf('%d%%', x);
    elseif verb == 2
       if ishandle(ics.hdl), 
           set(ics.hdl,'String',[ics.string, sprintf('%d%%', x)],'Position',ics.pos); 
           figure(ics.ghdl);
       end
    end
 end      % end big for
 
if isempty(MNS) 
    if source_t == 0
        MNS = ones(1,m);  % returns the whole set of places if no 
    else                  % other siphon was found
        MNS = zeros(0,m); % returns empty if no siphon was found 
    end                   % and there are source transitions
    newidx = find(~source_t);
end
MS = MNS';
NMS = MS(:,find(newidx));


% ========================================

function [R, idx] = ins(MNS, vect, newidx)

[j,k] = size(MNS);
fl = ones(1,j);

tst = 1;
for i = 1:j
    z = MNS(i,:) - vect;
    y = sum(z);
    if z >= 0 
        if tst
            if y
                MNS(i,:) = vect;
                newidx(i) = 1;
            end
            tst = 0;% tst=0 shows that vect is added to MNS.
        else
            fl(i) = 0;          % mark siphon as not minimal
            newidx(i) = 0;
        end
    end
end

idl = find(fl);
if tst
    R = [MNS(idl,:); vect];
    idx = [newidx(idl), 1];
else
    R = MNS(idl,:);
    idx = newidx(idl);
end

% =====================================

function [ck] = check(MNS, nrow)

[j,k] = size(MNS);

if sum(nrow~= ones(1,k)) == 0
    ck = 0;
    return;
end

for i = 1:j
if nrow >= MNS(i,:)
        ck = 0;
        return
    end
end
 
ck = 1;

% =====================================

function [ck] = check2(MNS, nrow)  % this variant checks equality

[j,k] = size(MNS);

if sum(nrow~= ones(1,k)) == 0
    ck = 0;
    return;
end

for i = 1:j
if nrow == MNS(i,:)
        ck = 0;
        return
    end
end
 
ck = 1;

% =====================================

function [res] = checkv(dt)

[j, k] = size(dt);

if isempty(dt), res = dt; return; end

res = dt(1,:);
z = 1;

for i = 2:j
    flg = 1;
    for u = 1:z
        if res(u,:) == dt(i,:)
            flg = 0;
            break;
        end
     end
     if flg == 1, res = [res; dt(i,:)]; z = z+1; end
end
