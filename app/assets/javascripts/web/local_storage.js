
function testDbVer(actualDbVersion, localItems) {
    console.log("testdbver");
    if(typeof(Storage) != "undefined") {
        try {
            var storedDbVersion = JSON.parse(localStorage.getItem("db_version"));
            if(!storedDbVersion || storedDbVersion != actualDbVersion) {
                for (localItem in localItems) {
                    localStorage.removeItem(localItem);
                }
                return true;
            }
        } catch (err) {
            return false;
        }
    }else {
        return false;
    }
}

function getStored(key){
    console.log("getst0red");
    if(typeof(Storage) != "undefined") {
        try {
            var store = JSON.parse(localStorage.getItem(key));
            if(store.length == 0) {
                return undefined;
            }
            return store;
        } catch (err) {
            return undefined;
        }
    }else {
        return window[key];
    }
}

function setStored(key, value){
    if(typeof(Storage) != "undefined") {
        localStorage.setItem(key, JSON.stringify(value));
    }else {
        window[key] = value;
    }
}
