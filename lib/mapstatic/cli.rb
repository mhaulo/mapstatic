require 'mapstatic'
require 'awesome_print'
require 'thor'
require 'json'

class Mapstatic::CLI < Thor

  desc "map FILENAME", "Generate a map"
  long_desc <<-LONGDESC
     `mapstatic map FILENAME` will create a new static map.

     A map can be created in two ways:

     1. With a bounding box, e.g.

     $ mapstatic map uk.png --zoom=6 --bbox=-10.93,49.64,3.15,59.57

     When creating a map with a bounding box, the width and height of the map
     will be determined by the zoom level.

     2. With a center lat, lng, width and height, e.g.

     $ mapstatic map greenwich.png --zoom=12 \
                                   --lat=51.477222 \
                                   --lng=0 \
                                   --width=700 \
                                   --height=700

     By default, the map will be generated with the OpenStreetMap tile set (Copyright
     OpenStreetMap contributors).

     You can generate a map using any tile set by passing the --provider option.
  LONGDESC

  option :zoom,     :required => true
  option :provider, :default => 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
  option :bbox
  option :lat
  option :lng
  option :width,  :default => 256
  option :height, :default => 256
  option :dryrun, :type => :boolean, :default => false

  def map(filename)
    params = Hash[options.map{|(k,v)| [k.to_sym,v]}]

    if params[:bbox]
      bbox = params[:bbox].split(",").map { |c| c.to_f }
      params[:bbox] = bbox
    end

    map = Mapstatic::Map.new(params)

    # TODO Remove this section, it's just for testing purposes
    #line_string = {
    #  "type": "Feature",
    #  "geometry": {
    #    "type": "LineString",
    #    "coordinates": [[23.8335, 61.4503], [23.8693, 61.4498]]
    #  }
    #}.to_json
    #map.geojson = line_string

    map.render_map(filename) unless options[:dryrun]

    metadata = {
      map_bbox: map.viewport.to_a.join(','),
      width: map.width.to_i,
      height: map.height.to_i,
      zoom: map.zoom
    }

    ap metadata
  end

end
