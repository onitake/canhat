
# Where to find dtc.
# Leave empty if dtc is on the $PATH.
DTCPATH :=
# Where to find the EEPROM utilities.
# See https://github.com/raspberrypi/hats/tree/master/eepromutils for more info.
# Leave empty if they are in the $PATH
EEPROMUTILS := hats/eepromutils/
# The type of EEPROM chip.
# Note that only certain chips are supported.
# Refer to https://github.com/raspberrypi/hats/blob/master/designguide.md
# for more info.
FLASHTYPE := 24c32
# The i2c bus where the EEPROM is found.
# 0 = i2c-0
FLASHBUS := 0
# The address of the flash on the i2c bus.
# Refer to the EEPROM data sheet for details.
# The circuit pulls A2..A0 to ground, which sets bits 3..1 of the device
# address to 0. Bit 0 is the read/write bit.
FLASHADDRESS := a0

.PHONY: all clean flash

all: canhat.eep

clean:
	rm -f *.eep *.dtbo

flash: canhat.eep
	$(EEPROMUTILS)eepflash.sh -w -f=$< -t=$(FLASHTYPE) -d=$(FLASHBUS) -a=$(FLASHADDRESS)

canhat.eep: eeprom_settings.txt canhat-overlay.dtbo
	$(EEPROMUTILS)eepmake $< $@ canhat-overlay.dtbo

canhat-overlay.dtbo: canhat-overlay.dts
	$(DTCPATH)dtc -I dts -O dtb -o $@ $^
