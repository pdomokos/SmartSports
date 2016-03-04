function admin_doctors_loaded() {
    console.log("admin doctors loaded");
    $("div.app2Menu a.menulink").removeClass("menulink-selected");
    $("#doctors-link").addClass("menulink-selected");
}