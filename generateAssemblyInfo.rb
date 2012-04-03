def readFile(path)
  begin
    file = File.open(path, 'rb')
    output = file.read
    file.close
    return output
  rescue Errno::ENOENT
    return nil
  end
end

def readLines(path)
  data = readFile path
  return nil if data == nil
  data = data.gsub("\r", '')
  return data.split "\n"
end

def writeFile(path, data)
  begin
    file = File.open(path, 'wb+')
    file.write data
    file.close
  rescue Errno::EINVAL
    return nil
  end
end

def getOS
  names =
    {
    'mswin32' => :windows,
    'linux' => :linux,
  }

  tokens = RUBY_PLATFORM.split '-'
  os = tokens[1]

  return names[os]
end

def joinPaths(*arguments)
  windowsSeparator = '\\'
  unixSeparator = '/'

  separator =
    getOS == :windows ?
  windowsSeparator :
    unixSeparator

  expression = Regexp.new "\\#{separator}+"
  path = arguments.join(separator).gsub(expression, separator)
  if getOS == :windows
    path = path.gsub(unixSeparator, windowsSeparator)
  end
  return path
end

def generateAssemblyInfo
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
  properties = joinPaths(modifiedPath, 'Properties')
  inputPath = joinPaths(properties, 'AssemblyInfo.template.cs')
  outputPath = joinPaths(properties, 'AssemblyInfo.cs')

  lines = nil
  status = IO.popen('git log --pretty=oneline') do |io|
    input = io.read.strip
    lines = input.split("\n")
  end
  pattern = /^[^ ].*? \((\d+)\):$/
  revision = lines.size

  lines = readLines(inputPath)
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
  writeFile(outputPath, output)
end

generateAssemblyInfo
