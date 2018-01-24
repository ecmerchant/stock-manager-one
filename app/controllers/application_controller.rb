class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  Stock_fields = {
    stock_id: "在庫管理番号",
    store_date: "入庫日",
    purchase_price: "仕入値",
    purchase_shop: "仕入先",
    brand: "ブランド",
    product_id: "型番",
    box: "箱",
    manual: "取説",
    tag: "タグ",
    paper_check: "紙確認",
    condition: "状態",
    other1: "その他1",
    other2: "その他2",
    note: "備考",
    image: "画像"
  }

end
