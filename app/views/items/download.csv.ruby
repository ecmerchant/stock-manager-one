require 'csv'
bom = "\uFEFF"

CSV.generate(bom, :row_sep => "\r\n") do |csv|

  headers = []
  cols = []

  if @item_id.present? then
    headers.push("商品ID")
    cols.push(:item_id)
  end

  if @title.present? then
    headers.push("商品名")
    cols.push(:title)
  end

  if @item_url.present? then
    headers.push("商品URL")
    cols.push(:item_url)
  end

  if @price.present? then
    headers.push("販売価格")
    cols.push(:price)
  end

  if @condition.present? then
    headers.push("コンディション")
    cols.push(:condition)
  end

  if @ship.present? then
    headers.push("配送期間")
    cols.push(:shipping)
  end

  spec_flg = false
  if @specs.present? then
    headers.push("ItemSpecs")
    cols.push(:item_specs)
    spec_flg = true
  end

  if headers.length > 0 then
    csv << headers
    data = @products.pluck(cols)
    data.each_slice(100) do |buf|
      buf.each do |tmp|
        csv << tmp
      end
    end
  end
end
