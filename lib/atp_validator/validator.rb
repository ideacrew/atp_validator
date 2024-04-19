require "java"

java_import "java.io.ByteArrayInputStream"
java_import "java.io.ByteArrayOutputStream"
java_import "javax.xml.transform.Source"
java_import "javax.xml.transform.stream.StreamSource"
java_import "net.sf.saxon.s9api.Processor"
java_import "net.sf.saxon.s9api.SaxonApiException"
java_import "net.sf.saxon.s9api.Serializer"
java_import "net.sf.saxon.s9api.XsltCompiler"
java_import "net.sf.saxon.s9api.XsltExecutable"
java_import "net.sf.saxon.s9api.XsltTransformer"

module AtpValidator
  class IgnoredOutputStream < Java::java.io.OutputStream
    import "java"
    # include "java.io.OutputStream"

    def initialize
      super
    end

    java_signature "void write(int b) throws java.io.IOException"
    def write(b)
    end
  end

  class Validator
    EMPTY_PAYLOAD_RESPONSE = <<-XMLCODE
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
  <svrl:failed-assert test="exists(/)" location="/">
    <svrl:text>The document is not valid XML.</svrl:text>
  </svrl:failed-assert>
</svrl:schematron-output>
    XMLCODE

    def initialize
      @configuration = Java::net.sf.saxon.Configuration.new
      @discard_stream = IgnoredOutputStream.new
      @configuration.setStandardErrorOutput(Java::java.io.PrintStream.new(@discard_stream.java_object))
      @processor = Java::net.sf.saxon.s9api.Processor.new(@configuration)
      x = @processor.newXsltCompiler()
      resource = @processor.java_object.getClass().getClassLoader().getResourceAsStream("resources/AccountTransfer-runtime.xsl")
      src = StreamSource.new(resource)
      @executable = x.compile(src)
    end

    def validate(string)
      begin
        bs = ByteArrayInputStream.new(string.to_java_bytes)
        source = StreamSource.new(bs)
        run_validation_against(source)
      rescue StandardError => e
        EMPTY_PAYLOAD_RESPONSE
      end
    end

    protected

    def run_validation_against(source)
      xt = @executable.load()
      bas = ByteArrayOutputStream.new()
      s = @processor.newSerializer(bas)
      xt.setSource(source)
      xt.setDestination(s)
      xt.transform()
      xt.close()
      s.close()
      bas.flush()
      String.from_java_bytes(bas.toByteArray())
    end
  end
end
