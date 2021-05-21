package org.openhbx.atp_validator;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import net.sf.saxon.s9api.SaxonApiException;

public class App {

  public static void main(String[] args) throws IOException, SaxonApiException {

    Validator v = new Validator();
    v.setup();
    ValidationRunner vr = new ValidationRunner(v);

    if (oneshotSpecified(args)) {
      byte[] buffer = new byte[4096];
      ByteArrayOutputStream bas = new ByteArrayOutputStream();
      int i = System.in.read(buffer, 0, 4096);
      while (i != -1) {
        bas.write(buffer, 0, i);
        i = System.in.read(buffer, 0, 4096);
      }
      bas.flush();
      byte[] validationResult = vr.validate(bas.toByteArray());
      bas.close();
      System.out.write(validationResult);
    } else {
      InReader reader = new InReader(System.in);
      OutWriter writer = new OutWriter(System.out);
      while (true) {
        byte[] readPacket = reader.readPacket();
        byte[] validationResult = vr.validate(readPacket);
        writer.writePacket(validationResult);
      }
    }
  }

  private static boolean oneshotSpecified(String[] args) {
    List<String> argList = new ArrayList<String>();
    argList.addAll(Arrays.asList(args));
    int oneshotArg = argList.indexOf("--oneshot");
    return oneshotArg != -1;
  }
}
