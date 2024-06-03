include Makefile.conf





CC_CUDA=nvcc -DENABLE_CUDA ${NVCC_FLAGS} -arch=sm_13 --compiler-bindir ${PFM_NVCC_CCBIN} -Xcompiler "${OPT} ${INCLUDES} ${OPENMP}"

INCLUDES=$(patsubst %,-I%,$(shell find src -type d))
SOURCES=$(shell find src/ -name "*.cpp")
CXX_SOURCES=$(shell find src/ -name "*.cxx")
C_SOURCES=$(shell find src/ -name "*.c")




OBJECTS=${SOURCES:src/%.cpp=obj/cpp/%.o}
OBJECTS+=${C_SOURCES:src/%.c=obj/c/%.o}
OBJECTS+=${CXX_SOURCES:src/%.cxx=obj/cpp/cxx/%.o}


LIBS=-lgomp
DEFINES=




DEPENDS=${OBJECTS:%.o=%.d}
DEPENDS+=${CUDA_OBJECTS:%.o=%.d}

ifeq (${DEVMODE}, true)
	OPT=-O0
	NVCC_FLAGS=-G -g
	UBSAN=-fsanitize=undefined
else
	OPT=-O3 -funroll-loops
	MISC_FLAGS=-DNDEBUG
	UBSAN=

endif

ifeq (${PARALELLIZE}, true)
	OPENMP=-fopenmp
else
	OPENMP=
endif

ifeq (${HIPATIA}, true)
	DEFINES+=-DHIPATIA
else

endif




CC_FLAGS=-Wall ${DEFINES} ${MISC_FLAGS} ${PROFILE} ${INCLUDES} ${OPENMP} ${OPT} ${UBSAN} -c -g -gdwarf-3  -Wextra
.PHONY: clean default

default: ./main.out

clean:
	rm -rf obj
	rm -f ./main.out
	rm -f src/util/std.h.gch
	rm -rf demo/all_controllers
	rm -rf demo/top_controllers
	rm -f score.txt
	rm -f responses.txt
	rm -f demo/test_local.ini
	rm -f demo/test.ini
	rm -f demo/train_local.ini

./main.out: ${OBJECTS} ${CUDA_OBJECTS} 
	g++ ${PROFILE} ${OBJECTS} ${CUDA_OBJECTS} ${UBSAN} ${PFM_LD_FLAGS} ${LIBS} -o $@

src/util/std.h.gch: src/util/std.h Makefile.conf Makefile
	g++ ${CC_FLAGS} -std=c++11 $< -o $@

obj/cpp/cxx/%.o: src/%.cxx Makefile.conf Makefile
	@mkdir -p $(shell dirname $@)
	g++ ${CC_FLAGS}  -std=c++11 -MMD $< -o $@

obj/cpp/%.o: src/%.cpp Makefile.conf Makefile src/util/std.h.gch
	@mkdir -p $(shell dirname $@)
	g++ ${CC_FLAGS} -std=c++11 -MMD $< -o $@

obj/c/%.o: src/%.c Makefile.conf Makefile
	@mkdir -p $(shell dirname $@)
	gcc ${CC_FLAGS} -std=c99 -MMD $< -o $@


-include ${DEPENDS}
