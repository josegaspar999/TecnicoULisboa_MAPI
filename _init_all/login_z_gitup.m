function login_z_svnup

% goto general folder
f= 'login_z_svnup.m';
p= which( f );
p= strrep( p, f,'' );
cd(p)
cd('..')

% call the svn update
!svn update
