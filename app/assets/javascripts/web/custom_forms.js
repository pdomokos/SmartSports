function custom_loaded() {
    console.log("custom_loaded called, start initializing");
    popup_messages = JSON.parse($("#popup-messages").val())

    registerCustomHandlers();
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
    $(".cficon").click(function(e) {
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
        document.getElementById("custom-create-form").submit();
    });

    $("#recentResourcesTable").on("ajax:success", function(e, data, status, xhr) {
            loadCustomForms();
            //popup_success(popup_messages.delete_data_success);
        }
    ).on("ajax:error", function(e, xhr, status, error) {
            msg = JSON.parse(xhr.responseText);
            console.log(msg);
            popup_error(popup_messages.failed_to_delete_data);
        }
    );
}

