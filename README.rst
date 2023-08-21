OpenFrame Example
=====================================

OpenFrame Example is a user project designed to showcase how to use Caravel's OpenFrame feature, integrating multiple IPs such as UART, SPI Master, Counter Timers, and more. Additionally, the project includes a "housekeeping" IP, which can be accessed using SPI for configuration and chip information. This README provides essential information about the project's features, IP configurations, and usage instructions.

Table of Contents
-----------------
- IP Overview
- Building
- Usage
  
  - UART
  - Counter Timer 0
  - Counter Timer 1
  - SPI Master
  - Housekeeping IP
- Interrupt System
- Contributing
- License

IP Overview
-----------

The OpenFrame Example project is built around a picoV32 CPU, which utilizes the Wishbone interface to communicate with various IPs. The project includes the following IPs and their respective base addresses:

- RAM: 0x00000000
- FLASH: 0x10000000
- UART: 0x20000000
- GPIO: 0x21000000
- Counter Timer 0: 0x22000000
- Counter Timer 1: 0x23000000
- SPI Master: 0x24000000
- GPIO Vector: 0x25000000
- Flash Control Configuration: 0x2D000000
- Debug Registers Configuration: 0x41000000

Additionally, the project includes a "housekeeping" IP that can be accessed using SPI for configuration and chip information. This IP is not accessible by the CPU Wishbone.

Building
--------

For instructions on building the OpenFrame Example project, please refer to the [README](./README) containing the build notes.


Usage
-----

UART
~~~~

.. list-table:: UART IP Configuration
   :widths: 20 10 50
   :header-rows: 1

   * - Address
     - Bit
     - Description
   * - 0x20000008
     - -
     - Enable UART (1) / Disable UART (0)
   * - 0x20000004
     - -
     - Read/write data through UART
   * - 0x20000000
     - -
     - Modify baud rate

Counter Timer 0
~~~~~~~~~~~~~~~

.. list-table:: Counter Timer 0 Configuration
   :widths: 20 10 50
   :header-rows: 1

   * - Address
     - Bit
     - Description
   * - 0x22000000
     - 0
     - Enable timer
   * - 0x22000000
     - 1
     - Configure one-shot (1) / periodic (0) mode
   * - 0x22000000
     - 2
     - Configure upcount (1) / down count (0) mode
   * - 0x22000008
     - -
     - Get/write counter value
   * - 0x22000000
     - -
     - Set periodic value

Counter Timer 1
~~~~~~~~~~~~~~~

.. list-table:: Counter Timer 1 Configuration
   :widths: 20 10 50
   :header-rows: 1

   * - Address
     - Bit
     - Description
   * - 0x23000000
     - 0
     - Enable timer
   * - 0x23000000
     - 1
     - Configure one-shot (1) / periodic (0) mode
   * - 0x23000000
     - 2
     - Configure upcount (1) / down count (0) mode
   * - 0x23000008
     - -
     - Get/write counter value
   * - 0x23000000
     - -
     - Set periodic value

SPI Master
~~~~~~~~~~

.. list-table:: SPI Master Configuration
   :widths: 20 10 50
   :header-rows: 1

   * - Address
     - Bit
     - Description
   * - 0x24000004
     - -
     - Read/write SDI or SDO
   * - 0x24000000
     - 13
     - Enable SPI
   * - 0x24000000
     - 12
     - Enable streaming mode
   * - 0x24000000
     - 9
     - Invert CSB polarity
   * - 0x24000000
     - 8
     - Change bit order (MSB first / LSB first)
   * - 0x24000000
     - 11
     - Change SPI mode

SPI Modes:
~~~~~~~~~~~

SPI mode determines the timing of data read and change relative to the SCK (Serial Clock) signal. There are two modes available:

- Mode 0 (Read and Change Data on Opposite SCK Edges)
  In this mode, data is read and changed on opposite edges of the SCK signal.

- Mode 1 (Read and Change Data on the Same SCK Edge)
  In this mode, data is read and changed on the same edge of the SCK signal.


Interrupt System
----------------

The picoV32 CPU utilizes an interrupt system, allowing each IP to trigger an interrupt. More information about interrupt configurations and handling will be added to this README in the future.

Contributing
------------

TODO

License
-------

TODO
