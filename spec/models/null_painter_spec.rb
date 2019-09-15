require 'spec_helper'

describe Mapstatic::Painter::NullPainter do
  it "should accept any geometry type, even garbage" do
    expect(Mapstatic::Painter::NullPainter.accept? "LineString").to be(true)
    expect(Mapstatic::Painter::NullPainter.accept? "foo").to be(true)
  end

  it "should draw without errors" do
    # Utilize Tempfile to create a unique filename. We don't the file itself for anything,
    # only to ensure we have a file path we can safely copy into.
    tmpfile = Tempfile.new ["foo", ".png"]
    filename = tmpfile.path
    tmpfile.close
    tmpfile.unlink
    FileUtils.cp "spec/fixtures/maps/london.png", filename

    image = MiniMagick::Image.new filename
    image.resize "256x256"

    map = create_map
    feature = line_string
    map.geojson = feature
    map.fit_bounds

    painter = Mapstatic::Painter::NullPainter.new(map: map, feature: JSON.parse(feature))
    painter.paint_to image

    expect(image.type).to eq("PNG")
  end

end
