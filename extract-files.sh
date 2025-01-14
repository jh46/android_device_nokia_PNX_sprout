#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=PNX_sprout
VENDOR=nokia

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

export TARGET_ENABLE_CHECKELF=false

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        product/etc/permissions/vendor.qti.hardware.data.connection-V1.0-java.xml | product/etc/permissions/vendor.qti.hardware.data.connection-V1.1-java.xml)
            [ "$2" = "" ] && return 0
            sed -i 's/version="2.0"/version="1.0"/g' "${2}"
            ;;
        vendor/etc/data/dsi_config.xml|vendor/etc/data/netmgr_config.xml)
            [ "$2" = "" ] && return 0
            fix_xml "${2}"
            ;;
        vendor/etc/nfcee_access.xml)
            [ "$2" = "" ] && return 0
            sed -i -e 's|xliff=\"urn:oasis:names:tc:xliff:document:1.2|android=\"http:\/\/schemas.android.com\/apk\/res\/android|' "${2}"
            ;;
        vendor/lib/hw/camera.qcom.so | vendor/lib64/hw/camera.qcom.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --remove-needed "libMegviiFacepp.so" "${2}"
            "${PATCHELF}" --remove-needed "libmegface-new.so" "${2}"
            "${PATCHELF}" --add-needed "libshim_megvii.so" "${2}"
            ;;
        system_ext/lib64/lib-imsvideocodec.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libshim_imsvideocodec.so" "${2}"
            ;;
        vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0.so|vendor/lib64/vendor.egistec.hardware.fingerprint@2.0.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --remove-needed "libhidlbase.so" "${2}"
            sed -i "s/libhidltransport.so/libhidlbase-v32.so\x00/" "${2}"
            ;;
        vendor/lib64/libwvhidl.so|vendor/lib64/mediadrm/libwvdrmengine.so)
            [ "$2" = "" ] && return 0
            if ! "${PATCHELF}" --print-needed "${2}" | grep -q "libcrypto_shim.so"; then
                "${PATCHELF}" --add-needed "libcrypto_shim.so" "${2}"
            fi
            ;;
        vendor/bin/hw/android.hardware.biometrics.fingerprint@2.1-service-ets)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
            ;;
        vendor/bin/pm-service)
            [ "$2" = "" ] && return 0
            grep -q libutils-v33.so "${2}" || "${PATCHELF}" --add-needed "libutils-v33.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
