# encoding: utf-8
module ApplicationHelper
  def car_name_autocomplete_source
    @car_name_autocomplete_source ||= Blurb.distinct_car_names.to_json
  end

  def value_to_human(value)
    units = {unit: 'mL', thousand: 'L'}

    number_to_human(value.to_i, format: '%n%u', units: units)
  end

  def price_to_human(price)
    units = {unit: '', thousand: 'k', million: 'm', billion: 'b', trillion: 't', quadrillion: 'q'}

    number_to_human(price.to_i, format: '%n%u', units: units)
  end

  def engine_value_options_for_select
    [600, 800, 1000, 1400, 1800, 2200, 3000, 4000, 5000, 6500, 8000, 10000, 12000].map do |el|
      [value_to_human(el), el.to_s]
    end
  end

  def price_options_for_select
    [1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000, 25000, 30000, 40000, 50000, 60000, 80000, 100000].map do |el|
      [price_to_human(el), el.to_s]
    end
  end

  def year_options_for_select
    small_years = [1960, 1970, 1980, 1990, 1992, 1995, 1997, 1999]
    big_years = (small_years.last..Date.today.year).to_a[1..-1]

    (small_years + big_years).map(&:to_s).reverse
  end

  def fuel_type_options_for_select
    Blurb.fuel_type_options
  end

  def transmission_options_for_select
    Blurb.transmission_options
  end

  def body_type_options_for_select
    Blurb.body_type_options
  end

  def equipment_options_for_select
    EquipmentOption.all.map(&:name)
  end

  def equipment_options_shortener(options)
    options ||= []
    subst = {
      'ABS (антиблокировочная система)' => 'ABS', 'EBD (система э/распределения тормозных усилий)' => 'EBD',
      'ESP (система поддержания динамической стабильности)' => 'ESP', 'EBS (Система помощи при экстренном торможении)' => 'EBS',
      'HAS (система контроля подъема в гору)' => 'HAS', 'HDC (система контроля спуска с горы)' => 'HDC',
      'багажник на крыше (релинги)' => 'релинги', 'CD/MP3 проигрыватель' => 'CD/MP3', 'CD-проигрыватель' => 'CD'
    }

    options.map{ |o| subst[o] || o }
  end

  def sms_step_element_class(step, current_step)
    Array.new.tap do |arr|
      arr << 'btn-info' if step == current_step
      arr << 'incomplete' if current_step && current_step.to_i < step
      arr << 'hidden-phone' if current_step && step != current_step
    end.compact.join(' ')
  end

  def phone(phone)
    '+375 %d %d %d %d' % phone.to_s.scan(/\+375(\d{2})(\d{3})(\d{2})(\d{2})/).flatten rescue nil
  end

  def mobile_device?
    mobile_user_agents = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                         'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                         'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                         'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                         'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                         'mobile'
    request.user_agent.to_s.downcase =~ Regexp.new(mobile_user_agents)
  end

  def sms_gateway
    if Rails.env.production?
      {phone: '1151', code: '157814', price: '9,900'}
    else
      {phone: '1141', code: '157082', price: '6,900'}
    end
  end

  def render_flash_messages
    html = ''
    flash.each do |type, msg|
      html << content_tag(:div, msg, class: "alert alert-#{type}")
    end

    html.html_safe
  end

  def render_errors_for(model)
    html = ''
    model.errors.full_messages.each do |msg|
      html << content_tag(:div, msg, class: "alert alert-error")
    end

    html.html_safe
  end
end
