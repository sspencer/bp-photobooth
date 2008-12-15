require 'Pathname'
require 'pp'



def dbg(o)
  str = o.class.name == "String" ? o : o.pretty_inspect
  #bp_log("info", "[PhotoBooth] #{str}\n")
  File.open("/tmp/dbg.txt", 'a') { |f| f.puts(str) }
end

#
# Take a interactive screenshot.
# 
class PhotoBooth

  # Reasonable number of samples, so we don't use too much memory
  @@DEFAULT_DELAY = 5

  # Constructor
  def initialize(args)
    dbg("initialize")
    @watching = false
    @last_file = nil
  end

  
  #
  #
  def watch(bp, args)
    dbg("watch")
    delay = args['delay'] || @@DEFAULT_DELAY
    delay = 2 if (delay < 2)
    delay = 20 if (delay > 20)
    @watching = true
    Thread.new(bp, args['callback'], delay) do | bp,callback,delay |
      homedir = File.expand_path("~")
      dbg("homedir #{homedir}")
      while @watching
        files = `ls -t #{homedir}/Pictures/Photo\\ Booth/*.jpg`
        cur = files.split("\n")[0]

        if (cur && cur != @last_file)
          @last_file = cur
          dbg("INVOKING CALLBACK #{cur}")
          callback.invoke(Pathname.new(cur))
        end
        dbg("sleeping")
        sleep delay
      end

      bp.complete()
    end
  end

  #
  # Stop watching
  #
  def stop(bp, args)
    @watching = false
    bp.complete()
  end

end

rubyCoreletDefinition = {
  'class' => "PhotoBooth",
  'name'  => "PhotoBooth",
  'major_version' => 0,
  'minor_version' => 0,
  'micro_version' => 1,
  'documentation' => 'A service that monitors the PhotoBoth directory for new photos.',

  'functions' =>
  [
    {
      'name' => 'watch',
      'documentation' => "Monitor Photo Booth directory for new photos.",
      'arguments' =>
      [
         {
            'name' => 'delay',
            'type' => 'integer',
            'required' => true,
            'documentation' => 'The time to delay between polling photo booth directory (default 5 seconds).'
          },
          {
            'name' => 'callback',
            'type' => 'callback',
            'required' => true,
            'documentation' => 'Called when service detects a new photo in Photo Booth directory.  ' + 
              'If there are any photos in the directory, you will be called at least once.'
          }
      ]
    },
    
    {
      'name' => 'stop',
      'documentation' => "Stop polling.",
      'arguments' => []
    },
    
  ] 
}
