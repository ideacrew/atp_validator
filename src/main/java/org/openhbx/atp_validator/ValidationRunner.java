package org.openhbx.atp_validator;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import net.sf.saxon.s9api.SaxonApiException;

/**
 *
 * @author tevans
 */
public class ValidationRunner {
  private Validator validator;
  
  public ValidationRunner(Validator v) {
    validator = v;
  }

  public byte[] validate(byte[] buffer) throws SaxonApiException, IOException {
    ByteArrayInputStream bs = new ByteArrayInputStream(buffer);
    Source source = new StreamSource(bs);
    return validator.runValidationAgainst(source);
  }
}
