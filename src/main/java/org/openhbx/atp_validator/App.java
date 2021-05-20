package org.openhbx.atp_validator;

import java.io.IOException;
import net.sf.saxon.s9api.SaxonApiException;

public class App 
{
    public static void main( String[] args ) throws IOException, SaxonApiException
    {
      InReader reader = new InReader(System.in);
      OutWriter writer = new OutWriter(System.out);
      Validator v = new Validator();
      v.setup();
      ValidationRunner vr = new ValidationRunner(v);

      while (true) {
        byte[] readPacket = reader.readPacket();
        byte[] validationResult = vr.validate(readPacket);
        writer.writePacket(validationResult);
      }
    }
}
