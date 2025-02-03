class TheaterSerializer < Blueprinter::Base
  identifier :id
  fields :name, :city, :address, :latitude, :longitude

  view :detail do
    association :screens, blueprint: ScreenSerializer
  end
end
