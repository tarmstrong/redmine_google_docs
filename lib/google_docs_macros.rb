require 'redmine'
require 'digest/md5'
require 'yaml'
include ActionView::Helpers::JavaScriptHelper

class GoogleSpreadsheetMacros
  def self.googless_macro(googless_wiki_content, args, nohead=false)
    key = ""
    query = ""

    if nohead != "true"
      nohead = "false";
    end

    # get a random string to add to the element IDs so multiple spreadsheets don't conflict.
    dom_id = Digest::MD5.hexdigest(rand().to_s)

    raise  "The correct usage is {{ googless(key,query) }}" unless args.length >= 1
    
    # redmine seemingly html-escapes all the wiki arguments, so we un-escape them
    key = escape_javascript(CGI.unescape(args[0]))

    if args.length >= 1
      # Queries can have commas in them, which the macro thinks are extra macro arguments.
      # We know they're just commas in the query, so join them.
      unescaped_query = args[1..-1].join(",").to_s.sub('"', '\"')
      query = escape_javascript(CGI.unescape(unescaped_query))
    end
    out = <<"EOF"
<div>
  <style type="text/css">
  /* this is used to override the th and td className */
  /* see cssClassNames property in the invokation of table.draw() */
    .small-font {
      font-size:80%;
    }
    .googlespreadsheet {
      margin-right: 50px;
    }
  </style>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script> 
  <script type="text/javascript"> 
  (function () {
    var prot, options, tableId, fakeSql, key;

    prot = (("https:" == document.location.protocol) ? "https://" : "http://");
    // Formatting options
    options = {
      showRowNumber: true,
      cssClassNames: {
        tableCell: 'small-font',
        headerCell: 'small-font'
      }
    };
  	// We want this to be unique for each embedded sheet. Otherwise only one sheet can display per page.
    tableId = 'table-' + "#{dom_id}";
    fakeSql = '#{query}';
    key = '#{key}';


    google.load('visualization', '1.s');
    
    function drawVisualization() {
      google.visualization.drawChart({
        "containerId": tableId,
        "dataSourceUrl": prot + 'spreadsheets.google.com/tq?key=' + key,
        "query": fakeSql,
        "refreshInterval": 5,
        "chartType": "Table",
        "options": options
      });
    }

    google.setOnLoadCallback(drawVisualization);
	        
  }());
  </script>
</div>
<div class='googlespreadsheet' id='table-#{dom_id}'>
Loading Google Spreadsheet...
</div>
EOF
  end
  
  # a function for {{googleissue()}}
  def self.get_issue(obj, args)
    # usage: {{googleissue(adfSDFiuhDSF98SDFhiushdafbhIDFXF0dsf)}}
    # gives the row of the google spreadsheet containing the issue number in the second column
    goodargs = []
    goodargs << args[0]
    if not obj.respond_to? :journalized_id or not obj.respond_to? :journalized_type
      if obj.is_a? Issue
        # we're in the "Description" part of the Issue page
        id = obj.id
      end
    else
      # we're in the comment thread of an Issue page
      id = obj.journalized_id
    end
    if id
      col = "B" #assuming second column
      issue_id = id
      issue_id_with_hash = "##{issue_id}"
      goodargs << "SELECT * WHERE #{col}='#{issue_id}' OR #{col}=#{issue_id} OR #{col}='#{issue_id_with_hash}'"
      out = googless_macro(obj, goodargs, "true")
    else
      raise "You need to be on an issue page to use the <strong>googleissue</strong> macro."
    end
  end
end

class GoogleDocumentMacros
  def self.get_doc(obj, args)
    doc_key = args[0]
    if args.length == 2
      edit = (args[1].strip == "edit")
    else
      edit = false
    end
    if /^[\w-]+$/.match(doc_key)
      if edit
        url = "https://docs.google.com/document/d/#{doc_key}/edit"
      else
        url = "https://docs.google.com/document/d/#{doc_key}"
      end
      out = "<iframe src='#{url}' width='800' height='400'></iframe>"
    else
      raise "The Google document key must be alphanumeric."
    end
  end
end
