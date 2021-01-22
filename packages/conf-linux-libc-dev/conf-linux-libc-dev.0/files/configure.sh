# Check if stdenv.h is installed

echo '#include <linux/stddef.h>' | cc -E - >/dev/null
