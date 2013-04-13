# encoding: utf-8
class Search < NoTable
  attributes :name, :start_year, :end_year, :start_price, :end_price, :fuel_type, :transmission,
             :start_engine_value, :end_engine_value, :equipment, :body_type, :show_outdated

  def to_conditions
    normalize_ranges
    normalize_equipment

    Hash.new.tap do |res|
      res[:created_at.gte] = 2.weeks.ago unless show_outdated?

      res[:year.gte] = start_year.to_i if start_year.present?
      res[:year.lte] = end_year.to_i if end_year.present?
      res[:price_value.gte] = start_price if start_price.present?
      res[:price_value.lte] = end_price if end_price.present?
      res[:name] = /^#{Regexp.escape(name.to_s)}/i if name.present?
      res[:fuel_type] = fuel_type if fuel_type.present?
      res[:transmission] = transmission if transmission.present?
      res[:engine_value.gte] = start_engine_value if start_engine_value.present?
      res[:engine_value.lte] = end_engine_value if end_engine_value.present?
      res[:equipment.all] = equipment if equipment.present?
      res[:body_type] = body_type if body_type.present?
    end
  end

  def to_param
    normalize_ranges
    normalize_equipment

    attributes.delete_if { |_, v| v.blank? }
  end

  def present?
    to_param.present?
  end

  def searchable?
    to_param.except('show_outdated').present?
  end

  def match?(blurb)
    Blurb.where(to_conditions).find(blurb.id) && true rescue false
  end

  def show_outdated?
    [1, '1', true].include?(show_outdated)
  end

  def to_s
    year_str = case
      when start_year.present? && end_year.present?
        "Год #{start_year} - #{end_year}"
      when start_year.present? && end_year.blank?
        "Год #{start_year} и больше"
      when start_year.blank? && end_year.present?
        "Год #{end_year} и меньше"
    end

    price_str = case
      when start_price.present? && end_price.present?
        "Цена #{start_price} - #{end_price}"
      when start_price.present? && end_price.blank?
        "Цена #{start_price} и больше"
      when start_price.blank? && end_price.present?
        "Цена #{end_price} и меньше"
    end

    engine_value_str = case
      when start_engine_value.present? && end_engine_value.present?
        "Объем #{start_engine_value} - #{end_engine_value}"
      when start_engine_value.present? && end_engine_value.blank?
        "Объем #{start_engine_value} и больше"
      when start_engine_value.blank? && end_engine_value.present?
        "Объем #{end_engine_value} и меньше"
    end


    Array.new.tap do |arr|
      arr << name if name.present?
      arr << year_str if year_str.present?
      arr << price_str if price_str.present?
      arr << engine_value_str if engine_value_str.present?
      arr << "Топливо #{fuel_type}" if fuel_type.present?
      arr << "Трансмиссия #{transmission}" if transmission.present?
      arr << "Кузов #{body_type}" if body_type.present?
      arr << "Опции #{equipment.join(', ')}" if equipment.present?
    end.delete_if(&:blank?).join(' | ')
  end

  private

  def normalize_equipment
    self.equipment = equipment.delete_if(&:blank?) if equipment.respond_to?(:delete_if)
  end

  def normalize_ranges
    normalize_range(:start_year, :end_year)
    normalize_range(:start_price, :end_price)
    normalize_range(:start_engine_value, :end_engine_value)
  end

  def normalize_range(min, max)
    min_value, max_value = attributes[min.to_s], attributes[max.to_s]
    return if [min_value, max_value].any?(&:blank?)

    if min_value.to_i > max_value.to_i
      send("#{min}=", max_value)
      send("#{max}=", min_value)
    end
  end
end
