class StocksController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'csv'

  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def show
    @user = current_user.email
    gon.res = Stock.find(1)
  end

  def import
    csvfile = params[:file]
    header_check = [
      "在庫管理番号","仕入先","ブランド","箱","取説","タグ","紙確認",
      "新古","画像","入庫日","仕入値","型番","その他１","その他２","備考"]

    if csvfile != nil then
      csv = CSV.table(csvfile.path)
      if csv.headers == header_check then
        logger.debug("sku header")
        td = csv[:sku]
        ImportDataJob.perform_later(td,current_user.email)
      end
    end

  end

  def export
    @products1 = Product.where(user: current_user.email).where(restcheck: true)
    @products2 = Product.where(user: current_user.email).where(restcheck: false).where(bitcheck: true)
    @products3 = Product.where(user: current_user.email).where(restcheck: false).where(bitcheck: false)
    fname = "在庫結果_" + (DateTime.now.strftime("%Y%m%d%H%M")) + ".csv"
    send_data render_to_string, filename: fname, type: :csv
  end

  def load
    csvfile = params[:set_file]
    header_check = ["入力種別","コード","設定値"]
    if csvfile != nil then
      csv = CSV.read(csvfile.path)
      logger.debug(csv[0])
      logger.debug(header_check)
      if csv[0] == header_check then
        logger.debug("check1")
      end
    end
  end

end
