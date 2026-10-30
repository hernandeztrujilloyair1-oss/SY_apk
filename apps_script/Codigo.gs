// GOOGLE APPS SCRIPT - API INTEGRAL SEGUROS (ESTILO APPSHEET / WORKFLOW CENTRAL)
// Pestañas requeridas: BASE, ALTAS-BAJAS, COTIZADO

function doGet(e) {
  var action = (e && e.parameter && e.parameter.action) ? e.parameter.action : "getPolizas";
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  
  if (action === "getPolizas") {
    var sheet = ss.getSheetByName("BASE") || ss.getSheets()[0];
    var data = sheet.getDataRange().getValues();
    if (data.length <= 1) return responseJSON([]);
    var headers = data[0];
    var list = [];
    for (var i = 1; i < data.length; i++) {
      var row = data[i];
      var item = {};
      for (var j = 0; j < headers.length; j++) {
        item[headers[j]] = row[j];
      }
      list.push(item);
    }
    return responseJSON(list);
  }
  
  return responseJSON({ error: "Accion no reconocida" });
}

function doPost(e) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var postData = JSON.parse(e.postData.contents);
  var action = postData.action || "guardarPoliza";
  
  if (action === "guardarPoliza") {
    var sheetBase = ss.getSheetByName("BASE") || ss.getSheets()[0];
    
    // Regla de negocio: Determinar Persona Moral si titulo esta vacio o RFC de 12
    var rfc = (postData.RFC || "").toString().replace(/\s+/g, "").replace(/-/g, "");
    var titular = postData.Titular || "";
    var tipoPersona = (rfc.length === 12 || !postData.Titulo) ? "MORAL" : "FISICA";
    
    // Validacion de aviso y cobro
    var aviso = postData.Aviso_Estado || "1°";
    
    sheetBase.appendRow([
      postData.ID_Poliza || ("POL-" + new Date().getTime().toString().slice(-6)),
      aviso,
      postData.Numero_Poliza || "",
      titular,
      rfc,
      postData.Aseguradora || "",
      postData.Ramo_o_Rubro || "Autos",
      postData.Bien_Asegurado || "",
      postData.Serie || "",
      postData.Placas || "",
      postData.Inicio_Vigencia || "",
      postData.Fin_Vigencia || "",
      parseFloat(postData.Prima_Neta || 0),
      postData.Forma_Pago || "Anual",
      postData.Clave_Agente_Asignada || "",
      postData.Vendedor || "SR RAUL",
      postData.Tipo_Vendedor || "Interno",
      postData.Expediente_Completo_492 || "PENDIENTE",
      postData.Es_Renovacion ? "SI" : "NO",
      postData.Poliza_Renovada_Numero || "",
      postData.Atendio || "Yair Hernández",
      new Date(), // Invisible Audit Timestamp
      tipoPersona
    ]);
    
    // Si se traslada a ALTAS-BAJAS se elimina la columna C (Control de cobranza) segun regla
    var sheetAltas = ss.getSheetByName("ALTAS-BAJAS");
    if (sheetAltas) {
      sheetAltas.appendRow([
        postData.ID_Poliza || "",
        aviso,
        // Columna C omitida
        titular,
        rfc,
        postData.Aseguradora || "",
        postData.Ramo_o_Rubro || "Autos",
        postData.Bien_Asegurado || "",
        postData.Serie || "",
        postData.Placas || "",
        postData.Inicio_Vigencia || "",
        postData.Fin_Vigencia || "",
        parseFloat(postData.Prima_Neta || 0),
        new Date()
      ]);
    }
    
    return responseJSON({ status: "success", id: postData.ID_Poliza });
  }
  
  return responseJSON({ error: "Comando invalido" });
}

function responseJSON(data) {
  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
