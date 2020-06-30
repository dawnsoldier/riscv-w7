#!/bin/bash

DIR=$1

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

GHDL=$2

SYNTAX="${GHDL} -s --std=08 --ieee=synopsys"
ANALYS="${GHDL} -a --std=08 --ieee=synopsys"
ELABOR="${GHDL} -e --std=08 --ieee=synopsys"
SIMULA="${GHDL} -r --std=08 --ieee=synopsys"

if [ ! -z "$3" ]
then
  if [ ! "$3" = 'all' ] && [ ! "$3" = 'mi' ] && \
     [ ! "$3" = 'ui' ] && [ ! "$3" = 'um' ] && \
     [ ! "$3" = 'uf' ] && [ ! "$3" = 'ud' ] && \
     [ ! "$3" = 'uc' ] && \
     [ ! "$3" = 'dhrystone' ] && \
     [ ! "$3" = 'coremark' ] && \
     [ ! "$3" = 'csmith' ] && \
     [ ! "$3" = 'torture' ]
  then
    cp $3 $DIR/sim/work/bram_mem.dat
  fi
fi

if [[ "$4" = [0-9]* ]];
then
  CYCLES="$4"
else
  CYCLES=10000000
fi

cd $DIR/sim/work

start=`date +%s`

$SYNTAX $DIR/vhdl/tb/configure.vhd
$ANALYS $DIR/vhdl/tb/configure.vhd

$SYNTAX $DIR/vhdl/lzc/lzc_wire.vhd
$ANALYS $DIR/vhdl/lzc/lzc_wire.vhd

$SYNTAX $DIR/vhdl/lzc/lzc_lib.vhd
$ANALYS $DIR/vhdl/lzc/lzc_lib.vhd
$SYNTAX $DIR/vhdl/lzc/lzc_4.vhd
$ANALYS $DIR/vhdl/lzc/lzc_4.vhd
$SYNTAX $DIR/vhdl/lzc/lzc_8.vhd
$ANALYS $DIR/vhdl/lzc/lzc_8.vhd
$SYNTAX $DIR/vhdl/lzc/lzc_16.vhd
$ANALYS $DIR/vhdl/lzc/lzc_16.vhd
$SYNTAX $DIR/vhdl/lzc/lzc_32.vhd
$ANALYS $DIR/vhdl/lzc/lzc_32.vhd
$SYNTAX $DIR/vhdl/lzc/lzc_64.vhd
$ANALYS $DIR/vhdl/lzc/lzc_64.vhd
$SYNTAX $DIR/vhdl/lzc/lzc_128.vhd
$ANALYS $DIR/vhdl/lzc/lzc_128.vhd
$SYNTAX $DIR/vhdl/lzc/lzc_256.vhd
$ANALYS $DIR/vhdl/lzc/lzc_256.vhd

$SYNTAX $DIR/vhdl/integer/int_constants.vhd
$ANALYS $DIR/vhdl/integer/int_constants.vhd
$SYNTAX $DIR/vhdl/integer/int_types.vhd
$ANALYS $DIR/vhdl/integer/int_types.vhd
$SYNTAX $DIR/vhdl/integer/int_wire.vhd
$ANALYS $DIR/vhdl/integer/int_wire.vhd
$SYNTAX $DIR/vhdl/integer/int_functions.vhd
$ANALYS $DIR/vhdl/integer/int_functions.vhd

$SYNTAX $DIR/vhdl/float/fp_cons.vhd
$ANALYS $DIR/vhdl/float/fp_cons.vhd
$SYNTAX $DIR/vhdl/float/fp_typ.vhd
$ANALYS $DIR/vhdl/float/fp_typ.vhd
$SYNTAX $DIR/vhdl/float/fp_wire.vhd
$ANALYS $DIR/vhdl/float/fp_wire.vhd
$SYNTAX $DIR/vhdl/float/fp_func.vhd
$ANALYS $DIR/vhdl/float/fp_func.vhd

$SYNTAX $DIR/vhdl/csr/csr_constants.vhd
$ANALYS $DIR/vhdl/csr/csr_constants.vhd
$SYNTAX $DIR/vhdl/csr/csr_wire.vhd
$ANALYS $DIR/vhdl/csr/csr_wire.vhd
$SYNTAX $DIR/vhdl/csr/csr_functions.vhd
$ANALYS $DIR/vhdl/csr/csr_functions.vhd

$SYNTAX $DIR/vhdl/compress/comp_constants.vhd
$ANALYS $DIR/vhdl/compress/comp_constants.vhd
$SYNTAX $DIR/vhdl/compress/comp_wire.vhd
$ANALYS $DIR/vhdl/compress/comp_wire.vhd
$SYNTAX $DIR/vhdl/compress/comp_decode.vhd
$ANALYS $DIR/vhdl/compress/comp_decode.vhd

$SYNTAX $DIR/vhdl/setting/constants.vhd
$ANALYS $DIR/vhdl/setting/constants.vhd
$SYNTAX $DIR/vhdl/setting/wire.vhd
$ANALYS $DIR/vhdl/setting/wire.vhd
$SYNTAX $DIR/vhdl/setting/functions.vhd
$ANALYS $DIR/vhdl/setting/functions.vhd

$SYNTAX $DIR/vhdl/memory/arbiter.vhd
$ANALYS $DIR/vhdl/memory/arbiter.vhd
$SYNTAX $DIR/vhdl/memory/pmp.vhd
$ANALYS $DIR/vhdl/memory/pmp.vhd

$SYNTAX $DIR/vhdl/speedup/prefetch.vhd
$ANALYS $DIR/vhdl/speedup/prefetch.vhd
$SYNTAX $DIR/vhdl/speedup/btb.vhd
$ANALYS $DIR/vhdl/speedup/btb.vhd

$SYNTAX $DIR/vhdl/tb/bram_mem.vhd
$ANALYS $DIR/vhdl/tb/bram_mem.vhd

$SYNTAX $DIR/vhdl/integer/int_library.vhd
$ANALYS $DIR/vhdl/integer/int_library.vhd
$SYNTAX $DIR/vhdl/integer/int_alu.vhd
$ANALYS $DIR/vhdl/integer/int_alu.vhd
$SYNTAX $DIR/vhdl/integer/int_bcu.vhd
$ANALYS $DIR/vhdl/integer/int_bcu.vhd
$SYNTAX $DIR/vhdl/integer/int_agu.vhd
$ANALYS $DIR/vhdl/integer/int_agu.vhd
$SYNTAX $DIR/vhdl/integer/int_mul.vhd
$ANALYS $DIR/vhdl/integer/int_mul.vhd
$SYNTAX $DIR/vhdl/integer/int_div.vhd
$ANALYS $DIR/vhdl/integer/int_div.vhd
$SYNTAX $DIR/vhdl/integer/int_reg_file.vhd
$ANALYS $DIR/vhdl/integer/int_reg_file.vhd
$SYNTAX $DIR/vhdl/integer/int_forward.vhd
$ANALYS $DIR/vhdl/integer/int_forward.vhd
$SYNTAX $DIR/vhdl/integer/int_decode.vhd
$ANALYS $DIR/vhdl/integer/int_decode.vhd
$SYNTAX $DIR/vhdl/integer/int_pipeline.vhd
$ANALYS $DIR/vhdl/integer/int_pipeline.vhd
$SYNTAX $DIR/vhdl/integer/int_unit.vhd
$ANALYS $DIR/vhdl/integer/int_unit.vhd

$SYNTAX $DIR/vhdl/float/fp_lib.vhd
$ANALYS $DIR/vhdl/float/fp_lib.vhd
$SYNTAX $DIR/vhdl/float/fp_ext.vhd
$ANALYS $DIR/vhdl/float/fp_ext.vhd
$SYNTAX $DIR/vhdl/float/fp_cmp.vhd
$ANALYS $DIR/vhdl/float/fp_cmp.vhd
$SYNTAX $DIR/vhdl/float/fp_max.vhd
$ANALYS $DIR/vhdl/float/fp_max.vhd
$SYNTAX $DIR/vhdl/float/fp_sgnj.vhd
$ANALYS $DIR/vhdl/float/fp_sgnj.vhd
$SYNTAX $DIR/vhdl/float/fp_cvt.vhd
$ANALYS $DIR/vhdl/float/fp_cvt.vhd
$SYNTAX $DIR/vhdl/float/fp_rnd.vhd
$ANALYS $DIR/vhdl/float/fp_rnd.vhd
$SYNTAX $DIR/vhdl/float/fp_fma.vhd
$ANALYS $DIR/vhdl/float/fp_fma.vhd
$SYNTAX $DIR/vhdl/float/fp_mac.vhd
$ANALYS $DIR/vhdl/float/fp_mac.vhd
$SYNTAX $DIR/vhdl/float/fp_fdiv.vhd
$ANALYS $DIR/vhdl/float/fp_fdiv.vhd
$SYNTAX $DIR/vhdl/float/fp_for.vhd
$ANALYS $DIR/vhdl/float/fp_for.vhd
$SYNTAX $DIR/vhdl/float/fp_reg.vhd
$ANALYS $DIR/vhdl/float/fp_reg.vhd
$SYNTAX $DIR/vhdl/float/fp_dec.vhd
$ANALYS $DIR/vhdl/float/fp_dec.vhd
$SYNTAX $DIR/vhdl/float/fp_exe.vhd
$ANALYS $DIR/vhdl/float/fp_exe.vhd
$SYNTAX $DIR/vhdl/float/fp_pipe.vhd
$ANALYS $DIR/vhdl/float/fp_pipe.vhd
$SYNTAX $DIR/vhdl/float/fpu.vhd
$ANALYS $DIR/vhdl/float/fpu.vhd

$SYNTAX $DIR/vhdl/csr/csr_alu.vhd
$ANALYS $DIR/vhdl/csr/csr_alu.vhd
$SYNTAX $DIR/vhdl/csr/csr_file.vhd
$ANALYS $DIR/vhdl/csr/csr_file.vhd
$SYNTAX $DIR/vhdl/csr/csr_unit.vhd
$ANALYS $DIR/vhdl/csr/csr_unit.vhd

$SYNTAX $DIR/vhdl/stage/fetch_stage.vhd
$ANALYS $DIR/vhdl/stage/fetch_stage.vhd
$SYNTAX $DIR/vhdl/stage/decode_stage.vhd
$ANALYS $DIR/vhdl/stage/decode_stage.vhd
$SYNTAX $DIR/vhdl/stage/execute_stage.vhd
$ANALYS $DIR/vhdl/stage/execute_stage.vhd
$SYNTAX $DIR/vhdl/stage/memory_stage.vhd
$ANALYS $DIR/vhdl/stage/memory_stage.vhd
$SYNTAX $DIR/vhdl/stage/writeback_stage.vhd
$ANALYS $DIR/vhdl/stage/writeback_stage.vhd

$SYNTAX $DIR/vhdl/unit/pipeline.vhd
$ANALYS $DIR/vhdl/unit/pipeline.vhd

$SYNTAX $DIR/vhdl/tb/cpu.vhd
$ANALYS $DIR/vhdl/tb/cpu.vhd

$SYNTAX $DIR/vhdl/tb/test_cpu.vhd
$ANALYS $DIR/vhdl/tb/test_cpu.vhd

WAVE=""

$ELABOR test_cpu
if [ "$3" = 'dhrystone' ]
then
  if [ "$5" = 'wave' ]
  then
    WAVE="--wave=dhrystone.ghw"
  fi
  cp $DIR/build/dhrystone/dat/dhrystone.dat bram_mem.dat
  $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
elif [ "$3" = 'coremark' ]
then
  if [ "$5" = 'wave' ]
  then
    WAVE="--wave=coremark.ghw"
  fi
  cp $DIR/build/coremark/dat/coremark.dat bram_mem.dat
  $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
elif [ "$3" = 'csmith' ]
then
  if [ "$5" = 'wave' ]
  then
    WAVE="--wave=csmith.ghw"
  fi
  cp $DIR/build/csmith/dat/csmith.dat bram_mem.dat
  $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
elif [ "$3" = 'torture' ]
then
  if [ "$5" = 'wave' ]
  then
    WAVE="--wave=torture.ghw"
  fi
  cp $DIR/build/torture/dat/torture.dat bram_mem.dat
  $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
elif [ "$3" = 'all' ]
then
  for filename in $DIR/build/isa/dat/*.dat; do
    cp $filename bram_mem.dat
    filename=${filename##*/}
    filename=${filename%.dat}
    if [ "$5" = 'wave' ]
    then
      WAVE="--wave=${filename}.ghw"
    fi
    echo "${filename}"
    $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
  done
elif [ "$3" = 'mi' ]
then
  for filename in $DIR/build/isa/dat/rv64mi*.dat; do
    cp $filename bram_mem.dat
    filename=${filename##*/}
    filename=${filename%.dat}
    if [ "$5" = 'wave' ]
    then
      WAVE="--wave=${filename}.ghw"
    fi
    echo "${filename}"
    $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
  done
elif [ "$3" = 'ui' ]
then
  for filename in $DIR/build/isa/dat/rv64ui*.dat; do
    cp $filename bram_mem.dat
    filename=${filename##*/}
    filename=${filename%.dat}
    if [ "$5" = 'wave' ]
    then
      WAVE="--wave=${filename}.ghw"
    fi
    echo "${filename}"
    $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
  done
elif [ "$3" = 'uc' ]
then
  for filename in $DIR/build/isa/dat/rv64uc*.dat; do
    cp $filename bram_mem.dat
    filename=${filename##*/}
    filename=${filename%.dat}
    if [ "$5" = 'wave' ]
    then
      WAVE="--wave=${filename}.ghw"
    fi
    echo "${filename}"
    $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
  done
elif [ "$3" = 'um' ]
then
  for filename in $DIR/build/isa/dat/rv64um*.dat; do
    cp $filename bram_mem.dat
    filename=${filename##*/}
    filename=${filename%.dat}
    if [ "$5" = 'wave' ]
    then
      WAVE="--wave=${filename}.ghw"
    fi
    echo "${filename}"
    $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
  done
elif [ "$3" = 'uf' ]
then
  for filename in $DIR/build/isa/dat/rv64uf*.dat; do
    cp $filename bram_mem.dat
    filename=${filename##*/}
    filename=${filename%.dat}
    if [ "$5" = 'wave' ]
    then
      WAVE="--wave=${filename}.ghw"
    fi
    echo "${filename}"
    $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
  done
elif [ "$3" = 'ud' ]
then
  for filename in $DIR/build/isa/dat/rv64ud*.dat; do
    cp $filename bram_mem.dat
    filename=${filename##*/}
    filename=${filename%.dat}
    if [ "$5" = 'wave' ]
    then
      WAVE="--wave=${filename}.ghw"
    fi
    echo "${filename}"
    $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
  done
else
  filename="$3"
  filename=${filename##*/}
  filename=${filename%.dat}
  if [ "$5" = 'wave' ]
  then
    WAVE="--wave=${filename}.ghw"
  fi
  echo "${filename}"
  $SIMULA test_cpu --ieee-asserts=disable-at-0 --max-stack-alloc=0 --stop-time=${CYCLES}ns ${WAVE}
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
