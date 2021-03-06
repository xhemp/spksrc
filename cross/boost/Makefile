PKG_NAME = boost
PKG_VERS = 1.63.0
PKG_EXT = tar.bz2
PKG_DIST_NAME = $(PKG_NAME)_$(subst .,_,$(PKG_VERS)).$(PKG_EXT)
PKG_DIST_SITE = https://sourceforge.net/projects/$(PKG_NAME)/files/$(PKG_NAME)/$(PKG_VERS)
PKG_DIR = $(PKG_NAME)_$(subst .,_,$(PKG_VERS))

DEPENDS = cross/bzip2 cross/zlib

HOMEPAGE = https://www.boost.org/
COMMENT  = Boost provides free peer-reviewed portable C++ source libraries.
LICENSE  = https://www.boost.org/LICENSE_1_0.txt

CONFIGURE_TARGET = boost_configure
COMPILE_TARGET = boost_compile
INSTALL_TARGET = boost_install

# Build all if not told otherwise (we exclude python library when "all" selected)
BOOST_LIBRARIES ?= all

# Expect already built python when python library selected
WITH_PYTHON_LIBRARY =
ifneq ($(findstring python,$(BOOST_LIBRARIES)),)
WITH_PYTHON_LIBRARY = 1
# The packages depending on boost with python, must build python before.
include $(WORK_DIR)/python-cc.mk
PYTHON_NAME = $(basename $(notdir $(PYTHON_INTERPRETER)))
else ifneq ($(findstring $(BOOST_LIBRARIES), all),)
# exclude python library if "all" selected
CONFIGURE_ARGS += --without-libraries=python
endif

# Useful variables for subst
comma:= ,
empty:=
space:= $(empty) $(empty)

GNU_CONFIGURE = 1
CONFIGURE_ARGS += --with-toolset=gcc --with-libraries=$(subst $(space),$(comma),$(sort $(BOOST_LIBRARIES))) --prefix=$(STAGING_INSTALL_PREFIX)

ifneq ($(strip $(WITH_PYTHON_LIBRARY)),)
CONFIGURE_ARGS += --with-python=$(WORK_DIR)/../../../native/$(PYTHON_NAME)/work-native/install/usr/local/bin/$(PYTHON_NAME)
ADDITIONAL_CFLAGS = -I$(STAGING_INSTALL_PREFIX)/$(PYTHON_INC_DIR)
ADDITIONAL_CXXFLAGS = -I$(STAGING_INSTALL_PREFIX)/$(PYTHON_INC_DIR)
endif

include ../../mk/spksrc.cross-cc.mk

ADDRESS_MODEL = 32
ifeq ($(findstring $(ARCH),$(x64_ARCHES) $(ARM8_ARCHES)),$(ARCH))
ADDRESS_MODEL = 64
endif


.PHONY: boost_configure
boost_configure:
	$(RUN) ./bootstrap.sh $(CONFIGURE_ARGS)

.PHONY: boost_compile
boost_compile:
	@# Recreate user-config.jam to include python-cc.mk on second run
	@rm -rf $(WORK_DIR)/$(PKG_DIR)/user-config.jam
	@echo "using gcc : `$(TC_PATH)$(TC_PREFIX)gcc -dumpversion` : $(TC_PATH)$(TC_PREFIX)g++ : <address-model>\"$(ADDRESS_MODEL)\" <cflags>\"$(CFLAGS)\" <cxxflags>\"$(CXXFLAGS)\" <linkflags>\"$(LDFLAGS)\" <link>\"shared\" ; " > $(WORK_DIR)/$(PKG_DIR)/user-config.jam
ifneq ($(strip $(WITH_PYTHON)),)
	@echo "using python : $(PYTHON_VERSION) : : $(STAGING_INSTALL_PREFIX)/$(PYTHON_INC_DIR) ;" >> $(WORK_DIR)/$(PKG_DIR)/user-config.jam
endif
	@echo "project : requirements <cxxflags>$(OFLAGS) ;" >> $(WORK_DIR)/$(PKG_DIR)/user-config.jam
	$(RUN) ./b2 --user-config=$(WORK_DIR)/$(PKG_DIR)/user-config.jam

.PHONY: boost_install
boost_install:
	$(RUN) ./b2 --user-config=$(WORK_DIR)/$(PKG_DIR)/user-config.jam install
