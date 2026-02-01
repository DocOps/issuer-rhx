require 'rake'
require 'fileutils'

# Load DocOps Lab development tasks
begin
  require 'docopslab/dev'
rescue LoadError
  # Skip if not available (e.g., production environment)
end

desc "Generate the manpage from AsciiDoc source"
task :manpage do
  puts "Generating manpage..."
  source_file = 'docs/manpage.adoc'
  output_dir = 'docs'
  output_file = 'issuer-rhx.1'

  FileUtils.mkdir_p(output_dir)

  # Asciidoctor command to generate manpage
  system("asciidoctor -b manpage -D #{output_dir} #{source_file} -o #{output_file}")

  puts "Manpage created at #{output_dir}/#{output_file}"
end

task default: :manpage
