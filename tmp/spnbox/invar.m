function C = invar(A)

% INVAR - Positive invariant computation.
%
% INVAR(A) returns a matrix whose columns give the minimal support positive
% invariants of a matrix A, i.e., it returns a basis for the solutions to
% Ax = 0, x >= 0.
%
% This is a modification of INVAR1. INVAR works with integers only!  
% INVAR1 is called if A is not an integer matrix.
%
% The solution is based on an algorithm by Martinez and Silva.

% INVAR is a slight modification of INVAR1; INVAR1 has been written by 
% John O. Moody. 

A = A'; 

% The line below calls INVAR1 if A is not an integer matrix. 
% INVAR1 should not be used for integer matrices.  

z = sum(sum(ceil(A)-A)); if z, C = invar1(A); return; end

[n,m] = size(A);

BC = [A eye(n)];	% BC is two matrices, B and C, C = identity at start
cc = m+1:m+n;		% Columns of the C portion of the matrix.
for j = 1:m,
	Ip = find(BC(:,j) > 0);
	Im = find(BC(:,j) < 0);
	if (length(Ip) > 0) & (length(Im) > 0),
		I = find(BC(:,j) == 0);
		k = length(BC(:,j));
                %length(Ip)
                %length(Im)
		for a = 1:length(Ip),	% Add linear combinations 
			for b = 1:length(Im),
                                d = gcd(BC(Ip(a),j),BC(Im(b),j));
                                x = BC(Im(b),j)/d;
				y = BC(Ip(a),j)/d;
				BC = [BC; -x*BC(Ip(a),:) + y*BC(Im(b),:)];
			    	k = k + 1;
			    	I = [I; k];
			end
		end
		BC = BC(I,:);		% Delete rows used above.
		if isempty(BC),
			break
		end

	  	% Identify and delete rows of C whose
		% support is not minimal with respect
		% to the other rows of C.

		C = BC(:,cc);
                [a,b] = size(BC(:,cc));%a
                rlist = ones(1, a);
                D = xor(BC(:,cc), zeros(a,b));

                for ii = 1:a
                    if rlist(ii)
                         for jj = ii+1:a
                             if rlist(jj)
                                 if D(ii,1:n) >= D(jj, 1:n)
                                     rlist(ii) = 0;
                                 elseif D(ii,1:n) <= D(jj,1:n)
                                     rlist(jj) = 0;
                                 end
                             end
                         end
                     end
                end

                rlist = (find(rlist));
                BC = BC(rlist,:);

		if isempty(BC),
			break
		end
	end
end
if isempty(BC)
	C = zeros(n,0);
else
	% Eliminate rows which are not part of null space.  This step
	% was not included in original program by Martinez and Silva,
	% but it seems to be necessary, at least as far as the way the
	% check for minimal support invariants was done above.
	I = [];
	x = ~(BC(:,cc)*A);
	for a = 1:length(BC(:,1)),
		if x(a,:),
			I = [I; a];
		end
	end
	BC = BC(I,:);
	% Now return answer
	if isempty(BC)
		C = zeros(n,0);
	else
		C = BC(:,cc)';
                [b, a] = size(C);
                for i = 1:a
                    C(:,a) = C(:,a)/gcdv(C(:,a));
                end
	end
end
