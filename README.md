# CAN HAT for Raspberry Pi 2/3+

Look! A hat! :tophat:

This little board extends the Raspberry Pi with a CAN interface and screw
terminals for external 5V power.

![board](https://user-images.githubusercontent.com/371687/57573365-f2a52800-7426-11e9-87c4-eca6107b6ef7.jpg)

## Specifications

### Mechanical

The board outline and component placement conform to the [Micro HAT specification]
and the [Add-On Boards and HATs] specification.

Instead of the usual DB9 connector found on many boards, this one has
screw terminals for easier wiring and a smaller footprint.

If you intend to adopt the CAN HAT in an industrial environment, replace the
screw terminals with more robust connectors, or make sure the wires are firmly
attached. You should also screw HAT and Raspberry Pi together using spacers and
M2.5 screws.

### Electronics

The circuit is built around the Microchip MCP2515 CAN Interface Controller,
but uses a Texas Instruments SN65HVD234 3.3 V CAN Transceiver to allow for full
3.3V operation. While driving the CAN bus with 3.3V instead of the usual 5V
will work fine, connecting 5V parts to the MCP2515 may cause damage, as it can
only handle logic levels about 1V above supply voltage.

See [Overview of 3.3V CAN Transceivers] for more information on 3.3V operation.

The MCP2515 is then connected to the SPI0 port on the Raspberry Pi header.

To reduce interference on the CAN bus, tuned microstrips were used to
connect the CAN transceiver to the terminals on the PCB. The differential
impedance is matched to 120Ω.

Aside from the CAN part, an additional ID EEPROM was added to conform to
the HAT specification. JP1 is only needed to program the EEPROM - for a
smaller PCB footprint, the pads can also be connected by other means.
The connection can be removed after the EEPROM has been programmed.

R5 controls the slop of the signals on the CAN bus. A 0Ω resistor should be
soldered for maximum performance.

The filter capacitor C3 is optional, but recommended.

C5 and J3 are intended to supply 5V power to the Raspberry Pi. They can be
left out if the Raspberry Pi is powered via USB.

## Cabling and Termination

It is recommended to use twisted pair or star quad cabling to connect other
CAN nodes. With star quad cables, connect opposite wires to the
same terminal for better noise resistance.

If the Raspberry Pi is the last node in a chain, attach a 120Ω termination
resistor to the unused terminal.

## Integration

The built-in ID EEPROM contains device information according to the
[HAT ID EEPROM Specification], as well as a Device Tree blob. This allows for
automatic configuration when Linux boots.

The EEPROM can be programmed in the field by shorting the jumper JP1 and
flashing with the help of [eepromutils].

The provided Makefile will compile a DeviceTree overlay and the device descriptor
into an EEPROM image. To build the image, type:

    make

To flash the image to the attached EEPROM, type:

    make flash

You might need to run this as root.

The preconfigured I²C bus and and device address correspond with the AT24C32E
chip on the HAT. Change them in the Makefile if you use a different device.

After the device descriptor is flashed, you can disconnect JP1 and reboot.
The CAN bus should then appear as network device `can0`.

## Compatibility

The HAT is fully compatible with the Linux drivers for the MCP2551.
Refer to the [CAN bus on raspberry pi quick guide] for more information
on how to configure the device manually.

This may be necessary on older Raspberry Pi boards that don't support the
ID EEPROM feature.

Note that the interface still needs to be brought up like a network device:

    ip link set can0 up type can bitrate 1000000

This configures a line speed of 1MHz. You probably shouldn't go too high,
but lower speeds will work fine too.

## Links

[Add-On Boards and HATs]: https://github.com/raspberrypi/hats
[Micro HAT Specification]: https://github.com/raspberrypi/hats/blob/master/uhat-board-mechanical.pdf
[HAT ID EEPROM Specification]: https://github.com/raspberrypi/hats/blob/master/eeprom-format.md
[CAN bus on raspberry pi quick guide]: https://www.raspberrypi.org/forums/viewtopic.php?t=141052
[eepromutils]: https://github.com/raspberrypi/hats/tree/master/eepromutils
[Overview of 3.3V CAN Transceivers]: http://www.ti.com/lit/an/slla337/slla337.pdf

### Data Sheets

* [Microchip MCP2515 CAN Interface Controller](https://www.microchip.com/wwwproducts/en/en010406)
* [Texas Instruments SN65HVD234 3.3 V CAN Transceiver](http://www.ti.com/product/SN65HVD234)
* [Microchip AT24C32E 32Kbit Serial EEPROM](https://www.microchip.com/wwwproducts/en/AT24C32E)

## Copyright

This circuit, schematics, board layouts and accompanying documentation is
Copyright © 2019 by Gregor Riepl

You may use it under terms of the CERN Open Hardware Licence, version v1.2.
