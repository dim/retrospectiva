* Copyright (C) 2007 Dimitrij Denissenko
* http://www.dvisionfactory.com
* http://retro.dvisionfactory.com/related-select-forms
* svn://dvisionfactory.com/rails/plugins/related_select_forms
* Please read LICENSE document for more information.

This plugin adds a new helper to the great RubyOnRails framework that allows to
generate multiple, dependent HTML select tags. It handles the relations with 
simple JavaScript (requires prototype.js library), so you do not need to code
any AJAX callbacks (can be handy when you only deal with a small amount of 
data). This plugin works also well with RJS templates and supports recursive
pre-selection of the related select tags (look on the examples).

The usage is trivial. First create a usual select (or collection_select) which
will act as "parent". Afterwards you can create one or many dependent 
child(ren) select(s) by calling:

    related_collection_select(
        object, method, parent_select_tag, collection, 
        value_method, text_method, reference_method, 
        options = {}, html_options = {})

=== Arguments:

* 'object', 'method', 'collection', 'value_method', 'text_method', 
  'options' & 'html_options' are used exactly the same way as in
  the standard collection_select helper method. 
* 'parent_select_tag' specifies, as the name says, the parent 
  select tag; argument can be passed as an array 
  [:parent_object, :method] or directly as string referencing the 
  tag id (e.g. "parent_object_method")
* Parameter 'reference_method' specifies the method that is used to get
  a reference to parent selection.
  
Additionally the 'options' argument can include a ':selected' attribute,
that will override the default pre-selection behaviour (which uses to call 
'@object.method' to determine the to be selected option).


=== Example: Two related select forms 

<b>tables</b>

    car_companies: id, name
    car_models:    id, name, car_company_id
  
<b>view</b>

    <%= collection_select(
          :car_company, :id, CarCompany.find(:all), :id, :name) %>
    <%= related_collection_select(
          :car_model, :id, [:car_company, :id], 
            CarModel.find(:all), :id, :name, :car_company_id) %>

The code above will create two drop-down select tags. The 1st allows the
selection of a car company. Based on this decision the 2nd select tag shows
company specific car models.


=== Example: Three related select forms

The script allows to generate an almost unlimited number of related selects:

<b>tables</b>

    categories: id, title, parent_id
    some_objects: id, name, category_id

<b>controller</b>

    @first_col = Category.find(:all, :conditions => 'parent_id IS NULL')
    @second_col = Category.find(:all, :conditions => 'parent_id > 0')
    @third_col = SomeObject.find(:all)
    @some_object = SomeObject.find(123)

<b>view</b>

    <%= collection_select(:category, :id, @first_col, :id, :title) %>
    <%= related_collection_select(:sub_category, :id, [:category, :id], 
          @second_col, :id, :title, :parent_id) %>
    <%= related_collection_select(:some_object, :id, [:sub_category, :id], 
          @third_col, :id, :name, :category_id, {}, {:size => 6}) %>

This example creates three related select tags. The 1st shows 'categories', 
the 2nd 'sub-categories' and the 3rd 'some_objects'. Because an '@some_object'
instence variable is defined, item with id='123' will be pre-selected 
automatically in the 3rd select tag. The 1st & 2nd select forms will also be
recursively adapted automatically.
