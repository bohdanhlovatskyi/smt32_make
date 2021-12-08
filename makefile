TARGET = main.elf
CC = arm-none-eabi-gcc

# -------- project's output directories ----------------
BIN_DIR = bin
OBJ_DIR = obj
dir_guard=@mkdir -p $(@D)

# ------------------- compiler flags ---------------------
CFLAGS = -mcpu=cortex-m4 -std=gnu11 -g3
CFLAGS += -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage
# CFLAGS += -MMD -MP -MF # here aftter MF should go name of file we want the information to store (".d")
#					- MT # same here but with ".o"
CFLAGS += -DDEBUG -DUSE_HAL_DRIVER -DSTM32F303xC
CFLAGS += --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb

# ------------------- include dirs -----------------------
INC = -I./Core/Inc
INC += -I./Drivers/CMSIS/Include
INC += -I./Drivers/CMSIS/Device/ST/STM32F3xx/Include
INC += -I./Drivers/STM32F3xx_HAL_Driver/Inc

# !!! adding the inlcude dirs paths to the compiler verboses
CFLAGS += $(INC)

# ------------------- linker flags -----------------------
# here we should use linking script that will specify the memory layout and so on
LD_SCRIPT = ./STM32F303VCTX_FLASH.ld
LFLAGS = -mcpu=cortex-m4 -Wl,--gc-sections -Wl,-T$(LD_SCRIPT) --specs=nosys.specs -Wl,-Map="counter.map" -Wl,--gc-sections -static -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -Wl,--end-group

# ------------------- source files ----------------------
SRC_FILES = $(wildcard Core/Src/*.c)
SRC_FILES += $(wildcard Drivers/STM32F3xx_HAL_Driver/Src/*.c)
ASM_FILES = $(wildcard Core/Startup/*.s)

# simply rename the source files to get the object files we need
cobj = $(SRC_FILES:%.c=$(OBJ_DIR)/%.o)
asm = $(ASM_FILES:%.s=$(OBJ_DIR)/%.o)
aobj = $(asm) $(cobj)
$(info Files to compile: $(aobj))
$(info )

# -------------------------------------------------------
# ----------- Acttually making the target ---------------
# -------------------------------------------------------

.PHONY: clean flash

all: $(TARGET)

# compilation target rule
%.elf: $(aobj)
	$(dir_guard)
	$(info -----------------------------------------------------)
	$(info ----------- IT IS LINKING TIME, HALLELUJAH ----------)
	$(info -----------------------------------------------------)
	$(info )
	$(CC) $(CFLAGS) $(LFLAGS) $(aobj) -o $@

# rule to compile the files specified in the sources
$(cobj): $(OBJ_DIR)/%.o: %.c
$(asm): $(OBJ_DIR)/%.o: %.s
$(aobj):
	$(dir_guard)
	$(info "[CC] $@")
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf bin 
	rm -rf obj
	rm *.bin
	rm *.elf

flash:
	arm-none-eabi-objcopy -O binary main.elf main.bin    
	st-flash write main.bin 0x8000000
