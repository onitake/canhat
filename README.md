# CAN HAT for Raspberry Pi 2/3+

Look! A hat!

This little board extends the Raspberry Pi with a CAN interface.

## Specifications

### Mechanical

The board layout is built according to the [Micro HAT specification].

Additionally, the complete [Add-On Boards and HATs] specs apply.

### Electronics

Only standard components from Microchip Semiconductor were used, these can be
ordered from any common parts supplier for a few dollars.

The circuit is based on similar designs found on the internet: A CAN
controller connected to the SPI bus of the Raspberry Pi and a CAN
transceiver that also provides ESD protection and line isolation.

Note that the controller runs on 3.3V, because the Raspberry Pi requires
3.3V logic levels.

The transceiver is powered from the 5V rail, but connected directly to the
controller without level shifters. It is expected (but not guaranteed!) that
the controller can handle 5V logic levels on the RX/TX lines.

## Features

Instead of the usual DB9 connector found on many boards, this one has two
screw terminals, for easier wiring and a smaller footprint. The disadvantage
of this is less mechanical stability. If you intend to adopt the CAN HAT
in an industrial environment, replace the screw terminals with more robust
connectors, or make sure the cables are firmly attached.

It is recommended to use twisted pair or star quad cabling to connect other
CAN nodes. With star quad cables, connect opposite wires to the
same terminal for better noise resitance.

If the Raspberry Pi is the last node in a chain, attach a 120Ω termination
resistor to the unused terminal.

An ID EEPROM is also built in, containing information according to the
[HAT ID EEPROM Specification], including a Device Tree blob. This EEPROM
can be programmed in the field by shorting the jumper JP1 and flashing
with the help of the [eepromutils].

## Compatibility

The HAT is fully compatible with the Linux drivers for the MCP2551.
Refer to the [CAN bus on raspberry pi quick guide] for more information
on how to configure the device manually.

:warning: **Work in progress**

This is a full-featured HAT and supports automatic configuration via
the built-in ID EEPROM.

If you own a newer Raspberry Pi board, it should read out the board
specification and DeviceTree blob from the EEPROM and auto-configure
the CAN device.

Note that the interface still needs to be brought up like a network device:

    ip link set can0 up type can bitrate 1000000

This configures a line speed of 1MHz. You probably shouldn't go too high,
but lower speeds will work fine.

## Links

[Add-On Boards and HATs]: https://github.com/raspberrypi/hats
[Micro HAT Specification]: https://github.com/raspberrypi/hats/blob/master/uhat-board-mechanical.pdf
[HAT ID EEPROM Specification]: https://github.com/raspberrypi/hats/blob/master/eeprom-format.md
[CAN bus on raspberry pi quick guide]: https://www.raspberrypi.org/forums/viewtopic.php?t=141052
[eepromutils]: https://github.com/raspberrypi/hats/tree/master/eepromutils

### Data Sheets

* [Microchip MCP2515 CAN Interface Controller](https://www.microchip.com/wwwproducts/en/en010406)
* [Microchip MCP2551 High-Speed CAN Transceiver](https://www.microchip.com/wwwproducts/en/MCP2551)
* [Microchip AT24C32E 32Kbit Serial EEPROM](https://www.microchip.com/wwwproducts/en/AT24C32E)

## Copyright

This circuit, schematics, board layouts and accompanying documentation is
Copyright © 2019 by Gregor Riepl

You may use it under terms of the CERN Open Hardware Licence, version v1.2.
