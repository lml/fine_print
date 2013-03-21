function fine_print_init_dialog(index, width, height) {
  $("#fine_print_dialog_" + index).dialog({
    autoOpen: false,
    draggable: false,
    modal: true,
    resizable: false,
    width: width,
    height: height
  }).on("dialogbeforeclose", function(event, ui) {
    window.history.back();
    return false;
  });
}

$(function () {
  try {
    $("#fine_print_dialog_0").dialog("open");
  }
  catch(e) {}
});
