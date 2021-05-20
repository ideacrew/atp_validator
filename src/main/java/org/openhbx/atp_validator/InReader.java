package org.openhbx.atp_validator;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;

/**
 *
 * @author tevans
 */
public class InReader {
  
  private InputStream inStream;
  
  public InReader(InputStream iStream) {
   inStream = iStream;
  }
  
  public byte[] readPacket() throws IOException {
    int packetSize = readPacketSize();
    return readInBytes(packetSize);
  }
  
  private int readPacketSize() throws IOException {
    byte[] sizeArray = {0x00, 0x00, 0x00, 0x00};
    for (int i = 0; i < 4; i++) {
      Integer read = inStream.read();
      if (read == -1) {
        System.exit(0);
      }
      sizeArray[i] = read.byteValue();
    }
    ByteBuffer b = ByteBuffer.allocate(4);
    b.put(sizeArray);
    b.rewind();
    return b.getInt();
  }
  
  private byte[] readInBytes(Integer size) throws IOException {
    byte[] buffer = new byte[size];
    int readIndex = 0;
    int readLeft = size;
    int readSize = inStream.read(buffer, readIndex, size);
    readLeft = readLeft - readSize;
    readIndex = readIndex + readSize;
    while (readLeft > 0) {
      readSize = inStream.read(buffer, readIndex, readLeft);
      readLeft = readLeft - readSize;
      readIndex = readIndex + readSize;
    }
    return buffer;
  }
  
}
