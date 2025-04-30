function login_z_update

% goto general folder
f= 'login_z_update.m';
[p,~,~]= fileparts( which(f) );
cd(p)
cd('..')

% call the GIT update
!git pull
