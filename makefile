ifneq ($(SECOND_CALL),true)

# if this is the top level instantiation of make, call back into itself with 
# the implicit rules option turned off. There has to be a simpler way
# to do this, but I havne't figured it out.
MKFLAGS := -r 

.PHONY: all
all:
	@SECOND_CALL=true $(MAKE) $(MKFLAGS) -f makefile

%:
	@SECOND_CALL=true $(MAKE) $(MKFLAGS) -f makefile $@

else

ifeq ($(MAKEFILE_LIST),)
$(warning This build system requires the MAKEFILE_LIST feature,)
$(warning which was added to GNU make in version 3.80.)
$(warning You are running $(MAKE_VERSION).)
$(error Required make feature missing)
endif

# figures out the system
include make.syscfg

# include top level macros
include macros.mk

# sub-makefiles have to fill these in
ALL_DEPS =
CLEAN =
FINAL =
TOOLS =
ALL_OBJS =

FINAL := $(call TOBUILDDIR, final)
#$(warning FINAL = $(FINAL))

final: $(FINAL)

# includes the config of the build
include config/make.config

include apps/makefile
include kernel/makefile
include kernel/addons/makefile
include tools/makefile
include lib/makefile
include boot/$(PLATFORM)/makefile

clean: $(CLEAN)
	rm -f $(ALL_OBJS)
	rm -f $(ALL)
	rm -f $(FINAL)

depsclean:
	rm -f $(ALL_DEPS)

appsclean:
	rm -rf $(APPS_BUILD_DIR)

allclean: depsclean clean
	rm -f $(TOOLS)

spotless:
	rm -rf $(BUILD_DIR)

#$(warning ALL_OBJS = $(ALL_OBJS))
#$(warning ALL_DEPS = $(ALL_DEPS))

ifeq ($(filter $(MAKECMDGOALS), allclean), )
-include $(ALL_DEPS)
endif

endif

