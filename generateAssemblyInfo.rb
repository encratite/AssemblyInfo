require 'nil/file'

targets = [
  'x86',
  'Debug',
  'Release',
  'bin',
]

modifiedPath = Dir.pwd
targets.each do |target|
  modifiedPath = modifiedPath.gsub("/#{target}", '')
end
properties = Nil.joinPaths(modifiedPath, 'Properties')
inputPath = Nil.joinPaths(properties, 'AssemblyInfo.template.cs')
outputPath = Nil.joinPaths(properties, 'AssemblyInfo.cs')

lines = nil
status = IO.popen('git log --pretty=oneline') do |io|
  input = io.read.strip
  lines = input.split("\n")
end
pattern = /^[^ ].*? \((\d+)\):$/
revision = lines.size

lines = Nil.readLines(inputPath)
if lines == nil
  puts "Unable to read file #{inputPath}"
  exit
end

pattern = /^\[assembly: AssemblyVersion\("(\d+)\.(\d+).+?"\)\]$/

lines.map! do |line|
  match = line.match(pattern)
  if match != nil
    major = match[1].to_i
    minor = match[2].to_i
    build = 0
    line = "[assembly: AssemblyVersion(\"#{major}.#{minor}.0.#{revision}\")]"
    puts line
  end
  line
end

output = lines.join("\n")
Nil.writeFile(outputPath, output)
