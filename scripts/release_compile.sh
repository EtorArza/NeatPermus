cat > Makefile.conf <<EOF
DEVMODE=false
CFLAGS= -std=c++11 -pthread -Wall
PARALELLIZE=true

HIPATIA=false
PFM_LD_FLAGS=
PFM_NVCC_CCBIN=
EOF

make


