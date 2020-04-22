# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Stock.create(
  stock_id: "9784569648958",
  store_date: "2018/01/12",
  ship_date: "2018/06/30",
  purchase_price: 5000,
  purchase_shop: "ebay",
  brand: "CITIZEN",
  product_id: "AO9006-52A",
  box: "有り",
  manual: "有り",
  tag: "有り",
  other1: "test case",
  other2: "",
  paper_check: "OK",
  condition: "新品",
  note: "これはテストデータです",
  image: 1
)
