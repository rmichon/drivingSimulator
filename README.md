# drivingSimulator

This repository contains the different softwares developed in the Frame of the Renault / CCRMA / CDR project conducted at Stanford Univeristy's Volkswagen Automotive Innovation Lab (VAIL).

# Content

- ./build: build the different elements except for udp2osc

- ./clean: removes the compiled objects except for udp2osc

- ./run: launch the sound engine

- ./chuck: the chuck codes

- ./faust: the faust codes

- ./udp2osc: a very simple program that retrieves the UDP messages from the car simulator, format them into OSC messages and send them on a defined port. Type "make" in this folder to build the program.

# TODO

- build and clean should be replaced by a makefile but it's fine for now...