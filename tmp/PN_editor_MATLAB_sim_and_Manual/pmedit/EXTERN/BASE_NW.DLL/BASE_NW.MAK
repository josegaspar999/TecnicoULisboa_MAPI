# Microsoft Visual C++ generated build script - Do not modify

PROJ = BASE_NW
DEBUG = 0
PROGTYPE = 1
CALLER = 
ARGS = 
DLLS = 
D_RCDEFINES = /d_DEBUG 
R_RCDEFINES = /dNDEBUG 
ORIGIN = MSVC
ORIGIN_VER = 1.00
PROJPATH = D:\WINAPP\PMAKER\3.1\INSTALL\EXTERNES\US\BASE_NW.DLL\
USEMFC = 0
CC = cl
CPP = cl
CXX = cl
CCREATEPCHFLAG = 
CPPCREATEPCHFLAG = 
CUSEPCHFLAG = 
CPPUSEPCHFLAG = 
FIRSTC =             
FIRSTCPP = BASE_NW.CPP 
RC = rc
CFLAGS_D_WDLL = /nologo /G2 /W3 /Zi /ALw /Od /D "_DEBUG" /FR /GD /Fd"STEP.PDB"
CFLAGS_R_WDLL = /nologo /f- /G3 /W3 /ALw /O2 /D "NDEBUG" /D "_AFXDLL" /D "_PMDLL" /GD /GEf 
LFLAGS_D_WDLL = /NOLOGO /NOD /NOE /PACKC:61440 /ALIGN:16 /ONERROR:NOEXE /CO /MAP:FULL
LFLAGS_R_WDLL = /NOLOGO /NOD /NOE /PACKC:61440 /ALIGN:16 /ONERROR:NOEXE /MAP:FULL
LIBS_D_WDLL = oldnames libw ldllcew commdlg.lib olecli.lib olesvr.lib shell.lib 
LIBS_R_WDLL = MFC250.LIB oldnames libw ldllcew commdlg.lib olecli.lib olesvr.lib shell.lib 
RCFLAGS = /nologo /d_AFXDLL 
RESFLAGS = /nologo 
RUNFLAGS = 
DEFFILE = BASE_NW.DEF
OBJS_EXT = 
LIBS_EXT = ..\GENERAL\PMKERNEL.LIB 
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
SBRS = BASE_NW.SBR


PMKERNEL_DEP = 

BASE_NW_DEP = d:\winapp\pmaker\3.1\install\externes\us\general\pmdoc.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\rdp.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\place.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\trans.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\arc.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\text.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\map.h


all:	$(PROJ).DLL

BASE_NW.OBJ:	BASE_NW.CPP $(BASE_NW_DEP)
	$(CPP) $(CFLAGS) $(CPPCREATEPCHFLAG) /c BASE_NW.CPP

BASE_NW.RES:	BASE_NW.RC $(BASE_NW_RCDEP)
	$(RC) $(RCFLAGS) $(RCDEFINES) -r BASE_NW.RC


$(PROJ).DLL::	BASE_NW.RES

$(PROJ).DLL::	BASE_NW.OBJ $(OBJS_EXT) $(DEFFILE)
	echo >NUL @<<$(PROJ).CRF
BASE_NW.OBJ +
$(OBJS_EXT)
$(PROJ).DLL
$(MAPFILE)
d:\winapp\msvc\lib\+
d:\winapp\msvc\mfc\lib\+
..\GENERAL\PMKERNEL.LIB+
$(LIBS)
$(DEFFILE);
<<
	link $(LFLAGS) @$(PROJ).CRF
	$(RC) $(RESFLAGS) BASE_NW.RES $@
	@copy $(PROJ).CRF MSVC.BND
	implib /nowep $(PROJ).LIB $(PROJ).DLL

$(PROJ).DLL::	BASE_NW.RES
	if not exist MSVC.BND 	$(RC) $(RESFLAGS) BASE_NW.RES $@

run: $(PROJ).DLL
	$(PROJ) $(RUNFLAGS)


$(PROJ).BSC: $(SBRS)
	bscmake @<<
/o$@ $(SBRS)
<<
