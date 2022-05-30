/**
 * Format Datatable string to appear like cash
 * <p>
 * Long desc here
 * </p>
 * 
 * @param {*} data 
 * @param {*} type 
 * @param {*} row 
 * @param {*} meta
 * 
 * @Date: 2020-03-16 16:51:30 
 * @returns string   
 */
function cashFormat(data, type, row, meta) {
    if (type === 'display') {
        data = '<span class="fixExo">$</span>' + data;
    }

    return data;
}

/**
 * Format Datatable string to appear like telephone hyperlink
 * <p>
 * Long desc here
 * </p>
 * 
 * @param {*} data 
 * @param {*} type 
 * @param {*} row 
 * @param {*} meta
 * 
 * @Date: 2020-03-16 16:51:30 
 * @returns string   
 */
function phoneFormat(data, type, row, meta) {
    if (type === 'display') {
        if (data === "") {
            data = "<span class='bold'>NONE</span>"
        }
        else {
            data = "<a href='tel:" + data + "'>" + data + "</a>";
        }
    }

    return data;
}

/**
 * Format Datatable string to appear like new tab hyperlink
 * <p>
 * Long desc here
 * </p>
 * 
 * @param {*} data 
 * @param {*} type 
 * @param {*} row 
 * @param {*} meta
 * 
 * @Date: 2020-03-16 16:51:30 
 * @returns string   
 */
function linkFormat(data, type, row, meta) {
    if (type === 'display') {
        var str = "";
        str = data;
        data = "<button class='Exo ExoSize paginate_button current' onClick='window.open(\"" + str + "\", \"_blank\");'>HERE</button>"
    }

    return data;
}

/**
 * Format Datatable string so (.+) - (.+) appears as (.+)<br>(.+)
 * <p>
 * Long desc here
 * </p>
 * 
 * @param {*} data 
 * @param {*} type 
 * @param {*} row 
 * @param {*} meta
 * 
 * @Date: 2020-03-16 16:51:30 
 * @returns string   
 */
function positionFormat(data, type, row, meta) {
    if (type === 'display') {
        var regex = /(.+) - (.+)/g;
        if (regex.test(data)) {
            //data = data.replace(regex, "$1<ul><li>$2</li></ul>");
            data = data.replace(regex, "$1<br>$2");
        }
    }

    return data;
}

/**
 * Generate a random integer between min and max.
 * <p>
 * Generate a random integer between min and max.
 * </p>
 * 
 * @Date: 2019-07-02 13:54:00
 * @param {number} min 
 * @param {number} max 
 * @returns Integer
 */
function getRandomInt(min, max) {
    fmin = Math.ceil(min);
    fmax = Math.floor(max);
    return Math.floor(Math.random() * (fmax - fmin + 1)) + fmin;
}
