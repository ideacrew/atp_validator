package org.openhbx.atp_validator;

import java.io.IOException;
import java.io.InputStream;
import javax.xml.transform.sax.SAXSource;
import net.sf.saxon.s9api.SaxonApiException;
import org.junit.Test;
import org.xml.sax.InputSource;

/**
 *
 * @author tevans
 */
public class ValidatorTest {

  @Test
  public void testSetup() throws SaxonApiException {
    Validator v = new Validator();
    v.setup();
  }
  
  @Test
  public void testExample() throws SaxonApiException, IOException {
    Validator v = new Validator();
    v.setup();
    InputStream iStream = getClass().getClassLoader().getResourceAsStream("org/openhbx/atp_validator/example_xml.xml");
    SAXSource source = new SAXSource(new InputSource(iStream));
  }
}
