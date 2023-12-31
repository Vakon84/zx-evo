TARGET      := avrconf

#The Directories, Source, Includes, Objects, Binary and ReCXXSRC
SRCDIR      := src
INCDIR		:= ../../sdk/gcWin/src
LIBDIR      := lib
BUILDDIR    := obj
TARGETDIR   := bin
RESDIR      := res

ASMEXT      := s
CXXEXT      := c
OBJEXT      := rel
HEXEXT      := hex
LIBEXT      := lib
OUTEXT      := spg

ASMFLAGS    := -g
CXXFLAGS    := --std-c11 -mz80 --opt-code-speed -I$(INCDIR)
LNKFLAGS    := -mz80 --no-std-crt0 --code-loc 0x0000 -Wl-b_CODE=0x0200 -Wl-b_DATA=0xB000

#---------------------------------------------------------------------------------
#DO NOT EDIT BELOW THIS LINE
#---------------------------------------------------------------------------------
CXX         := sdcc
ASM         := sdasz80

ASMSRC      := $(wildcard $(SRCDIR)/*.$(ASMEXT))
CXXSRC      := $(wildcard $(SRCDIR)/*.$(CXXEXT))
LIBSRC      := $(wildcard $(LIBDIR)/*.$(LIBEXT))

OBJECTS     := $(patsubst $(SRCDIR)/%, $(BUILDDIR)/%, $(ASMSRC:.$(ASMEXT)=.$(OBJEXT)))
OBJECTS     += $(patsubst $(SRCDIR)/%, $(BUILDDIR)/%, $(CXXSRC:.$(CXXEXT)=.$(OBJEXT)))
STRIP       := strip

#Defauilt Make
all: $(TARGET)

#Make the Directories
directories:
	@mkdir -p $(TARGETDIR)
	@mkdir -p $(BUILDDIR)

#Clean only Objects
clean cleanall:
	# $(foreach obj, $(OBJECTS), $(RM) -f $(obj))
	@$(RM) -rf $(BUILDDIR)
	@$(RM) -rf $(TARGETDIR)
	@$(RM) -rf $(TARGET).$(OUTEXT)

#Link
$(TARGET): $(OBJECTS)
	mkdir -p $(TARGETDIR)
	$(CXX) -o $(TARGETDIR)\$(TARGET).$(HEXEXT) $(LNKFLAGS) -l $(LIBSRC) $^
	../../tools/hex2bin/hex2bin -e bin $(TARGETDIR)/$(TARGET).$(HEXEXT)
	../../tools/spgbld/spgbld -b $(RESDIR)/spg.ini $(TARGET).$(OUTEXT)

#Compile C
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(CXXEXT)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

#Compile ASM
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(ASMEXT)
	@mkdir -p $(dir $@)
	$(ASM) $(ASMFLAGS) -o $@ $<

print-%  : ; @echo $* = $($*)

#Non-File Targets
.PHONY: all clean
