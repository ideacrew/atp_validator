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

## Port Protocol

The port protocol is a simple, language-agnostic interoperability method that comes from Erlang.

Basically how it works is processes talk to each other by sending messages over standard in and standard out to each other.

Invoking a port works like this:
1. Encode the size of the message you are going to send to the application as a big-endian four-byte integer.
2. Send that four-byte specifier to the STDIN of the child process, followed by the message itself.
3. Wait to read back in, from the STDOUT of the child process, four bytes.  These bytes are a big-endian value specifying the value of the response message.
4. Read the specified number of bytes back in from the STDOUT of the child process - this is your response message.

## Research

Prior to choosing to undertake this task in java, we considered multiple ruby libraries and frameworks.

**Fill in this section with considered libraries and results from attempting to use them**.
