function C = invar1(A)
% INVAR1(A) returns a matrix whose columns give the minimal support place
% invariants of a petri net incidence matrix A, i.e., it returns the basis
% for the solutions to x'A = 0, the null space of A'.
%
% See also SIPH.
%
% The solution is based on an algorithm by Martinez and Silva.
%

% Notes: 1. This file has been written by John O. Moody, and later included 
%           by M.V.Iordache in the toolbox. 
%        2. The use of INVAR instead of INVAR1 is recommended for integer 
%           matrices A.

[n,m] = size(A);
BC = [A eye(n)];	% BC is two matrices, B and C, C = identity at start
cc = m+1:m+n;		% Columns of the C portion of the matrix.
for j = 1:m,
	Ip = find(BC(:,j) > 0);
	Im = find(BC(:,j) < 0);
	if (length(Ip) > 0) & (length(Im) > 0),
		I = find(BC(:,j) == 0);
		k = length(BC(:,j));
		for a = 1:length(Ip),	% Add linear combinations 
			for b = 1:length(Im),
				x = BC(Ip(a),j)/BC(Im(b),j);
				BC = [BC; BC(Ip(a),:) - x*BC(Im(b),:)];
			    	k = k + 1;
			    	I = [I; k];
			end
		end
		BC = BC(I,:);		% Delete rows used above.
		if isempty(BC),
			break
		end
		C = BC(:,cc);
		BC(:,cc) = C/max(max(C));  		% Normalize
		f = 2/min(C(find(C > 0)));	     	% Scaling factor
	  	k = length(BC(:,1)); 	% Identify and delete rows of C whose
		a = 1;     		% support is not minimal with respect
		while a <= k,		% to the other rows of C.
		    for b = 1:k,
			if a ~= b,
			    if (f*BC(a,cc) >= BC(b,cc))
			    	BC = [BC(1:a-1,:); BC(a+1:k,:)];
			    	k = k - 1;
			    	a = a - 1;
			    	break;
			    end
			end
		    end
		    a = a + 1;
		end
		if isempty(BC),
			break
		end
	end
end
if isempty(BC)
	C = [];
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
		C = [];
	else
		C = BC(:,cc)';
		C = C/min(C(find(C > 0)));
	end
end
