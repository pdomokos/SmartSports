function connections_loaded () {
    console.log("connections_loaded called");
    popup_messages = JSON.parse($("#popup-messages").val());
    $("#connections-link").addClass("menulink-selected");

    loadConnections();

    $("#connectionIcons").on("click", "li", function(evt){
        var conn = $(this)[0];
        showConnectionModal(conn.dataset.connectionid, conn.dataset.connectionname, conn.dataset.connectionsync);
    });

    $("#statConnectionModal").on("click", "i", function(evt) {
        var connId = $(this)[0].dataset.connectionid;
        var connName = $(this)[0].dataset.connectionname;
        var userId = $("#current-user-id")[0].value;
        var url = "/users/"+userId+"/connections/"+connId;
        $.ajax({
            url: url,
            type: 'PUT',
            data: {sync: true},
            success: function(data, textStatus, jqXHR) {
                console.log("sync conn "+connName+" started");
                $("#statConnectionModal i").addClass('fa-spin');

                setupPoll(url);
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.log("sync conn AJAX Error: "+textStatus);
                $("#statConnectionModal i").attr('class', 'fa fa-exclamation-triangle red');
            }
        });
    });

    $("#statConnectionModal").on('click', '.deleteConnectionButton', function(evt){

        var uid = $(this)[0].dataset.userid;
        var connid = $(this)[0].dataset.connectionid;
        console.log("del clicked, uid="+uid+" connid="+connid);

        var url = "/users/"+uid+"/connections/"+connid;
        $.ajax({
            url: url,
            type: 'DELETE',
            success: function(data, textStatus, jqXHR) {

                loadConnections();
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.log("delete conn AJAX Error: "+textStatus);

                popup_error("Failed to delete");
            }
        });
    });
}

function clearPollTimers() {
    if (typeof window.syncTimeout1 == "number") {
        window.clearTimeout(window.syncTimeout1);
    }
    window.syncTimeout1 = null;
    if (typeof window.syncTimeout2 == "number") {
        window.clearTimeout(window.syncTimeout2);
    }
    window.syncTimeout2 = null;
}

function setupPoll(url) {
    clearPollTimers();
    window.syncTimeout1 = setInterval(function () {
        console.log("connection timer fired");
        pollSync(url, 'poll');
    }, 10000);

    window.syncTimeout2 = setTimeout(function () {
        console.log("connection timer 2 fired");
        pollSync(url, 'stop');
    }, 50000);
}

function pollSync(url, cmd) {
    if(cmd==='poll') {
        $.ajax({
            url: url,
            type: 'GET',
            success: function (data, textStatus, jqXHR) {
                if(data.sync_status==='success') {
                    clearPollTimers();
                    $("#statConnectionModal i").attr('class', 'fa fa-check green');
                    $("#statConnectionModal .syncDate").html(getDateString(data.synced_at));
                    loadConnections();
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.log("poll error");
            }
        });
    } else if(cmd==='stop') {
        console.log("poll timeout");
        $("#statConnectionModal i").attr('class', 'fa fa-exclamation-triangle red');
        clearPollTimers();
    } else {
        console.log("pollSync: invalid cmd");
    }
}
function getDateString(d) {
    var lang = $("#user-lang")[0].value;
    if(d==null || d==='' || d==='missing_date') {
        if(lang=='hu') {
            return "Nincs Adat";
        } else {
            return "Missing Date";
        }
    }
    return moment(d).format(moment_fmt);
}

function showConnectionModal(connId, connName, connectionSync) {
    $("#statConnectionModal .modal-title").html(connName);
    $("#statConnectionModal .modal-header>span").addClass('iconselect_' + connName.toLowerCase());
    $("#statConnectionModal .syncDate").html(getDateString(connectionSync));
    $("#statConnectionModal i").removeClass('fa-spin');
    $("#statConnectionModal i").attr('class', 'fa fa-refresh');
    $("#statConnectionModal i").attr('data-connectionid', connId);
    $("#statConnectionModal i").attr('data-connectionname', connName.toLowerCase());
    $("#statConnectionModal .deleteConnectionButton").attr('data-connectionid', connId);
    var userid =  $("#current-user-id")[0].value;
    $("#statConnectionModal .deleteConnectionButton").attr('data-userid', userid);
    $("#statConnectionModal").modal('toggle');
    clearPollTimers();
}

function loadConnections() {
    var current_user = $("#current-user-id")[0].value;
    var lang = $("#user-lang")[0].value;
    var url = 'users/' + current_user + '/connections.js&lang='+lang;
    $.ajax({
        url: urlPrefix() + url,
        type: 'GET',
        error: function (jqXHR, textStatus, errorThrown) {
            console.log("load connections AJAX Error: " + textStatus);
        },
        success: function (data, textStatus, jqXHR) {
            var connected = [];
            $("#connectionIcons li").each(function(idx){
                    connected.push($(this)[0].dataset.connectionname.toLowerCase());
                }
            );
            bindConnectButton(connected);
            $("#connectionIcons li").tooltip({
                    placement: "bottom",
                    show: {
                        delay: 500
                    }
                }
            )
        }
    });
}

function bindConnectButton (connected) {
    var remaining = new Set(['withings', 'moves', 'fitbit', 'google', 'misfit']);
    connected.forEach(function (c) {
        remaining.delete(c)
    });
    remaining.forEach(function (cname) {
        $(".connectionsSelect").append("<option>" + cname + "</option>")
    });

    links = {
        moves: "/auth/moves",
        withings: "/auth/withings",
        fitbit: "/auth/fitbit",
        google: "/auth/google_oauth2",
        misfit: "/auth/shine"
    };

    $("#addConnectionModal").on("click", "button.addConnButton", function (evt) {
        evt.preventDefault();
        var connectionName = $("#addConnectionModal .connectionsSelect").val();
        window.location = links[connectionName];
    });
}
