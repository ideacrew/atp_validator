# ATPValidator

Executes XML business rules to validate ATP payloads for OpenHBX.

## Building

This project builds as a shaded jar, so build with:
```
mvn clean compile assembly:single
```

## Running

This application runs in two modes:
1. packet port mode: the application stays alive indefinitely receiving and sending messages using the port protocol, with packet size of 4.  This is the default.
2. oneshot mode: the application reads the XML file from standard in and prints the results on standard out, then exits.  Run with `--oneshot` to activate this mode.  Example: `cat example.xml | java -jar atp_validator-0.1.0-jar-with-dependencies.jar --oneshot`

## Research

Prior to choosing to undertake this task in java, we considered multiple ruby libraries and frameworks.

**Fill in this section with considered libraries and results from attempting to use them**.
