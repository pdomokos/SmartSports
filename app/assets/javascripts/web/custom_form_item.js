function custom_item_loaded() {
    console.log("custom_item_loaded called, start initializing");
    popup_messages = JSON.parse($("#popup-messages").val());

    initForms();
    registerCustomItemHandlers();
}

function initForms() {
    initDiet();
    initActivity();
    initMeasurement();
    init_genetics();
    initMedication();
    initLifestyle();
    init_genetics();
    initLabresult();
}

function refreshElements(userId, cfId, cb) {
    $.ajax({
        url: "/users/"+userId+"/custom_forms/"+cfId+"/custom_form_elements.js",
        type: 'GET',
        error: function (jqXHR, textStatus, errorThrown) {
            console.log("index cfe AJAX Error: " +errorThrown);
        },
        success: function (data, textStatus, jqXHR) {
            console.log("index cfe success");
            if(typeof(cb)=='function') {
                cb();
            }
        }
    });
}

function registerCustomItemHandlers() {

    $(".deleteCustomFormIcon").click(function (e) {
        console.log("delete cf item clicked, "+ e.target.parentElement.action);
        $.ajax({
            url: e.target.parentElement.action,
            type: 'DELETE',
            error: function (jqXHR, textStatus, errorThrown) {
                console.log("delete cf AJAX Error: " +errorThrown);
            },
            success: function (data, textStatus, jqXHR) {
                location.href=getParent(document.location.href);
            }
        });
    });

    $(".editCustomFormIcon").click(function (e) {
        console.log("edit cf item clicked, " + e.target.parentElement);
        $("#addFormGroup").removeClass('hidden');
        $("#showFormGroup").addClass('hidden');
    });

    $("#cancelQuestionButton").click(function (e) {
        console.log("cancel edit clicked, " + e.target.parentElement);
        $("#addFormGroup").addClass('hidden');
        $("#showFormGroup").removeClass('hidden');
        initForms();
    });

    var succ_fn = function(d, st, jq) {
        console.log("AJAX successful cfe: ");
        console.log(d);
        console.log(st);
        console.log(jq);
        console.log("^^^^^^^^^^^^^^^^^^^^^");
    };

    var err_fn =  function(d, st, jq) {
        console.log("AJAX error, cfe");
    };

    $("#addFormButton").click(function () {
        console.log("addFormButton clicked");
        console.log($(this));
        var form_ids = $(this)[0].dataset.elements.split(',');
        var cfId = $(this)[0].dataset.cform;
        var userId = $("#current-user-id").val();
        console.log(form_ids);
        var reqs = [];
        var i;
        var f;
        for(i in form_ids) {
            f = $("form.cfe-" + form_ids[i])[0];
            var validateName = "validate_"+f.dataset.formtype.split("_")[0]+"_form";
            var fn = window[validateName];
            if (typeof fn === "function") {
                console.log(validateName + "(\"#"+ f.id+"\") called");
                if(!fn("#"+f.id)) {
                    console.log("validate "+f.dataset.formtype+" failed" );
                    return;
                }
            } else {
                console.log(validateName + " missing");
            }
        }
        for(i in form_ids) {
            f = $("form.cfe-" + form_ids[i])[0];
            var id = f.id;
            console.log(""+i+" = ");
            console.log(f);
            reqs.push($.ajax({
                url: f.action,
                type: 'POST',
                data: $("#"+id).serialize()
            }).done(succ_fn)
                .fail(err_fn));
        }
        $.when.apply(undefined, reqs).then(function () {
            console.log("ALL COMPLETE");
            popup_success(popup_messages.save_success);
            refreshElements(userId, cfId, function(){initForms();});
        });
    });

    $("#form-add-element").submit(function (e) {
        console.log("add element clicked " + this);
        window.ctarget = e;
        var cfId = e.currentTarget.dataset.formid;
        var userId = $("#current-user-id").val();
        var url = "/users/"+userId+"/custom_forms/"+cfId+"/custom_form_elements";
        $.ajax({
            url: url,
            type: 'POST',
            data: $(this).serialize(),
            error: function (jqXHR, textStatus, errorThrown) {
                console.log("delete cfe AJAX Error: " +errorThrown);
            },
            success: function (data, textStatus, jqXHR) {
                refreshElements(userId, cfId);
            }
        });
        return false;
    });

    $("#customFormElementList").on('click', '.listDeleteIcon', function(e) {
        var cfeId = e.target.dataset.formelementid;
        var cfId = e.target.dataset.formid;
        var userId = $("#current-user-id").val();
        var url = "/users/"+userId+"/custom_forms/"+cfId+"/custom_form_elements/"+cfeId;
        console.log("del clicked :"+url);
        $.ajax({
            url: url,
            type: 'DELETE',
            error: function (jqXHR, textStatus, errorThrown) {
                console.log("delete cfe AJAX Error: " + textStatus);
            },
            success: function (data, textStatus, jqXHR) {
                refreshElements(userId, cfId);
            }
        });
    });
}

function getParent(url) {
    var arr = url.split("/");
    var len = arr.length;
    if(arr[len-1]==="") {
        len = len - 1;
    }
    return arr.slice(0, len-1).join("/");
}
