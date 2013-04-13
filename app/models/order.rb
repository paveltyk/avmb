class Order < NoTable
  attributes :price

  def to_criteria
    [:price_value, price.to_sym] if price.present?
  end

  def to_param
    {price: invert(price)}
  end

  def invert(val)
    val.to_s == 'asc' ? 'desc' : 'asc'
  end
end
