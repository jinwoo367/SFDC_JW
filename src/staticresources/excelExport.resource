var tablesToExcel = (function() {
var uri = 'data:application/vnd.ms-excel;base64,'
, tmplWorkbookXML = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">'
	+ '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office"><Created>{created}</Created></DocumentProperties>'
	+ '<Styles>'
	+ '<Style ss:ID="header"><Alignment ss:Horizontal="Center"/><Borders/><Font ss:Bold="1" ss:Size="10" /><Interior ss:Color="#DAEEF3" ss:Pattern="Solid"/><NumberFormat/><Protection/></Style>'
	+ '<Style ss:ID="number"><Alignment ss:Horizontal="Right"/><Borders/><Font ss:Size="10" /><Interior/><NumberFormat/><Protection/></Style>'
	+ '<Style ss:ID="text"><Alignment ss:Horizontal="Left"/><Borders/><Font ss:Size="10" /><Interior/><NumberFormat/><Protection/></Style>'
	+ '</Styles>'
	+ '{worksheets}</Workbook>'
, tmplWorksheetXML = '<Worksheet ss:Name="{nameWS}"><Table ss:DefaultColumnWidth="120">{columns}{rows}</Table></Worksheet>'
, tmplCellXML = '<Cell{attributeStyleID}{attributeFormula}><Data ss:Type="{nameType}">{data}</Data></Cell>'
, base64 = function(s) { return window.btoa(unescape(encodeURIComponent(s))) }
, format = function(s, c) { return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; }) }
	return function(wbName, listFieldset, listData) {
		var ctx = "";
		var workbookXML = "";
		var worksheetsXML = "";
		var rowsXML = "";
		var columnXML = "";
		var bApiDisplayYn = false;
		rowsXML += '<Row>';
		for(var i=0; i < listFieldset.length; i++){
			var fieldInfo = listFieldset[i];
			if(!bApiDisplayYn && fieldInfo.fAPIName != undefined && fieldInfo.fAPIName != ''){
				bApiDisplayYn = true;
			}
			ctx = { 
				attributeStyleID:' ss:StyleID="header"'
				, nameType:'String'
				, data:fieldInfo.fLabel
				, attributeFormula:''
			};
			rowsXML += format(tmplCellXML, ctx);
		}
		rowsXML += '</Row>';

		if(bApiDisplayYn){
			rowsXML += '<Row>';
			for(var i=0; i < listFieldset.length; i++){
				var fieldInfo = listFieldset[i];
				ctx = { 
					attributeStyleID:' ss:StyleID="header"'
					, nameType:'String'
					, data:fieldInfo.fAPIName
					, attributeFormula:''
				};
				rowsXML += format(tmplCellXML, ctx);
			}
			rowsXML += '</Row>';
			rowsXML += '<Row>';
            for(var i=0; i < listFieldset.length; i++){
                var fieldInfo = listFieldset[i];
                ctx = {
                    attributeStyleID:' ss:StyleID="header"'
                    , nameType:'String'
                    , data:fieldInfo.fSample
                    , attributeFormula:''
                };
                rowsXML += format(tmplCellXML, ctx);
            }
            rowsXML += '</Row>';
		}
		for(var i=0; i < listData.length; i++){
			var data = listData[i];
			console.log('data: ' + data);
			rowsXML += '<Row>';
			for(var j=0; j < listFieldset.length; j++){
				var fieldInfo = listFieldset[j];
				console.log('fieldInfo : ' + JSON.stringify(fieldInfo));
				var dataType = fieldInfo.fType;
				var dataStyle = '';
				console.log('fieldInfo.fAPIName :' + fieldInfo.fAPIName);
				var dataValue = data[fieldInfo.fAPIName];
				console.log('dataValue : ' + dataValue);
				if(dataType == 'number' || dataType == 'currency' || dataType == 'double') dataStyle = 'number';
				else if(dataType == 'currency') dataStyle = 'number';
				else dataStyle = 'text';
				ctx = { 
					attributeStyleID:' ss:StyleID="'+dataStyle+'"'
					, nameType:'String'
					, data:dataValue
					, attributeFormula:''
				};
				rowsXML += format(tmplCellXML, ctx);
			}
			rowsXML += '</Row>'
		}
		ctx = {columns:columnXML , rows: rowsXML, nameWS: wbName };
		worksheetsXML += format(tmplWorksheetXML, ctx);
		ctx = {created: (new Date()).getTime(), worksheets: worksheetsXML};
		workbookXML = format(tmplWorkbookXML, ctx);

		var link = document.createElement("A");
		link.href = uri + base64(workbookXML);
		link.download = wbName || 'Workbook.xlsx';
		link.target = '_blank';
		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);
  }
})();
var goBack = function(){
	window.history.back(-1);
}
var clearNum = 10;
var myTimer = setInterval(function () {
	clearNum--;
	j$("#checker").text(clearNum);
	if(clearNum == 0) {
		clearInterval(myTimer);
		goBack();
	}
}, 1000);