# CAN HAT for Raspberry Pi Zero

Look! A hat! :tophat:

This little board extends the Raspberry Pi with a CAN interface, a 5V regulator
to supply the Pi with power and a pin header to access some GPIO lines.

![canhat](https://github.com/onitake/canhat/assets/371687/27ac0d41-902f-49d6-9be3-aae559b2bb56)


## Specifications

### Mechanical

The board outline and component placement conform to the [Micro HAT specification]
and the [Add-On Boards and HATs] specification. It is designed to fit the
Raspberry Pi Zero, but can also be mounted to other models. (Pi 2, 3, 4, ...)

Instead of the usual DB9 connector found on many CAN interface boards, the
CAN HAT has terminal blocks for easier wiring and a smaller footprint.

For added stability, 11mm spacers should be mounted between the Pi and the HAT.

### Electronics

The circuit is built around the Microchip MCP2515 CAN Interface Controller,
connected to SPI port 0 on the Raspberry Pi, and a CAN transceiver IC.

It is highly recommended to use a 5V CAN transceiver with a separate 3.3V
input for the RX/TX pins, such as Texas Instruments SN65HVD541.
When using a different transceiver without split voltage, the voltage inputs
must be reconfigured through solder bridges JP3 and JP4.

The SN65HVD541 also supports disabling the transceiver through pin 8.
This pin is connected to ground via JP2 and 0Ω resistor R5 by default,
which enables the transceiver at full speed. With JP2, it can be connected
to Raspberry Pi pin GPIO22, which makes it controllable. Not that this is not
supported by the MCP2515 device drivers and must be implemented manually.
R5 is useful for transceivers that support slope control, but this is not
available in the SN65HVD541.

See the section "Transceiver Configuration" below.

To reduce interference on the CAN bus, tuned microstrips were used to
connect the CAN transceiver to the terminals on the PCB. The differential
impedance is matched to 60Ω. For added fun, the pair length is also matched
with meanders.

Aside from the CAN interface part, an additional ID EEPROM ensures conformance
with the HAT specification. JP1 is only needed to program the EEPROM. The part
can be left out if desired, and the connection be made by other means, such as
a screwdriver or a temporary solder bridge.

The left side of the board is populated with a 6-24V to 5V step-down converter.
If the Raspberry Pi is powered via USB, the components for this converter
should not be soldered, or at least not be connected to a power source.
It's also possible to power the Rasberry Pi from a 5V source via this
connector directly. See the section "Power Options" below.

Note that the AP63205 regulator is rated for a maximum current of 2A.
The [Add-On Boards and HATs] specification recommends at least 2.5A, but 2A
is normally sufficient unless a lot of peripherals and USB devices are used.
The Raspberry Pi 3 and the CAN HAT will only draw a few hundred mA when using
Ethernet and the CAN bus and no other external peripherals.

Overvoltage protection is done through the TVS diode D1, but note it cannot
handle overcurrent. The fuse may not react quickly enough if a large amount
of energy is sent through D1, and it may still fail to protect the circuit.

### Transceiver Configuration

The recommended transceiver SN65HVDA541 has separate voltage inputs for
the logic and the CAN transceiver. In the default configuration, the logic
is connected to 3.3V and the transceiver to 5V.

If transceiver power control should be possible from the Raspberry Pi,
cut the solder bridge from JP2 (IOCTL) pins 1-2 and connect 2-3 instead.
Note that this is not supported by the driver and must be implemented
separately.

For over transceivers, the 3.3V power supply should be disconnected by
cutting JP3 (3VIO) and choosing an appropriate voltage on JP4 (VBUS).
1-2 is 5V and 2-3 is 3.3V. Note that there is no input voltage protection
on the MCP2515, which is powered from 3.3V. Choosing a 5V part may result
in damage to the MCP2515.

If the chosen transceiver supports slope control on pin 8, JP2 should be
left in position 1-2 and the 0Ω resistor R5 should be replaced with an
appropriate value. Refer to the transceiver's data sheet for more information.

### Power Options

:warning: **Do not supply power to the Raspberry Pi and J5 at the same time!**

The CAN hat can backpower the Raspberry Pi, but it can also be powered by it.

The following configurations are supported:

#### All power on Raspberry Pi

If you're already powering the Raspberry Pi from a 5V source (such as USB),
you don't need the regulator circuit on the CAN hat.

Leave out the parts J5, F2, D1, D2, C9, U4, C10, L1, C12 and C13.

#### 5V power on CAN hat

In this configuration, 5V is delivered directly from the hat to the RPi.

Leave out the parts F2, D1, D2, C9, U4, C10, L1, C12 and C13, but connect
the solder bridge JP5.

#### 12V power on CAN hat

If you only have a 12V power source available, you can populate the step-down
voltage regulator on the CAN hat, which will convert the input to 5V and feed
it to the Raspberry Pi.

Keep the solder bridge JP5 disconnected, or you may damage your Raspberry Pi!

Input polarity reversal and overvoltage is protected by D2 and D1, but you
should still make sure not to swap the polarity on the 12V input.
Failure to do so could lead to a short-circuit via other bus components.

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
Copyright © 2019-2022 by Gregor Riepl

You may use it under the terms of the CERN Open Hardware Licence, version v1.2.

Raspberry Pi is a trademark of the Raspberry Pi Foundation.
