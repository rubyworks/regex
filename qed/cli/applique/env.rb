require 'regex'

When 'Given a file (((\S+))) containing' do |file, text|
  File.open(file, 'w'){ |f| f << text }
end

When 'invoking the command' do |text|
  text = text.sub(/^\$\s+/, '')
  @out = `#{text}`
end

When 'Should produce' do |text|
  @out.strip.assert == text.strip
end

When 'result in a new file (((\S+))) containing' do |file, text|
  File.read(file).strip.assert == text.strip
end

