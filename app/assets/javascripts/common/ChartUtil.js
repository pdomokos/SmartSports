function calcMean(data) {
    ret = data.reduce(function (prev, curr) {
        return prev + curr.value / data.length
    }, 0.0);
    return ret
}
function getColorMap(data) {
    var labels = Array.from(new Set(data.map( function(d) {return (d.group)}))).sort();
    var colors = ['bg1Point','bg2Point','bg3Point','bg4Point'];
    var self = this;
    var i = 0;
    var colorMap = {};
    labels.forEach(function(elem) {
        if(i>colors.length-1)
            colorMap[elem] = colors[colors.length-1];
        else
            colorMap[elem] = colors[i++];
    });
    return colorMap;
}