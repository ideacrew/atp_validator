package org.openhbx.atp_validator;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

/**
 *
 * @author tevans
 */
public class Validator {
  
  private XsltExecutable executable;
  private Processor p;
  
  public Validator() {
    p = new Processor(false);
  }
  
  public void setup() throws SaxonApiException {
    executable = createExecutable();
  }

  public byte[] runValidationAgainst(Source source) throws SaxonApiException, IOException {
    XsltTransformer xt = executable.load();
    ByteArrayOutputStream bas = new ByteArrayOutputStream();
    Serializer s = p.newSerializer(bas);
    xt.setSource(source);
    xt.setDestination(s);
    xt.transform();
    xt.close();
    s.close();
    bas.flush();
    return bas.toByteArray();
  }
  
  public XsltExecutable createExecutable() throws SaxonApiException {
    return createExecutableFromSource(getStylesheetResource());
  }
  
  public Source getStylesheetResource() {
    InputStream stream = getClass().getClassLoader().getResourceAsStream("org/openhbx/atp_validator/AccountTransfer-runtime.xsl");
    return new StreamSource(stream);
  }
  
  public XsltExecutable createExecutableFromSource(Source src) throws SaxonApiException {
    XsltCompiler x = p.newXsltCompiler();
    return x.compile(src);
  }
}
