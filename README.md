# Juicy-gcode: A lightweight SVG to GCode converter for maximal curve fitting

[![Hackage](https://img.shields.io/hackage/v/juicy-gcode.svg)](https://hackage.haskell.org/package/juicy-gcode)
[![Travis](https://travis-ci.org/domoszlai/juicy-gcode.svg?branch=master)](http://travis-ci.org/domoszlai/juicy-gcode)
![Appveyor](https://ci.appveyor.com/api/projects/status/github/domoszlai/juicy-gcode?branch=master&svg=true)

## Overview

Juicy-gcode is a configurable SVG to G-code converter that approximates bezier curves with [biarcs](http://dlacko.org/blog/2016/10/19/approximating-bezier-curves-by-biarcs/) for maximal curve fitting.

## Installation

The easiest way is to download one of the pre-built binaries from the [releases page](https://github.com/domoszlai/juicy-gcode/releases).
Alternatively, you can build from source code as follows:

- Install [Stack](https://docs.haskellstack.org/en/stable/install_and_upgrade/) if you do not have it yet
- `$ git clone https://github.com/domoszlai/juicy-gcode.git`
- `$ stack build`
- `$ stack install`
- `$ juicy-gcode --help`

## Usage

> :warning: **Breaking change**: Since version 0.2.0.1, default DPI is changed to 96 and the option to mirror the Y axis is removed (it is always mirrored now)

The easier way to use juicy-gcode is to simply provide an SVG file name. The generated GCode will be written to standard output.

```
$ juicy-gcode SVGFILE
```

Alternativly, you can provide an output file name as well.

```
$ juicy-gcode SVGFILE -o OUTPUT
```

Sometimes you want to overwrite some default settings. These are the 

* *--dpi* (default 96 DPI) [the resolution of the SVG file](https://developer.mozilla.org/en-US/docs/Web/CSS/resolution) that is used to determine the size of the SVG when it does not contain explicit units
* *--resolution* (default is 0.1 mm) the resolution of the generated GCode. Paths smaller than this are replaced by line segments instead of further approximated by biarcs
 
```
$ juicy-gcode SVGFILE --dpi 72 --resolution 0.01 
```

Some firmwares (e.g. [Marlin](https://marlinfw.org/docs/gcode/G005.html)) can handle bezier curves directly. In this case
you can command juicy-gcode not to approximate bezier-curves but emit them unchanged. 

```
$ juicy-gcode SVGFILE --generate-bezier
```

## Configuration

The generated GCode is highly dependent on the actual device it wil be executed by. In juicy-gcode, these settings are called
GCode flavour and consists of the following:

- Begin GCode routine (commands that are executed *before* the actual print job)
- End GCode routine (commands that are executed *after* the actual print job)
- Tool on (command to switch the actual tool on)
- Tool off (command to switch the actual tool off)

These setting can be influenced by a GCode flavor configuration file. The default settings
are good for 

```
gcode
{
   begin = "G17;G90;G0 Z10;G0 X0 Y0;M3;G4 P2000.000000"
   end = "G0 Z10;M5;M2"
   toolon =  "G00 Z10"
   tooloff = "G01 Z0 F10.00"
}
```

and can be set by the by the `--flavor` or `-f` command line option.

A new configuration file can be set by the `--flavor` or `-f` command line option.



## Limitations

SVG features that are not supported:

- texts
- filling
- clipping
- images

## Testing and bugs

There is a JavaScript [hanging plotter simulator](https://github.com/domoszlai/hanging-plotter-simulator) mainly developed to test the generated gcode.
Please file an issue if you run into a problem (or drop me an email to dlacko @ gmail.com).
