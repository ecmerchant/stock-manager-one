class Product < ApplicationRecord

    require 'typhoeus'
    require 'uri'
    require 'rexml/document'

    def self.search(query, user)
      logger.debug("============== Item Search =================")
      search_user = user + "_detail"
      search_condition = SearchCondition.find_by(user: search_user)

      group_id = Time.zone.now.strftime("%Y%m%d%H%M")

      appid = search_condition.app_id.to_s
      cat = search_condition.category_id.to_s
      lp = search_condition.low_price.to_s
      hp = search_condition.high_price.to_s
      cond = search_condition.item_condition.to_s
      sale = search_condition.sales_type.to_s
      rank = search_condition.rank.to_s
      score = search_condition.score.to_s
      handling_time = search_condition.handling_time.to_s

      search_group = SearchGroup.create(
        user: user,
        group_id: group_id,
        query: query,
        low_price: lp,
        high_price: hp,
        category_id: cat,
        item_condition: cond,
        sales_type: sale,
        rank: rank,
        score: score,
        handling_time: handling_time,
        status: "データ取得開始"
      )

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
                  + "&keywords=" + URI.escape(query.encode("Shift_JIS")).gsub("+","%20")
      else
        endpoint  = "https://svcs.ebay.com/services/search/FindingService/v1?"\
                  + "OPERATION-NAME=findItemsAdvanced"\
                  + "&SECURITY-APPNAME=" + appid \
                  + "&RESPONSE-DATA-FORMAT=XML"\
                  + "&REST-PAYLOAD"\
                  + "&sortOrder=PricePlusShippingLowest"\
                  + itemfiler\
                  + "&categoryId=" + cat\
                  + "&keywords=" + URI.escape(query.encode("Shift_JIS")).gsub("+","%20")
      end

      charset = nil

      logger.debug("------------ Endpoint ---------------")
      logger.debug(endpoint)


      #pagination
      total_page = 1
      current_page = 1

      product_list = []
      counter = 0

      (1..100).each do |page_num|
        url = endpoint + "&paginationInput.pageNumber=" + page_num.to_s
        logger.debug("------------ Url ---------------")
        logger.debug(url)

        request = Typhoeus::Request.new(
          url,
          method: :get
        )

        request.run
        res = request.response.body

        xml_doc = Nokogiri::XML(res)
        doc = REXML::Document.new(res)
        items = doc.get_elements('//findItemsAdvancedResponse/searchResult/item')

        total_page = doc.get_elements('//findItemsAdvancedResponse/paginationOutput/totalPages')[0].text
        current_page = doc.get_elements('//findItemsAdvancedResponse/paginationOutput/pageNumber')[0].text

        item_hash = {}

        items.each do |buf|
          title = buf.elements['title'].text
          item_id = buf.elements['itemId'].text
          price = buf.elements['sellingStatus/convertedCurrentPrice'].text
          condition = buf.elements['condition/conditionDisplayName'].text
          item_url = buf.elements['viewItemURL'].text
          ship = buf.elements['shippingInfo/handlingTime'].text

          request = Typhoeus::Request.new(
            item_url,
            method: :get
          )
          request.run
          res = request.response.body

          doc = Nokogiri::HTML.parse(res, nil)
          temp = doc.css("div.section")
          temp1 = temp.css("tr")
          item_specs = {}

          temp1.each do |tp|
            if tp.css("td.attrLabels")[0] != nil then
              label = tp.css("td.attrLabels")[0].text
              spec = tp.css("td")[1].text
              if spec.include?(":") then
                spec = spec.match(/^([\s\S]*?):/)[1]
              end

              if label.include?(":") then
                label = label.match(/^([\s\S]*?):/)[1]
              end

              label.strip!
              spec.strip!
              item_specs[label] = spec
            else
              if tp.css("b")[0] != nil then
                label = tp.css("th")[0].text
                spec = tp.css("b")[0].text
                if spec.include?(":") then
                  spec = spec.match(/^([\s\S]*?):/)[1]
                end

                if label.include?(":") then
                  label = label.match(/^([\s\S]*?):/)[1]
                end

                label.strip!
                spec.strip!
                item_specs[label] = spec
              end
            end
          end

          sp = JSON.generate(item_specs)

          product_data = {
            user: user,
            item_id: item_id,
            title: title,
            price: price,
            condition: condition,
            shipping: ship,
            item_url: item_url,
            item_specs: sp,
            group_id: group_id
          }

          if item_hash.has_key?(item_id) == false then
            product_list << Product.new(product_data)
            item_hash[item_id] = title
          end
          #logger.debug(product_data)

          counter += 1
          search_group.update(
            status: "データ取得中 " + counter.to_s + "件済み"
          )
        end

        search_group.update(
          status: "データ取得中 " + counter.to_s + "件済み"
        )

        Product.import product_list, on_duplicate_key_update: {constraint_name: :product_upsert, columns: [:title, :price, :condition, :shipping, :item_url, :item_specs]}

        logger.debug(total_page)
        logger.debug(current_page)

        if current_page.to_i >= total_page.to_i then
          search_group.update(
            status: "データ取得完了 合計" + counter.to_s + "件"
          )
          return
        end
      end
      search_group.update(
        status: "データ取得完了 合計" + counter.to_s + "件"
      )
    end

end
