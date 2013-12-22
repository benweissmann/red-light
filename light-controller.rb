module LightController
  RED    = 24
  ORANGE = 23
  YELLOW = 18
  GREEN  = 4
  BLUE   = 22
  PURPLE = 17

  INVALID_STATE = -1

  COLORS = [RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE]

  class << self
    # Performs basic initialization
    def init
      set_modes
      reset
    end

    # Sets the color. You MUST pass in one of the
    # above constants.
    def set_color color
      unless COLORS.include? color
        raise "Invalid color: #{color}"
      end
      reset_pins
      set_pin color, 1
    end

    # Gets the color. Return nil for no color on,
    # INVALID_STATE if multiple colors are on,
    # else one of the above constants.
    def get_color
      pins = COLORS.select do |pin|
        get_pin pin
      end

      if pins.length == 0
        return nil
      elsif pins.length == 1
        return pins.first
      else
        return INVALID_STATE
      end
    end

    # Turns off all LEDs.
    def reset
      if @thread
        Thread.kill @thread
      end

      reset_pins
    end

    # plays a rainbow
    def rainbow
      cycle COLORS, 0.5
    end

    # cycles through a list of colors waiting
    # [delay] seconds between each
    def cycle colors=[], delay=0.5
      @thread = Thread.new do
        i = 0
        loop do
          set_color colors[i]
          i = (i+1) % colors.length
          sleep delay
        end
      end
    end

    # toggle debugging mode. In debugging mode, gpio commands
    # are printed, not executed
    def debug state=true
      @debug = state
    end

    private

    def set_modes
      COLORS.each do |pin|
        set_mode pin, "out"
      end
    end

    def set_mode pin, mode
      exec "gpio -g mode #{pin} #{mode}"
    end

    def set_pin pin, color
      exec "gpio -g write #{pin} #{color}"
    end

    def get_pin pin
      return exec("gpio -g read #{pin}").strip.to_i == 1
    end

    def exec cmd
      if @debug
        puts "[LightController] #{cmd}"
        return ""
      else
        return `#{cmd}`
      end
    end

    def reset_pins
      COLORS.each do |pin|
        set_pin pin, 0
      end
    end
  end
end


LightController.init