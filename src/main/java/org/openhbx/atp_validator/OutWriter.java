package org.openhbx.atp_validator;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.ByteBuffer;

/**
 *
 * @author tevans
 */
public class OutWriter {
  private OutputStream outStream;
  
  public OutWriter(OutputStream oStream) {
    outStream = oStream;
  }
  
  public void writePacket(byte[] packet) throws IOException {
    int packetSize = packet.length;
    ByteBuffer b = ByteBuffer.allocate(4);
    b.putInt(packetSize);
    outStream.write(b.array());
    outStream.write(packet);
    outStream.flush();
  }
}
