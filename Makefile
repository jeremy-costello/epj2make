ifneq ($(V),1)
.SILENT:
endif

.PHONY: all objdir cleantarget clean realclean distclean

# CORE VARIABLES

MODULE := epj2make
VERSION :=
CONFIG := release
ifndef COMPILER
COMPILER := default
endif

TARGET_TYPE = executable

# FLAGS

ECFLAGS =
ifndef DEBIAN_PACKAGE
CFLAGS =
LDFLAGS =
endif
PRJ_CFLAGS =
CECFLAGS =
OFLAGS =
LIBS =

ifdef DEBUG
NOSTRIP := y
endif

CONSOLE = -mconsole

# INCLUDES

EPJ2MAKE_ABSPATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

ifndef EC_SDK_SRC
EC_SDK_SRC := $(EPJ2MAKE_ABSPATH)../eC
endif

_CF_DIR = $(EC_SDK_SRC)/
include $(_CF_DIR)crossplatform.mk
include $(_CF_DIR)default.cf

# POST-INCLUDES VARIABLES

OBJ = obj/$(CONFIG).$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX)/

RES =

TARGET_NAME := epj2make

TARGET = obj/$(CONFIG).$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX)/$(TARGET_NAME)$(OUT)

_ECSOURCES = \
	project/Project.ec \
	project/ProjectConfig.ec \
	project/ProjectNode.ec \
	settings/CompilerSettings.ec \
	settings/CompilerConfig.ec \
	settings/configFiles.ec \
	epj2make.ec

ECSOURCES = $(call shwspace,$(_ECSOURCES))

_COBJECTS = $(addprefix $(OBJ),$(patsubst %.ec,%$(C),$(notdir $(_ECSOURCES))))

_SYMBOLS = $(addprefix $(OBJ),$(patsubst %.ec,%$(S),$(notdir $(_ECSOURCES))))

_IMPORTS = $(addprefix $(OBJ),$(patsubst %.ec,%$(I),$(notdir $(_ECSOURCES))))

_ECOBJECTS = $(addprefix $(OBJ),$(patsubst %.ec,%$(O),$(notdir $(_ECSOURCES))))

_BOWLS = $(addprefix $(OBJ),$(patsubst %.ec,%$(B),$(notdir $(_ECSOURCES))))

COBJECTS = $(call shwspace,$(_COBJECTS))

SYMBOLS = $(call shwspace,$(_SYMBOLS))

IMPORTS = $(call shwspace,$(_IMPORTS))

ECOBJECTS = $(call shwspace,$(_ECOBJECTS))

BOWLS = $(call shwspace,$(_BOWLS))

OBJECTS = $(ECOBJECTS) $(OBJ)$(MODULE).main$(O)

SOURCES = $(ECSOURCES)

RESOURCES = \
	locale/es.mo \
	locale/he.mo \
	locale/ru.mo \
	locale/zh_CN.mo \
	../crossplatform.mk

LIBS += $(SHAREDLIB) $(EXECUTABLE) $(LINKOPT)

ifndef STATIC_LIBRARY_TARGET
LIBS += \
	$(call _L,ecrt)
OFLAGS += $(if $(ENABLE_PYTHON_RPATHS),-Wl$(comma)-rpath='$$ORIGIN/../lib',)
OFLAGS += $(RPATHS_FOR_PORTABLE_BINARIES)
endif

PRJ_CFLAGS += \
	 $(if $(DEBUG), -g, -O2 -ffast-math) $(FPIC) -w

ECFLAGS += -module $(MODULE)
ECFLAGS += -nolinenumbers

# PLATFORM-SPECIFIC OPTIONS

ifdef LINUX_TARGET

endif

ifndef WINDOWS_TARGET
ifndef MANDIR
export MANDIR=$(DESTDIR)$(prefix)/share/man
endif
endif

CECFLAGS += -cpp $(_CPP)

OFLAGS += \
	-L$(EC_SDK_SRC)/$(SODESTDIR)

# TARGETS

all: objdir $(TARGET)

objdir:
	$(call mkdir,$(OBJ))

$(OBJ)$(MODULE).main.ec: $(SYMBOLS) $(COBJECTS)
	@$(call rm,$(OBJ)symbols.lst)
	@$(call touch,$(OBJ)symbols.lst)
	$(call addtolistfile,$(SYMBOLS),$(OBJ)symbols.lst)
	$(call addtolistfile,$(IMPORTS),$(OBJ)symbols.lst)
	$(ECS) -console $(ARCH_FLAGS) $(ECSLIBOPT) @$(OBJ)symbols.lst -symbols obj/$(CONFIG).$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX) -o $(call quote_path,$@)

$(OBJ)$(MODULE).main.c: $(OBJ)$(MODULE).main.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(OBJ)$(MODULE).main.ec -o $(OBJ)$(MODULE).main.sym -symbols $(OBJ)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(OBJ)$(MODULE).main.ec -o $(call quote_path,$@) -symbols $(OBJ)

ifdef USE_RESOURCES_EAR
$(RESOURCES_EAR): $(RESOURCES) | objdir
	$(EAR) aw$(EARFLAGS) $(RESOURCES_EAR) ../crossplatform.mk ""
	$(EAR) aw$(EARFLAGS) $(RESOURCES_EAR) locale/es.mo locale/he.mo locale/ru.mo locale/zh_CN.mo "locale"
endif

$(SYMBOLS): | objdir
$(OBJECTS): | objdir
$(TARGET): $(SOURCES) $(RESOURCES_EAR) $(SYMBOLS) $(OBJECTS) | objdir
	@$(call rm,$(OBJ)objects.lst)
	@$(call touch,$(OBJ)objects.lst)
	$(call addtolistfile,$(OBJ)$(MODULE).main$(O),$(OBJ)objects.lst)
	$(call addtolistfile,$(ECOBJECTS),$(OBJ)objects.lst)
ifndef STATIC_LIBRARY_TARGET
	$(LD) $(OFLAGS) @$(OBJ)objects.lst $(LIBS) -o $(TARGET) $(INSTALLNAME) $(SONAME)
ifndef NOSTRIP
	$(STRIP) $(STRIPOPT) $(TARGET)
endif
	$(EAR) aw$(EARFLAGS) $(TARGET) ../crossplatform.mk ""
	$(EAR) aw$(EARFLAGS) $(TARGET) locale/es.mo locale/he.mo locale/ru.mo locale/zh_CN.mo "locale"
else
	$(AR) rcs $(TARGET) $(OBJECTS) $(LIBS)
endif
	$(call cp,$(TARGET),$(EC_SDK_SRC)/obj/$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX)/bin/)

install:
	$(if $(WINDOWS_HOST),$(call cp,$(TARGET),"$(BINDIR)/"),install $(INSTALL_FLAGS) $(TARGET) $(BINDIR)/$(MODULE)$(E))
ifndef WINDOWS_TARGET
	mkdir -p $(MANDIR)/man1
	$(call cpr,share/man/man1,$(MANDIR)/man1)
endif

# SYMBOL RULES

$(OBJ)Project.sym: project/Project.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,project/Project.ec) -o $(call quote_path,$@)

$(OBJ)ProjectConfig.sym: project/ProjectConfig.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,project/ProjectConfig.ec) -o $(call quote_path,$@)

$(OBJ)ProjectNode.sym: project/ProjectNode.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,project/ProjectNode.ec) -o $(call quote_path,$@)

$(OBJ)CompilerSettings.sym: settings/CompilerSettings.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,settings/CompilerSettings.ec) -o $(call quote_path,$@)

$(OBJ)CompilerConfig.sym: settings/CompilerConfig.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,settings/CompilerConfig.ec) -o $(call quote_path,$@)

$(OBJ)configFiles.sym: settings/configFiles.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,settings/configFiles.ec) -o $(call quote_path,$@)

$(OBJ)epj2make.sym: epj2make.ec
	$(ECP) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) -c $(call quote_path,epj2make.ec) -o $(call quote_path,$@)

# C OBJECT RULES

$(OBJ)Project.c: project/Project.ec $(OBJ)Project.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,project/Project.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)ProjectConfig.c: project/ProjectConfig.ec $(OBJ)ProjectConfig.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,project/ProjectConfig.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)ProjectNode.c: project/ProjectNode.ec $(OBJ)ProjectNode.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,project/ProjectNode.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)CompilerSettings.c: settings/CompilerSettings.ec $(OBJ)CompilerSettings.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,settings/CompilerSettings.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)CompilerConfig.c: settings/CompilerConfig.ec $(OBJ)CompilerConfig.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,settings/CompilerConfig.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)configFiles.c: settings/configFiles.ec $(OBJ)configFiles.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,settings/configFiles.ec) -o $(call quote_path,$@) -symbols $(OBJ)

$(OBJ)epj2make.c: epj2make.ec $(OBJ)epj2make.sym | $(SYMBOLS)
	$(ECC) $(CFLAGS) $(CECFLAGS) $(ECFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,epj2make.ec) -o $(call quote_path,$@) -symbols $(OBJ)

# OBJECT RULES

$(OBJ)Project$(O): $(OBJ)Project.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)Project.c) -o $(call quote_path,$@)

$(OBJ)ProjectConfig$(O): $(OBJ)ProjectConfig.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)ProjectConfig.c) -o $(call quote_path,$@)

$(OBJ)ProjectNode$(O): $(OBJ)ProjectNode.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)ProjectNode.c) -o $(call quote_path,$@)

$(OBJ)CompilerSettings$(O): $(OBJ)CompilerSettings.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)CompilerSettings.c) -o $(call quote_path,$@)

$(OBJ)CompilerConfig$(O): $(OBJ)CompilerConfig.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)CompilerConfig.c) -o $(call quote_path,$@)

$(OBJ)configFiles$(O): $(OBJ)configFiles.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)configFiles.c) -o $(call quote_path,$@)

$(OBJ)epj2make$(O): $(OBJ)epj2make.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(call quote_path,$(OBJ)epj2make.c) -o $(call quote_path,$@)

$(OBJ)$(MODULE).main$(O): $(OBJ)$(MODULE).main.c
	$(CC) $(CFLAGS) $(PRJ_CFLAGS) $(FVISIBILITY) -c $(OBJ)$(MODULE).main.c -o $(call quote_path,$@)

cleantarget:
	$(call rm,$(OBJ)$(MODULE).main$(O) $(OBJ)$(MODULE).main.c $(OBJ)$(MODULE).main.ec $(OBJ)$(MODULE).main$(I) $(OBJ)$(MODULE).main$(S))
	$(call rm,$(OBJ)symbols.lst)
	$(call rm,$(OBJ)objects.lst)
	$(call rm,$(TARGET))
ifdef SHARED_LIBRARY_TARGET
ifdef LINUX_TARGET
ifdef LINUX_HOST
	$(call rm,$(OBJ)$(LP)$(MODULE)$(SO)$(basename $(VER)))
	$(call rm,$(OBJ)$(LP)$(MODULE)$(SO))
endif
endif
endif

clean: cleantarget
	$(call rm,$(_OBJECTS))
	$(call rm,$(_ECOBJECTS))
	$(call rm,$(_COBJECTS))
	$(call rm,$(_BOWLS))
	$(call rm,$(_IMPORTS))
	$(call rm,$(_SYMBOLS))
ifdef USE_RESOURCES_EAR
	$(call rm,$(RESOURCES_EAR))
endif

realclean: cleantarget
	$(call rmr,$(OBJ))

distclean: cleantarget
	$(call rmr,obj/)
	$(call rmr,.configs/)
	$(call rm,*.ews)
	$(call rm,*.Makefile)
