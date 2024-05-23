# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common LineageOS stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

TARGET_BOOT_ANIMATION_RES := 1080

# Inherit from PNX_sprout device
$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_DEVICE := PNX_sprout
PRODUCT_NAME := lineage_PNX_sprout
PRODUCT_BRAND := Nokia
PRODUCT_MODEL := Nokia 8.1
PRODUCT_MANUFACTURER := HMD Global
PRODUCT_RELEASE_NAME := PNX_sprout

PRODUCT_GMS_CLIENTID_BASE := android-hmd-rev2

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_DEVICE=PNX_sprout \
    PRODUCT_NAME=Phoenix_00WW \
    PRIVATE_BUILD_DESC="PNX_00WW_FIH-user 11 00WW_6_21F 00WW_6_21F release-keys"

# Set BUILD_FINGERPRINT variable to be picked up by both system and vendor build.prop
BUILD_FINGERPRINT := Nokia/Phoenix_00WW/PNX_sprout:11/RKQ1.200906.002/00WW_6_21F:user/release-keys
