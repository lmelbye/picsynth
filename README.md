# picsynth
An 8-bit synthesizer for PIC16f877 microcontroller 

Tones are giving by sending signal on PIN 19-30 corresponding to tones A4-A5 (440 Hz- 880 Hz) and
the output is send as an 8 bit digital signal on PIN 33-40. 

* It is possible to play 3 tones simultaneously
* Due to memory constrains only the first quarter of the sine waves is stored in `osc.ASM`. The rest is calculated using symmetry of the sine function.

The output digital output signal can be converted to an analogue signal using a resistor ladder. See diagram below 

![diagram](https://lmelbye.github.com/picsynth/images/diagram.png)

An example of the output signal with three tones playing simultaneously 

![signal](https://lmelbye.github.com/picsynth/images/tone.jpg)
