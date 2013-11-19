LOCAL_PATH:= $(call my-dir)


include $(CLEAR_VARS)
LOCAL_MODULE := rtmp
PATH_RTMP := rtmpdump/librtmp
LOCAL_CFLAGS := -DRTMPDUMP_VERSION=v2.4 -DNO_CRYPTO
LOCAL_LDLIBS := -llog
LOCAL_SRC_FILES := log.c \
$(PATH_RTMP)/rtmp.c \
$(PATH_RTMP)/amf.c \
$(PATH_RTMP)/hashswf.c \
$(PATH_RTMP)/parseurl.c
					
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/rtmpdump
include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE := rtmpdump
LOCAL_SRC_FILES := rtmpdump-jni.c
LOCAL_SHARED_LIBRARIES := rtmp
include $(BUILD_SHARED_LIBRARY)

SPEEX	:= speex-1.2rc1
include $(CLEAR_VARS)
LOCAL_MODULE    := speex_jni
LOCAL_SRC_FILES := speex_jni.cpp \
		$(SPEEX)/libspeex/speex.c \
		$(SPEEX)/libspeex/speex_callbacks.c \
		$(SPEEX)/libspeex/bits.c \
		$(SPEEX)/libspeex/modes.c \
		$(SPEEX)/libspeex/nb_celp.c \
		$(SPEEX)/libspeex/exc_20_32_table.c \
		$(SPEEX)/libspeex/exc_5_256_table.c \
		$(SPEEX)/libspeex/exc_5_64_table.c \
		$(SPEEX)/libspeex/exc_8_128_table.c \
		$(SPEEX)/libspeex/exc_10_32_table.c \
		$(SPEEX)/libspeex/exc_10_16_table.c \
		$(SPEEX)/libspeex/filters.c \
		$(SPEEX)/libspeex/quant_lsp.c \
		$(SPEEX)/libspeex/ltp.c \
		$(SPEEX)/libspeex/lpc.c \
		$(SPEEX)/libspeex/lsp.c \
		$(SPEEX)/libspeex/vbr.c \
		$(SPEEX)/libspeex/gain_table.c \
		$(SPEEX)/libspeex/gain_table_lbr.c \
		$(SPEEX)/libspeex/lsp_tables_nb.c \
		$(SPEEX)/libspeex/cb_search.c \
		$(SPEEX)/libspeex/vq.c \
		$(SPEEX)/libspeex/window.c \
		$(SPEEX)/libspeex/high_lsp_tables.c

LOCAL_C_INCLUDES += 
LOCAL_CFLAGS = -DFIXED_POINT -DEXPORT="" -UHAVE_CONFIG_H -I$(LOCAL_PATH)/$(SPEEX)/include
include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)
include $(LOCAL_PATH)/aac/Config.mk

LOCAL_MODULE := aac-encoder

ENC_SRC := aac/src

LOCAL_C_INCLUDES := $(LOCAL_PATH)/aac/inc

LOCAL_SRC_FILES = \
    aac-enc.c \
    $(ENC_SRC)/cmnMemory.c \
    aac/basic_op/basicop2.c \
    aac/basic_op/oper_32b.c \
    $(ENC_SRC)/aac_rom.c \
    $(ENC_SRC)/aacenc.c \
    $(ENC_SRC)/aacenc_core.c \
    $(ENC_SRC)/adj_thr.c \
    $(ENC_SRC)/band_nrg.c \
    $(ENC_SRC)/bit_cnt.c \
    $(ENC_SRC)/bitbuffer.c \
    $(ENC_SRC)/bitenc.c \
    $(ENC_SRC)/block_switch.c \
    $(ENC_SRC)/channel_map.c \
    $(ENC_SRC)/dyn_bits.c \
    $(ENC_SRC)/grp_data.c \
    $(ENC_SRC)/interface.c \
    $(ENC_SRC)/line_pe.c \
    $(ENC_SRC)/memalign.c \
    $(ENC_SRC)/ms_stereo.c \
    $(ENC_SRC)/pre_echo_control.c \
    $(ENC_SRC)/psy_configuration.c \
    $(ENC_SRC)/psy_main.c \
    $(ENC_SRC)/qc_main.c \
    $(ENC_SRC)/quantize.c \
    $(ENC_SRC)/sf_estim.c \
    $(ENC_SRC)/spreading.c \
    $(ENC_SRC)/stat_bits.c \
    $(ENC_SRC)/tns.c \
    $(ENC_SRC)/transform.c

ifeq ($(VOTT), v5)
LOCAL_SRC_FILES += \
	$(ENC_SRC)/asm/ARMV5E/AutoCorrelation_v5.s \
	$(ENC_SRC)/asm/ARMV5E/band_nrg_v5.s \
	$(ENC_SRC)/asm/ARMV5E/CalcWindowEnergy_v5.s \
	$(ENC_SRC)/asm/ARMV5E/PrePostMDCT_v5.s \
	$(ENC_SRC)/asm/ARMV5E/R4R8First_v5.s \
	$(ENC_SRC)/asm/ARMV5E/Radix4FFT_v5.s
endif

ifeq ($(VOTT), v7)
LOCAL_SRC_FILES += \
	$(ENC_SRC)/asm/ARMV5E/AutoCorrelation_v5.s \
	$(ENC_SRC)/asm/ARMV5E/band_nrg_v5.s \
	$(ENC_SRC)/asm/ARMV5E/CalcWindowEnergy_v5.s \
	$(ENC_SRC)/asm/ARMV7/PrePostMDCT_v7.s \
	$(ENC_SRC)/asm/ARMV7/R4R8First_v7.s \
	$(ENC_SRC)/asm/ARMV7/Radix4FFT_v7.s
endif

LOCAL_ARM_MODE := arm

LOCAL_LDLIBS := -llog

LOCAL_STATIC_LIBRARIES := 
LOCAL_SHARED_LIBRARIES :=

LOCAL_CFLAGS := $(VO_CFLAGS)

ifeq ($(VOTT), v5)
LOCAL_CFLAGS += -DARMV5E -DARM_INASM -DARMV5_INASM
LOCAL_C_INCLUDES += $(ENC_SRC)/asm/ARMV5E
endif

ifeq ($(VOTT), v7)
LOCAL_CFLAGS += -DARMV5E -DARMV7Neon -DARM_INASM -DARMV5_INASM -DARMV6_INASM
LOCAL_C_INCLUDES += $(ENC_SRC)/asm/ARMV5E
LOCAL_C_INCLUDES += $(ENC_SRC)/asm/ARMV7
endif

include $(BUILD_SHARED_LIBRARY)

