function custom_loaded() {
    console.log("custom_loaded called, start initializing");
    popup_messages = JSON.parse($("#popup-messages").val())

    registerCustomHandlers();
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
            console.log("load recent diets AJAX Error: " + textStatus);
        },
        success: function (data, textStatus, jqXHR) {
            $(".deleteDiet").removeClass("hidden");
        }
    });

}

function registerCustomHandlers() {
    $("#customFormIcons").on('click', '.cficon', function(e) {
        var cfid = e.currentTarget.dataset.customformid;
        location.href = location.href+"/"+cfid;
    });

    $(".iconSelect").click(function(e){
        imgid = e.currentTarget.id;
        $("#iconselect ul li").removeClass("customiconselected");
        $("#"+imgid).parent('li').addClass("customiconselected");
        console.log("datasel: "+ e.currentTarget.dataset.icon);
        $("#custom-create-form input[name='custom_form[image_name]']").val(imgid);
    });

    $("#save-custom-form").click(function () {

        var current_user = $("#current-user-id")[0].value;
        var url = '/users/' + current_user + '/custom_forms';

        $.ajax({
            url:  url,
            type: 'POST',
            data: $("#custom-create-form").serialize(),
            error: function (jqXHR, textStatus, errorThrown) {
                console.log("load recent diets AJAX Error: " + textStatus);
            },
            success: function (data, textStatus, jqXHR) {
                loadCustomForms();
                $("#addCustomModal").modal('toggle');
            }
        });
    });
}
