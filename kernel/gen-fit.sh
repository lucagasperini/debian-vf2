#!/usr/bin/env bash
set -euo pipefail

#
# make-fit.sh
#
# Genera image.fit per StarFive VisionFive 2 / JH7110
#
# Uso:
#   ./make-fit.sh Image.gz initramfs.cpio.gz board.dtb [image.fit]
#

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Usage: $0 <Image.gz> <initramfs.cpio.gz> <dtb> [output.fit]"
    exit 1
fi

KERNEL="$(realpath "$1")"
INITRAMFS="$(realpath "$2")"
DTB="$(realpath "$3")"
OUTPUT="${4:-image.fit}"

MKIMAGE="${MKIMAGE:-mkimage}"

for f in "$KERNEL" "$INITRAMFS" "$DTB"; do
    if [ ! -f "$f" ]; then
        echo "Error: file not found: $f" >&2
        exit 1
    fi
done

if ! command -v "$MKIMAGE" >/dev/null 2>&1; then
    echo "Error: mkimage not found"
    echo "Install u-boot-tools or set MKIMAGE=/path/to/mkimage"
    exit 1
fi

ITS="$(mktemp --suffix=.its)"
trap 'rm -f "$ITS"' EXIT

cat > "$ITS" <<EOF
/dts-v1/;

/ {
    description = "U-boot FIT image for visionfive2";

    #address-cells = <2>;

    images {
        vmlinux {
            description = "vmlinux";
            data = /incbin/("${KERNEL}");

            type = "kernel";
            arch = "riscv";
            os = "linux";

            load = <0x0 0x40200000>;
            entry = <0x0 0x40200000>;

            compression = "gzip";
        };

        ramdisk {
            description = "initramfs";
            data = /incbin/("${INITRAMFS}");

            type = "ramdisk";
            arch = "riscv";
            os = "linux";

            load = <0x0 0x46100000>;

            compression = "none";
        };

        fdt {
            description = "VisionFive 2 DTB";
            data = /incbin/("${DTB}");

            type = "flat_dt";
            arch = "riscv";

            load = <0x0 0x46000000>;

            compression = "none";

            hash-1 {
                algo = "sha256";
            };
        };
    };

    configurations {
        default = "config-1";

        config-1 {
            description = "visionfive2 with opensbi";

            kernel = "vmlinux";
            fdt = "fdt";
            loadables = "ramdisk";
        };
    };
};
EOF

echo "Creating VisionFive 2 FIT image"
echo "  Kernel:    $KERNEL"
echo "  Initramfs: $INITRAMFS"
echo "  DTB:       $DTB"
echo "  Output:    $OUTPUT"
echo

"$MKIMAGE" \
    -f "$ITS" \
    -A riscv \
    -O linux \
    -T flat_dt \
    "$OUTPUT"

echo
echo "FIT created successfully:"
ls -lh "$OUTPUT"

echo
echo "FIT contents:"
"$MKIMAGE" -l "$OUTPUT"
