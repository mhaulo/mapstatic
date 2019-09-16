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
        @width  = params.fetch(:width)
        @height = params.fetch(:height)
        lat    = params.fetch(:lat).to_f
        lng    = params.fetch(:lng).to_f

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
        (delta * TILE_SIZE).to_i.abs
      end
    end

    def height
      @height || begin
        delta = Conversion.lat_to_y(viewport.top, zoom) - Conversion.lat_to_y(viewport.bottom, zoom)
        (delta * TILE_SIZE).to_i.abs
      end
    end

    def geojson=(data)
      if data.is_a? String
        @geojson = JSON.parse data
      else
        @geojson = data
      end
    end

    def fit_bounds
      return if @geojson.nil?

      coordinates = @geojson["geometry"]["coordinates"]
      geojson_bounding_box = BoundingBox.for(coordinates)

      # TODO  add padding
      @viewport.left =   geojson_bounding_box.left
      @viewport.right =  geojson_bounding_box.right
      @viewport.top =    geojson_bounding_box.top
      @viewport.bottom = geojson_bounding_box.bottom
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
