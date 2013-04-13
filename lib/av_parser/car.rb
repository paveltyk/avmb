# encoding: utf-8
class AvParser::Car
  ROOT_URL = 'http://av.by'
  attr_reader :id

  PARSE_RULES = {
      name: lambda { |b| b.main_doc.at_css('title').text.scan(/ПРОДАЖА АВТО \| AV\.BY  - (.+)/m).flatten.first },
      price: lambda { |b| b.main_doc.at_css('span.textprace').text.strip },
      year: lambda { |b| b.details.scan(%r{Год выпуска:\s+(\d{4})}m).flatten.first },
      engine_value: lambda { |b| b.details.scan(%r{Объем:\s+(\d+)}m).flatten.first },
      doors: lambda { |b| b.details.scan(%r{Дверей:\s+(\d+)}m).flatten.first },
      color: lambda {|b| b.details.scan(%r{Цвет:\s+([^\r]+)}m).flatten.first.strip },
      fuel_type: lambda { |b| b.details.scan(%r{Тип топлива:\s+([^\r]+)}m).flatten.first.strip },
      transmission: lambda { |b| b.details.scan(%r{Трансмиссия:\s+([^\r]+)}m).flatten.first.strip },
      drive_type: lambda { |b| b.details.scan(%r{Привод:\s+([^\r]+)}m).flatten.first.strip },
      body_type: lambda {|b| b.details.scan(%r{Тип кузова:\s+([^\r]+)}m).flatten.first.strip },
      cylinders_count: lambda { |b| b.details.scan(%r{Цилиндров:\s+([^\r]+)}m).flatten.first.strip },
      class_of_vehicle: lambda {|b| b.details.scan(%r{Класс:\s+([^\r]+)}m).flatten.first.strip },
      phone: lambda { |b| b.details.scan(/(\+375[^\r]+)       /).flatten.first.strip },
      message: lambda { |b| b.details.scan(/Дополнительная информация:(.*?)(?:Цена:|Физическое лицоЮридическое лицо)/m).flatten.first.strip },
      images: lambda { |b| b.img_doc.text.scan(%r{Photo\[\d{1}\] = '([^']+)';}).flatten },
      equipment: lambda { |b| b.details_doc.to_s.scan(/^   - (.*?)<br>/i).flatten },
      mileage_value: lambda { |b| b.details.scan(%r{Пробег, [^:]+:\s+(\d+)}m).flatten.first.strip },
      mileage_units: lambda { |b| b.details.scan(%r{Пробег, ([^:]+):\s+\d+}m).flatten.first.strip },
      country: lambda { |b| b.details.scan(%r{Страна нахождения а/м:\s+\n(.+)\n}).flatten.first.strip },
      city: lambda { |b| b.details.scan(%r{Страна нахождения а/м:\s+\n.+\n.+\n(.+)\n}).flatten.first.strip }
  }

  def initialize(id)
    @id = id
  end

  def method_missing(method, *args)
    if PARSE_RULES[method]
      begin
        PARSE_RULES[method].call(self)
      rescue => e
        msg = "Failed to get #{method} of car with vendor_id #{id}: #{e}"
        parsing_errors << msg

        puts msg
      end
    else
      super
    end
  end

  def parsing_errors
    @parsing_errors ||= []
  end

  def details
    @details ||= details_doc.text
  end

  def details_doc
    @details_doc ||= main_doc.at_css('#main_content table[align="center"][border="0"][cellpadding="2"][cellspacing="0"][width="100%"]')
  end

  def main_doc
    @main_doc ||= Nokogiri::HTML(open(main_doc_url).read)
  end

  def main_doc_url
    "#{ROOT_URL}/public/public.php?event=View&public_id=#{@id}"
  end

  def img_doc
    @img_doc ||= Nokogiri::HTML(open(img_doc_url).read)
  end

  def img_doc_url
    "#{ROOT_URL}/public/public.php?event=View_XXL&public_id=#{@id}"
  end
end
