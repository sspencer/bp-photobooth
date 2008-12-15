require 'PhotoBooth.rb'

class BPProxy
  def complete()
    puts "COMPLETE"
  end
end

class Callback
  def invoke(val)
    puts "CALLBACK: #{val}"
  end
end

bp = BPProxy.new
photo = PhotoBooth.new([])

callback = Callback.new
puts "TEST WATCH"
photo.watch(bp, {'callback'=>callback, 'delay'=>5})
sleep 17
puts "TEST STOP"
photo.stop(bp, {})
sleep 1


