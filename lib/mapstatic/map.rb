require 'mini_magick'
require 'json'

module Mapstatic
  class Map
    TILE_SIZE = 256

    attr_reader :lat, :lng, :viewport, :geojson
    attr_accessor :tile_source, :zoom

    def initialize(params={})
      @zoom = params.fetch(:zoom).to_i

      if params[:bbox]
        left, bottom, right, top = params[:bbox]
        @viewport = BoundingBox.new top: top, bottom: bottom, left: left, right: right
      else
        @width  = params.fetch(:width).to_i
        @height = params.fetch(:height).to_i
        lat    = params.fetch(:lat, 0).to_f
        lng    = params.fetch(:lng, 0).to_f

        @viewport = BoundingBox.from(
          center_lat: lat,
          center_lng: lng,
          width: @width.to_f / TILE_SIZE,
          height: @height.to_f / TILE_SIZE,
          zoom: @zoom
        )
      end

      if params[:tile_source]
        @tile_source = TileSource.new(params[:tile_source])
      else
        @tile_source = TileSource.new("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")
      end
    end

    def width
      @width || begin
        delta = Conversion.lng_to_x(viewport.right, zoom) - Conversion.lng_to_x(viewport.left, zoom)
        (delta * TILE_SIZE).abs
      end
    end

    def height
      @height || begin
        delta = Conversion.lat_to_y(viewport.top, zoom) - Conversion.lat_to_y(viewport.bottom, zoom)
        (delta * TILE_SIZE).abs
      end
    end

    def geojson=(data)
      if data.is_a? String
        @geojson = JSON.parse data
      elsif data.is_a? Hash
        # This looks really ugly, but it's just a quick and dirty way to ensure that keys in
        # the hash are strings, not symbols.
        @geojson = JSON.parse data.to_json
      end
    end

    def fit_bounds
      return if @geojson.nil?

      coordinates = @geojson["geometry"]["coordinates"]
      geojson_bounding_box = BoundingBox.for(coordinates)
      @viewport.set_to geojson_bounding_box
    end

    def to_image
      Renderer.new(self).render
    end

    def to_file(filename)
      Renderer.new(self).render_to(filename)
    end
    alias_method :render_map, :to_file
  end
end
