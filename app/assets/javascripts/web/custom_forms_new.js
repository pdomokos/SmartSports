function custom_loaded() {
    console.log("custom_loaded called, start initializing");
    //popup_messages = JSON.parse($("#popup-messages").val())
    loadCustomForms();
}


function loadCustomForms() {
    var self = this;
    var current_user = $("#current-user-id")[0].value;
    //var lang = $("#data-lang-diet")[0].value;
    var url = 'users/' + current_user + '/custom_forms.js';

    $.ajax({
        url: urlPrefix() + url,
        type: 'GET',
        error: function (jqXHR, textStatus, errorThrown) {
            console.log("load recent diets AJAX Error: "+textStatus);
        },
        success: function (data, textStatus, jqXHR) {
            $(".deleteDiet").removeClass("hidden");
        }
    });
}
