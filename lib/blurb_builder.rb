# encoding: utf-8
class BlurbBuilder
  attr_reader :car

  def initialize(car)
    @car = car
  end

  def to_blurb
    blurb = Blurb.new(to_blurb_attrs, without_protection: true)
    blurb.parsing_errors = car.parsing_errors

    blurb
  end

  def to_blurb_attrs
    {
        vendor_id: car.id,
        name: car.name,
        price_currency: self.class.process_price(car.price)[0],
        price_value: self.class.process_price(car.price)[1],
        year: car.year,
        engine_value: car.engine_value,
        doors: car.doors,
        fuel_type: car.fuel_type,
        color: car.color,
        transmission: car.transmission,
        drive_type: car.drive_type,
        body_type: car.body_type,
        cylinders_count: car.cylinders_count,
        class_of_vehicle: car.class_of_vehicle,
        message: car.message,
        phone: car.phone,
        equipment: car.equipment,
        mileage_value: car.mileage_value,
        mileage_units: car.mileage_units,
        country: car.country,
        city: car.city
    }
  end

  #returns array of [Currency, Value]
  def self.process_price(price)
    currency, price = price.to_s.strip.scan(/(\$|€|Br)\s+(\d+)/i).flatten
    price = price.to_i unless price.nil?

    [currency, price]
  end
end
