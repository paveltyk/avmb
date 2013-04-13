# encoding: utf-8
class AvParser::List
  ROOT_URL = 'http://av.by'

  def ids
    @ids ||= main_doc.css('font[color="#7FAAE0"] b').map{ |node| node.text.gsub('#', '').strip.to_i }
  end

  private

  def main_doc
    @main_doc ||= Nokogiri::HTML(open(main_doc_url).read)
  end

  def main_doc_url
    "#{ROOT_URL}/public/index.php?last_id=5&show_new=0&page=2"
  end
end
