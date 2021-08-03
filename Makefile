SRCDIR:=src/
TESTSRCDIR:=test/
CFILES:=$(wildcard $(SRCDIR)*.c)
CXXFILES:=$(wildcard $(SRCDIR)*.cpp)
TESTCFILES:=$(wildcard $(TESTSRCDIR)*.c)
TESTCXXFILES:=$(wildcard $(TESTSRCDIR)*.cpp)
INC:=-Iinc/
CFLAGS:=-std=gnu18 -Wall -Wfatal-errors
CXXFLAGS:=-std=gnu++20 -Wshadow=local -Wall -Wfatal-errors
CPPFLAGS:=$(INC) -MMD -MP
LDFLAGS:=
ODIR:=obj/
DEBUGODIR:=$(ODIR)debug/
RELEASEODIR:=$(ODIR)release/
TESTODIR:=$(ODIR)test/
DEBUG_OFILES = $(patsubst $(SRCDIR)%,$(DEBUGODIR)%,$(patsubst %.c,%.c.o,$(CFILES)))
DEBUG_OFILES += $(patsubst $(SRCDIR)%,$(DEBUGODIR)%,$(patsubst %.cpp,%.cpp.o,$(CXXFILES)))
RELEASE_OFILES = $(patsubst $(SRCDIR)%,$(RELEASEODIR)%,$(patsubst %.c,%.c.o,$(CFILES)))
RELEASE_OFILES += $(patsubst $(SRCDIR)%,$(RELEASEODIR)%,$(patsubst %.cpp,%.cpp.o,$(CXXFILES)))
TEST_OFILES = $(patsubst $(TESTSRCDIR)%,$(TESTODIR)%,$(patsubst %.c,%.c.o,$(TESTCFILES)))
TEST_OFILES += $(patsubst $(TESTSRCDIR)%,$(TESTODIR)%,$(patsubst %.cpp,%.cpp.o,$(TESTCXXFILES)))
ALL_OFILES = $(DEBUG_OFILES) $(RELEASE_OFILES) $(TEST_OFILES)
RELEASE_TARGET := final
DEBUG_TARGET := final_debug
TEST_TARGET := final_test
WERROR_CONFIG := -Werror -Wno-error=unused-variable

.DEFAULT_GOAL := all

.PHONY: all clean debug release test

all: release debug test

release: CFLAGS += -O2 $(WERROR_CONFIG)
release: CXXFLAGS += -O2 $(WERROR_CONFIG)
release: $(RELEASE_TARGET)

debug: CFLAGS += -Og -ggdb
debug: CXXFLAGS += -Og -ggdb
debug: CPPFLAGS += -DDEBUG
debug: $(DEBUG_TARGET)

test: CFLAGS += -Og -ggdb
test: CXXFLAGS += -Og -ggdb
test: CPPFLAGS += -DDEBUG
test: LDFLAGS += -lgtest -lgtest_main
test: $(TEST_TARGET)

-include $(DEBUG_OFILES:%.o=%.d)
-include $(RELEASE_OFILES:%.o=%.d)

$(ALL_OFILES) : Makefile

$(RELEASEODIR) $(DEBUGODIR) $(TESTODIR) :
	mkdir -p $@

$(DEBUGODIR)%.c.o: $(SRCDIR)%.c | $(DEBUGODIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(RELEASEODIR)%.c.o: $(SRCDIR)%.c | $(RELEASEODIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(TESTODIR)%.c.o: $(TESTSRCDIR)%.c | $(TESTODIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(DEBUGODIR)%.cpp.o: $(SRCDIR)%.cpp | $(DEBUGODIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(RELEASEODIR)%.cpp.o: $(SRCDIR)%.cpp | $(RELEASEODIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(TESTODIR)%.cpp.o: $(TESTSRCDIR)%.cpp | $(TESTODIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(DEBUG_TARGET): $(DEBUG_OFILES)
	$(CXX) -o $@ $^ $(LDFLAGS)

$(RELEASE_TARGET): $(RELEASE_OFILES)
	$(CXX) -o $@ $^ $(LDFLAGS)

$(TEST_TARGET): $(TEST_OFILES) $(filter-out $(DEBUGODIR)main%, $(DEBUG_OFILES))
	$(CXX) -o $@ $^ $(LDFLAGS)

clean:
	rm -rf $(ODIR)
	rm -f $(RELEASE_TARGET)
	rm -f $(DEBUG_TARGET)
	rm -f $(TEST_TARGET)
