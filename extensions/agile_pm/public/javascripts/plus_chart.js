PlusChart = {};

PlusChart.Base = Class.create({
  
});

PlusChart.Stack = Class.create(PlusChart.Base, {
  
  initialize: function(element, total, items) {
    this.element = $(element);
    this.total = total;    
    this.element.
      addClassName('plus-chart').    
      addClassName('plus-chart-stack');
    
    this.dimensions = this.element. 
      update(new Element('div').update('&nbsp;')).
      down('div').getDimensions();
    this.remaining = this.dimensions.width;
    
    this.element.update('');    
    if (items) items.each(function(item) { this.insertItem(item) }.bind(this)); 
  },
  
  insertItem: function(item) {
    if (this.total == 0) return;

    var width = Math.round(this.dimensions.width * item.value / this.total);
    if (width > this.remaining) width = this.remaining;
    if (width < 1) return;
    
    var label = item.label || item.value;        
    var slice = new Element('div', {
      className: 'plus-chart-stack-item' 
    }).setStyle({ 'float': 'left'}).update(label); 
    this.element.insert(slice);
    
    if (item.className) slice.addClassName(item.className);
    if (item.title) slice.title = item.title;    
    if (slice.getWidth() > width) {
      slice.update('&nbsp;');
      slice.title = slice.title ? slice.title + ' - ' + label : label;   
    }
    slice.setStyle({ 'width': (width - 1) + 'px' });    
    this.remaining = this.remaining - width;
  }

});
