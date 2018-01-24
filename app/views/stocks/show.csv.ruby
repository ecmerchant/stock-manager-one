require 'csv'

CSV.generate do |csv|

  csv_column_names = %w(氏名 アドレス 番号 ステータス)
     #%w(氏名 アドレス)はrubyのリテラルの一つで、["氏名","アドレス"]と同値になります。
  csv << csv_column_names
  @products.each do |tary|
    csv_column_values = []
    for f in tary
      csv_column_values.push(mic[f])
    end
    csv << csv_column_values
  end
end
