require "singleton"

class Terrain < Delegator
  include Singleton
  attr_accessor :image

  module Color
    EMPTY   = ::Gosu::Color.new(  0,   0,   0,   0)
    SURFACE = ::Gosu::Color.new(255,  75,  75,  75)
  end

  def initialize
    generate
  end

  def generate
    # rand seed
    cycles = rand(10)

    # http://banisterfiend.wordpress.com/2008/08/23/texplay-an-image-manipulation-tool-for-ruby-and-gosu/
    width, height = $window.width, $window.height
    self.image ||= ::TexPlay.create_image($window, width, height)

    # bounds
    x1, y1  = 0, height/1.5
    x2, y2  = width, height

    # paint terrain
    image.paint do
      # clear
      rect(0, 0, x2, y2, :fill => true, :color => Color::EMPTY)

      # draw
      x1 = 0.0
      while(x1 < $window.width) do
        y1 = (Math.sin(x1 / width * cycles) * 100) + height / 1.5
        line(x1, y1, x1, y2, :fill => true, :texture => Gosu::Image["terrain.png"])
        pixel(x1, y1, :color => Color::SURFACE)
        x1 += 1.0
      end
    end
  end

  def __getobj__
    image # return object we are delegating to, required
  end

  def draw
    image.draw(0, 0, 0)
  end

  def collide_point?(x, y)
    return false if x < 0 || y < 0 || x > width || y > height
    image.get_pixel(x, y)[3] != 0 rescue false
  end

  def highest_collide_point(x)
    (0..height).to_a.each do |y|
      return y if collide_point?(x, y)
    end
  end

  def remove_circle(center_x, center_y, radius=1, burn_radius_factor=3)
    image.paint do
      # burn terrain
      circle(center_x, center_y, radius * 1.3, :fill => true, :mode => :darken, :color => Gosu::Color.new(200, 0, 0, 0))
      # remove terrain
      circle(center_x, center_y, radius, :color => Color::EMPTY, :fill => true)
    end
  end

end
