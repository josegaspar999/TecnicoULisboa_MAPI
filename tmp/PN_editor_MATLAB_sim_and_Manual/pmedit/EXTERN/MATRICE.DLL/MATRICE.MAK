# Microsoft Visual C++ generated build script - Do not modify

PROJ = MATRICE
DEBUG = 0
PROGTYPE = 1
CALLER = 
ARGS = 
DLLS = 
D_RCDEFINES = /d_DEBUG 
R_RCDEFINES = /dNDEBUG 
ORIGIN = MSVC
ORIGIN_VER = 1.00
PROJPATH = D:\WINAPP\PMAKER\3.1\INSTALL\EXTERNES\US\MATRICE.DLL\
USEMFC = 0
CC = cl
CPP = cl
CXX = cl
CCREATEPCHFLAG = 
CPPCREATEPCHFLAG = 
CUSEPCHFLAG = 
CPPUSEPCHFLAG = 
FIRSTC =             
FIRSTCPP = MATRICE.CPP 
RC = rc
CFLAGS_D_WDLL = /nologo /G2 /W3 /Zi /ALw /Od /D "_DEBUG" /FR /GD /Fd"MATRICE.PDB"
CFLAGS_R_WDLL = /nologo /f- /G3 /W3 /ALw /O2 /D "NDEBUG" /D "_AFXDLL" /D "_PMDLL" /GD /GEf 
LFLAGS_D_WDLL = /NOLOGO /NOD /NOE /PACKC:61440 /ALIGN:16 /ONERROR:NOEXE /CO /MAP:FULL
LFLAGS_R_WDLL = /NOLOGO /NOD /NOE /PACKC:61440 /ALIGN:16 /ONERROR:NOEXE /MAP:FULL
LIBS_D_WDLL = oldnames libw ldllcew commdlg.lib olecli.lib olesvr.lib shell.lib 
LIBS_R_WDLL = MFC250 oldnames libw ldllcew commdlg.lib olecli.lib olesvr.lib shell.lib 
RCFLAGS = /nologo /d_AFXDLL 
RESFLAGS = /nologo 
RUNFLAGS = 
DEFFILE = MATRICE.DEF
OBJS_EXT = 
LIBS_EXT = ..\GENERAL\PMAPI.LIB ..\GENERAL\CMATRICE.LIB ..\GENERAL\PMKERNEL.LIB 
!if "$(DEBUG)" == "1"
CFLAGS = $(CFLAGS_D_WDLL)
LFLAGS = $(LFLAGS_D_WDLL)
LIBS = $(LIBS_D_WDLL)
MAPFILE = nul
RCDEFINES = $(D_RCDEFINES)
!else
CFLAGS = $(CFLAGS_R_WDLL)
LFLAGS = $(LFLAGS_R_WDLL)
LIBS = $(LIBS_R_WDLL)
MAPFILE = nul
RCDEFINES = $(R_RCDEFINES)
!endif
!if [if exist MSVC.BND del MSVC.BND]
!endif
SBRS = MATRICE.SBR


PMAPI_DEP = 

CMATRICE_DEP = 

PMKERNEL_DEP = 

MATRICE_DEP = d:\winapp\pmaker\3.1\install\externes\us\general\pmdoc.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\rdp.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\place.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\trans.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\arc.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\text.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\map.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\pmapi.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\cmatrice.h


MATRICE_RCDEP = d:\winapp\pmaker\3.1\install\externes\us\matrice.dll\main.ico


all:	$(PROJ).DLL

MATRICE.OBJ:	MATRICE.CPP $(MATRICE_DEP)
	$(CPP) $(CFLAGS) $(CPPCREATEPCHFLAG) /c MATRICE.CPP

MATRICE.RES:	MATRICE.RC $(MATRICE_RCDEP)
	$(RC) $(RCFLAGS) $(RCDEFINES) -r MATRICE.RC


$(PROJ).DLL::	MATRICE.RES

$(PROJ).DLL::	MATRICE.OBJ $(OBJS_EXT) $(DEFFILE)
	echo >NUL @<<$(PROJ).CRF
MATRICE.OBJ +
$(OBJS_EXT)
$(PROJ).DLL
$(MAPFILE)
d:\winapp\msvc\lib\+
d:\winapp\msvc\mfc\lib\+
..\GENERAL\PMAPI.LIB+
..\GENERAL\CMATRICE.LIB+
..\GENERAL\PMKERNEL.LIB+
$(LIBS)
$(DEFFILE);
<<
	link $(LFLAGS) @$(PROJ).CRF
	$(RC) $(RESFLAGS) MATRICE.RES $@
	@copy $(PROJ).CRF MSVC.BND
	implib /nowep $(PROJ).LIB $(PROJ).DLL

$(PROJ).DLL::	MATRICE.RES
	if not exist MSVC.BND 	$(RC) $(RESFLAGS) MATRICE.RES $@

run: $(PROJ).DLL
	$(PROJ) $(RUNFLAGS)


$(PROJ).BSC: $(SBRS)
	bscmake @<<
/o$@ $(SBRS)
<<
