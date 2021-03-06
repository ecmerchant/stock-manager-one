
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
  var targetfile = document.getElementById('file_e');
  if(targetfile != null){
    targetfile.onchange = function(){
      var flabel = document.getElementById('fname_e');
      var fname = targetfile.value.replace(/\\/g, '/').replace(/.*\//, '');
      flabel.value = fname;
    }
  }

  //キーワード入力用テーブル
  var dd = gon.keylist;
  var maxRownum = 300;
  var mydata = [];
  var colOption = [{className: 'htCenter htMiddle'},{className: 'htMiddle'},{className: 'htCenter htMiddle'}];
  var cheaders = ["ASIN","キーワード","入力価格"];
  var maxColnum = cheaders.length;
  var colWidth = [120, 280, 120];

  if(dd != null){
    var dl = dd.length;
    if(dl < 100){
      dl = 100;
    }
    for(var i = 0; i < dl; i++){
      mydata[i] = [];
      if(dd[i] != null){
        mydata[i][0] = dd[i].asin;
        mydata[i][1] = dd[i].key;
        mydata[i][2] = dd[i].input_price;
      }else{
        mydata[i][0] = "";
        mydata[i][1] = "";
        mydata[i][2] = "";
      }
    }
  }else{
    for(var i = 0; i < maxRownum; i++){
      mydata[i] = [];
      for(var j = 0; j < maxColnum; j++){
        mydata[i][j] = "";
      }
    }
  }

  var keyword_container = document.getElementById('keyword_table');
  var keyword_handsontable = new Handsontable(keyword_container, {
    /* オプション */
    width: 600,
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
    manualColumnResize: true,
    autoColumnSize: false,
    colWidths: colWidth,
    className: "htMiddle",
    columns: colOption
  });

  //検索結果表示

  var resheader = ["ASIN","検索キー","入力価格","販売価格(＄)","商品名","商品URL","コンディション","アイテムID"]
  var init_data = [];
  init_data[0] = [];
  for(var ss = 0; ss < resheader.length; ss++ ){
    init_data[0][ss] = "";
  }

  var result_container = document.getElementById('result_table');
  var result_handsontable = new Handsontable(result_container, {
    /* オプション */
    width: 1000,
    height: 320,
    contextMenu: true,
    data: init_data,
    wordWrap: false,
    rowHeaders: true,
    colHeaders: resheader,
    maxCols: resheader.length,
    maxRows: 100000,
    columnSorting: true,
    sortIndicator: true,
    manualColumnResize: true,
    autoColumnSize: true,
    className: "htMiddle"
  });

  //ajax
  $("#search").click(function () {
    if(document.getElementById("search").innerText == "検索開始"){
      alert("eBayの情報取得を開始します");
      document.getElementById("search").innerText = "中断";
      document.getElementById("search").className = "btn btn-warning";
      document.getElementById("progress").value = "continue";
      repajax(0);
    }else{
      document.getElementById("search").innerText = "検索開始";
      document.getElementById("search").className = "btn btn-primary";
      document.getElementById("progress").value = "cancel";
    }
  });

  function repajax(colnum){

    var tempData = keyword_handsontable.getDataAtRow(colnum);
    var body = [];
    body[0] = tempData;
    body[1] = colnum;
    if(tempData[0] == ""){
      alert("終了しました");
      return;
    }
    body = JSON.stringify(body);
    myData = {data: body};

    if(document.getElementById("progress").value == "cancel"){
      alert("中断します")
      return;
    }

    $.ajax({
      url: "/items/search",
      type: "POST",
      data: myData,
      dataType: 'json',
      success: function (resData) {
        nd = [];
        for(var p = 0; p < resData.length; p++){
          nd[p] = [];
          nd[p] = [colnum, p, resData[p]]
        }
        result_handsontable.setDataAtCell(nd);
        result_handsontable.render();
        colnum++;
        repajax(colnum);
      },
      error: function (resData) {
        alert("failed");
      }
    });
  }

  $("#export").click(function () {
    var ck = [];
    ck[0] = document.getElementById("chk_asin").checked;
    ck[1] = document.getElementById("chk_key").checked;
    ck[2] = document.getElementById("chk_iprice").checked;
    ck[3] = document.getElementById("chk_sprice").checked;
    ck[4] = document.getElementById("chk_title").checked;
    ck[5] = document.getElementById("chk_url").checked;
    ck[6] = document.getElementById("chk_cond").checked;
    ck[7] = document.getElementById("chk_id").checked;

    var dc = [];
    var a = 0;
    for(var p = 0; p < 8; p++){
      if(ck[p] == true){
        ck[p] = "";
      }else{
        dc[a] = p;
        a++;
      }
    }
    var bom = new Uint8Array([0xEF, 0xBB, 0xBF]);
    var header = ["ASIN", "検索キー", "入力価格", "販売価格", "商品名", "商品URL","コンディション", "商品ID"];
    var content = result_handsontable.getData();
    var cc = [];
    if(dc[0] != null){
      for(var m = 0; m < dc.length; m++){
        header.splice(dc[m]-m,1);
      }
    }
    cc = header.join(",") + "\r\n";
    for(var c = 0; c < content.length; c++){
      if(dc[0] != null){
        for(var m = 0; m < dc.length; m++){
          content[c].splice(dc[m]-m,1);
        }
      }
      cc = cc + content[c].join(",") + "\r\n";
    }
    var date = new Date();
    var td = formatDate(date, 'yyyyMMddHHmm')
    document.getElementById("export").download = "検索結果_" + td + ".csv";
    var blob = new Blob([ bom, cc ], { "type" : "text/csv" });
    document.getElementById("export").href = window.URL.createObjectURL(blob);
  });

  //タブ切り替え時にリロード

  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    var activated_tab = e.target // activated tab
    var previous_tab = e.relatedTarget // previous tab
    keyword_handsontable.render();
    result_handsontable.render();
  })

})

function formatDate (date, format) {
  format = format.replace(/yyyy/g, date.getFullYear());
  format = format.replace(/MM/g, ('0' + (date.getMonth() + 1)).slice(-2));
  format = format.replace(/dd/g, ('0' + date.getDate()).slice(-2));
  format = format.replace(/HH/g, ('0' + date.getHours()).slice(-2));
  format = format.replace(/mm/g, ('0' + date.getMinutes()).slice(-2));
  format = format.replace(/ss/g, ('0' + date.getSeconds()).slice(-2));
  format = format.replace(/SSS/g, ('00' + date.getMilliseconds()).slice(-3));
  return format;
};
