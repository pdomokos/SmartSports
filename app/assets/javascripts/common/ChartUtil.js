function calcMean(data) {
    ret = data.reduce(function (prev, curr) {
        return prev + curr.value / data.length
    }, 0.0);
    return ret
}
function getColorMap(data, elementName, colors) {
    var labelSet = new Set();
    var groups = Object.keys(data);
    groups.forEach(function(g) {
       data[g].forEach(function(item) {
           labelSet.add(item.group);
       })
    });
    var labels = Array.from(labelSet).sort();
    if(elementName===undefined) {
        elementName = "Point"
    }
    if(colors===undefined) {
        colors = ['col1', 'col2', 'col3', 'col4'];
    }
    var colorClasses = $.map(colors,function(d) {return d+elementName});
    var i = 0;
    var colorMap = {};
    labels.forEach(function(elem) {
        if(i>colors.length-1)
            colorMap[elem] = colorClasses[colorClasses.length-1];
        else
            colorMap[elem] = colorClasses[i++];
    });
    return colorMap;
}