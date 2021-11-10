#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'

print "Package name (e.g., com.example.solr.analysis): "
package = gets.chomp

print "Filter class, capitalized (e.g., Lowercasify): "
filtername = gets.chomp

puts
puts "Package: #{package}"
puts "Filter class: #{filtername}"
puts
print "OK? (y/N) "
response = gets.chomp
exit(1) unless response =~ /\A\s*[Yy]\s*\Z/


factory = %Q(
package #{package};

import com.billdueber.solr_scaffold.analysis.SimpleFilterFactory;
import org.apache.lucene.analysis.TokenStream;

import java.util.Map;

public class #{filtername}FilterFactory extends SimpleFilterFactory {

  public #{filtername}FilterFactory(Map<String, String> args) {
    super(args);
  }

  public L#{filtername}Filter create(TokenStream input) {
    return new #{filtername}Filter(input, getEchoInvalidInput());
  }
}

)

filter =  %Q(
package #{package};


import com.billdueber.solr_scaffold.analysis.SimpleFilter;
import org.apache.lucene.analysis.TokenStream;



public class #{filtername}Filter extends SimpleFilter {

  public #{filtername}Filter(TokenStream aStream, Boolean echoInvalidInput) {
    super(aStream, echoInvalidInput);
  }

  @Override
  public String munge(String str) {
    return str.toLowerCase();
  }

}
)

target_dir = (%w[src main java].concat(package.split('.'))).join("/")
p = Pathname.new(__dir__) + target_dir
FileUtils.mkpath(p.to_s)

File.open(p + "#{filtername}Filter.class", 'w:utf-8') { |out| out.puts filter }
File.open(p + "#{filtername}FilterFactory.class", 'w:utf-8') { |out| out.puts factory }
