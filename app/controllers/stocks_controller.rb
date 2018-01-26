class StocksController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'csv'
  require 'date'


  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end


  def search
    logger.debug("\nSearching....")
    # 検索フォームの入力内容で検索する
    @q = Stock.search(params[:q])
    # 重複を排除
    @products = @q.result(distinct: true)
    redirect_to stocks_show_path
  end

  def show
    @exdata = nil
    @account = Account.new
    @user = current_user.email
    @header_hash = Stock_fields
    gon.stocklist = Stock.all
    gon.codelist = Code.all
    if request.post? then
      @q = Stock.search(search_params)
      # 重複を排除
      @products = @q.result(distinct: true)

      if params[:export_button]
        fname = "在庫結果_" + (DateTime.now.strftime("%Y%m%d%H%M")) + ".csv"

        td = CSV.generate do |csv|

          csv_column_names = Stock_fields.values

          csv << csv_column_names
          @products.each do |tary|
            csv_column_values = []
            Stock_fields.each_key{|key|
              csv_column_values.push(tary[key])
            }
            csv << csv_column_values
          end
        end
        send_data td, filename: fname, type: :csv
      end
    else
      @q = Stock.search
      @products = nil
    end
  end

  def import
    csvfile = params[:file]
    header_check = ["在庫管理番号","仕入先","ブランド","箱","取説","タグ","紙確認",
      "新古","画像","入庫日","仕入値","型番","その他１","その他２","備考"]

    if csvfile != nil then
      csv = CSV.read(csvfile.path)
      if csv[0] == header_check then
        logger.debug("header ok")
        ps = Code.where(category: csv[0][1])
        br = Code.where(category: csv[0][2])
        bx = Code.where(category: "有無")
        mn = Code.where(category: "有無")
        tg = Code.where(category: "有無")
        pc = Code.where(category: "指示")
        cd = Code.where(category: "状態")

        for row in csv do
          if row[0] != "在庫管理番号" then
            target = Stock.find_or_create_by(stock_id:row[0])
            target.update(
              stock_id: row[0],
              purchase_shop: ps.find_by(number: row[1]).value,
              brand: br.find_by(number: row[2]).value,
              box: bx.find_by(number: row[3]).value,
              manual: mn.find_by(number: row[4]).value,
              tag: tg.find_by(number: row[5]).value,
              paper_check: pc.find_by(number: row[6]).value,
              condition: cd.find_by(number: row[7]).value,
              store_date: custom_parse(row[9]),
              image: row[8],
              purchase_price: row[10],
              product_id: row[11],
              other1: row[12],
              other2: row[13],
              note: row[15]
            )
          end
        end
      else
        logger.debug("not header")
      end
    end
    redirect_to stocks_show_path
  end

  def update
    csvfile = params[:file_e]
    pass_check = params[:password_in]
    logger.debug(pass_check)
    account = Account.all.first
    logger.debug(account)
    if account.authenticate(pass_check)
      if csvfile != nil then
        csv = CSV.table(csvfile.path)

        csv.each do |row|
          logger.debug(row[0])
          target = Stock.find_by(stock_id:row[0])
          if target != nil then
            target.delete
          end
        end

        logger.debug("complete")
        flash[:success] = "削除成功"
      end
    else
      logger.debug ("error")
      flash[:alarm] = "パスワードが違います"
    end
    redirect_to "/stocks/show#tab_e"
  end

  def export
    fname = "在庫結果_" + (DateTime.now.strftime("%Y%m%d%H%M")) + ".csv"
    send_data render_to_string, filename: fname, type: :csv
  end

  def load
    csvfile = params[:set_file]
    header_check = [:type,:code,:value]
    if csvfile != nil then
      csv = CSV.table(csvfile.path)
      logger.debug(csv.headers)
      logger.debug(header_check)
      if csv.headers == header_check then
        logger.debug("header is ok")
        csv.each do |row|
          logger.debug(row[:type].to_s + " " + row[:code].to_s + " " + row[:value].to_s)
          target = Code.find_or_create_by(value:row[:value])
          target.update(
            number: row[:code],
            category: row[:type],
            value: row[:value]
          )
        end
      end
    end
    gon.codelist = Code.all
    redirect_to stocks_show_path
  end

  def setpw
    logger.debug("recieved")
    logger.debug(params[:password])

    account = Account.all.first
    if account.authenticate(params[:password])
      logger.debug("Success!!!!!")
      logger.debug(params[:new_password])
      account.update(
        password: params[:new_password]
      )
      redirect_to "/stocks/show#tab_d", notice: 'パスワード変更に成功しました'
    else
      logger.debug("Noooooooooooooo!!!!!")
      redirect_to "/stocks/show#tab_d", alert: 'パスワード変更に失敗'
    end

  end


  # 文字列を日付に変換
  private def custom_parse(str)
    date = nil
    if str && !str.empty? #railsなら、if str.present? を使う
      begin
        date = DateTime.parse(str).to_s
      # parseで処理しきれない場合
      rescue ArgumentError
        formats = ['%Y:%m:%d %H:%M:%S'] # 他の形式が必要になったら、この配列に追加
        formats.each do |format|
          begin
            date = DateTime.strptime(str, format)
            break
          rescue ArgumentError
          end
        end
      end
    end
    return date
  end

  def search_params
    params.require(:q).permit!
  end

end
