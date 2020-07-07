class ItemsController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'typhoeus'
  require 'uri'
  require 'cgi'
  require 'rexml/document'

  def download
    if request.post? then
      item_id = params[:item_id]
      title = params[:title]
      item_url = params[:item_url]
      price = params[:price]
      condition = params[:condition]

      redirect_to '/items/get#tab_c'
    end
  end

  def get

    @user = current_user.email

    @group_id = nil
    @search_group = SearchGroup.where(user: @user)
    @products = nil

    if @search_group.length > 0 then
      @search_group = @search_group.last
      @group_id = @search_group.group_id
      @status = @search_group.status
      @products = Product.where(user: @user, group_id: @group_id)
    else
      @search_group = nil
      @status = "実行前"
    end

    @search_user = @user + "_detail"
    @condition = SearchCondition.find_or_create_by(user: @search_user)

    @search_keyword = params[:search_keyword]

    @sales_group = {
      '0: All': 'All',
      '1: Auction': 'Auction',
      '2: Auction with BIN': 'AuctionWithBIN',
      '3: Fixed Price (Buy It Now)': 'FixedPrice'
    }

    @condition_group = {
      '0: All': 1,
      '1: New': 1000,
      '2: Used': 3000
    }

    @category_group = {
      '0: All': -1,
      '1: Jewelry & Watches': 281,
      '2: Antiques': 20081,
      '3: Art': 550,
      '4: Cameras & Photo': 625,
      '5: Business & Industrial': 12576,
      '6: Books': 267,
      '7: Baby': 2984,
      '8: Cell Phones & PDAs': 15032,
      '9: Clothing, Shoes & Accessories': 11450,
      '10: Coins & Paper Money': 11116,
      '11: Collectibles': 1,
      '12: Computers & Networking': 58058,
      '13: Crafts': 14339,
      '14: Dolls & Bears': 237,
      '15: DVDs & Movies': 11232,
      '16: Electronics': 293,
      '17: Entertainment Memorabilia': 45100,
      '18: Gift Certificates': 31411,
      '19: Health & Beauty': 26395,
      '20: Home & Garden': 11700,
      '21: Music': 11233,
      '22: Musical Instruments': 619,
      '23: Pet Supplies': 1281,
      '24: Pottery & Glass': 870,
      '25: Sporting Goods': 382,
      '26: Sports Mem, Cards & Fan Shop': 64482,
      '27: Tickets': 1305,
      '28: Toys & Hobbies': 220,
      '29: Video Games': 1249
    }

    if request.post? then
      ProductSearchJob.perform_later(@search_keyword, @user)
      redirect_to '/items/get#tab_c'
    end

  end

  def show
    gon.keylist = Item.all
    @user = current_user.email
    @item = Item.find_by(user: current_user.email)
    @condition = SearchCondition.find_by(user: current_user.email)
    @sales_group = {
      '0: All': 'All',
      '1: Auction': 'Auction',
      '2: Auction with BIN': 'AuctionWithBIN',
      '3: Fixed Price (Buy It Now)': 'FixedPrice'
    }

    @condition_group = {
      '0: All': 1,
      '1: New': 1000,
      '2: Used': 3000
    }

    @category_group = {
      '0: All': -1,
      '1: Jewelry & Watches': 281,
      '2: Antiques': 20081,
      '3: Art': 550,
      '4: Cameras & Photo': 625,
      '5: Business & Industrial': 12576,
      '6: Books': 267,
      '7: Baby': 2984,
      '8: Cell Phones & PDAs': 15032,
      '9: Clothing, Shoes & Accessories': 11450,
      '10: Coins & Paper Money': 11116,
      '11: Collectibles': 1,
      '12: Computers & Networking': 58058,
      '13: Crafts': 14339,
      '14: Dolls & Bears': 237,
      '15: DVDs & Movies': 11232,
      '16: Electronics': 293,
      '17: Entertainment Memorabilia': 45100,
      '18: Gift Certificates': 31411,
      '19: Health & Beauty': 26395,
      '20: Home & Garden': 11700,
      '21: Music': 11233,
      '22: Musical Instruments': 619,
      '23: Pet Supplies': 1281,
      '24: Pottery & Glass': 870,
      '25: Sporting Goods': 382,
      '26: Sports Mem, Cards & Fan Shop': 64482,
      '27: Tickets': 1305,
      '28: Toys & Hobbies': 220,
      '29: Video Games': 1249
    }

    if @item == nil then
      @item = Item.new
    end

    logger.debug(@condition)
    if @condition == nil then
      logger.debug("User is not found")
      @condition = SearchCondition.new
    end
  end

  def search
    if request.post? then
      res = JSON.parse(params[:data])
      query = res[0]

      #検索条件の反映
      cuser = SearchCondition.find_by(user:current_user.email)
      appid = cuser.app_id
      cat = cuser.category_id
      lp = cuser.low_price
      hp = cuser.high_price
      cond = cuser.item_condition
      sale = cuser.sales_type
      rank = cuser.rank
      score = cuser.score
      handling_time = cuser.handling_time

      itemfilter = ""
      if sale == "All" then
        itemfiler = "&itemFilter(0).name=ListingType"\
                  + "&itemFilter(0).value(0)=FixedPrice"\
                  + "&itemFilter(0).value(1)=AuctionWithBIN"\
                  + "&itemFilter(0).value(2)=Auction"
      else
        itemfiler = "&itemFilter(0).name=ListingType"\
                  + "&itemFilter(0).value(0)=" + sale
      end

      if cond == "1" then
        itemfiler = itemfiler + "&itemFilter(1).name=Condition"\
                  + "&itemFilter(1).value(0)=1000"\
                  + "&itemFilter(1).value(1)=3000"\

      else
        itemfiler = itemfiler + "&itemFilter(1).name=Condition"\
                  + "&itemFilter(1).value(0)=" + cond
      end
      fnum = 2
      if score != nil then
        itemfiler = itemfiler + "&itemFilter(2).name=FeedbackScoreMin"\
                  + "&itemFilter(2).value(0)=" + score
        fnum = fnum + 1
      end

      if handling_time != nil then
        itemfiler = itemfiler + "&itemFilter(3).name=MaxHandlingTime"\
                  + "&itemFilter(3).value(0)=" + handling_time.to_i.to_s
        fnum = fnum + 1
      end

      if lp != nil then
        itemfiler = itemfiler + "&itemFilter(" + fnum.to_s + ").name=MinPrice"\
                  + "&itemFilter(" + fnum.to_s + ").value(0)=" + lp.to_s
        fnum = fnum + 1
      end

      if hp != nil then
        itemfiler = itemfiler + "&itemFilter(" + fnum.to_s + ").name=MaxPrice"\
                  + "&itemFilter(" + fnum.to_s + ").value(0)=" + hp.to_s
        fnum = fnum + 1
      end

      if cat == "-1" then
        endpoint  = "https://svcs.ebay.com/services/search/FindingService/v1?"\
                  + "OPERATION-NAME=findItemsAdvanced"\
                  + "&SECURITY-APPNAME=" + appid \
                  + "&RESPONSE-DATA-FORMAT=XML"\
                  + "&REST-PAYLOAD"\
                  + itemfiler\
                  + "&sortOrder=PricePlusShippingLowest"\
                  + "&keywords=" + URI.escape(query[1].encode("Shift_JIS")).gsub("+","%20")
      else
        endpoint  = "https://svcs.ebay.com/services/search/FindingService/v1?"\
                  + "OPERATION-NAME=findItemsAdvanced"\
                  + "&SECURITY-APPNAME=" + appid \
                  + "&RESPONSE-DATA-FORMAT=XML"\
                  + "&REST-PAYLOAD"\
                  + "&sortOrder=PricePlusShippingLowest"\
                  + itemfiler\
                  + "&categoryId=" + cat\
                  + "&keywords=" + URI.escape(query[1].encode("Shift_JIS")).gsub("+","%20")
      end

      charset = nil

      logger.debug("------------ Endpoint ---------------")
      logger.debug(endpoint)

      request = Typhoeus::Request.new(
        endpoint,
        method: :get
      )

      request.run
      res = request.response.body

      xml_doc = Nokogiri::XML(res)
      doc = REXML::Document.new(res)

      logger.debug("---------- Debug -----------")
      logger.debug(res)


      titems = xml_doc.xpath('itemId')


      dpath = doc.elements['findItemsAdvancedResponse/searchResult']

      spath = dpath.elements['item[' + String(rank) + ']']
      if spath != nil then
        logger.debug("Item Found")
        title = spath.elements['title'].text
        itemid = spath.elements['itemId'].text
        price = spath.elements['sellingStatus/convertedCurrentPrice'].text
        condi = spath.elements['condition/conditionDisplayName'].text
        ur = spath.elements['viewItemURL'].text
        ship = spath.elements['shippingInfo/handlingTime'].text
      else
        logger.debug("no item")
        title = "該当なし"
        itemid = ""
        price = ""
        condi = ""
        ur = ""
        ship = ""
      end
      logger.debug(title)

      buf = [
        query[0],
        query[1],
        query[2],
        price,
        title,
        ur,
        condi,
        ship,
        itemid
      ]
      render json:buf
    end
  end

  def save
    logger.debug("===================")
    logger.debug("Start save process")
    if request.post? then
      logger.debug(params[:search_condition])
      @condition = SearchCondition.find_or_initialize_by(user: current_user.email)
      @condition.update(user_params)
    else request.patch?
      @condition = SearchCondition.find_or_initialize_by(user: current_user.email)
      @condition.update(user_params)
    end
    redirect_to items_show_path
  end

  def update
    logger.debug("===================")
    @user = current_user.email
    search_user = @user + "_detail"
    if request.post? then
      logger.debug(params[:search_condition])
      @condition = SearchCondition.find_by(user: search_user)
      @condition.update(user_params)
    end
    redirect_to items_get_path
  end

  def delete
    Item.delete_all
    redirect_to items_show_path
  end

  def load
    csvfile = params[:file_e]
    header_check = [:asin,:keyword,:price]
    if csvfile != nil then
      csv = CSV.table(csvfile.path, encoding: "Shift_JIS:UTF-8")
      logger.debug(csv.headers)
      logger.debug(header_check)
      if csv.headers == header_check then
        logger.debug("header is ok")
        csv.each do |row|
          logger.debug(row[:asin].to_s + " " + row[:keyword].to_s + " " + row[:price].to_s)
          Item.create(
            user: current_user.email,
            asin: row[:asin],
            key: row[:keyword],
            input_price: row[:price]
          )
        end
      end
    end
    redirect_to items_show_path
  end

  private def user_params
    params.require(:search_condition).permit(:app_id, :low_price, :high_price, :handling_time, :category_id, :item_condition, :rank, :sales_type, :score, :user)
  end

end
