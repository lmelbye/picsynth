# picsynth
An 8-bit synthesizer for PIC16f877 microcontroller 

Tones are giving by sending signal on PIN 19-30 corresponding to tones A4-A5 (440 Hz- 880 Hz) and
the output is send as an 8 bit digital signal on PIN 33-40. 

* It is possible to play 3 tones simultaneously
* Due to memory constrains only the first quarter of the sine waves is stored in `osc.ASM`. The rest is calculated using symmetry of the sine function.

Inputs tone can be handles with contact switches and
the output signal can be converted to an analogue signal using a resistor ladder.
This signal can then be amplified and played via a loudspeaker. See diagram below for complete setup.
![diagram](/images/diagram.png?raw=true "Diagram")

An example of the output signal with three tones playing simultaneously
![signal](/images/tone.jpg?raw=true "An example of the output signal with three tones playing simultaneously")
