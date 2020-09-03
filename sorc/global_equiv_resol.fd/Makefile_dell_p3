SHELL := bash

FC ?= ifort
#FC = ftn 
FFLAGS ?= -O2 -g

#INCS  = -I${NETCDF}/include
#LIBS = ${NETCDF_LDFLAGS} ${HDF5_LDFLAGS} ${Z_LIB}
#LIBS = -L${NETCDF}/lib -lnetcdf -lnetcdff -L${HDF5}/lib -lhdf5_hl -lhdf5

INCS = -I${NETCDF}/include
LIBS = -L${NETCDF}/lib -lnetcdf -lnetcdff -L${HDF5}/lib -lhdf5_hl -lhdf5

REGIONAL_GRID = global_equiv_resol 

.PHONY: all
all : $(REGIONAL_GRID)

$(REGIONAL_GRID): global_equiv_resol.o
	$(FC) $(FFLAGS) ${INCS} ${LIBS} -o $@ $^

.SUFFIXES:
.SUFFIXES: .f90 .o

.f90.o:
	$(FC) $(FFLAGS) ${INCS} -c $<

.PHONY: clean
clean:
	rm -f *.o *.mod $(REGIONAL_GRID)

install:
	cp $(REGIONAL_GRID) ../../exec/.
