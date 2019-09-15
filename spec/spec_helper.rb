require 'mapstatic'
require 'vcr'
require 'json'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

def images_are_identical(image1, image2)
  expect(`compare -metric MAE #{image1} #{image2} null: 2>&1`.chomp).to eq("0 (0)")
end

def create_map
  Mapstatic::Map.new(
    lat: 51.515579783755925,
    lng: -0.1373291015625,
    zoom: 11,
    width: 256,
    height: 256,
    provider: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
  )
end

def line_string
  {
    "type": "Feature",
    "geometry": {
      "type": "LineString",
      "coordinates": [[-0.3481, 51.5283], [0,2208, 51,4462]]
    }
  }.to_json
end
