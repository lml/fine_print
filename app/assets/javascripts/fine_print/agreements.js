function fine_print_agreement_checkbox(index) {
  var checkbox = $("#fine_print_confirmation_checkbox_" + index);
  if (!checkbox) {
    return;
  }
  checkbox.change(function() {
    $("#fine_print_submit_ok_" + index).attr("disabled", !this.checked);
    try {
      if (this.checked) {
        $("#fine_print_submit_ok_" + index).button("enable");
      }
      else {
        $("#fine_print_submit_ok_" + index).button("disable");
      }
    }
    catch(e) {}
  });
  $("#fine_print_submit_ok_" + index).attr("disabled", !checkbox.checked);
}
