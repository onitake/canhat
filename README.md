# CAN HAT for Raspberry Pi 2/3+

Look! A hat! :tophat:

This little board extends the Raspberry Pi with a CAN interface, a 5V regulator
to supply the Pi with power and a pin header to access some GPIO lines.

![canhat](https://user-images.githubusercontent.com/371687/87884297-e85cc180-ca0d-11ea-8d3f-9ff7ddcb1a1c.png)

## Specifications

### Mechanical

The board outline and component placement conform to the [Micro HAT specification]
and the [Add-On Boards and HATs] specification.

Instead of the usual DB9 connector found on many CAN interfaces, this one has
screw terminals for easier wiring and a smaller footprint. There is a separate
version in the db9 branch that includes two DB9 connectors instead. These
can even be connected to the voltage regulator, if the Pi should be powered
from the bus.

If you intend to adopt the CAN HAT in an industrial environment, replace the
screw terminals with more robust connectors, or make sure the wires are firmly
connected. You should also mount the HAT to the Raspberry Pi using spacers
and M2.5 screws.

### Electronics

The circuit is built around the Microchip MCP2515 CAN Interface Controller
and a CAN transceiver IC. Since the Raspberry Pi and the controller are
powered by 3.3V, you should use a CAN transceiver that works with 3.3V logic
levels.

It is highly recommended to use a 5V CAN transceiver with a separate 3.3V
input to drive the logic circuits. Texas Instruments SN65HVD541 is such a
transceiver. To use it, solver a 0Ω resistor or wire into R7.

If you prefer to use a 3.3V transceiver instead, you don't need R7. See
[Overview of 3.3V CAN Transceivers] for more information on 3.3V CAN bus
operation.

Some transceivers also support powering down the bus by pulling pin 5 low.
If you solder a 0Ω resistor into R6 and leave out R7, you can control
power to the bus via GPIO22. Note this may "abuse" the GPIO pin for
powering some of the transceiver's logic, so make sure you do not exceed
the maximum drive current of the GPIO pin.

The MCP2515 is then connected to the SPI0 port on the Raspberry Pi header.

To reduce interference on the CAN bus, tuned microstrips were used to
connect the CAN transceiver to the terminals on the PCB. The differential
impedance is matched to 60Ω. For added fun, the pair length is also matched,
despite the comparatively low signal speed of the CAN bus (1MHz).

Aside from the CAN part, an additional ID EEPROM was added to conform to
the HAT specification. JP1 is only needed to program the EEPROM. The part can
be left out if desired, and the connection be made by other means.

R5 controls the slope of the signals on the CAN bus. A 0Ω resistor should be
soldered for maximum performance. Some transceivers use the pin for other
purposes, refer to the respective data sheet if you don't use the
recommended transceiver.

The left side of the board is populated with a 6-24V to 5V step-down converter.
If the Raspberry Pi is powered via USB, the components for this converter
should not be soldered, or at least not be connected to a power source.

:warning: **Do not connect a power source to both the Raspberry Pi and J5!**

Note that the AP63205 regulator is rated for a maximum current of 2A.
The [Add-On Boards and HATs] specification recommends at least 2.5A, but 2A
is normally sufficient unless a lot of peripherals and USB devices are used.
The Raspberry Pi 3 and the CAN HAT will only draw a few hundred mA when using
Ethernet and the CAN bus and no other external peripherals.

It is also possible to power the 5V rail directly from the J5 connector.
Solder a 0Ω jumper into R10 to achieve this and leave out F2, D7, U4, L1, C9,
C10, C12 and C13. For additional voltage stability on the bus transceiver,
C12 can be added if desired.

:warning: **Only solder R10 if you want to power the Raspbery Pi by J5 directly!**

When using the step-down converter, the input polarity is protected by D7.
However, because the negative terminal is directly connected to the ground
plane and the CAN bus ground, polarity reversal may still lead to a
short-circuit via other bus components. Avoid connecting a power source in
reverse.

## Cabling and Termination

It is recommended to use twisted pair or star quad cabling to connect other
CAN nodes. With star quad cables, connect opposite wires together to the
same terminal for better noise resistance.

Use shielded cable if possible and make sure all CAN bus componentes share
a common ground. To facilitate connecting the bus ground, there is a ground
terminal for each CAN connection, marked with an earth sign (⏚).

If the Raspberry Pi is the last node in a chain, attach a 120Ω termination
resistor to the terminals marked with a downwards arrow (↓).

:warning: **Note the polarity on the terminals! CAN does not support swapping
the H/L pins.**

## GPIO Pins

For added convenience, 4 Raspberry Pi GPIO pins are available via an optional
connector on the board. If you would like to use them, solder the J3 header.

R11, R12, R13, R14 are optional pull-up resistors. When using the GPIO lines
as external inputs, you can solder 1k-10k resistors into them. A ground pin
for toggling the logic level is available on the pin header.

The 4 GPIO lines are: GPIO19, GPIO20, GPIO21, GPIO26. GPIO19-21 are also
available for SPI, but this requires custom configuration and is outside
the scope of the CAN HAT.

Note: To actually use the GPIO pins, you must edit eeprom_settings.txt to
suit your custom configuration, or enable the GPIO pins from user space
after booting the Raspberry Pi.

## Integration

The built-in ID EEPROM contains device information according to the
[HAT ID EEPROM Specification], as well as a Device Tree blob. This allows for
automatic configuration when Linux boots.

The EEPROM can be programmed in the field by shorting the jumper JP1 and
flashing with the help of [eepromutils].

The provided Makefile will compile a DeviceTree overlay and the device descriptor
into an EEPROM image. To build the image, type:

    make

To flash the image to the attached EEPROM, you first need to allow access to
the first I²C bus. On the Raspberry Pi, this bus is used for several system
components, and hidden by default to avoid accidental access. Put the following
line into `/boot/config.txt`:

    dtparam=i2c_vc=on

Short the write protection jumper, reboot, and flash the EEPROM:

    sudo make flash

Remove the line from `/boot/config.txt` and the jumper, then reboot.

The preconfigured I²C bus and and device address correspond with the AT24C32E
chip on the HAT. Change them in the Makefile if you use a different device.

The CAN bus should then appear automatically as network device `can0`.

## Compatibility

The HAT is fully compatible with the Linux drivers for the MCP2551.
Refer to the [CAN bus on raspberry pi quick guide] for more information
on how to configure the device manually.

This may be necessary on older Raspberry Pi boards that don't support the
ID EEPROM feature.

During testing, you can use the following command to quickly load the driver
without the ID EEPROM:

    sudo dtoverlay mcp2515-can0 oscillator=16000000 interrupt=12

Note that the interface still needs to be brought up like a network device:

    sudo ip link set can0 up type can bitrate 125000 loopback off sample-point 0.75

This configures a line speed of 1MHz. Commonly supported rates are 125kHz or
1MHz. Choose according to your other CAN components and wiring quality.

## Links

[Add-On Boards and HATs]: https://github.com/raspberrypi/hats
[Micro HAT Specification]: https://github.com/raspberrypi/hats/blob/master/uhat-board-mechanical.pdf
[HAT ID EEPROM Specification]: https://github.com/raspberrypi/hats/blob/master/eeprom-format.md
[CAN bus on raspberry pi quick guide]: https://www.raspberrypi.org/forums/viewtopic.php?t=141052
[eepromutils]: https://github.com/raspberrypi/hats/tree/master/eepromutils
[Overview of 3.3V CAN Transceivers]: http://www.ti.com/lit/an/slla337/slla337.pdf

### Data Sheets

* [Microchip MCP2515 CAN Interface Controller](https://www.microchip.com/wwwproducts/en/en010406)
* [Microchip MCP2551](http://ww1.microchip.com/downloads/en/devicedoc/21667e.pdf)
* [Texas Instruments SN65HVD234 3.3 V CAN Transceiver](http://www.ti.com/product/SN65HVD234)
* [Microchip AT24C32E 32Kbit Serial EEPROM](https://www.microchip.com/wwwproducts/en/AT24C32E)
* [Diodes Inc AP63205 Buck Regulator](https://www.diodes.com/assets/Datasheets/AP63200-AP63201-AP63203-AP63205.pdf)

## Legal

This circuit, schematics, board layouts and accompanying documentation is
Copyright © 2019-2020 by Gregor Riepl

You may use it under the terms of the CERN Open Hardware Licence, version v1.2.

Raspberry Pi is a trademark of the Raspberry Pi Foundation.
