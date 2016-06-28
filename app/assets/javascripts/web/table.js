function show_table(url, lang, header, fnName, fnName2) {
    this.lang = lang;
    this.url = url;
    console.log("datatable clicked");
    console.log(url);
    $.ajax({
        url: urlPrefix() + url,
        type: 'GET',
        error: function (jqXHR, textStatus, errorThrown) {
            console.log("datatable activity AJAX Error: #{textStatus}");
        },
        success: function (data, textStatus, jqXHR) {
            var get_table_row = window[fnName];
            if (typeof get_table_row === "function") {
                var tblData = $.map(data, function (item, i) {
                    return([get_table_row(item)]);
                }).filter(function (v) {
                    return(v != null);
                });
            }
            if (lang == 'hu') {
                var plugin = {
                    sEmptyTable: "Nincs rendelkezésre álló adat",
                    sInfo: "Találatok: _START_ - _END_ Összesen: _TOTAL_",
                    sInfoEmpty: "Nulla találat",
                    sInfoFiltered: "(_MAX_ összes rekord közül szűrve)",
                    sInfoPostFix: "",
                    sInfoThousands: " ",
                    sLengthMenu: "_MENU_ találat oldalanként",
                    sLoadingRecords: "Betöltés...",
                    sProcessing: "Feldolgozás...",
                    sSearch: "Keresés:",
                    sZeroRecords: "Nincs a keresésnek megfelelő találat",
                    oPaginate: {
                        sFirst: "Első",
                        sPrevious: "Előző",
                        sNext: "Következő",
                        sLast: "Utolsó"
                    },
                    oAria: {
                        sSortAscending: ": aktiválja a növekvő rendezéshez",
                        sSortDescending: ": aktiválja a csökkenő rendezéshez"
                    }
                }
            }
            var show_table = window[fnName2];
            if (typeof show_table === "function") {
                show_table(tblData, header, plugin);
            }

        }
    });
}

function get_diet_table_row(item) {
    var ret = [moment(item.date).format("YYYY-MM-DD HH:MM"), item.category, item.name, item.amount1, item.amount2];
    return ret;
}

function get_exercise_table_row(item) {
    var ret = [moment(item.date).format("YYYY-MM-DD HH:MM"), item.name, item.intensity, item.duration, item.calories];
    return ret;
}

function get_measurement_table_row(item) {
    var ret = ([moment(item.date).format("YYYY-MM-DD HH:MM"), item.type, item.value]);
    return ret;
}

function get_medication_table_row(item) {
    var ret = [moment(item.date).format("YYYY-MM-DD HH:MM"), item.category, item.name, item.amount];
    return ret;
}

function get_lifestyle_table_row(item) {
    var ret = [moment(item.date).format("YYYY-MM-DD HH:MM"), item.category, item.type, item.property1, item.property2];
    return ret;
}

function get_genetics_table_row(item) {
    var ret = [item.type, item.diabetes_key, item.property1, item.property2, item.property3, item.property4];
    return ret;
}

function get_labresult_table_row(item) {
    var ret = [moment(item.date).format("YYYY-MM-DD HH:MM"), item.category, item.value];
    return ret;
}

function show_exercise_table(tblData, header, plugin) {
    $("#exercise-data-container").html("<table id=\"exercise-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>");
    $("#exercise-data").dataTable({
        data: tblData,
        columns: [
            {"title": header[0]},
            {"title": header[1]},
            {"title": header[2]},
            {"title": header[3]},
            {"title": header[4]}
        ],
        order: [
            [0, "desc"]
        ],
        lengthMenu: [10],
        language: plugin
    });
    location.href = "#openModalEx";
}


function show_measurement_table(tblData, header, plugin) {
    console.log(header[0]);
    $("#health-data-container").html("<table id=\"health-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>");
    $("#health-data").dataTable({
        data: tblData,
        columns: [
            {"title": header[0]},
            {"title": header[1]},
            {"title": header[2]}
        ],
        order: [
            [0, "desc"]
        ],
        lengthMenu: [10],
        language: plugin
    });
    location.href = "#openModal";
}

function show_diet_table(tblData, header, plugin) {
    $("#diet-data-container").html("<table id=\"diet-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>");
    $("#diet-data").dataTable({
        data: tblData,
        columns: [
            {"title": header[0]},
            {"title": header[1]},
            {"title": header[2]},
            {"title": header[3]},
            {"title": header[4]}
        ],
        order: [
            [0, "desc"]
        ],
        lengthMenu: [10],
        language: plugin
    });
    location.href = "#openModalDiet";
}

function show_medication_table(tblData, header, plugin) {
    $("#medication-data-container").html("<table id=\"medication-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>");
    $("#medication-data").dataTable({
        data: tblData,
        columns: [
            {"title": header[0]},
            {"title": header[1]},
            {"title": header[2]},
            {"title": header[3]}
        ],
        order: [
            [0, "desc"]
        ],
        lengthMenu: [10],
        language: plugin
    });
    location.href = "#openModalMedication";
}

function show_lifestyle_table(tblData, header, plugin) {
    $("#lifestyle-data-container").html("<table id=\"lifestyle-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>");
    $("#lifestyle-data").dataTable({
        data: tblData,
        columns: [
            {"title": header[0]},
            {"title": header[1]},
            {"title": header[2]},
            {"title": header[3]},
            {"title": header[4]}
        ],
        order: [
            [0, "desc"]
        ],
        lengthMenu: [10],
        language: plugin
    });
    location.href = "#openModalLifestyle";
}

function show_genetics_table(tblData, header, plugin) {
    $("#genetics-data-container").html("<table id=\"genetics-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>");
    $("#genetics-data").dataTable({
        data: tblData,
        columns: [
            {"title": header[0]},
            {"title": header[1]},
            {"title": header[2]},
            {"title": header[3]},
            {"title": header[4]},
            {"title": header[5]}
        ],
        order: [
            [0, "desc"]
        ],
        lengthMenu: [10],
        language: plugin
    });
    location.href = "#openModalGenetics";
}

function show_labresult_table(tblData, header, plugin) {
    $("#labresult-data-container").html("<table id=\"labresult-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>");
    $("#labresult-data").dataTable({
        data: tblData,
        columns: [
            {"title": header[0]},
            {"title": header[1]},
            {"title": header[2]}
        ],
        order: [
            [0, "desc"]
        ],
        lengthMenu: [10],
        language: plugin
    });
    location.href = "#openModalLabresult";
}

