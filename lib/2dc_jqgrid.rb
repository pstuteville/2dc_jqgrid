module ActionView

  module Helpers
    
    def jqgrid_stylesheets
      # css = capture { stylesheet_link_tag 'jqgrid/ui.all' }
      # css << capture { stylesheet_link_tag 'jqgrid/ui.jqgrid' }    
      css = capture { stylesheet_link_tag 'jqgrid/ui.jqgrid' }    
      # css << capture { stylesheet_link_tag 'jqgrid/jquery-ui-1.7.1.custom' }    
    end

    def jqgrid_javascripts
      # javascript 'jquery-1.3.2.min', 'jquery-ui-1.7.2.custom.min', 'jqModal'
      # js = capture { javascript_include_tag 'jqgrid/jquery' }
      # js << capture { javascript_include_tag 'jqgrid/jquery.ui.all' }
      # js << capture { javascript_include_tag 'jqgrid/jquery.layout' }
      # js << capture { javascript_include_tag 'jqgrid/jqModal' }
      # js << capture { javascript_include_tag 'jqgrid/jquery.jqGrid' }
      # js = capture { javascript_include_tag 'jquery-1.3.2.min' }
      # js << capture { javascript_include_tag 'jquery-ui-1.7.2.custom.min' }
      # js = capture { javascript_include_tag 'jquery.layout.min' }
      # js << capture { javascript_include_tag 'jqModal' }
      js = capture { javascript_include_tag 'jqgrid/i18n/grid.locale-en' }
      js << capture { javascript_include_tag 'jqgrid/jquery.jqGrid.min' }
      
      # js << capture { javascript_include_tag 'jqgrid/JsonXml.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.base.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.celledit.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.common.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.custom.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.formedit.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.import.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.inlinedit.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.loader.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.postext.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.setcolumns.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.subgrid.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.tbltogrid.js' }
      # js << capture { javascript_include_tag 'jqgrid/grid.treegrid.js' }
      # js << capture { javascript_include_tag 'jqgrid/jqDnR.js' }
      # js << capture { javascript_include_tag 'jqgrid/jqModal.js' }
      # js << capture { javascript_include_tag 'jqgrid/jquery.fmatter.js' }
      # js << capture { javascript_include_tag 'jqgrid/jquery.searchFilter.js' }
      
    end

    def jqgrid(title, id, action, columns = {}, options = {})

      # Default options
      options[:rows_per_page] = "10" if options[:rows_per_page].blank?
      options[:sort_column] = "id" if options[:sort_column].blank?
      options[:sort_order] = "asc" if options[:sort_order].blank?
      options[:height] = "150" if options[:height].blank?
      options[:error_handler] = 'null' if options[:error_handler].blank?      
      options[:error_handler_return_value] = options[:error_handler]
      options[:error_handler_return_value] = "true;" if options[:error_handler_return_value] == 'null'
      options[:inline_edit_handler] = 'null' if options[:inline_edit_handler].blank?      

      options[:add] = (options[:add].blank?) ? "false" : options[:add].to_s    
      options[:delete] = (options[:delete].blank?) ? "false" : options[:delete].to_s
      options[:inline_edit] = (options[:inline_edit].blank?) ? "false" : options[:inline_edit].to_s
      edit_button = (options[:edit] == true && options[:inline_edit] == "false") ? "true" : "false"

      # Generate columns data
      col_names, col_model = gen_columns(columns)

      # Disablable search
      search_button = ""
      unless options[:search].kind_of?(FalseClass)
        search_button = %Q(
      .navButtonAdd("##{id}_pager",{caption:"#{options[:search_caption] || "Search"}",title:"#{options[:search_title] || "Toggle Search"}",buttonicon:'#{options[:search_icon] || 'ui-icon-search'}',
      	onClickButton:function(){ 
      		if(jQuery("#t_#{id}").css("display")=="none") {
      			jQuery("#t_#{id}").css("display","");
      		} else {
      			jQuery("#t_#{id}").css("display","none");
      		}
      	} 
      })
      )
      end
 
      # Enable post_data array for appending to each request
      # :post_data => {'_search' => 1, : :myfield => 2}
      post_data = ""
      if options[:post_data]
        post_data = %Q/postData: #{get_edit_options(options[:post_data])},/
      end
      
      
      # Enable multi-selection (checkboxes)
      multiselect = ""
      if options[:multi_selection]
        multiselect = %Q/multiselect: true,/
        multihandler = %Q/
          jQuery("##{id}_select_button").click( function() { 
            var s; s = jQuery("##{id}").getGridParam('selarrrow'); 
            #{options[:selection_handler]}(s); 
            return false;
          });/
      end

      # Enable master-details
      masterdetails = ""
      if options[:master_details]
        masterdetails = %Q/
          onSelectRow: function(ids) { 
            if(ids == null) { 
              ids=0; 
              if(jQuery("##{id}_details").getGridParam('records') >0 ) 
              { 
                jQuery("##{id}_details").setGridParam({url:"#{options[:details_url]}?q=1&id="+ids,page:1})
                .setCaption("#{options[:details_caption]}: "+ids)
                .trigger('reloadGrid'); 
              } 
            } 
            else 
            { 
              jQuery("##{id}_details").setGridParam({url:"#{options[:details_url]}?q=1&id="+ids,page:1})
              .setCaption("#{options[:details_caption]} : "+ids)
              .trigger('reloadGrid'); 
            } 
          },/
      end

      # Enable selection link, button
      # The javascript function created by the user (options[:selection_handler]) will be called with the selected row id as a parameter
      selection_link = ""
      if (options[:direct_selection].blank? || options[:direct_selection] == false) && options[:selection_handler].present? && (options[:multi_selection].blank? || options[:multi_selection] == false)
        selection_link = %Q/
        jQuery("##{id}_select_button").click( function(){ 
          var id = jQuery("##{id}").getGridParam('selrow'); 
          if (id) { 
            #{options[:selection_handler]}(id); 
          } else { 
            alert("Please select a row");
          }
          return false; 
        });/
      end

      # Enable direct selection (when a row in the table is clicked)
      # The javascript function created by the user (options[:selection_handler]) will be called with the selected row id as a parameter
      direct_link = ""
      if options[:direct_selection] && options[:selection_handler].present? && options[:multi_selection].blank?
        direct_link = %Q/
        onSelectRow: function(id){ 
          if(id){ 
            #{options[:selection_handler]}(id); 
          } 
        },/
      end

      # Enable grid_loaded callback
      # When data are loaded into the grid, call the Javascript function options[:grid_loaded] (defined by the user)
      grid_loaded = ""
      if options[:grid_loaded].present?
        grid_loaded = %Q/
        loadComplete: function(){ 
          #{options[:grid_loaded]}();
        },
        /
      end

      # Enable inline editing
      # When a row is selected, all fields are transformed to input types
      editable = ""
      if options[:edit] && options[:inline_edit] == "true"
        editable = %Q/
        onSelectRow: function(id){ 
          if(id && id!==lastsel){ 
            jQuery('##{id}').restoreRow(lastsel);
            jQuery('##{id}').editRow(id, true, #{options[:inline_edit_handler]}, #{options[:error_handler]});
            lastsel=id; 
          } 
        },/
      end
      
      # Enable subgrids
      subgrid = ""
      subgrid_enabled = "subGrid:false,"
      if options[:subgrid]
        subgrid_enabled = "subGrid:true,"
        options[:subgrid][:rows_per_page] = "10" if options[:subgrid][:rows_per_page].blank?
        options[:subgrid][:sort_column] = "id" if options[:subgrid][:sort_column].blank?
        options[:subgrid][:sort_order] = "asc" if options[:subgrid][:sort_order].blank?
        subgrid_search = (options[:subgrid][:search].blank?) ? "false" : options[:subgrid][:search]
        options[:subgrid][:add] = (options[:subgrid][:add].blank?) ? "false" : options[:subgrid][:add].to_s    
        options[:subgrid][:delete] = (options[:subgrid][:delete].blank?) ? "false" : options[:subgrid][:delete].to_s
        options[:subgrid][:edit] = (options[:subgrid][:edit].blank?) ? "false" : options[:subgrid][:edit].to_s   
        
        cut
        
        subgrid_inline_edit = ""
        if options[:subgrid][:inline_edit] == true
          options[:subgrid][:edit] = "false"
          subgrid_inline_edit = %Q/
          onSelectRow: function(id){ 
            if(id && id!==lastsel){ 
              jQuery('#'+subgrid_table_id).restoreRow(lastsel);
              jQuery('#'+subgrid_table_id).editRow(id,true); 
              lastsel=id; 
            } 
          },
          /
        end
          
        if options[:subgrid][:direct_selection] && options[:subgrid][:selection_handler].present?
          subgrid_direct_link = %Q/
          onSelectRow: function(id){ 
            if(id){ 
              #{options[:subgrid][:selection_handler]}(id); 
            } 
          },
          /
        end     
        
        sub_col_names, sub_col_model = gen_columns(options[:subgrid][:columns])
        
        subgrid = %Q(
        subGridRowExpanded: function(subgrid_id, row_id) {
        		var subgrid_table_id, pager_id;
        		subgrid_table_id = subgrid_id+"_t";
        		pager_id = "p_"+subgrid_table_id;
        		$("#"+subgrid_id).html("<table id='"+subgrid_table_id+"' class='scroll'></table><div id='"+pager_id+"' class='scroll'></div>");
        		jQuery("#"+subgrid_table_id).jqGrid({
        			url:"#{options[:subgrid][:url]}?q=2&id="+row_id,
              editurl:'#{options[:subgrid][:edit_url]}?parent_id='+row_id,                            
        			datatype: "json",
        			colNames: #{sub_col_names},
        			colModel: #{sub_col_model},
        		   	rowNum:#{options[:subgrid][:rows_per_page]},
        		   	pager: pager_id,
        		   	imgpath: '/images/jqgrid',
        		   	sortname: '#{options[:subgrid][:sort_column]}',
        		    sortorder: '#{options[:subgrid][:sort_order]}',
                viewrecords: true,
                toolbar : [true,"top"], 
        		    #{subgrid_inline_edit}
        		    #{subgrid_direct_link}
        		    height: '100%'
        		})
        		.navGrid("#"+pager_id,{edit:#{options[:subgrid][:edit]},add:#{options[:subgrid][:add]},del:#{options[:subgrid][:delete]},search:false})
        		.navButtonAdd("#"+pager_id,{caption:"Search",title:"Toggle Search",buttonimg:'/images/jqgrid/search.png',
            	onClickButton:function(){ 
            		if(jQuery("#t_"+subgrid_table_id).css("display")=="none") {
            			jQuery("#t_"+subgrid_table_id).css("display","");
            		} else {
            			jQuery("#t_"+subgrid_table_id).css("display","none");
            		}
            	} 
            });
            jQuery("#t_"+subgrid_table_id).height(25).hide().filterGrid(""+subgrid_table_id,{gridModel:true,gridToolbar:true});
        	},
        	subGridRowColapsed: function(subgrid_id, row_id) {
        	},
        )
      end


      
      # Add options[:custom_buttons] to add custom buttons to nav bar.  Very useful for restful urls among other things.
      # It takes the following hash of arguments (or an array of hashes for many buttons):
      # :function_name => jsFunctionToCallWithSelectedIds, :caption => "Button", :title => "Press Me", :icon => "ui-icon-alert"
      if options[:custom_buttons]
        options[:custom_buttons] = [options[:custom_buttons]] unless options[:custom_buttons].kind_of?(Array)
        get_ids_call = options[:multi_selection] ?  'selarrrow' : 'selrow'
        custom_buttons = ""
        options[:custom_buttons].find_all{|custom_button_details|  custom_button_details.kind_of?(Hash) }.each do |button_properties_hash|
          next if button_properties_hash[:function_name].blank?
          custom_buttons += %Q(.navButtonAdd(
            '##{id}_pager',
            {
              caption:"#{escape_javascript(button_properties_hash[:caption]) || ''}",
              title:"#{escape_javascript(button_properties_hash[:title]) || 'Custom Button'}", 
              buttonicon:"#{button_properties_hash[:icon] || "ui-icon-alert"}", 
              onClickButton: function(){ 
                              var selected_ids = jQuery("##{id}").getGridParam("#{get_ids_call}")
                              // no check for null selected_ids as someone may want an Add button or something similar
                              #{button_properties_hash[:function_name]}(selected_ids);
                            }
            })
          )
        end
      end
      
      # Generate required Javascript & html to create the jqgrid
      %Q(
      <link rel="stylesheet" type="text/css" media="screen" href="/stylesheets/jqgrid/ui.jqgrid.css" />
        <script type="text/javascript">
        var lastsel;
        var gridimgpath = '/images/jqgrid'; 
        jQuery(document).ready(function(){
        jQuery("##{id}").jqGrid({
            // adding ?nd='+new Date().getTime() prevent IE caching
            url:'#{action}?nd='+new Date().getTime(),
            editurl:'#{options.delete(:edit_url)}',
            datatype: "json",
            colNames:#{col_names},
            colModel:#{col_model},
            pager: jQuery('##{id}_pager'),
            rowNum:#{options.delete(:rows_per_page)},
            rowList:[10,25,50,100],
            imgpath: '/images/jqgrid',
            sortname: '#{options.delete(:sort_column)}',
            viewrecords: true,
            height: '#{options.delete(:height)}',            
            toolbar : [true,"top"],
            #{options[:width].blank? ? '' : "width:" + "'" + options.delete(:width).to_s + "'" + ',' } 
            sortorder: '#{options.delete(:sort_order)}',
            #{post_data}
            #{multiselect}
            #{masterdetails}
            #{grid_loaded}
            #{direct_link}
            #{editable}
            #{subgrid_enabled}
            #{subgrid}
            caption: "#{title}"
        });
        jQuery("#t_#{id}").height(25).hide().filterGrid("#{id}",{gridModel:true,gridToolbar:true});
        #{multihandler}
        #{selection_link}
        jQuery("##{id}").navGrid('##{id}_pager',{edit:#{edit_button},add:#{options[:add]},del:#{options[:delete]},search:false,refresh:true},
        {height:290,reloadAfterSubmit:false, jqModal:false, closeOnEscape:true, bottominfo:"Fields marked with (*) are required",afterSubmit:function(r,data){return #{options[:error_handler_return_value]}(r,data,'edit');}},
        {afterSubmit:function(r,data){return #{options[:error_handler_return_value]}(r,data,'add');}},
        {afterSubmit:function(r,data){return #{options[:error_handler_return_value]}(r,data,'delete');}
        })
        #{search_button}#{custom_buttons};
        });
        </script>
        <table id="#{id}" class="scroll" cellpadding="0" cellspacing="0"></table>
        <div id="#{id}_pager" class="scroll" style="text-align:center;"></div>
      )
    end
    # .navButtonAdd('##{id}_pager',{caption:”Create PDF”, buttonimg:”../images/pdf.gif”, 
    #   onClickButton: function() {
    #    document.location.href='ExportToPDF.cfm';
    #   }, position:”last”, title: 'Export to PDF' });
    
    # .navButtonAdd("##{id}_pager",{caption:"Edit",title:"Toggle Search",buttonimg:'/images/jqgrid/search.png',
    #   onClickButton:function(rowid){ 
    #     var gr = jQuery("#grid_id").getGridParam("selrow"); 
    #     if( gr != null ){
    #       alert('');
    #      document.location.href='ExportToPDF.cfm';
    #       
    #     } else {
    #       alert('Please select a row to edit');              
    #     }
    #   } 
    # })

    private
    
    def gen_columns(columns)
      # Generate columns data
      col_names = "[" # Labels
      col_model = "[" # Options
      columns.each do |c|
        col_names << "'#{c[:label]}',"
        col_model << "{name:'#{c[:field]}', index:'#{c[:field]}'#{get_attributes(c)}, hidden:#{c[:hidden] || 'false'}, formoptions:#{c[:formoptions] ? c[:formoptions] : '{}' }},"
      end
      col_names.chop! << "]"
      col_model.chop! << "]"
      [col_names, col_model]
    end

    # Generate a list of attributes for related column (align:'right', sortable:true, resizable:false, ...)
    def get_attributes(column)
      options = ","
      column.except(:field, :label, :formoptions).each do |couple|
        if couple[0] == :editoptions
          options << "editoptions:#{get_edit_options(couple[1])},"
        elsif couple[0] == :custom_formatter
          options << "formatter:#{couple[1]},"
        elsif couple[0] == :custom_unformatter
          options << "unformat:#{couple[1]},"
        else
          case couple[1]
            when String
              options << "#{couple[0]}:'#{couple[1]}',"
            when Hash
              options << %Q/#{couple[0]}:/
              options << get_edit_options(couple[1])
              options << ","
            else
              options << "#{couple[0]}:#{couple[1]},"
          end
        end
      end
      options.chop!
    end

    # Generate options for editable fields (value, data, width, maxvalue, cols, rows, ...)
    def get_edit_options(editoptions)
      options = "{"
      editoptions.each do |couple|
        if couple[0] == :value # :value => [[1, "Rails"], [2, "Ruby"], [3, "jQuery"]]
          options << %Q/value:"/
          case couple[1][0]
            when Array
              couple[1].each do |v|
                options << "#{v[0]}:#{v[1]};"
              end
            else
              options << "#{couple[1][0]}:#{couple[1][1]};"
          end
          options.chop! << %Q/",/
        elsif couple[0] == :data # :data => [Category.all, :id, :title])
          options << %Q/value:"/
          couple[1].first.each do |v|
            options << "#{v[couple[1].second]}:#{v[couple[1].third]};"
          end
          options.chop! << %Q/",/
        else # :size => 30, :rows => 5, :maxlength => 20, ...
          options << %Q/#{couple[0]}:"#{couple[1]}",/
        end
      end
      options.chop! << "}"
    end 
  end
end


module JqgridJson
  def to_jqgrid_json(attributes, current_page, per_page, total)
    json = %Q({"page":"#{current_page}","total":#{total/per_page.to_i+1},"records":"#{total}","rows":[)
    each do |elem|
      json << %Q({"id":"#{elem.id}","cell":[)
      couples = elem.attributes.symbolize_keys
      attributes.each do |atr|
        case atr
          when String
            atr = atr.split('.').inject([]) {|array, element| array << element.to_sym}
          when Array
            atr = atr.inject([]) {|array, element| array << element.to_sym}
          when Symbol
            atr = [atr]
          else
            raise ArgumentError, "Must pass a string or array.  Received #{atr.inspect}"
        end
        value = couples[atr[0]]
        if elem.respond_to?(atr[0]) && value.blank?
          combined_send_call = atr.inject(nil) {|aggregated_send_object, recursive_send_method|
            if aggregated_send_object.blank? 
              aggregated_send_object = elem.send(recursive_send_method.to_sym)
            else
              aggregated_send_object = aggregated_send_object.send(recursive_send_method.to_sym)
            end
            aggregated_send_object
            }
          value = combined_send_call 
          value = (value ? "Yes" : "No") if value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
        end
        json << %Q("#{value}",)
      end
      json.chop! << "]},"
    end
    json.chop! unless json.last == "[" 
    json << "]}"
  end
end

class Array
  include JqgridJson
end