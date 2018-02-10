require 'csv'

CSV.generate(encoding: Encoding::SJIS) do |csv|

  @products.each do |tary|
    csv_column_values = []
    for f in tary
      csv_column_values.push(mic[f])
    end
    csv << csv_column_values
  end
end
