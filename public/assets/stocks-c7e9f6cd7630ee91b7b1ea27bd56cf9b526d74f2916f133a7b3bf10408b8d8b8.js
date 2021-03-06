
//HTML読込後に実行
window.addEventListener('DOMContentLoaded', function() {

  $(document).ready(function() {
  // #(ハッシュ)指定されたタブを表示する
    var hashTabName = document.location.hash;
    if (hashTabName) {
      $('.nav-tabs a[href="' + hashTabName + '"]').tab('show');
    }
  });

  //インポートするファイル名の表示
  var targetfile = document.getElementById('file');
  if(targetfile != null){
    targetfile.onchange = function(){
      var flabel = document.getElementById('fname');
      var fname = targetfile.value.replace(/\\/g, '/').replace(/.*\//, '');
      flabel.value = fname;
    }
  }
  //インポートするファイル名の表示
  var targetfile3 = document.getElementById('file_e');
  if(targetfile3 != null){
    targetfile3.onchange = function(){
      var flabel3 = document.getElementById('fname_e');
      var fname3 = targetfile3.value.replace(/\\/g, '/').replace(/.*\//, '');
      flabel3.value = fname3;
    }
  }
  //在庫管理表のデーブル表示
  var dd = gon.stocklist;
  var maxRownum = 9600;
  var mydata = [];
  var colOption = [];
  var cheaders = ["在庫管理番号","入庫日","仕入値","仕入先","種別","棚情報","ブランド","型番","箱","取説","タグ","その他1","その他2","紙確認","新古","備考","画像"];
  var maxColnum = cheaders.length;
  var colWidth = [];

  if(dd != null){
    for(var i = 0; i < dd.length; i++){
      mydata[i] = [];
      mydata[i][0] = dd[i].stock_id;
      mydata[i][1] = dd[i].store_date;
      mydata[i][2] = dd[i].purchase_price;
      mydata[i][3] = dd[i].purchase_shop;
      mydata[i][4] = dd[i].category;
      mydata[i][5] = dd[i].place;
      mydata[i][6] = dd[i].brand;
      mydata[i][7] = dd[i].product_id;
      mydata[i][8] = dd[i].box;
      mydata[i][9] = dd[i].manual;
      mydata[i][10] = dd[i].tag;
      mydata[i][11] = dd[i].other1;
      mydata[i][12] = dd[i].other2;
      mydata[i][13] = dd[i].paper_check;
      mydata[i][14] = dd[i].condition;
      mydata[i][15] = dd[i].note;
      mydata[i][16] = dd[i].image;
    }
  }else{
    for(var i = 0; i < maxRownum; i++){
      mydata[i] = [];
      for(var j = 0; j < maxColnum; j++){
        mydata[i][j] = "";
      }
    }
  }

  for(var i = 0; i < maxColnum; i++){
    colOption[i] = {className: 'htCenter htMiddle'};
    colWidth[i] = 80;
  }

  var stock_container = document.getElementById('stock_data');
  var stock_handsontable = new Handsontable(stock_container, {
    /* オプション */
    width: 1140,
    height: 320,
    contextMenu: true,
    data: mydata,
    wordWrap: false,
    rowHeaders: true,
    colHeaders: cheaders,
    maxCols: maxColnum,
    maxRows: maxRownum,
    columnSorting: true,
    sortIndicator: true,
    //fixedColumnsLeft: 7,
    manualColumnResize: true,
    autoColumnSize: false,
    colWidths: colWidth,
    rowHeights:40,
    className: "htMiddle",
    columns: colOption
  });

  ////////
  //設定ファイルの表示
  var res = gon.codelist;
  var maxRownum2 = 1000;
  var mydata2 = [];
  var colOption2 = [];
  var cheaders2 = ["入力種別","コード","設定値"];
  var maxColnum2 = cheaders2.length;
  var colWidth2 = [];

  if(res != null){
    for(var i = 0; i < res.length; i++){
      mydata2[i] = [];
      mydata2[i][0] = res[i].category;
      mydata2[i][1] = res[i].number;
      mydata2[i][2] = res[i].value;
    }
  }else{
    for(var i = 0; i < maxRownum2; i++){
      mydata2[i] = [];
      for(var j = 0; j < maxColnum2; j++){
        mydata2[i][j] = "";
      }
    }
  }

  for(var i = 0; i < maxColnum2; i++){
    colOption2[i] = {className: 'htCenter htMiddle'};
    colWidth2[i] = 80;
  }

  var setting_container = document.getElementById('setting_data');
  var setting_handsontable = new Handsontable(setting_container, {
    /* オプション */
    width: 400,
    height: 280,
    contextMenu: true,
    data: mydata2,
    wordWrap: false,
    rowHeaders: true,
    colHeaders: cheaders2,
    maxCols: maxColnum2,
    maxRows: maxRownum2,
    columnSorting: true,
    sortIndicator: true,
    //fixedColumnsLeft: 7,
    manualColumnResize: true,
    autoColumnSize: false,
    colWidths: colWidth2,
    rowHeights:40,
    className: "htMiddle",
    columns: colOption2
  });
  ////////////
  //タブ切り替え時にリロード

  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    var activated_tab = e.target // activated tab
    var previous_tab = e.relatedTarget // previous tab
    stock_handsontable.render();
    setting_handsontable.render();
  })
  
  //インポートするファイル名の表示
  var targetfile2 = document.getElementById('set_file');
  targetfile2.onchange = function(){
    var flabel2 = document.getElementById('set_fname');
    var fname2 = targetfile2.value.replace(/\\/g, '/').replace(/.*\//, '');
    flabel2.value = fname2;
  }

})
;
