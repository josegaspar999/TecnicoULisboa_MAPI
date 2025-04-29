# Microsoft Visual C++ generated build script - Do not modify

PROJ = CYCLE_TI
DEBUG = 0
PROGTYPE = 1
CALLER = 
ARGS = 
DLLS = 
D_RCDEFINES = /d_DEBUG 
R_RCDEFINES = /dNDEBUG 
ORIGIN = MSVC
ORIGIN_VER = 1.00
PROJPATH = D:\WINAPP\PMAKER\3.1\INSTALL\EXTERNES\US\CYCLE.DLL\
USEMFC = 0
CC = cl
CPP = cl
CXX = cl
CCREATEPCHFLAG = 
CPPCREATEPCHFLAG = 
CUSEPCHFLAG = 
CPPUSEPCHFLAG = 
FIRSTC =             
FIRSTCPP = TEMPS_CY.CPP
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
DEFFILE = CYCLE_TI.DEF
OBJS_EXT = 
LIBS_EXT = ..\GENERAL\CMATRICE.LIB ..\GENERAL\PMAPI.LIB ..\GENERAL\PMKERNEL.LIB 
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
SBRS = CYCLE_TI.SBR


CYCLE_TI_DEP = d:\winapp\pmaker\3.1\install\externes\us\general\pmdoc.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\rdp.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\place.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\trans.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\arc.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\text.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\map.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\pmapi.h \
	d:\winapp\pmaker\3.1\install\externes\us\general\cmatrice.h


CYCLE_TI_RCDEP = d:\winapp\pmaker\3.1\install\externes\us\cycle.dll\main.ico


CMATRICE_DEP = 

PMAPI_DEP = 

PMKERNEL_DEP = 

all:	$(PROJ).DLL

CYCLE_TI.OBJ:	CYCLE_TI.CPP $(CYCLE_TI_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c CYCLE_TI.CPP

CYCLE_TI.RES:	CYCLE_TI.RC $(CYCLE_TI_RCDEP)
	$(RC) $(RCFLAGS) $(RCDEFINES) -r CYCLE_TI.RC


$(PROJ).DLL::	CYCLE_TI.RES

$(PROJ).DLL::	CYCLE_TI.OBJ $(OBJS_EXT) $(DEFFILE)
	echo >NUL @<<$(PROJ).CRF
CYCLE_TI.OBJ +
$(OBJS_EXT)
$(PROJ).DLL
$(MAPFILE)
d:\winapp\msvc\lib\+
d:\winapp\msvc\mfc\lib\+
..\GENERAL\CMATRICE.LIB+
..\GENERAL\PMAPI.LIB+
..\GENERAL\PMKERNEL.LIB+
$(LIBS)
$(DEFFILE);
<<
	link $(LFLAGS) @$(PROJ).CRF
	$(RC) $(RESFLAGS) CYCLE_TI.RES $@
	@copy $(PROJ).CRF MSVC.BND
	implib /nowep $(PROJ).LIB $(PROJ).DLL

$(PROJ).DLL::	CYCLE_TI.RES
	if not exist MSVC.BND 	$(RC) $(RESFLAGS) CYCLE_TI.RES $@

run: $(PROJ).DLL
	$(PROJ) $(RUNFLAGS)


$(PROJ).BSC: $(SBRS)
	bscmake @<<
/o$@ $(SBRS)
<<
